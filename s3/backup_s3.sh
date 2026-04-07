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

echo "Parámetros recibidos - Directorio: ${DIRECTORIO} | Bucket: ${BUCKET}"
