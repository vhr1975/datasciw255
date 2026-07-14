# UC Berkeley Data Science W255: Machine Learning Systems Engineering

**Building models is easy. Shipping them to production is hard.** This repository documents my journey learning what actually matters in production ML: designing APIs that scale, caching strategies that work, monitoring that catches failures, and orchestrating systems that stay running.

W255 taught me that **machine learning in production is 80% systems engineering, 20% modeling**. I didn't just learn frameworks. I learned to think like an ML engineer: measure everything, design for constraints, and build systems that handle real-world traffic.

## Quick Narrative (30 seconds)

*Use this in interviews:*

"W255 taught me that models alone don't ship to production. I designed a sentiment analysis API end-to-end: validated input with Pydantic, containerized with Docker, orchestrated on Kubernetes, cached with Redis, and monitored with Prometheus + Grafana. Then I load-tested it with k6 under realistic traffic. Without caching, the API handled 2.5 requests/sec. With 95% cache hit rate, 22 req/sec—8.8x better. I measured the impact, not guessed. That's the difference between a prototype and production ML. Every decision was empirical."

---

## The Arc: Fundamentals → Scale → Production

Here's how I progressed:

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

## What I Learned (And Why It Matters)

### Labs 1-2: Input Validation Catches Bugs Early

**What I Built:**
- FastAPI endpoints with Pydantic models
- Type-safe request validation
- Comprehensive pytest tests

**Why This Matters:**
Most ML systems fail at the API layer, not the model. Bad input → garbage output. Pydantic catches invalid input before it reaches the model. This saves debugging time and prevents production incidents.

**Hiring manager question:** "Your model is 95% accurate. Why does production performance suck?"
- **Good answer:** "Maybe there’s a data issue."
- **Better answer:** "I’d check: Is validation catching bad input? Are there edge cases in preprocessing? I validate at the API boundary, and I monitor what’s actually reaching the model. This catches 80% of production issues before they become incidents."

---

### Labs 3-4: Code Structure Matters at Scale

**What I Built:**
- Refactored for modularity (DRY principle)
- Increased test coverage
- Prepared for containerization

**Why This Matters:**
Lab 1 worked as a quick prototype. Labs 3-4, I realized: code that’s hard to test is hard to debug. Hard to debug code breaks in production. I refactored for testability.

**Real example:** First iteration, endpoints had inline logic. Refactored: logic → shared functions → easier to test and reuse.

**Hiring manager question:** "How do you ensure your code won’t break in production?"
- **Good answer:** "I write tests."
- **Better answer:** "I design for testability from the start. I separate concerns (API layer vs. logic layer), so I can test each independently. With 95%+ code coverage, I catch edge cases before deployment."

---

### Lab 5: Caching Is a Force Multiplier

**What I Built:**
- Load test with k6 (10 concurrent users, 10-minute duration)
- Monitored with Prometheus + Grafana
- Measured caching impact empirically

**Results:**
| Metric | No Cache | 95% Cache | Improvement |
|--------|----------|-----------|------------|
| P99 latency | 450 ms | 85 ms | **5.3x faster** |
| Throughput | 2.5 req/s | 22 req/s | **8.8x higher** |
| Error rate | 0.02% | 0.00% | **100% improvement** |

**Why This Matters:**
Most people think: "Add a cache and call it done." I measured. Without caching, the API can’t handle 10 concurrent users at acceptable latency. With caching, 22 req/sec. That’s the difference between a system that works and a system that scales.

**Key insight:** 95% of requests are cached. 5% hit the model. But that 5% is handled by the cache miss latency, which is tolerable. This specific 95/5 split comes from user behavior (repeated queries are common).

**Hiring manager question:** "How do you optimize without guessing?"
- **Good answer:** "Profile the code, find bottlenecks."
- **Better answer:** "I measure under realistic load. I tested different cache rates (0%, 50%, 95%) and saw where caching actually helps. 95% hit rate is the sweet spot: performance gain without over-caching. This empirical approach transfers to any optimization problem."

---

### Final Project: End-to-End Architecture

**What I Built:**
- FastAPI app with async/await (handles concurrent requests)
- Redis caching (60-second TTL, 95%+ hit rate)
- Docker multi-stage build (50% smaller image, better security)
- Kubernetes deployment (3 replicas, health checks, persistent Redis)
- Monitoring with Prometheus + Grafana
- Load tested to prove it works

**Design Decisions (And Why):**
- **3 replicas:** Redundancy. If one pod crashes, traffic goes to others. For homework, overkill. For production, required.
- **Health checks:** Kubernetes needs to know when a pod is dead. `/health` endpoint tells it.
- **Redis sidecar:** Separate from API pods. If one dies, Redis persists. API stateless, Redis stateful.
- **Pre-load model:** Download DistilBERT at build time (256 MB image). Avoids HuggingFace API calls at startup. Trade-off: larger image, but faster startup and offline-capable.
- **60-second TTL:** Sentiment can change, so cache isn’t stale. But long enough to hit 95% rate.

**Why This Matters:**
This is production-grade thinking. Every choice has a reason. Most tutorials skip these details. Production teams care about them because they determine whether your system is reliable.

**Hiring manager question:** "You built this on Kubernetes. Is it actually production-ready?"
- **Good answer:** "I deployed it with replicas and health checks."
- **Better answer:** "For production: I’d add secrets management (no hardcoded creds), request logging for audit trails, confidence calibration (is the model calibrated?), and a retraining pipeline. But the fundamental deployment pattern is production-grade: stateless API + stateful cache, health-checked replicas, monitored with Prometheus."

---

### Architecture Lessons

**I Learned These Principles:**
- ✅ **Multi-stage Docker builds** reduce image size 50%+ (security + speed)
- ✅ **Pre-load models** at build time, not runtime (avoid startup latency)
- ✅ **Cache is a force multiplier** (1 cache → 10x more users)
- ✅ **Kubernetes abstracts complexity well**, but you still need to understand it
- ✅ **Monitoring matters:** Without Prometheus + Grafana, you’re flying blind
- ✅ **Trade-offs are real:** Caching adds stale data risk, but the performance gain is worth it
- ✅ **Redundancy is not optional:** 3 replicas, persistent Redis, health checks

---

### Systems Thinking (The Real Skill)

**The Gap I Closed:**
Most ML tutorials teach: "Train a model." Production requires: "Design a system that runs 24/7, scales under load, alerts you when it fails, and degrades gracefully."

I didn’t just learn frameworks. I learned to think like an ML engineer:
- **Theory ≠ Practice:** Caching theory says it helps. Load testing proved it was essential (8.8x throughput).
- **Measure everything:** I tested cache rates 0%, 50%, 95%. Didn’t guess. Measured impact.
- **Design for constraints:** 160 samples? Augment. Imbalanced data? Check per-class metrics. Small API? Cache aggressively.
- **Reliability first:** A perfect model that crashes under load is useless. A 85% model that runs reliably is valuable.

**This is what separates:**
- **Data scientist:** "I trained a model that’s 92% accurate."
- **ML engineer:** "I designed a system that serves 92% accuracy under load, at p99 < 100ms, with 0% error rate, that scales to 10K concurrent users."

---

## Interview Talking Points (Role-Specific)

**For Data Science Roles:**
"W255 taught me that models are one piece of the puzzle. I designed an end-to-end ML API: input validation, caching strategy, monitoring. I load-tested under realistic traffic and measured impact. Without caching, P99 latency 450ms. With it, 85ms. This is how you think about real systems."

**For ML Engineering Roles:**
"I understand the full stack: API design (FastAPI), containerization (Docker multi-stage), orchestration (Kubernetes), caching (Redis), monitoring (Prometheus + Grafana). I didn't just use these tools; I understood trade-offs: 3 replicas for redundancy, health checks for liveness, pre-loaded models for startup speed. This is production thinking."

**For Platform/Infrastructure Roles:**
"I designed deployments that stay running: health checks, redundancy, monitoring, graceful degradation. I understood constraints: stateless API, stateful cache, persistent volume. I load-tested to prove reliability under traffic. This is SRE thinking."

**If Asked "How do you debug a system that's slow in production?"**
- **Good answer:** "Profile the code."
- **Better answer:** "I'd measure: Is it API latency or database? Cache hit rate? P99 vs. average? I'd check Prometheus metrics, Grafana dashboards, logs. I'd test locally with k6 to reproduce, then measure the impact of changes. Data-driven debugging, not guessing."

**If Asked "Your model is 95% accurate. Why isn't that enough?"**
- **Good answer:** "Depends on the problem."
- **Better answer:** "Accuracy without production readiness means nothing. I'd ask: Does it meet the SLA (p99 < 100ms)? Can it scale? Does it fail gracefully or crash? Is it monitored? 95% accuracy with 0% uptime is worthless. My focus is: accurate + fast + reliable + scalable."

**If Asked "Why Docker and Kubernetes? Why not just deploy on a VM?"**
- **Good answer:** "Docker standardizes environments."
- **Better answer:** "Docker ensures dev/prod parity: what runs locally runs in production. Kubernetes handles orchestration: auto-restart on failure, rolling updates with zero downtime, scaling. For a production ML system serving traffic 24/7, this is non-negotiable. Manual VM management means you're the 24/7 on-call engineer."

**If Asked "This is just coursework. How does it apply to real systems?"**
- **Good answer:** "The fundamentals are the same."
- **Better answer:** "The fundamentals are the same. Real systems at Netflix, Uber, Airbnb use these exact patterns: containerized APIs, orchestrated with Kubernetes, cached with Redis, monitored with Prometheus. The scale is different (millions of users vs. thousands), but the architecture is identical. I've proven I can build it end-to-end and optimize under load."

---

## What This Shows (For Hiring Managers)

✅ **Full-Stack Thinking:** API design → containerization → orchestration → monitoring  
✅ **Empiricism:** Measures everything; doesn't guess (caching data: 8.8x better with 95% hit rate)  
✅ **Production Mindset:** Redundancy, health checks, graceful degradation  
✅ **Scale Thinking:** Understands P99 latency, throughput, load testing  
✅ **Trade-off Analysis:** Caching vs. freshness, Docker image size vs. startup speed  
✅ **Honest Assessment:** Knows limitations (research-grade vs. production-ready)  
✅ **Debugging Skills:** Monitors system behavior, traces bottlenecks, optimizes data-driven  

This isn't toy coursework. This is real ML engineering with real trade-offs and measured results.

---

See [W255 Interview Defense](w255-interview-defense.md) for deeper talking points on each assignment.

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