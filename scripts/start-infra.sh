#!/usr/bin/env bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

log()    { echo -e "${CYAN}[INFO]${NC}  $*"; }
ok()     { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()   { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error()  { echo -e "${RED}[ERROR]${NC} $*" >&2; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"
log "Diretório do projeto: $PROJECT_ROOT"

COMPOSE_CMD=""

if command -v docker &>/dev/null; then
    if docker info &>/dev/null 2>&1; then
        ok "Docker está em execução."
        COMPOSE_CMD="docker compose"
    else
        warn "Docker encontrado mas não está em execução. Tentando Podman..."
    fi
fi

if [[ -z "$COMPOSE_CMD" ]] && command -v podman &>/dev/null; then
    if podman info &>/dev/null 2>&1; then
        ok "Podman está em execução."
        COMPOSE_CMD="podman compose"
    fi
fi

if [[ -z "$COMPOSE_CMD" ]]; then
    error "Nem Docker nem Podman estão disponíveis ou em execução. Instale/inicie um deles antes de continuar."
fi

log "Verificando containers em execução..."

RUNNING=$($COMPOSE_CMD ps --services --filter status=running 2>/dev/null | wc -l)
if [[ "$RUNNING" -gt 0 ]]; then
    warn "Alguns containers já estão ativos:"
    $COMPOSE_CMD ps
    echo ""
    read -rp "$(echo -e "${YELLOW}Deseja reiniciar a infraestrutura? [s/N]:${NC} ")" ANSWER
    ANSWER="${ANSWER:-N}"
    if [[ "$ANSWER" =~ ^[sS]$ ]]; then
        log "Derrubando containers existentes..."
        $COMPOSE_CMD down
    else
        log "Mantendo containers existentes. Encerrando."
        exit 0
    fi
fi

log "Iniciando a infraestrutura com: $COMPOSE_CMD up -d"
$COMPOSE_CMD up -d

echo ""
log "Status dos containers:"
$COMPOSE_CMD ps

echo ""
ok "Infraestrutura iniciada com sucesso!"
echo -e "  ${CYAN}Aplicação:${NC}  http://localhost"
echo -e "  ${CYAN}Prometheus:${NC} http://localhost:9090"
echo -e "  ${CYAN}Grafana:${NC}    http://localhost:3000  (admin / admin)"
