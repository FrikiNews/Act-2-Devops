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
