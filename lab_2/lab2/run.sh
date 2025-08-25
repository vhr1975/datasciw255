#!/bin/bash
IMAGE_NAME=lab2
APP_NAME=lab2

# Train the model
echo "Training model..."
python src/train.py

# Move model artifacts to api source directory
echo "Copy model artifacts..."
copy model_pipeline.pkl /src

# Build the Docker image
echo "Building Docker image..."
echo "Script executed from: ${PWD}"
echo "IMAGE_NAME = ${IMAGE_NAME}"
echo "APP_NAME = ${APP_NAME}"

# docker build -t my-image .
# rebuild and run the new image
docker build -t ${IMAGE_NAME} .

# Run the Docker container in detached mode
echo "Starting Docker container..."
#docker run -d -p 8000:80 --name my-container my-image
docker run -d --name ${APP_NAME} -p 8000:8000 ${IMAGE_NAME}

echo "Wait for the server to start up..."
sleep 10

# Test endpoints with curl
echo "Testing endpoints..."
if curl -sSf http://localhost:8000/predict/ > /dev/null; then
  echo "Prediction endpoint is up"
else
  echo "Prediction endpoint is down"
fi

if curl -sSf http://localhost:8000/health > /dev/null; then
  echo "Health endpoint is up"
else
  echo "Health endpoint is down"
fi

# Kill the running container
echo "Stopping Docker container..."

# stop and remove container
docker stop ${APP_NAME}

# Clean up Docker resources
echo "Cleaning up Docker resources..."
docker rm ${APP_NAME}

# delete image
docker image rm ${APP_NAME}




