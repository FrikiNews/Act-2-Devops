#!/usr/bin/env bash
# backup_s3.sh - Comprime un directorio y lo sube a un bucket S3
# Uso: bash s3/backup_s3.sh <directorio> <bucket>

set -euo pipefail

if [[ $# -lt 2 ]]; then
    echo "Uso: bash s3/backup_s3.sh <directorio> <bucket>" >&2
    exit 1
fi

DIRECTORIO="$1"
BUCKET="$2"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
ARCHIVO_COMPRIMIDO="/tmp/backup_${TIMESTAMP}.tar.gz"

if [[ ! -d "$DIRECTORIO" ]]; then
    echo "ERROR: El directorio '${DIRECTORIO}' no existe." >&2
    exit 1
fi

echo "Comprimiendo ${DIRECTORIO} en ${ARCHIVO_COMPRIMIDO}..."
tar -czf "$ARCHIVO_COMPRIMIDO" -C "$(dirname "$DIRECTORIO")" "$(basename "$DIRECTORIO")"
echo "Compresión exitosa."
