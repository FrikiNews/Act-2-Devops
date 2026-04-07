#!/usr/bin/env bash
# deploy.sh - Orquestador CI/CD simulado
# Uso: ./deploy.sh <accion_ec2> <instance_id> <directorio_backup> <bucket>
#
# Ejemplo:
#   ./deploy.sh iniciar i-123456 ./data mi-bucket-devops

set -euo pipefail

# ─── Carga de configuración ──────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/config/config.env"

if [[ -f "$CONFIG_FILE" ]]; then
    # shellcheck source=config/config.env
    source "$CONFIG_FILE"
fi

# ─── Parámetros (tienen precedencia sobre config.env) ────────────────────────
ACCION="${1:-${ACCION_EC2:-}}"
INSTANCE_ID="${2:-${INSTANCE_ID:-}}"
DIRECTORIO="${3:-${DIRECTORY:-}}"
BUCKET="${4:-${BUCKET_NAME:-}}"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_DIR="${SCRIPT_DIR}/logs"
LOG_FILE="${LOG_DIR}/deploy_${TIMESTAMP}.log"

mkdir -p "$LOG_DIR"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# ─── Validación de parámetros ────────────────────────────────────────────────
if [[ -z "$ACCION" || -z "$INSTANCE_ID" || -z "$DIRECTORIO" || -z "$BUCKET" ]]; then
    echo "Uso: ./deploy.sh <accion_ec2> <instance_id> <directorio_backup> <bucket>" >&2
    echo "Acciones válidas: listar | iniciar | detener | terminar" >&2
    exit 1
fi

log "══════════════════════════════════════════════════"
log " Iniciando deploy - Acción: ${ACCION} | Instancia: ${INSTANCE_ID}"
log "══════════════════════════════════════════════════"

# ─── Paso 1: Gestión EC2 ─────────────────────────────────────────────────────
log "[1/2] Ejecutando gestión EC2..."
if python3 "${SCRIPT_DIR}/ec2/gestionar_ec2.py" "$ACCION" "$INSTANCE_ID" 2>&1 | tee -a "$LOG_FILE"; then
    log "[1/2] Gestión EC2 completada exitosamente."
else
    log "[1/2] ERROR: Falló la gestión EC2." >&2
    exit 1
fi

# ─── Paso 2: Backup S3 ───────────────────────────────────────────────────────
log "[2/2] Ejecutando backup S3..."
if bash "${SCRIPT_DIR}/s3/backup_s3.sh" "$DIRECTORIO" "$BUCKET" 2>&1 | tee -a "$LOG_FILE"; then
    log "[2/2] Backup S3 completado exitosamente."
else
    log "[2/2] ERROR: Falló el backup S3." >&2
    exit 1
fi

# ─── Resumen ─────────────────────────────────────────────────────────────────
log "══════════════════════════════════════════════════"
log " Deploy finalizado con éxito."
log " Log completo en: ${LOG_FILE}"
log "══════════════════════════════════════════════════"
