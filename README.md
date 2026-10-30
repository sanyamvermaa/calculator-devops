# Calculator DevOps

End-to-end CI/CD pipeline for a Spring Boot Calculator REST API.
CSE 816 Software Production Engineering — Mini-Project (10 marks).

## Features

- Spring Boot 3.3 REST API: `/api/v1/{add,subtract,multiply,divide}`
- Validated inputs; HTTP 400 + structured JSON error for malformed params and divide-by-zero
- JUnit 5 unit tests + Spring MockMvc integration tests (14 tests)
- `/actuator/health` probe
- Multi-stage Dockerfile (JDK/Maven build stage → slim JRE runtime stage)
- Non-root container user (`uid=100(app)`)
- Docker Compose stack: app + nginx reverse proxy on a shared bridge network
- Health-check driven startup (`depends_on: service_healthy`)
- Jenkins declarative pipeline: Checkout → Build → Test → Docker Build → Push → Deploy
- GitHub webhook trigger + email notification on success and failure
- Docker Hub image publishing with a per-build tag

## Quick start (local, via Docker Compose)

```bash
git clone https://github.com/sanyamvermaa/calculator-devops.git
cd calculator-devops
docker compose up -d
curl 'http://localhost/api/v1/add?a=2&b=3'
```

The stack publishes **only port 80** (nginx). The app's 8080 is internal to the
`calc-net` network — nginx is the single entry point.

## Build and test

```bash
./mvnw clean package     # fat jar at target/calculator-devops-1.0.0.jar
./mvnw test              # JUnit 5 tests + JUnit XML in target/surefire-reports/
./mvnw spring-boot:run   # run directly on http://localhost:8080
```

Requires **JDK 21**. If `java -version` shows an older JDK:

```bash
export JAVA_HOME=$(/usr/libexec/java_home -v 21)   # macOS
```

## Endpoints

| Method | Path | Example | Result |
|--------|------|---------|--------|
| GET | `/api/v1/add?a=&b=` | `/api/v1/add?a=2&b=3` | `5` |
| GET | `/api/v1/subtract?a=&b=` | `/api/v1/subtract?a=5&b=2` | `3` |
| GET | `/api/v1/multiply?a=&b=` | `/api/v1/multiply?a=4&b=3` | `12` |
| GET | `/api/v1/divide?a=&b=` | `/api/v1/divide?a=10&b=2` | `5` (`b=0` → HTTP 400) |
| GET | `/actuator/health` | `/actuator/health` | `{"status":"UP",...}` |

### Success response

```json
{"operation":"add","a":2.0,"b":3.0,"result":5.0}
```

### Error response (HTTP 400)

```json
{
  "timestamp": "2026-10-30T13:57:39.025767Z",
  "status": 400,
  "error": "Bad Request",
  "message": "Cannot divide by zero",
  "path": "/api/v1/divide"
}
```

The same shape is returned for a missing parameter
(`Missing required parameter: b`) and a non-numeric parameter
(`Invalid value for parameter 'a': must be a number`).

## Docker

```bash
docker build -t sanyamvermaa/calculator-devops:1.0.0 .
docker run --rm -d -p 8080:8080 --name calc sanyamvermaa/calculator-devops:1.0.0
docker exec calc id     # uid=100(app) — proves the non-root user
docker stop calc
```

## Compose stack

```bash
docker compose up -d                 # start calculator + nginx
docker compose ps                    # calculator should read (healthy)
docker compose logs -f calculator    # follow app logs
docker compose down                  # stop and remove
```

`DOCKER_IMAGE` overrides the image tag, which is how the Jenkins Deploy stage
rolls out the exact build it just pushed:

```bash
DOCKER_IMAGE=sanyamvermaa/calculator-devops:42 docker compose up -d
```

## Pipeline

On every push to `main` the GitHub webhook triggers Jenkins:

1. **Checkout** — `checkout scm`, prints the head commit
2. **Build** — `./mvnw clean package -DskipTests`
3. **Test** — `./mvnw test`; JUnit XML published; a red test fails the build
4. **Docker Build** — tagged `:${BUILD_NUMBER}` and `:latest`
5. **Push** — Docker Hub, credentials read from the Jenkins credentials store (`dockerhub-creds`)
6. **Deploy** — `docker compose up -d`, then polls `/actuator/health` until `UP`

Build status is emailed on success and on failure.

## Repository layout

```
calculator-devops/
├── src/main/java/com/example/calculator/
│   ├── CalculatorApplication.java
│   ├── controller/CalculatorController.java
│   ├── service/CalculatorService.java
│   ├── dto/{CalculationResponse,ApiError}.java
│   └── exception/{DivideByZeroException,GlobalExceptionHandler}.java
├── src/test/java/com/example/calculator/
│   ├── CalculatorServiceTest.java      # 7 unit tests
│   └── CalculatorControllerIT.java     # 7 MockMvc tests
├── Dockerfile                          # multi-stage, non-root
├── docker-compose.yml                  # calculator + nginx on calc-net
├── nginx/nginx.conf                    # reverse proxy
├── Jenkinsfile                         # 6-stage declarative pipeline
├── scripts/preflight.sh                # pre-demo smoke check
└── docs/report.pdf                     # 3-page project report
```

## Links

- GitHub: https://github.com/sanyamvermaa/calculator-devops
- Docker Hub: https://hub.docker.com/r/sanyamvermaa/calculator-devops
- Report (PDF): [docs/report.pdf](docs/report.pdf)
