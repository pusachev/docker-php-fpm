#!/bin/bash

# Get the PHP_VERSION from .env file
if [ -f .env ]; then
    PHP_VERSION=$(grep "PHP_VERSION" .env | cut -d '=' -f 2)
else
    echo "Error: .env file not found."
    exit 1
fi

# Check if PHP_VERSION was found
if [ -z "$PHP_VERSION" ]; then
    echo "Error: PHP_VERSION not found in .env file."
    exit 1
fi

echo "Using PHP version: $PHP_VERSION"
IMAGE="pusachev/php-fpm:$PHP_VERSION"

echo "Step 1: Stopping containers using image $IMAGE"
CONTAINERS=$(docker ps -q --filter "ancestor=$IMAGE")

if [ -z "$CONTAINERS" ]; then
    echo "No running containers found using image $IMAGE"
else
    echo "Found the following containers using $IMAGE:"
    docker ps --filter "ancestor=$IMAGE" --format "table {{.ID}}\t{{.Names}}\t{{.Status}}"

    echo "Stopping containers..."
    for CONTAINER_ID in $CONTAINERS; do
        echo "Stopping container: $CONTAINER_ID"
        docker stop $CONTAINER_ID
    done
    echo "All containers using $IMAGE have been stopped."
fi

echo "Step 2: Removing image $IMAGE"
if docker image inspect $IMAGE >/dev/null 2>&1; then
    docker image rm $IMAGE
    echo "Image $IMAGE has been removed."
else
    echo "Image $IMAGE not found locally."
fi

echo "Step 3: Rebuilding image $IMAGE"
docker build -t $IMAGE .
echo "Image $IMAGE has been rebuilt successfully."

echo "Step 4: Pushing image to Docker Hub"
docker push $IMAGE
echo "Image $IMAGE has been pushed to Docker Hub."

echo "Process completed."