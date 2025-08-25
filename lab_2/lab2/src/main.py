# python -m uvicorn main:app --reload --port 8500 

from typing import Union
from fastapi import FastAPI, Query, HTTPException
from pydantic import BaseModel, validator, constr
import datetime
import numpy as np
import joblib

# Your values should be "typed" to be reasonable for the values. Check the documentation on the dataset as your reference point.
# The names that you use for the data values are important and should be semantically sensible for both the input model and the 
# output model (i.e. Do not use x as a variable name)

# model for data inputs
# MedInc, HouseAge, AveRooms, AveBedrms, Population, AveOccup, Latitude, and Longitude. All specified as a float.
class PredictionInput(BaseModel):
    MedInc: float
    HouseAge: float
    AveRooms: float
    AveBedrms: float
    Population: float
    AveOccup: float
    Latitude: float
    Longitude: float    
    
    @validator('MedInc')
    def validate_MedInc(cls, v):
        if v <= 0:
            raise ValueError("MedInc must be greater than 0")
        return v
 
# pydantic model for data output
class PredictionOutput(BaseModel):
    prediction: float   
    
app = FastAPI()

model = joblib.load("model_pipeline.pkl")

@app.get("/", status_code=501)
async def root():
    return {"message": "not implemented"}

@app.get("/hello/",  status_code=200)
def read_item(name: str =  Query(default=..., title="Name parameter", description="Name string parameter")):
    results = {"hello": name}
    if name:         
        return results
    else :
        raise HTTPException(
            status_code = 400, detail=  "string {name} required"
        )
        
@app.post("/predict", response_model = PredictionOutput)
async def predict(data: PredictionInput) -> PredictionOutput:      
    y_pred = model.predict([list(data.dict().values())])
        
    # Return the prediction results
    return PredictionOutput(prediction=y_pred[0])
    

@app.get("/health/",  status_code=200)
def health():
    current_time = datetime.datetime.now().isoformat()
    return {"current_time": current_time}