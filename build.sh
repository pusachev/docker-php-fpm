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
VERSION_IMAGE="pusachev/php-fpm:$PHP_VERSION"
LATEST_IMAGE="pusachev/php-fpm:latest"

echo "Step 1: Stopping containers using images $VERSION_IMAGE or $LATEST_IMAGE"
CONTAINERS=$(docker ps -q --filter "ancestor=$VERSION_IMAGE" --filter "ancestor=$LATEST_IMAGE")

if [ -z "$CONTAINERS" ]; then
    echo "No running containers found using these images"
else
    echo "Found the following containers:"
    docker ps --filter "ancestor=$VERSION_IMAGE" --filter "ancestor=$LATEST_IMAGE" --format "table {{.ID}}\t{{.Names}}\t{{.Status}}"

    echo "Stopping containers..."
    for CONTAINER_ID in $CONTAINERS; do
        echo "Stopping container: $CONTAINER_ID"
        docker stop $CONTAINER_ID
    done
    echo "All containers have been stopped."
fi

echo "Step 2: Removing images"
# Remove version-specific image
if docker image inspect $VERSION_IMAGE >/dev/null 2>&1; then
    docker image rm $VERSION_IMAGE
    echo "Image $VERSION_IMAGE has been removed."
else
    echo "Image $VERSION_IMAGE not found locally."
fi

# Remove latest image
if docker image inspect $LATEST_IMAGE >/dev/null 2>&1; then
    docker image rm $LATEST_IMAGE
    echo "Image $LATEST_IMAGE has been removed."
else
    echo "Image $LATEST_IMAGE not found locally."
fi

echo "Step 3: Rebuilding images"
# Build version-specific image
docker build -t $VERSION_IMAGE .
echo "Image $VERSION_IMAGE has been rebuilt successfully."

# Tag as latest as well
docker tag $VERSION_IMAGE $LATEST_IMAGE
echo "Image also tagged as $LATEST_IMAGE"

echo "Step 4: Pushing images to Docker Hub"
# Push version-specific image
docker push $VERSION_IMAGE
echo "Image $VERSION_IMAGE has been pushed to Docker Hub."

# Push latest image
docker push $LATEST_IMAGE
echo "Image $LATEST_IMAGE has been pushed to Docker Hub."

echo "Process completed."