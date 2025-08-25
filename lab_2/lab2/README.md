# README

## Documentation

1. What this application does
   - runs a simple `FastAPI` API with uvicorn as the async webworker
   - The API has endpoints for returning `hello {NAME}` and healthchecking
   - The API has endpoints that predicts the median house value for a given set of features based on the California Housing dataset.
2. How to build your application
   - `docker build -t lab_2 .`
3. How to run your application
   - `./run.sh`
4. How to test your application
   - `poetry run pytest`

## Q&A

 1. What does Pydantic handle for us?
    - Pydantic handles validation and parsing of data, and ensures that data is of the correct type and structure, based on the defined Pydantic models. 
 2. What do GitHub Actiosn do?
    - GitHub Actions, can build, test, and deploy your code right from your repository. It allows you to create custom workflows that can be triggered based on events like push, pull requests, or on a schedule.
 3. Describe the Sequence Diagram
    - The Sequence Diagram shows how data flows between a user input, an API, and a machine learning model. It shows that the user sending a JSON payload to the API, the API checks if the input meets the requirements with Pydantic. If the input does not meet the requirements, an error message is sent. If it does, the API sends the input to the model, which processes the data and returns the ML model output. The output is then returned as a data model to the user.
