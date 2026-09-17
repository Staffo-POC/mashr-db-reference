#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const readline = require('readline');

const ROOT_DIR = path.resolve(__dirname, '..');
const SEED_DIR = path.join(ROOT_DIR, 'database/seed/20260914');
const SCHEMA_FILE = path.join(ROOT_DIR, 'database/schema/master/MAS_01_tables.sql');

function readUtf16File(filePath) {
  const buf = fs.readFileSync(filePath);
  return buf.toString('utf16le');
}

console.log('Loading schema definitions...');
const schemaText = readUtf16File(SCHEMA_FILE);

function getTableMetadata(tableName) {
  const regex = new RegExp(`CREATE TABLE \\[dbo\\]\\.\\[${tableName}\\]\\s*\\(([\\s\\S]*?)\\)\\s*ON`, 'i');
  const match = schemaText.match(regex);
  if (!match) throw new Error('Table not found: ' + tableName);
  const lines = match[1].split('\n');
  const cols = [];
  const meta = {};
  for (const line of lines) {
    const m = line.match(/^\s*\[([^\]]+)\]\s+\[([^\]]+)\](?:\(([^)]+)\))?\s*(NOT NULL|NULL)?/i);
    if (m) {
      const colName = m[1];
      const colType = m[2].toLowerCase();
      const isNullable = !line.toUpperCase().includes('NOT NULL');
      cols.push(colName);
      meta[colName] = { name: colName, type: colType, isNullable };
    }
  }
  return { cols, meta };
}

// RFC 4180 CSV line parser
function parseCsvLine(text) {
  const result = [];
  let cur = '';
  let inQuotes = false;
  for (let i = 0; i < text.length; i++) {
    const c = text[i];
    if (c === '"') {
      if (inQuotes && text[i + 1] === '"') {
        cur += '"';
        i++;
      } else {
        inQuotes = !inQuotes;
      }
    } else if (c === ',' && !inQuotes) {
      result.push(cur);
      cur = '';
    } else {
      cur += c;
    }
  }
  result.push(cur);
  return result;
}

function formatSqlValueWithMeta(val, colMeta) {
  const trimmed = (val !== undefined && val !== null) ? val.trim() : '';
  const isNullLiteral = trimmed === '' || trimmed.toUpperCase() === 'NULL';

  if (isNullLiteral) {
    if (colMeta && !colMeta.isNullable) {
      if (['varchar', 'nvarchar', 'char', 'nchar', 'text', 'ntext'].includes(colMeta.type)) {
        return "N''";
      }
      if (['int', 'smallint', 'tinyint', 'bigint', 'decimal', 'numeric', 'float', 'real', 'money', 'smallmoney'].includes(colMeta.type)) {
        return '0';
      }
      if (colMeta.type === 'uniqueidentifier') {
        return "'FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF'";
      }
    }
    return 'NULL';
  }

  // Handle boolean / bit
  if (colMeta && colMeta.type === 'bit') {
    return (trimmed === '1' || trimmed.toLowerCase() === 'true') ? '1' : '0';
  }

  // Numeric types: strip formatting if safe, or return as number
  if (colMeta && ['int', 'smallint', 'tinyint', 'bigint', 'decimal', 'numeric', 'float', 'real', 'money', 'smallmoney'].includes(colMeta.type)) {
    if (!isNaN(trimmed) && trimmed !== '') {
      return trimmed;
    }
  }

  // Escape single quotes
  const escaped = trimmed.replace(/'/g, "''");
  return `N'${escaped}'`;
}

async function convertFullTableCsv(csvFilename, tableName, outSqlFilename, batchSize = 500) {
  const csvPath = path.join(SEED_DIR, csvFilename);
  if (!fs.existsSync(csvPath)) {
    console.log(`Skipping ${csvFilename} (not found)`);
    return;
  }
  const outPath = path.join(SEED_DIR, outSqlFilename);
  const { cols, meta } = getTableMetadata(tableName);
  console.log(`Converting ${csvFilename} -> ${outSqlFilename} (dbo.${tableName}, ${cols.length} cols)...`);

  const colListSql = cols.map(c => `[${c}]`).join(', ');

  const outStream = fs.createWriteStream(outPath, { encoding: 'utf8' });
  outStream.write(`USE [MAS]\nGO\n\nPRINT 'Seeding dbo.${tableName}...';\n`);

  const rl = readline.createInterface({
    input: fs.createReadStream(csvPath, { encoding: 'utf8' }),
    crlfDelay: Infinity
  });

  let rowCount = 0;
  let currentBatch = [];

  for await (const line of rl) {
    const cleanLine = line.replace(/^\uFEFF/, '').trim();
    if (!cleanLine) continue;

    const values = parseCsvLine(cleanLine);
    // Skip header line if first column matches column name
    if (values[0] === cols[0]) {
      continue;
    }

    if (values.length < cols.length) {
      while (values.length < cols.length) {
        values.push('');
      }
    }

    const rowSql = `(${cols.map((colName, idx) => formatSqlValueWithMeta(values[idx], meta[colName])).join(', ')})`;
    currentBatch.push(rowSql);
    rowCount++;

    if (currentBatch.length >= batchSize) {
      outStream.write(`INSERT INTO [dbo].[${tableName}] (${colListSql})\nVALUES\n  ${currentBatch.join(',\n  ')};\nGO\n\n`);
      currentBatch = [];
    }
  }

  if (currentBatch.length > 0) {
    outStream.write(`INSERT INTO [dbo].[${tableName}] (${colListSql})\nVALUES\n  ${currentBatch.join(',\n  ')};\nGO\n\n`);
  }

  outStream.write(`PRINT 'Seeded dbo.${tableName}: ${rowCount} rows.';\nGO\n`);
  outStream.end();

  console.log(`Finished ${tableName}: ${rowCount} rows generated.`);
}

async function convertEmployeeMaster(csvFilename, outSqlFilename, batchSize = 500) {
  const csvPath = path.join(SEED_DIR, csvFilename);
  if (!fs.existsSync(csvPath)) {
    console.log(`Skipping ${csvFilename} (not found)`);
    return;
  }
  const outPath = path.join(SEED_DIR, outSqlFilename);
  const { meta } = getTableMetadata('tEmployee');
  console.log(`Converting ${csvFilename} -> ${outSqlFilename} (dbo.tEmployee)...`);

  const empCols = [
    'EmployeeCode', 'Prefix', 'FirstName', 'LastName', 'EnglishName',
    'PID', 'Sex', 'BirthDate', 'StartDate', 'ProbationInterval',
    'ProbationDuration', 'BatchProbation_ID', 'ResignDate', 'ResignDueDate',
    'WageRate', 'Accountno', 'BankName'
  ];

  const colListSql = empCols.map(c => `[${c}]`).join(', ');

  const outStream = fs.createWriteStream(outPath, { encoding: 'utf8' });
  outStream.write(`USE [MAS]\nGO\n\nPRINT 'Seeding dbo.tEmployee from Master Extract...';\n`);

  const rl = readline.createInterface({
    input: fs.createReadStream(csvPath, { encoding: 'utf8' }),
    crlfDelay: Infinity
  });

  let rowCount = 0;
  let currentBatch = [];

  for await (const line of rl) {
    const cleanLine = line.replace(/^\uFEFF/, '').trim();
    if (!cleanLine) continue;

    const v = parseCsvLine(cleanLine);
    if (v[9] === 'EmployeeCode' || v[0] === 'ProjectName') {
      continue;
    }

    const rowValues = [
      v[9],  // EmployeeCode
      v[10], // Prefix
      v[11], // FirstName
      v[12], // LastName
      v[13], // EnglishName
      v[14], // PID
      v[15], // Sex
      v[16], // BirthDate
      v[17], // StartDate
      v[18], // ProbationInterval
      v[19], // ProbationDuration
      v[20], // BatchProbation_ID
      v[21], // ResignDate
      v[22], // ResignDueDate
      v[23], // WageRate
      v[25], // Accountno
      v[26], // BankName
    ];

    const rowSql = `(${empCols.map((colName, idx) => formatSqlValueWithMeta(rowValues[idx], meta[colName])).join(', ')})`;
    currentBatch.push(rowSql);
    rowCount++;

    if (currentBatch.length >= batchSize) {
      outStream.write(`INSERT INTO [dbo].[tEmployee] (${colListSql})\nVALUES\n  ${currentBatch.join(',\n  ')};\nGO\n\n`);
      currentBatch = [];
    }
  }

  if (currentBatch.length > 0) {
    outStream.write(`INSERT INTO [dbo].[tEmployee] (${colListSql})\nVALUES\n  ${currentBatch.join(',\n  ')};\nGO\n\n`);
  }

  outStream.write(`PRINT 'Seeded dbo.tEmployee: ${rowCount} rows.';\nGO\n`);
  outStream.end();

  console.log(`Finished tEmployee: ${rowCount} rows generated.`);
}

function generateConstraintScripts() {
  const disableSql = `USE [MAS]
GO

PRINT 'Disabling all foreign key constraints...';
EXEC sp_MSforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL';
GO

PRINT 'Clearing existing seed data from target transaction tables...';
IF OBJECT_ID(N'dbo.tLOG_OTApprove', N'U') IS NOT NULL DELETE FROM [dbo].[tLOG_OTApprove];
IF OBJECT_ID(N'dbo.tTimeStamp', N'U') IS NOT NULL DELETE FROM [dbo].[tTimeStamp];
IF OBJECT_ID(N'dbo.tTimeInOut_AddLeave', N'U') IS NOT NULL DELETE FROM [dbo].[tTimeInOut_AddLeave];
IF OBJECT_ID(N'dbo.tTimeInOut', N'U') IS NOT NULL DELETE FROM [dbo].[tTimeInOut];
IF OBJECT_ID(N'dbo.tLogAddLeaveManagement', N'U') IS NOT NULL DELETE FROM [dbo].[tLogAddLeaveManagement];
IF OBJECT_ID(N'dbo.tRequest', N'U') IS NOT NULL DELETE FROM [dbo].[tRequest];
IF OBJECT_ID(N'dbo.tEmployee', N'U') IS NOT NULL DELETE FROM [dbo].[tEmployee];
GO
`;
  fs.writeFileSync(path.join(SEED_DIR, '00_disable_constraints.sql'), disableSql, 'utf8');

  const enableSql = `USE [MAS]
GO

PRINT 'Re-enabling all foreign key constraints...';
EXEC sp_MSforeachtable 'ALTER TABLE ? WITH NOCHECK CHECK CONSTRAINT ALL';
GO
`;
  fs.writeFileSync(path.join(SEED_DIR, '99_enable_constraints.sql'), enableSql, 'utf8');
}

async function main() {
  console.log('Generating constraint management scripts...');
  generateConstraintScripts();

  console.log('Starting CSV to SQL conversion for 20260914...');
  await convertEmployeeMaster('01_employee_master.csv', '10_dbo.tEmployee.sql');
  await convertFullTableCsv('02_tTimeInOut.csv', 'tTimeInOut', '11_dbo.tTimeInOut.sql', 100);
  await convertFullTableCsv('02_tTimeInOut_AddLeave.csv', 'tTimeInOut_AddLeave', '12_dbo.tTimeInOut_AddLeave.sql', 100);
  await convertFullTableCsv('03_tTimeStamp.csv', 'tTimeStamp', '13_dbo.tTimeStamp.sql', 500);
  await convertFullTableCsv('04_tLogAddLeaveManagement.csv', 'tLogAddLeaveManagement', '14_dbo.tLogAddLeaveManagement.sql', 500);
  await convertFullTableCsv('04_tRequest.csv', 'tRequest', '15_dbo.tRequest.sql', 100);
  await convertFullTableCsv('06_tLOG_OTApprove_20260914_20260916.csv', 'tLOG_OTApprove', '16_dbo.tLOG_OTApprove.sql', 500);

  console.log('\nAll seed SQL files generated successfully in database/seed/20260914/!');
}

main().catch(err => {
  console.error('Error during conversion:', err);
  process.exit(1);
});
