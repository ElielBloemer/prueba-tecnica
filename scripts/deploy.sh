#!/bin/bash

if [ -z "$1" ]; then
  echo "Error: Debes proporcionar el hash SHA como parámetro."
  echo "Uso: $0 <sha>"
  exit 1
fi

SHA=$1
IMAGE_NAME="ebloemer/nginx-server"
CONTAINER_NAME="nginx-server"

echo "Desplegando la imagen: $IMAGE_NAME:$SHA"

if [ "$(docker ps -aq -f name=$CONTAINER_NAME)" ]; then
  echo "Deteniendo y eliminando el contenedor anterior..."
  docker stop $CONTAINER_NAME && docker rm $CONTAINER_NAME
fi

echo "Eliminando la imagen anterior..."
docker image rm -f $IMAGE_NAME:$SHA || echo "No se encontró una imagen anterior con este SHA."

echo "Haciendo pull de la nueva imagen..."
docker pull $IMAGE_NAME:$SHA

echo "Ejecutando el nuevo contenedor..."
docker run -d --name $CONTAINER_NAME -p 80:80 --restart always $IMAGE_NAME:$SHA 

if [ "$(docker ps -q -f name=$CONTAINER_NAME)" ]; then
  echo "El contenedor se está ejecutando correctamente."
  echo "Accede a: http://<tu-servidor>:8080"
else
  echo "Error: No se pudo iniciar el contenedor."
  exit 1
fi
