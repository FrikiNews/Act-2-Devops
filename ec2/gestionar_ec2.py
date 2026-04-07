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
from botocore.exceptions import BotoCoreError, ClientError


def obtener_cliente(region: str):
    return boto3.client("ec2", region_name=region)


def listar_instancias(cliente):
    try:
        respuesta = cliente.describe_instances()
        reservaciones = respuesta.get("Reservations", [])
        if not reservaciones:
            print("No se encontraron instancias EC2.")
            return

        print(f"{'ID':<22} {'Estado':<14} {'Tipo':<14} {'IP Pública':<18} {'Nombre'}")
        print("-" * 90)
        for reservacion in reservaciones:
            for instancia in reservacion["Instances"]:
                iid = instancia.get("InstanceId", "N/A")
                estado = instancia["State"]["Name"]
                tipo = instancia.get("InstanceType", "N/A")
                ip = instancia.get("PublicIpAddress", "N/A")
                tags = instancia.get("Tags", [])
                nombre = next((t["Value"] for t in tags if t["Key"] == "Name"), "Sin nombre")
                print(f"{iid:<22} {estado:<14} {tipo:<14} {ip:<18} {nombre}")
    except (BotoCoreError, ClientError) as e:
        print(f"Error al listar instancias: {e}", file=sys.stderr)
        sys.exit(1)


def iniciar_instancia(cliente, instance_id: str):
    try:
        respuesta = cliente.start_instances(InstanceIds=[instance_id])
        estado_previo = respuesta["StartingInstances"][0]["PreviousState"]["Name"]
        estado_actual = respuesta["StartingInstances"][0]["CurrentState"]["Name"]
        print(f"Instancia {instance_id}: {estado_previo} → {estado_actual}")
    except (BotoCoreError, ClientError) as e:
        print(f"Error al iniciar la instancia {instance_id}: {e}", file=sys.stderr)
        sys.exit(1)


def detener_instancia(cliente, instance_id: str):
    try:
        respuesta = cliente.stop_instances(InstanceIds=[instance_id])
        estado_previo = respuesta["StoppingInstances"][0]["PreviousState"]["Name"]
        estado_actual = respuesta["StoppingInstances"][0]["CurrentState"]["Name"]
        print(f"Instancia {instance_id}: {estado_previo} → {estado_actual}")
    except (BotoCoreError, ClientError) as e:
        print(f"Error al detener la instancia {instance_id}: {e}", file=sys.stderr)
        sys.exit(1)


def terminar_instancia(cliente, instance_id: str):
    try:
        confirmacion = input(
            f"¿Seguro que deseas TERMINAR (eliminar) la instancia {instance_id}? [s/N]: "
        ).strip().lower()
        if confirmacion != "s":
            print("Operación cancelada.")
            return

        respuesta = cliente.terminate_instances(InstanceIds=[instance_id])
        estado_previo = respuesta["TerminatingInstances"][0]["PreviousState"]["Name"]
        estado_actual = respuesta["TerminatingInstances"][0]["CurrentState"]["Name"]
        print(f"Instancia {instance_id}: {estado_previo} → {estado_actual}")
    except (BotoCoreError, ClientError) as e:
        print(f"Error al terminar la instancia {instance_id}: {e}", file=sys.stderr)
        sys.exit(1)


def mostrar_ayuda():
    print(__doc__)


def main():
    import os
    region = os.environ.get("REGION", "us-east-1")
    cliente = obtener_cliente(region)

    if len(sys.argv) < 2:
        mostrar_ayuda()
        sys.exit(1)

    accion = sys.argv[1].lower()

    if accion == "listar":
        listar_instancias(cliente)

    elif accion == "iniciar":
        if len(sys.argv) < 3:
            print("Error: debes proporcionar un instance_id.", file=sys.stderr)
            print("Uso: python3 gestionar_ec2.py iniciar <instance_id>")
            sys.exit(1)
        iniciar_instancia(cliente, sys.argv[2])

    elif accion == "detener":
        if len(sys.argv) < 3:
            print("Error: debes proporcionar un instance_id.", file=sys.stderr)
            print("Uso: python3 gestionar_ec2.py detener <instance_id>")
            sys.exit(1)
        detener_instancia(cliente, sys.argv[2])

    elif accion == "terminar":
        if len(sys.argv) < 3:
            print("Error: debes proporcionar un instance_id.", file=sys.stderr)
            print("Uso: python3 gestionar_ec2.py terminar <instance_id>")
            sys.exit(1)
        terminar_instancia(cliente, sys.argv[2])

    else:
        print(f"Acción desconocida: '{accion}'", file=sys.stderr)
        mostrar_ayuda()
        sys.exit(1)


if __name__ == "__main__":
    main()
