#!/usr/bin/env bash
# backup_s3.sh - Comprime un directorio y lo sube a un bucket S3
# Uso: bash s3/backup_s3.sh <directorio> <bucket>

set -euo pipefail

# ─── Validación de parámetros ────────────────────────────────────────────────
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
    local mensaje="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $mensaje" | tee -a "$LOG_FILE"
}

# ─── Validación del directorio ───────────────────────────────────────────────
log "Iniciando backup del directorio: ${DIRECTORIO}"

if [[ ! -d "$DIRECTORIO" ]]; then
    log "ERROR: El directorio '${DIRECTORIO}' no existe." >&2
    exit 1
fi

# ─── Compresión de archivos ──────────────────────────────────────────────────
log "Comprimiendo archivos en: ${ARCHIVO_COMPRIMIDO}"
if tar -czf "$ARCHIVO_COMPRIMIDO" -C "$(dirname "$DIRECTORIO")" "$(basename "$DIRECTORIO")"; then
    TAMAÑO=$(du -sh "$ARCHIVO_COMPRIMIDO" | cut -f1)
    log "Compresión exitosa. Tamaño: ${TAMAÑO}"
else
    log "ERROR: Falló la compresión." >&2
    exit 1
fi

# ─── Subida a S3 ─────────────────────────────────────────────────────────────
DESTINO_S3="s3://${BUCKET}/backups/backup_${TIMESTAMP}.tar.gz"
log "Subiendo archivo a: ${DESTINO_S3}"

if aws s3 cp "$ARCHIVO_COMPRIMIDO" "$DESTINO_S3"; then
    log "Subida exitosa a S3: ${DESTINO_S3}"
else
    log "ERROR: Falló la subida a S3." >&2
    exit 1
fi

# ─── Limpieza ────────────────────────────────────────────────────────────────
rm -f "$ARCHIVO_COMPRIMIDO"
log "Archivo temporal eliminado."
log "Backup completado exitosamente."
log "Log guardado en: ${LOG_FILE}"
