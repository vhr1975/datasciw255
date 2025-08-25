# python -m uvicorn main:app --reload --port 8500 

from typing import Union

from fastapi import FastAPI, Query, HTTPException

app = FastAPI()

@app.get("/", status_code=501)
async def root():
    return {"message": "not implemented"}

@app.get("/hello/",  status_code=200)
def read_item(name: str =  Query(default=..., title="Naeme parameter", description="Name string parameter")):
    results = {"hello": name}
    if name: 
        results.update({"hello": name})
        return results
    else :
        raise HTTPException(
            status_code = 400, detail=  "string {name} required"
        )
