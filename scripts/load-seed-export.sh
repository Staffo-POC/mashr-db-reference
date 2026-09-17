#!/usr/bin/env bash
# Load a seed export produced by scripts/export/Export-MashrSeed.ps1 into the
# local Docker database.
#
#   ./scripts/load-seed-export.sh ~/Downloads/mashr-seed-20260907.zip
#   ./scripts/load-seed-export.sh /path/to/20260907 --name 20260907b
#   ./scripts/load-seed-export.sh <zip> --no-setup     # stage only, don't import
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

SOURCE=""
SNAPSHOT_NAME=""
RUN_SETUP=1

while [[ $# -gt 0 ]]; do
  case "$1" in
    --name)      SNAPSHOT_NAME="$2"; shift 2 ;;
    --no-setup)  RUN_SETUP=0; shift ;;
    -h|--help)
      sed -n '2,10p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
      exit 0 ;;
    *)
      if [[ -n "${SOURCE}" ]]; then
        echo "Unexpected argument: $1" >&2
        exit 1
      fi
      SOURCE="$1"; shift ;;
  esac
done

if [[ -z "${SOURCE}" ]]; then
  echo "Usage: ./scripts/load-seed-export.sh <export.zip | export-folder> [--name <snapshot>] [--no-setup]" >&2
  exit 1
fi

if [[ ! -e "${SOURCE}" ]]; then
  echo "Not found: ${SOURCE}" >&2
  exit 1
fi

STAGE_DIR="$(mktemp -d)"
cleanup() { rm -rf "${STAGE_DIR}"; }
trap cleanup EXIT

# --- unpack ----------------------------------------------------------------
if [[ -d "${SOURCE}" ]]; then
  SEED_SOURCE="${SOURCE%/}"
else
  case "${SOURCE}" in
    *.zip)
      command -v unzip >/dev/null 2>&1 || { echo "unzip is required to read ${SOURCE}" >&2; exit 1; }
      unzip -q -o "${SOURCE}" -d "${STAGE_DIR}"
      ;;
    *)
      echo "Expected a .zip file or a folder: ${SOURCE}" >&2
      exit 1
      ;;
  esac

  # The zip may hold the snapshot folder itself or a single wrapper folder.
  if compgen -G "${STAGE_DIR}/*.sql" >/dev/null; then
    SEED_SOURCE="${STAGE_DIR}"
  else
    SEED_SOURCE=""
    while IFS= read -r dir; do
      if compgen -G "${dir}/*.sql" >/dev/null; then
        SEED_SOURCE="${dir}"
        break
      fi
    done < <(find "${STAGE_DIR}" -mindepth 1 -maxdepth 2 -type d)
    if [[ -z "${SEED_SOURCE}" ]]; then
      echo "No .sql files found inside ${SOURCE}" >&2
      exit 1
    fi
  fi
fi

if ! compgen -G "${SEED_SOURCE}/*.sql" >/dev/null; then
  echo "No .sql files found in ${SEED_SOURCE}" >&2
  exit 1
fi

# --- snapshot name ---------------------------------------------------------
if [[ -z "${SNAPSHOT_NAME}" ]]; then
  SNAPSHOT_NAME="$(basename "${SEED_SOURCE}")"
  SNAPSHOT_NAME="${SNAPSHOT_NAME%.zip}"
  SNAPSHOT_NAME="${SNAPSHOT_NAME#mashr-seed-}"
fi

TARGET_DIR="${ROOT_DIR}/database/seed/${SNAPSHOT_NAME}"
if [[ -d "${TARGET_DIR}" ]]; then
  echo "Snapshot ${SNAPSHOT_NAME} already exists at database/seed/${SNAPSHOT_NAME}"
  read -r -p "Overwrite it? [y/N] " reply
  [[ "${reply}" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 1; }
  rm -rf "${TARGET_DIR}"
fi

mkdir -p "${TARGET_DIR}"
cp "${SEED_SOURCE}"/*.sql "${TARGET_DIR}/"
for extra in _manifest.json _README.md; do
  [[ -f "${SEED_SOURCE}/${extra}" ]] && cp "${SEED_SOURCE}/${extra}" "${TARGET_DIR}/"
done

echo "Staged $(ls -1 "${TARGET_DIR}"/*.sql | wc -l | tr -d ' ') SQL files into database/seed/${SNAPSHOT_NAME}"

# --- point .env at the new snapshot ----------------------------------------
[[ -f .env ]] || cp .env.example .env
TMP_ENV="$(mktemp)"
grep -v '^MASHR_SEED_SNAPSHOT=' .env > "${TMP_ENV}" || true
printf 'MASHR_SEED_SNAPSHOT=%s\n' "${SNAPSHOT_NAME}" >> "${TMP_ENV}"
mv "${TMP_ENV}" .env
echo "Set MASHR_SEED_SNAPSHOT=${SNAPSHOT_NAME} in .env"

if [[ -f "${TARGET_DIR}/_manifest.json" ]]; then
  echo
  echo "Manifest:"
  sed -n '1,25p' "${TARGET_DIR}/_manifest.json"
fi

if [[ ${RUN_SETUP} -eq 1 ]]; then
  echo
  echo "Rebuilding the local database with snapshot ${SNAPSHOT_NAME}..."
  "${ROOT_DIR}/scripts/setup.sh"
  echo
  echo "Now run: ./scripts/check-site-data.sh"
else
  echo
  echo "Staged only. Run ./scripts/setup.sh when you are ready to import."
fi
