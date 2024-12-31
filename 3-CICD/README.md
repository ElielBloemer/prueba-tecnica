
# Pipeline CI/CD para NGINX con Actualización Automática ⚙️

Este proyecto implementa un pipeline CI/CD para construir, publicar y desplegar una imagen de Docker que contiene un servidor NGINX con un archivo index.html predeterminado. El pipeline está configurado para reaccionar a cambios en el archivo index.html y desplegar automáticamente la nueva versión en un servidor remoto.


## Estructura del Proyecto


```bash
  .
├── 3-CICD/
│   ├── Dockerfile       # Dockerfile para construir la imagen de NGINX
│   ├── index.html       # Archivo HTML para servir desde NGINX
│   ├── README.md        # Archivo explicando detalles de la implemtacion   
│────── ./github/workflows/
│               └── ci-cd.yml  # Pipeline CI/CD para GitHub Actions

```
    
## Componentes 🧩

**1. Dockerfile** 🐳

Este Dockerfile utiliza una imagen base de NGINX y copia el archivo index.html para servirlo como contenido estático.

```bash
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
```

**2. Archivo index.html** 🌐

El archivo HTML que será servido por NGINX:
```bash
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NGINX Server</title>
</head>
<body>
    <h1>BEM VINDO AO NGINX FAÇA BOM USO QUE VAI DAR BOM!!! </h1>
</body>
</html>
```

**3-Pipeline CI/CD (ci-cd.yml)** ⚙️

El pipeline implementado en GitHub Actions automatiza el proceso de construcción, publicación y despliegue.

Eventos de Activación:

```bash
on:
  push:
    branches:
      - main
    paths:
      - "3-CICD/index.html"
  workflow_dispatch:    
```
 - Push: Se ejecuta cuando hay cambios en el archivo 3-CICD/index.html en la rama main.
 - Workflow Dispatch: Permite ejecutar manualmente el pipeline desde la interfaz de GitHub.

### Etapas del Pipeline
**1-Checkout del Código**

 - Clona el repositorio en el runner de GitHub Actions


```bash
- name: Checkout code
  uses: actions/checkout@v3
```

**2-Inicio de Sesión en Docker Hub** 🐳

Autentica en Docker Hub usando las credenciales almacenadas en los secretos del repositorio:

```bash
- name: Log in to Docker Hub
  uses: docker/login-action@v2
  with:
    username: ${{ secrets.DOCKER_USERNAME }}
    password: ${{ secrets.DOCKER_PASSWORD }}
```

**3-Construcción de la Imagen Docker**

- Construye la imagen Docker basada en el Dockerfile y utiliza el SHA del commit como etiqueta:
```bash
- name: Build Docker image
  run: |
    docker build -t ebloemer/nginx-server:${{ github.sha }} -f 3-CICD/Dockerfile 3-CICD
    echo "IMAGE_TAG=${{ github.sha }}" >> $GITHUB_ENV
```

**4-Publicación de la Imagen**

Publica la imagen en Docker Hub para que esté disponible para el servidor remoto:

```bash
- name: Push Docker image
  run: |
    docker push ebloemer/nginx-server:${{ github.sha }}
```

**5-Despliegue en el Servidor Remoto**

- Conecta al servidor remoto mediante SSH y ejecuta un script de despliegue que:
  - Detiene y elimina el contenedor anterior.
  - Descarga la nueva imagen de Docker Hub.
  - Crea y ejecuta el contenedor actualizado.
- Configuracion del paso:

```bash
- name: Deploy on remote server
  uses: appleboy/ssh-action@v0.1.10
  with:
    host: ${{ secrets.SERVER_HOST }}
    username: ${{ secrets.SERVER_USER }}
    key: ${{ secrets.SERVER_SSH_KEY }}
    script: |
      echo "Creando y ejecutando el script en el servidor remoto..."
      mkdir -p ~/deploy-scripts
      cat << EOF > ~/deploy-scripts/deploy.sh
      #!/bin/bash

      if [ -z "\$1" ]; then
        echo "Error: Debes proporcionar el hash SHA como parámetro."
        exit 1
      fi

      SHA=\$1
      IMAGE_NAME="ebloemer/nginx-server"
      CONTAINER_NAME="nginx-server"

      echo "Desplegando la imagen: \$IMAGE_NAME:\$SHA"

      if [ "\$(docker ps -aq -f name=\$CONTAINER_NAME)" ]; then
        docker stop \$CONTAINER_NAME && docker rm \$CONTAINER_NAME
      fi

      docker image rm -f \$IMAGE_NAME:\$SHA || true
      docker pull \$IMAGE_NAME:\$SHA
      docker run -d --name \$CONTAINER_NAME -p 80:80 --restart always \$IMAGE_NAME:\$SHA
      EOF

      chmod +x ~/deploy-scripts/deploy.sh
      ~/deploy-scripts/deploy.sh ${{ github.sha }}
```

### Para Usarlo debes:
**1-Configurar Secretos en GitHub:** 🔒

  - **DOCKER_USERNAME** y **DOCKER_PASSWORD:** Credenciales de Docker Hub.
  - **SERVER_HOST, SERVER_USER, SERVER_SSH_KEY:** Detalles para acceder al servidor remoto.

**2-Ejecución Automática:**

  - Realiza cambios en el archivo **3-CICD/index.html** y realiza un push en la rama **main**.

**3-Ejecución Manual:**

Activa el pipeline manualmente desde la interfaz de GitHub Actions.  

**4-Verifica el despliegue:**

Accede al servidor remoto para confirmar que la nueva versión está disponible en http://<IP__PUBLICA_DEL_SERVIDOR>.


🚨 **IMPORTANTE!** 🚨

- El servidor remoto debe tener Docker instalado y configurado.
- Conexion via ssh desde internet para que se pueda desplegar el contenido.


### Autor

**Eliel Bloemer**

Con este pipeline, el proceso de despliegue está completamente automatizado y sigue las mejores prácticas de CI/CD. Muchas gracias por tu tiempo
Si tienes dudas, por favor no dudes en contactarme.😊
