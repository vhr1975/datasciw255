# Lab1 Assignment 

In lab1, I created a FastAPI web framework application, with several endpoints that perform different tasks. The application is designed to be easily extensible, so additional endpoints and features can be added as needed.

## Build API

To build the application, I used Poetry to manage my package dependencies. Poetry is a dependency management tool for Python projects, it creates and manages virtual environments and also stores all the package dependencies in a file called pyproject.toml

## Run API

To run the application, I used a bash script called run.sh that automates the process. The script first sets up the virtual environment and installs the necessary dependencies, and then runs the FastAPI application. The script also allows me to easily specify the host and port on which the application should run. To run the application, you will need to have Docker installed on your machine.

## Test API

To test the application, I used Pytest, a popular testing framework for Python. Pytest allows me to write unit tests for each endpoint in the application, which helps to ensure that the application is working correctly. To run the tests, you can use the command pytest in the application's root directory.

## Containerize API

I containerized the API application using Docker, which allowed me to easily deploy the application in a variety of environments. I also created a run.sh bash script that automates all the steps, from setting up the dependencies to running the API application. This script is useful for quickly and easily reproducing the lab1 work or deploying the API in different environment.

# Summary 

In summary, in lab1 I created a machine learning application using FastAPI, managed my package dependencies with Poetry, containerized the application with Docker, and wrote unit tests for the application using Pytest. The application can be built, run, and tested using the provided run.sh script and pytest command, respectively.

## Questions

1 What status code should be raised when a query parameter does not match our expectations? 

* When a query parameter does not match our expectations, it's common to raise a HTTP 400 Bad Request status code. This indicates to the client that their request was invalid and could not be processed as it was missing or incorrect parameter. 

2 What does Python Poetry handle for us? 

Python Poetry is a dependency management tool for Python projects. It handles the following for us: 
* Creating and managing virtual environments 
* Installing and managing package dependencies 
* Storing all package dependencies in a file called pyproject.toml 
* Providing a simple command line interface for managing dependencies 

3 What advantages do multi-stage docker builds give us? 

* Reduced size of the final image: By only copying the necessary files from previous stages, the final image can be significantly smaller in size.
* Improved security: By not including unnecessary files in the final image, the attack surface of the container is reduced.
* Better caching: When building an image, Docker can cache the results of each build step. With multi-stage builds, you can take advantage of this caching to speed up the build process. 
* Separation of concerns: Multi-stage builds allow you to separate the build process from the runtime process, making it easier to understand and maintain the application. 
