# script.ps1 - Windows Startup Script
Write-Host "[INFO]  Project directory: $((Get-Item .).FullName)" -ForegroundColor Cyan

# 1. Check if Docker is available
try {
    $dockerInfo = docker info 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK]    Docker is running." -ForegroundColor Green
    } else {
        Write-Host "[ERROR] Docker is not running. Please start Docker Desktop." -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "[ERROR] Docker command not found. Is Docker installed?" -ForegroundColor Red
    exit 1
}

# 2. Check running containers
Write-Host "[INFO]  Checking running containers..." -ForegroundColor Cyan
$running = (docker compose ps --services --filter status=running).Count
if ($running -gt 0) {
    Write-Host "[WARN]  Some containers are already active:" -ForegroundColor Yellow
    docker compose ps
    Write-Host ""
    
    $answer = Read-Host -Prompt "Do you want to restart the infrastructure? [y/N]"
    if ($answer -match "^[yYsS]$") {
        Write-Host "[INFO]  Taking down existing containers..." -ForegroundColor Cyan
        docker compose down
    } else {
        Write-Host "[INFO]  Keeping existing containers. Exiting." -ForegroundColor Cyan
        exit 0
    }
}

# 3. Start infrastructure
Write-Host "[INFO]  Starting infrastructure with: docker compose up -d" -ForegroundColor Cyan
docker compose up -d

# 4. Display status
Write-Host ""
Write-Host "[INFO]  Container status:" -ForegroundColor Cyan
docker compose ps

Write-Host ""
Write-Host "[OK]    Infrastructure started successfully!" -ForegroundColor Green
Write-Host "  Application:  http://localhost"
Write-Host "  Prometheus:   http://localhost/prometheus/"
Write-Host "  Grafana:      http://localhost/grafana/  (admin / admin)"
