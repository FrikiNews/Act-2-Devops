#!/usr/bin/env python3
"""
gestionar_ec2.py - Gestión de instancias EC2 mediante Boto3
Uso:
    python3 gestionar_ec2.py listar
    python3 gestionar_ec2.py iniciar <instance_id>
    python3 gestionar_ec2.py detener <instance_id>
    python3 gestionar_ec2.py terminar <instance_id>
"""

import sys
import boto3


def obtener_cliente(region: str):
    return boto3.client("ec2", region_name=region)


def main():
    import os
    region = os.environ.get("REGION", "us-east-1")
    obtener_cliente(region)

    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)

    accion = sys.argv[1].lower()
    print(f"Acción recibida: {accion}")


if __name__ == "__main__":
    main()
