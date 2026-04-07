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
LOG_DIR="$(dirname "$0")/../logs"
LOG_FILE="${LOG_DIR}/backup_${TIMESTAMP}.log"

mkdir -p "$LOG_DIR"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

if [[ ! -d "$DIRECTORIO" ]]; then
    log "ERROR: El directorio '${DIRECTORIO}' no existe."
    exit 1
fi

log "Comprimiendo ${DIRECTORIO} en ${ARCHIVO_COMPRIMIDO}..."
tar -czf "$ARCHIVO_COMPRIMIDO" -C "$(dirname "$DIRECTORIO")" "$(basename "$DIRECTORIO")"
log "Compresión exitosa."

DESTINO_S3="s3://${BUCKET}/backups/backup_${TIMESTAMP}.tar.gz"
log "Subiendo a ${DESTINO_S3}..."
aws s3 cp "$ARCHIVO_COMPRIMIDO" "$DESTINO_S3"
log "Subida exitosa."

rm -f "$ARCHIVO_COMPRIMIDO"
log "Backup completado. Log guardado en: ${LOG_FILE}"
