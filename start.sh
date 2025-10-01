#!/bin/bash

# Nome da imagem e do container
IMAGE_NAME="n8nio/n8n"
CONTAINER_NAME="n8n_instance"

# Caminho do repositório git do n8n (ajuste conforme onde você clonou)
N8N_DIR="$HOME/n8n"

echo "🔍 Verificando se a imagem $IMAGE_NAME existe..."
if [[ "$(docker images -q $IMAGE_NAME:latest 2> /dev/null)" == "" ]]; then
    echo "❌ Imagem não encontrada. Construindo a partir do git do n8n..."
    if [ -d "$N8N_DIR" ]; then
        cd "$N8N_DIR" || exit
        docker build -t $IMAGE_NAME .
    else
        echo "⚠️ Diretório $N8N_DIR não encontrado. Clone o repositório antes de rodar este script."
        exit 1
    fi
else
    echo "✅ Imagem $IMAGE_NAME já existe."
fi

echo "🚀 Verificando se o container $CONTAINER_NAME já está rodando..."
if [ "$(docker ps -q -f name=$CONTAINER_NAME)" ]; then
    echo "⚠️ O container $CONTAINER_NAME já está em execução."
elif [ "$(docker ps -aq -f status=exited -f name=$CONTAINER_NAME)" ]; then
    echo "🔄 Iniciando container parado..."
    docker start -ai $CONTAINER_NAME
else
    echo "📦 Criando e iniciando container $CONTAINER_NAME..."
    docker run -d \
        --name $CONTAINER_NAME \
        -p 5678:5678 \
        -v ~/.n8n:/home/node/.n8n \
        $IMAGE_NAME
fi
