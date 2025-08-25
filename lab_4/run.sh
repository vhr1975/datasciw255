#!/bin/bash
IMAGE_NAME=lab4
APP_NAME=lab4

# Run pytest within poetry virtualenv
#poetry env remove python3.10
#poetry install
#poetry run pytest -vv -s

#source ~/.bashrc

# START UP MINIKUBE
minikube start --kubernetes-version=v1.25.4

# SETUP DOCKER DAEMON TO BUILD WITH MINIKUBE
eval $(minikube docker-env)

# delete any existing deployments or services
kubectl delete --all deployments --namespace=w255
kubectl delete --all services --namespace=w255

# ENSURE API MODEL IS TRAINED
echo "Check if model_pipeline.pkl exists. If not, then train model" #lab_3 folder

# train.py already contains code to check if exists
cd ./lab4
poetry run python ./trainer/train.py
cd ..

# stop and remove image in case this script was run before
# docker stop ${APP_NAME}
# docker rm ${APP_NAME}

# rebuild and run the new image
docker build -t ${IMAGE_NAME} ./lab4

echo pwd 
# APPLY(?) K8 NAMESPACE
#kubectl create -f ./lab3/infra/namespace.yaml --namespace=w255
kubectl apply -f ./lab4/infra/namespace.yaml --namespace=w255
kubectl config set-context --current --namespace=w255

# APPLY DEPLOYMENTS AND SERVICES
kubectl apply -f ./lab4/infra/deployment-redis.yaml
kubectl apply -f ./lab4/infra/deployment-pythonapi.yaml
kubectl apply -f ./lab4/infra/service-redis.yaml
kubectl apply -f ./lab4/infra/service-prediction.yaml

# Need to wait to allow pod to start running
echo "Wait for pods to be ready"
kubectl wait pod --all --for=condition=Ready=true --timeout=300s

# PORT-FORWARD A LOCAL PORT ON YOUR MACHINE TO YOUR API SERVICE
kubectl -n w255 port-forward service/prediction-service 8000:8000 &

# From lab 1 solutions: wait for the /health endpoint to return a 200 and then move on
finished=false
while ! $finished; do
    health_status=$(curl -o /dev/null -s -w "%{http_code}\n" -X GET "http://localhost:8000/health")
    if [ $health_status == "200" ]; then
        finished=true
        echo "API is ready"
    else
        echo "API not responding yet"
        sleep 1
    fi
done

# check a few endpoints and their http response
echo "test hello, return status code 200"
curl -o /dev/null -s -w "%{http_code}\n" -X GET "http://localhost:8000/hello?name=Winegar" # 200
echo "test hello, return status code 422"
curl -o /dev/null -s -w "%{http_code}\n" -X GET "http://localhost:8000/hello?nam=Winegar" # 422
echo "test return status code 404"
curl -o /dev/null -s -w "%{http_code}\n" -X GET "http://localhost:8000/" # 404
echo "test docs return status code 200"
curl -o /dev/null -s -w "%{http_code}\n" -X GET "http://localhost:8000/docs" # 200
echo "test predict, return prediction"
curl -X 'POST' \
    'http://localhost:8000/predict' \
    -H 'accept: application/json' \
    -H 'Content-Type: application/json' \
    -d '{ "houses": [
        {"MedInc": 8.3252,
        "HouseAge": 41.0,
        "AveRooms": 6.98412698,
        "Population": 322.0,
        "AveOccup": 2.55555556,
        "Latitude": 37.88,
        "Longitude": -122.23}
        ,
        {"MedInc": 5,
        "HouseAge": 81.0,
        "AveRooms": 4,
        "Population": 200.0,
        "AveOccup": 2.55555556,
        "Latitude": 80.88,
        "Longitude": -100.23}
        ]
    }'

echo ""
echo "test health, return status code 200"
curl -o /dev/null -s -w "%{http_code}\n" -X GET "http://localhost:8000/health"

echo "Stopping app"
# find the PID of app on port 8000 and kill it
# https://medium.com/@valgaze/utility-post-whats-running-on-port-8000-and-how-to-stop-it-2ed771fbb422
kill -9 $(lsof -i TCP:8000 | grep LISTEN | awk '{print $2}')

echo "Clean up and stop minikube"
# CLEAN UP MINIKUBE: DELETE ALL RESOURCES IN W255, DELETE W255 NAMESPACE, STOP MINIKUBE
kubectl delete -f ./lab4/infra
minikube stop
#minikube delete