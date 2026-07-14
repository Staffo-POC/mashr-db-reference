#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MERMAID_DIR="${SCRIPT_DIR}/mermaid"
IMAGES_DIR="${SCRIPT_DIR}/images"

if ! command -v mmdc >/dev/null 2>&1; then
  echo "ERROR: Mermaid CLI command 'mmdc' was not found." >&2
  echo "Install it with: npm install -g @mermaid-js/mermaid-cli" >&2
  exit 1
fi

if [ ! -d "${MERMAID_DIR}" ]; then
  echo "ERROR: Mermaid source directory not found: ${MERMAID_DIR}" >&2
  exit 1
fi

mkdir -p "${IMAGES_DIR}"

found=0
for input in "${MERMAID_DIR}"/*.mmd; do
  [ -e "${input}" ] || continue
  found=1
  name="$(basename "${input}" .mmd)"
  output="${IMAGES_DIR}/${name}.svg"
  echo "Rendering ${input} -> ${output}"
  mmdc -i "${input}" -o "${output}"
done

if [ "${found}" -eq 0 ]; then
  echo "ERROR: No .mmd files found in ${MERMAID_DIR}" >&2
  exit 1
fi

echo "Done. SVG files are in ${IMAGES_DIR}"
