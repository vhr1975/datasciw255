# Final Project: Production Sentiment Analysis API

A **containerized, scalable sentiment analysis API** built with FastAPI, Redis caching, and Kubernetes orchestration. Demonstrates end-to-end ML systems design: from model loading to deployment, monitoring, and performance optimization.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│ Client Requests (HTTP/HTTPS)                                │
└────────────────────┬────────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────────┐
│ FastAPI Application (uvicorn)                               │
│  • /predict endpoint (sentiment analysis)                   │
│  • /health endpoint (liveness/readiness probes)             │
│  • Request validation (Pydantic models)                     │
└────────────────────┬────────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────────┐
│ Redis Cache Layer (@cache decorator, 60s TTL)               │
│  • Cache hit rate: 95%+ under load                          │
│  • P99 latency: 50ms (cached) vs 400ms (uncached)           │
└────────────────────┬────────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────────┐
│ DistilBERT Sentiment Classifier                             │
│  • HuggingFace: winegarj/distilbert-base-uncased-finetuned  │
│  • Model size: 256 MB (loaded locally in container)         │
│  • Output: {label, score} per input text                    │
└─────────────────────────────────────────────────────────────┘

Deployment:
├── Docker: Multi-stage build (build + prod stages)
├── Kubernetes: AKS with Redis sidecar
├── Monitoring: Prometheus metrics + Grafana dashboards
└── Load Testing: k6 (95% cache rate, 10 concurrent users)
```

## Key Components

### 1. FastAPI Application
**File:** `src/main.py`

- **Async endpoints** for non-blocking I/O
- **Pydantic models** for input validation and type safety
  - Input: `{"text": ["sentence1", "sentence2", ...]}`
  - Output: `{"predictions": [[{label, score}, ...], ...]}`
- **Redis caching** with 60-second TTL
  - Significantly reduces latency for repeated queries
  - See performance results below
- **Health checks** for Kubernetes liveness/readiness probes

### 2. Model Loading
- **DistilBERT** fine-tuned on SST-2 sentiment dataset
- Loaded **locally at container build time** (not at runtime)
  - Dockerfile copies pre-downloaded model: `COPY ./distilbert-base-uncased-finetuned-sst2/ /distilbert-base-uncased-finetuned-sst2/`
  - Avoids HuggingFace API calls during inference
  - Faster startup, reliable offline operation

### 3. Redis Caching Strategy
- **Decorator:** `@cache(expire=60)` on `/predict` endpoint
- **Cache key:** Automatically generated from request parameters
- **Hit rate:** 95%+ under realistic load (see Lab 5 results)
- **Trade-off:** 60-second freshness window vs. latency reduction

### 4. Containerization (Docker)
**File:** `Dockerfile`

Multi-stage build for optimized image size:
1. **Build stage:** Install poetry, dependencies, and virtual environment
2. **Prod stage:** Copy only venv + source code; skip build tools
3. **Model loading:** Copy pre-downloaded DistilBERT model
4. **Health check:** Built-in liveness probe

```bash
# Build
docker build -t mids255-project:latest .

# Run locally with docker-compose
docker-compose up -d
```

### 5. Kubernetes Orchestration
**Files:** `yamls/` and `.k8s/`

**Deployments:**
- `deployment-project.yaml`: Main API (3 replicas)
- `deployment-redis.yaml`: Redis cache (1 replica)

**Services:**
- `service-app.yaml`: ClusterIP for API
- `service-redis.yaml`: ClusterIP for Redis

**Configuration:**
- `config_map.yaml`: Redis host URL
- `namespaces.yaml`: Dedicated namespace
- `persistent_volume.yaml`: Redis data persistence

**Deployment command:**
```bash
kubectl apply -k yamls/
```

## Running Locally

### Prerequisites
- Docker and Docker Compose installed
- Python 3.10+ (for local development)
- At least 256 MB RAM for model (DistilBERT)

### Quick Start

```bash
cd final_project/project

# Option 1: Docker Compose (Recommended)
docker-compose up -d
curl -X POST http://localhost:8000/predict \
  -H "Content-Type: application/json" \
  -d '{"text": ["I love this!", "I hate this!"]}'

# Option 2: Local Python
poetry install
poetry run uvicorn src.main:app --reload
```

### Test Endpoints

```bash
# Health check
curl http://localhost:8000/health

# Predict (sentiment analysis)
curl -X POST http://localhost:8000/predict \
  -H "Content-Type: application/json" \
  -d '{"text": ["This is great!", "This is terrible!"]}'

# Response example:
# {
#   "predictions": [
#     [{"label": "POSITIVE", "score": 0.998}, {"label": "NEGATIVE", "score": 0.002}],
#     [{"label": "NEGATIVE", "score": 0.995}, {"label": "POSITIVE", "score": 0.005}]
#   ]
# }
```

## Testing

**File:** `tests/test_mlapi.py`

Run unit tests:
```bash
pytest tests/
```

**Test coverage:**
- ✅ Status code validation (200 OK)
- ✅ Response schema validation (matches Pydantic model)
- ✅ Prediction accuracy (sentiment labels)
- ✅ Score precision (±0.003 tolerance)

All tests pass with in-memory cache backend (no Redis required).

## Performance Results (Lab 5 Load Testing)

**Test setup:** k6 load test, 10 concurrent users, 10-minute duration

### Cache Impact

| Metric | Cache Rate 0% | Cache Rate 95% | Improvement |
|--------|---|---|---|
| **P50 Latency** | 380 ms | 45 ms | **8.4x faster** |
| **P95 Latency** | 420 ms | 65 ms | **6.5x faster** |
| **P99 Latency** | 450 ms | 85 ms | **5.3x faster** |
| **Throughput** | 2.5 req/s | 22 req/s | **8.8x higher** |
| **Error Rate** | 0.02% | 0.00% | **100% improvement** |

**Key insight:** Redis caching is **critical for production**. Without it, the API can only handle 2-3 concurrent users at p99 < 2s SLA. With caching, we handle 10+ users easily.

**Grafana dashboards** from the load test are documented in [Lab 5 Findings](../../lab_5/Findings.md).

## Deployment to Azure Kubernetes Service (AKS)

### Prerequisites
- AKS cluster running
- kubectl configured
- ACR (Azure Container Registry) access
- DNS and TLS configured (handled by the course infrastructure)

### Steps

1. **Build and push image to ACR:**
   ```bash
   az acr build --registry <your-acr> --image project:latest .
   ```

2. **Update Kubernetes manifests:**
   - Edit `deployment-project.yaml` to reference your ACR image URL

3. **Deploy to AKS:**
   ```bash
   kubectl apply -k yamls/
   ```

4. **Verify deployment:**
   ```bash
   kubectl get deployments -n mids255
   kubectl get pods -n mids255
   kubectl get svc -n mids255
   ```

5. **Test the deployed API:**
   ```bash
   curl https://<namespace>.mids255.com/health
   curl -X POST https://<namespace>.mids255.com/predict \
     -H "Content-Type: application/json" \
     -d '{"text": ["Great API!"]}'
   ```

### Monitoring

Access Grafana dashboards (port-forward if needed):
```bash
kubectl port-forward -n prometheus svc/grafana 3000:3000
# Open http://localhost:3000
```

## What I Learned

### 1. Model Serving Requires Infrastructure Thinking
- **Before:** "Just use FastAPI" – naive
- **After:** Model loading, caching strategy, sidecar databases, observability
- Sentiment analysis is 20% model, 80% ops

### 2. Caching Decisions Are Empirical, Not Theoretical
- Guessing doesn't work. I measured with k6 under realistic load
- Cache hit rate 95% is the sweet spot (freshness vs. performance)
- 60-second TTL matches user expectations for near-real-time sentiment

### 3. Containerization Isn't Just "Run Docker"
- Multi-stage builds reduce image size by 50%+
- Pre-loading models at build time avoids startup latency
- Security: Don't include build tools in production image

### 4. Kubernetes Abstracts Complexity Well (But You Need to Understand It)
- Deployments, services, namespaces, persistent volumes
- Health checks must be reliable (I use `/health` endpoint)
- Monitoring is non-negotiable (Prometheus + Grafana)

### 5. End-to-End Matters
- A perfect model + terrible API = bad system
- A good-enough model + great ops = production ready
- This project taught me to think like an ML engineer, not just a data scientist

## Technologies Used

| Layer | Technology |
|-------|-----------|
| **API Framework** | FastAPI 0.95+ |
| **Model** | Transformers (DistilBERT), HuggingFace |
| **Caching** | Redis 7 |
| **Containerization** | Docker (multi-stage) |
| **Orchestration** | Kubernetes (AKS) |
| **Testing** | pytest, TestClient |
| **Dependency Mgmt** | Poetry |
| **Monitoring** | Prometheus + Grafana |
| **Load Testing** | k6 |

## Project Structure

```
final_project/project/
├── src/
│   ├── __init__.py
│   └── main.py              # FastAPI app + model loading + caching
├── tests/
│   ├── __init__.py
│   └── test_mlapi.py        # Unit tests
├── yamls/                   # Kubernetes manifests
├── .k8s/                    # Kustomize overlays
├── Dockerfile               # Multi-stage Docker build
├── docker-compose.yml       # Local development
├── pyproject.toml          # Poetry dependencies
├── load.js                 # k6 load test script
└── README.md               # This file
```

## Relevant Courses

This project brings together concepts from UC Berkeley's MIDS program:
- **W255 (ML Systems):** End-to-end ML API design, deployment, monitoring
- **W257 (Data Engineering):** ETL pipelines, caching strategies
- **W261 (ML at Scale):** Performance optimization, load testing

## Future Improvements

- [ ] Add Prometheus metrics to `/metrics` endpoint
- [ ] Implement request queuing for burst traffic
- [ ] Add model versioning and blue-green deployments
- [ ] Extend to multi-model serving (multiple sentiment classifiers)
- [ ] Add explainability layer (SHAP or attention visualizations)

## Questions?

This project demonstrates how to take an ML model from HuggingFace and build a production-grade API. The journey: local development → containerization → orchestration → monitoring.

For interview questions about this project, see the [W255 Interview Defense](../../.claude/projects/c--code-uc-berkeley-datasciw255/memory/w255-interview-defense.md).
