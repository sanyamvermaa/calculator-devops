#!/usr/bin/env bash
# Pre-demo smoke check. Run ~10 minutes before the live demo.
set -e

GITHUB_USER="sanyamvermaa"
DOCKERHUB_USER="sanyamvermaa"

echo "=== 1. docker daemon ==="
docker info > /dev/null && echo OK

echo "=== 2. jenkins up ==="
curl -fsSI http://localhost:8080 > /dev/null && echo OK

echo "=== 3. ngrok tunnel ==="
curl -s http://localhost:4040/api/tunnels | grep -o 'https://[^"]*ngrok[^"]*' | head -1

echo "=== 4. compose stack healthy ==="
docker compose ps
curl -fsS http://localhost/actuator/health && echo "" && echo OK

echo "=== 5. API responds through nginx ==="
curl -fsS 'http://localhost/api/v1/add?a=2&b=3' && echo "" && echo OK

echo "=== 6. GitHub repo reachable ==="
curl -fsSI "https://github.com/${GITHUB_USER}/calculator-devops" > /dev/null && echo OK

echo "=== 7. Docker Hub repo exists ==="
curl -fsSI "https://hub.docker.com/r/${DOCKERHUB_USER}/calculator-devops" > /dev/null && echo OK

echo "" && echo "All preflight checks passed — ready to demo."
