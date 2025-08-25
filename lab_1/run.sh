#!/bin/bash

########################################################

## MIDS 255 Course Lab 1 Assignemnt 

## The script will execute the following steps:
## 1. Build docker container
## 2. Run docker container
## 3. Curl the endpoints and return status codes
## 4. Kill the running docker container after tests
## 5. Delete the built docker container

########################################################

# set date 
DATE=`date +%Y-%m-%d-%H-%M-%S` 

echo "The current date is:$DATE"
echo "The script has been execute from:$PWD"

BASEDIR=$(cd $(dirname $0) && pwd)
echo "The script location is:${BASEDIR} "

echo "Building the docker container"
sudo docker build -t mids-255-lab1-image-$DATE .

echo "Deploying the container"
sudo docker run -d --name mids-255-lab1-container-$DATE -p 8000:8000 mids-255-lab1-image-$DATE 

sleep 5
wait

echo "testing '/hello' endpoint with ?name=Winegar"
curl -o /dev/null -s -w "%{http_code}\n" -X GET "http://localhost:8000/hello?name=Winegar"

echo "testing '/' endpoint"
curl -o /dev/null -s -w "%{http_code}\n" -X GET "http://localhost:8000/"

echo "testing '/docs' endpoint"
curl -o /dev/null -s -w "%{http_code}\n" -X GET "http://localhost:8000/docs"

echo " Kill the docker container"
sudo docker kill mids-255-lab1-container-$DATE 

echo "Delete the built docker container"
sudo docker rm mids-255-lab1-container-$DATE

