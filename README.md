# project-devops

Proyecto de automatización en AWS con enfoque DevOps.  
Gestiona instancias EC2 y realiza respaldos en S3 desde una instancia EC2 Linux dentro de AWS Learner Lab.

---

## Estructura del proyecto

```
project-devops/
├── ec2/
│   └── gestionar_ec2.py   # Gestión de instancias EC2 con Boto3
├── s3/
│   └── backup_s3.sh       # Script de respaldo hacia S3
├── logs/                  # Logs generados automáticamente
├── config/
│   └── config.env         # Variables de entorno (sin credenciales)
├── deploy.sh              # Orquestador CI/CD simulado
└── README.md
```

---

## Requisitos del entorno

- AWS CLI configurado (`aws configure`)
- Python 3 con `boto3` instalado (`pip3 install boto3`)
- Git y GitHub CLI (`gh`)
- Bash

---

## Instrucciones de uso

### Script EC2

```bash
python3 ec2/gestionar_ec2.py listar
python3 ec2/gestionar_ec2.py iniciar  <instance_id>
python3 ec2/gestionar_ec2.py detener  <instance_id>
python3 ec2/gestionar_ec2.py terminar <instance_id>
```

### Script de respaldo S3

```bash
bash s3/backup_s3.sh <directorio> <bucket>
```

### Orquestador (deploy.sh)

```bash
chmod +x deploy.sh
./deploy.sh <accion_ec2> <instance_id> <directorio_backup> <bucket>

# Ejemplo:
./deploy.sh iniciar i-123456 ./data mi-bucket-devops
```

### Usando config.env

Editar `config/config.env` con los valores del entorno y ejecutar:

```bash
source config/config.env
./deploy.sh $ACCION_EC2 $INSTANCE_ID $DIRECTORY $BUCKET_NAME
```

---

## Flujo Git

```
feature/* → develop → main
```

1. Crear rama de funcionalidad:  
   `git checkout -b feature/gestionar-ec2`
2. Desarrollar con commits progresivos:  
   `git commit -m "feat: listar instancias EC2"`
3. Push y merge a `develop`:  
   `git push origin feature/gestionar-ec2`
4. Merge a `main` cuando esté estable.

---

## Reflexión

**¿Qué ventaja tienen los commits progresivos?**  
Permiten rastrear el historial de cambios de forma granular, facilitan la detección de errores, el code review y el rollback a un estado anterior sin afectar funcionalidades completas.

**¿Por qué evitar hardcoding?**  
Los valores fijos en el código hacen que los scripts sean difíciles de reutilizar, aumentan el riesgo de exponer datos sensibles y rompen la separación entre configuración y lógica de negocio.

**¿Qué rol cumple deploy.sh?**  
Actúa como orquestador CI/CD: recibe parámetros, delega la gestión de EC2 al script Python, ejecuta el backup en S3, valida errores en cada paso y genera un log unificado del despliegue.

**¿Qué ventaja tiene separar config del código?**  
Centraliza los valores del entorno en un único archivo, permite cambiar configuraciones sin tocar la lógica, facilita el despliegue en múltiples entornos (dev, staging, prod) y reduce el riesgo de comprometer credenciales.
