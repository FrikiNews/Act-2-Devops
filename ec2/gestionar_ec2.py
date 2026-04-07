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


def listar_instancias(cliente):
    respuesta = cliente.describe_instances()
    reservaciones = respuesta.get("Reservations", [])
    if not reservaciones:
        print("No se encontraron instancias EC2.")
        return
    print(f"{'ID':<22} {'Estado':<14} {'Tipo':<14} {'IP Pública'}")
    print("-" * 70)
    for reservacion in reservaciones:
        for instancia in reservacion["Instances"]:
            iid = instancia.get("InstanceId", "N/A")
            estado = instancia["State"]["Name"]
            tipo = instancia.get("InstanceType", "N/A")
            ip = instancia.get("PublicIpAddress", "N/A")
            print(f"{iid:<22} {estado:<14} {tipo:<14} {ip}")


def iniciar_instancia(cliente, instance_id: str):
    respuesta = cliente.start_instances(InstanceIds=[instance_id])
    estado_previo = respuesta["StartingInstances"][0]["PreviousState"]["Name"]
    estado_actual = respuesta["StartingInstances"][0]["CurrentState"]["Name"]
    print(f"Instancia {instance_id}: {estado_previo} → {estado_actual}")


def detener_instancia(cliente, instance_id: str):
    respuesta = cliente.stop_instances(InstanceIds=[instance_id])
    estado_previo = respuesta["StoppingInstances"][0]["PreviousState"]["Name"]
    estado_actual = respuesta["StoppingInstances"][0]["CurrentState"]["Name"]
    print(f"Instancia {instance_id}: {estado_previo} → {estado_actual}")


def main():
    import os
    region = os.environ.get("REGION", "us-east-1")
    cliente = obtener_cliente(region)

    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)

    accion = sys.argv[1].lower()

    if accion == "listar":
        listar_instancias(cliente)
    elif accion == "iniciar":
        iniciar_instancia(cliente, sys.argv[2])
    elif accion == "detener":
        detener_instancia(cliente, sys.argv[2])
    else:
        print(f"Acción no implementada aún: {accion}")


if __name__ == "__main__":
    main()
