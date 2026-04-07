#!/usr/bin/env bash
# deploy.sh - Orquestador CI/CD simulado
# Uso: ./deploy.sh <accion_ec2> <instance_id> <directorio_backup> <bucket>

set -euo pipefail

ACCION="${1:-}"
INSTANCE_ID="${2:-}"
DIRECTORIO="${3:-}"
BUCKET="${4:-}"

if [[ -z "$ACCION" || -z "$INSTANCE_ID" || -z "$DIRECTORIO" || -z "$BUCKET" ]]; then
    echo "Uso: ./deploy.sh <accion_ec2> <instance_id> <directorio_backup> <bucket>" >&2
    exit 1
fi

echo "Parámetros recibidos - Acción: ${ACCION} | Instancia: ${INSTANCE_ID} | Dir: ${DIRECTORIO} | Bucket: ${BUCKET}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_DIR="${SCRIPT_DIR}/logs"
LOG_FILE="${LOG_DIR}/deploy_${TIMESTAMP}.log"
mkdir -p "$LOG_DIR"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "Iniciando deploy - Acción: ${ACCION} | Instancia: ${INSTANCE_ID}"

log "[1/2] Ejecutando gestión EC2..."
if python3 "${SCRIPT_DIR}/ec2/gestionar_ec2.py" "$ACCION" "$INSTANCE_ID" 2>&1 | tee -a "$LOG_FILE"; then
    log "[1/2] EC2 completado."
else
    log "ERROR: Falló la gestión EC2."
    exit 1
fi

log "[2/2] Ejecutando backup S3..."
if bash "${SCRIPT_DIR}/s3/backup_s3.sh" "$DIRECTORIO" "$BUCKET" 2>&1 | tee -a "$LOG_FILE"; then
    log "[2/2] Backup S3 completado."
else
    log "ERROR: Falló el backup S3."
    exit 1
fi

log "Deploy finalizado con éxito. Log en: ${LOG_FILE}"
