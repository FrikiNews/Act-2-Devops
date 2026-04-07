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

echo "[1/2] Ejecutando gestión EC2..."
python3 "${SCRIPT_DIR}/ec2/gestionar_ec2.py" "$ACCION" "$INSTANCE_ID"
echo "[1/2] EC2 completado."

echo "[2/2] Ejecutando backup S3..."
bash "${SCRIPT_DIR}/s3/backup_s3.sh" "$DIRECTORIO" "$BUCKET"
echo "[2/2] Backup S3 completado."
