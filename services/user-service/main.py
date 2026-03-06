from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Optional
import os
from datetime import datetime

app = FastAPI(title="User Service", version="1.0.0")

# In-memory store (in production this would be a real database)
users_db = {
    1: {"id": 1, "name": "John Doe", "email": "john@example.com", "created_at": "2024-01-01"},
    2: {"id": 2, "name": "Jane Smith", "email": "jane@example.com", "created_at": "2024-01-02"},
}

class User(BaseModel):
    name: str
    email: str

class UserResponse(BaseModel):
    id: int
    name: str
    email: str
    created_at: str

@app.get("/health")
def health_check():
    return {
        "status": "healthy",
        "service": "user-service",
        "timestamp": datetime.utcnow().isoformat()
    }

@app.get("/users")
def get_users():
    return {"users": list(users_db.values()), "total": len(users_db)}

@app.get("/users/{user_id}")
def get_user(user_id: int):
    if user_id not in users_db:
        raise HTTPException(status_code=404, detail="User not found")
    return users_db[user_id]

@app.post("/users", status_code=201)
def create_user(user: User):
    new_id = max(users_db.keys()) + 1
    new_user = {
        "id": new_id,
        "name": user.name,
        "email": user.email,
        "created_at": datetime.utcnow().strftime("%Y-%m-%d")
    }
    users_db[new_id] = new_user
    return new_user

@app.delete("/users/{user_id}")
def delete_user(user_id: int):
    if user_id not in users_db:
        raise HTTPException(status_code=404, detail="User not found")
    del users_db[user_id]
    return {"message": f"User {user_id} deleted"}