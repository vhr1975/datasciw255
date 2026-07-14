# UC Berkeley Data Science W255: Machine Learning Systems Engineering

**Production ML systems from scratch.** This repository documents my journey building, deploying, and monitoring a complete ML API: from FastAPI skeleton to Kubernetes orchestration to live performance monitoring.

## The Arc: Fundamentals → Scale → Production

W255 taught me that machine learning in production is **80% systems engineering, 20% modeling**. The progression:

### **Labs 1-2: Build an API**
- Design RESTful endpoints with FastAPI
- Validate input with Pydantic (catches bugs early)
- Manage dependencies reproducibly with Poetry
- Write comprehensive tests with pytest

### **Labs 3-4: Modularize & Automate**
- Refactor for maintainability and extensibility
- Increase test coverage (edge cases matter)
- Prepare for containerization

### **Lab 5: Measure Performance Under Load**
- Load test with k6 (ramp from 0 → 10 → 0 users)
- Monitor with Prometheus + Grafana dashboards
- **Key finding:** Caching improves P99 latency 5.3x (450ms → 85ms)

### **Final Project: Ship It**
- Containerize with Docker (multi-stage build)
- Orchestrate with Kubernetes (AKS, replicas, health checks)
- Serve a production sentiment analysis model (DistilBERT)
- Prove it works under load with k6 and Grafana

---

## Labs Overview

| Lab | Focus | Key Deliverables |
|-----|-------|-----------------|
| **Lab 1** | API Fundamentals | FastAPI + Poetry + Docker + pytest |
| **Lab 2** | Input Validation | Pydantic models, error handling |
| **Lab 3** | Modularity | Refactored code structure |
| **Lab 4** | Code Quality | Tests, logging, CI/CD foundations |
| **Lab 5** | **Performance** | K6 load tests, Grafana dashboards, caching impact |
| **Final** | **End-to-End** | Full ML pipeline: model → API → K8s → monitoring |

### Lab 1: FastAPI ML Application & Containerization
- Built extensible FastAPI web application with multiple endpoints
- Managed dependencies with Poetry (reproducible builds)
- Containerized with Docker and automated with bash scripts
- Tested with pytest

**Key insight:** Input validation with Pydantic catches bugs before they reach the model.

### Lab 2: ML API with Validation & CI/CD
- Developed California housing prediction API
- Implemented Pydantic input validation
- Explored GitHub Actions for CI/CD
- Wrote comprehensive tests

**Key insight:** Type safety and validation are non-negotiable.

### Lab 3-4: Refactoring & Scale
- Extended API with additional endpoints
- Refactored for modularity (DRY principle)
- Improved test coverage
- Prepared for production deployment

**Key insight:** Code structure matters at scale. Well-organized code is easier to test, debug, and extend.

### Lab 5: Performance Testing & Monitoring ⭐
- **Load tested** the API with k6 under realistic traffic patterns
- **Monitored** with Prometheus metrics + Grafana dashboards
- **Measured** the impact of caching (Redis)
- **Results:** 5.3x latency improvement, 8.8x throughput improvement

**Key insight:** Theory ≠ practice. Measure everything. Cache hit rate 95% transforms a 2.5 req/sec system into a 22 req/sec system.

See [Lab 5 Findings](lab_5/Findings.md) for detailed metrics and Grafana dashboard evidence.

### Final Project: End-to-End ML API
- Sentiment analysis API using DistilBERT from HuggingFace
- Containerized with Docker multi-stage build
- Orchestrated on Azure Kubernetes Service (AKS)
- Cached with Redis (60-second TTL)
- Monitored with Prometheus + Grafana
- Load tested with k6

**Architecture:**
```
Client → FastAPI (async) → Redis Cache (95% hit rate) → DistilBERT Model
         ↓
      Prometheus metrics → Grafana dashboards
```

See [Final Project README](final_project/project/README.md) for complete architecture, setup, and deployment guide.

---

## Key Technologies

| Layer | Technology |
|-------|-----------|
| **API Framework** | FastAPI (async, type hints) |
| **Model** | HuggingFace Transformers (DistilBERT) |
| **Caching** | Redis |
| **Containerization** | Docker (multi-stage build) |
| **Orchestration** | Kubernetes (Azure AKS) |
| **Monitoring** | Prometheus + Grafana |
| **Load Testing** | k6 |
| **Dependency Management** | Poetry |
| **Testing** | pytest |

---

## Performance Highlights

### Without Caching
- P99 latency: 450 ms
- Throughput: 2.5 req/sec
- Error rate: 0.02%

### With Caching (95% hit rate)
- **P99 latency: 85 ms** (5.3x faster ✅)
- **Throughput: 22 req/sec** (8.8x higher ✅)
- **Error rate: 0.00%** (100% reliable ✅)

[See Lab 5 Findings for detailed analysis](lab_5/Findings.md)

---

## Running the Project

### Quick Start (Local Development)

```bash
cd final_project/project

# Option 1: Docker Compose
docker-compose up -d
curl -X POST http://localhost:8000/predict \
  -H "Content-Type: application/json" \
  -d ‘{"text": ["I love this!", "I hate this!"]}’

# Option 2: Local Python
poetry install
poetry run uvicorn src.main:app --reload
```

### Testing

```bash
pytest tests/
```

### Deployment to Kubernetes

```bash
# Build and push to container registry
az acr build --registry <your-acr> --image project:latest .

# Deploy to AKS
kubectl apply -k yamls/
kubectl get pods -n mids255
```

---

## What I Learned

### Technical Skills
- ✅ **API Design:** REST patterns, input validation, error handling
- ✅ **Containerization:** Docker multi-stage builds, optimization for production
- ✅ **Orchestration:** Kubernetes deployments, services, health checks, scaling
- ✅ **Caching:** Redis strategies, trade-offs (freshness vs. performance)
- ✅ **Monitoring:** Prometheus metrics, Grafana dashboards, alerting
- ✅ **Testing:** Unit tests, integration tests, load testing
- ✅ **Performance:** Measured optimization, P99 latency tuning, throughput scaling

### Systems Thinking
- **Production ≠ Research:** A perfect model with terrible ops = bad system
- **Measure, Don’t Guess:** I tested caching empirically under load. Theory said it would help; practice proved it was essential
- **Trade-offs Are Real:** Caching adds stale data risk, but the performance gain is worth it
- **Monitoring Matters:** Without Prometheus + Grafana, you’re flying blind
- **Reliability Requires Redundancy:** 3 API replicas, persistent Redis, health checks

### Architecture Lessons
- Multi-stage Docker builds reduce image size 50%+ (security + speed)
- Pre-load models at build time, not runtime (avoid startup latency)
- Cache is a force multiplier (1 cache → 10x more users)
- Kubernetes abstracts complexity well, but you still need to understand it

---

## Interview Defense

This portfolio demonstrates production ML engineering:
- **Labs 1-2:** "I learned that validation catches bugs early"
- **Labs 3-4:** "I learned that code structure matters at scale"
- **Lab 5:** "I measured caching impact: 5.3x latency improvement, 8.8x throughput. This is data-driven optimization."
- **Final Project:** "End-to-end: I designed, containerized, deployed, and monitored. This is how teams ship ML."

See [W255 Interview Defense](w255-interview-defense.md) for specific talking points.

---

## Project Structure

```
datasciw255/
├── lab_1/              # FastAPI skeleton
├── lab_2/              # Pydantic validation
├── lab_3/              # Refactoring
├── lab_4/              # Code quality
├── lab_5/              # Load testing + Grafana
│   ├── README.md
│   ├── Findings.md     # Detailed performance analysis
│   ├── load.js         # k6 load test script
│   └── images/         # Grafana dashboards
├── final_project/      # Production API
│   ├── project/
│   │   ├── src/main.py       # FastAPI + Redis + Model
│   │   ├── tests/            # Unit tests
│   │   ├── Dockerfile        # Multi-stage build
│   │   ├── docker-compose.yml
│   │   ├── yamls/            # K8s manifests
│   │   └── README.md         # Architecture guide
│   └── trainer/              # Model training (reference)
└── README.md           # This file
```

---

## How to Use This Repository

### For Learning
1. Start with [Lab 1 README](lab_1/README.md) to understand API design
2. Progress through labs 2-4 for testing and modularity
3. Read [Lab 5 Findings](lab_5/Findings.md) for performance insights
4. Study [Final Project README](final_project/project/README.md) for end-to-end architecture

### For Job Interviews
- See [W255 Interview Defense](w255-interview-defense.md) for talking points
- Reference performance metrics from Lab 5
- Walk through the architecture: "I containerized, orchestrated, monitored, and load-tested"

### For Code Examples
- FastAPI patterns: `final_project/project/src/main.py`
- Testing patterns: `final_project/project/tests/test_mlapi.py`
- Docker patterns: `final_project/project/Dockerfile`
- Kubernetes patterns: `final_project/project/yamls/`

---

## Key Takeaways

**W255 is about production ML systems:**
- Model accuracy matters, but **systems engineering matters more**
- You don’t just train models; you **ship them, scale them, monitor them**
- Every decision should be **measured and data-driven**
- **Caching, monitoring, and redundancy are not optional**

The arc from Lab 1 (Hello World API) to Final Project (production sentiment analysis) shows what it takes to ship ML at scale.

---

## Contact

Questions about this portfolio? Refer to the specific lab READMEs or the [Interview Defense guide](w255-interview-defense.md).

---

**Portfolio Status:** ✅ Production-ready. All labs complete, final project deployed, performance validated under load.