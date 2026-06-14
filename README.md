<div align="center">
  <h1>
    <img src="https://skillicons.dev/icons?i=nginx,docker,prometheus,grafana" /><br>
    Resilient Web Infrastructure 🇺🇸
  </h1>
  <p>
    <img src="https://img.shields.io/badge/Node.js-20-339933?style=flat&logo=node.js&logoColor=white" />
    <img src="https://img.shields.io/badge/Nginx-alpine-009639?style=flat&logo=nginx&logoColor=white" />
    <img src="https://img.shields.io/badge/PostgreSQL-16-336791?style=flat&logo=postgresql&logoColor=white" />
    <img src="https://img.shields.io/badge/Docker-Compose-2496ED?style=flat&logo=docker&logoColor=white" />
    <img src="https://img.shields.io/badge/Prometheus-enabled-E6522C?style=flat&logo=prometheus&logoColor=white" />
    <img src="https://img.shields.io/badge/Grafana-enabled-F46800?style=flat&logo=grafana&logoColor=white" />
  </p>
</div>

This repository contains a resilient web infrastructure built with Docker Compose, featuring load-balanced Node.js applications behind an Nginx reverse proxy, a PostgreSQL database, and a full observability stack powered by Prometheus and Grafana.

---

## Project Structure

```
resilient-web-infrastructure/
│
├── docker-compose.yml          # Orchestrates all services
├── nginx.conf                  # Nginx reverse proxy + load balancer config
│
├── apps/
│   ├── app1/                   # Node.js application instance 1
│   │   ├── Dockerfile
│   │   ├── server.js           # Express API (auth, books CRUD)
│   │   ├── index.html
│   │   └── package.json
│   └── app2/                   # Node.js application instance 2 (identical)
│       ├── Dockerfile
│       ├── server.js
│       ├── index.html
│       └── package.json
│
├── prometheus/
│   └── prometheus.yml          # Scrape targets configuration
│
├── script.sh                   # Automated startup script (Linux/Mac)
└── script.ps1                  # Automated startup script (Windows)
```

---

## Tech Stack

| Technology | Version | Purpose |
|---|---|---|
| [Node.js](https://nodejs.org/) | 20 (Alpine) | Application runtime |
| [Express](https://expressjs.com/) | — | Web framework |
| [Nginx](https://nginx.org/) | Alpine | Reverse proxy & load balancer |
| [PostgreSQL](https://www.postgresql.org/) | 16 | Relational database |
| [Docker](https://www.docker.com/) | — | Containerisation |
| [Prometheus](https://prometheus.io/) | latest | Metrics collection |
| [Grafana](https://grafana.com/) | latest | Metrics visualisation & dashboards |
| [nginx-prometheus-exporter](https://github.com/nginx/nginx-prometheus-exporter) | 1.1 | Nginx metrics exporter |
| [postgres_exporter](https://github.com/prometheus-community/postgres_exporter) | latest | PostgreSQL metrics exporter |

---

## Architecture Overview

```
Internet
    │
    ▼
 Nginx :80          ← Reverse proxy (round-robin load balancing)
  ├── app1 :80      ← Node.js instance 1
  └── app2 :80      ← Node.js instance 2
         │
         ▼
    PostgreSQL       ← Shared database (livrosdb)

Observability
  ├── Prometheus :9090   ← Scrapes metrics from all services
  │     ├── nginx-exporter :9113
  │     └── postgres-exporter :9187
  └── Grafana :3000      ← Dashboard & visualisation
```

---

## Services & Ports

| Service | Host Port | Description |
|---|---|---|
| nginx | `80` | Entry point — proxies requests to app1/app2 |
| app1 | internal | Node.js instance 1 |
| app2 | internal | Node.js instance 2 |
| postgres | internal | PostgreSQL database |
| prometheus | internal | Metrics scraper |
| grafana | internal | Dashboard UI |
| cadvisor | internal | Container resource metrics |
| nginx-exporter | internal | Exposes nginx metrics to Prometheus |
| postgres-exporter | internal | Exposes PostgreSQL metrics to Prometheus |

---

## Requirements

- **Docker** 24.x or higher
- **Docker Compose** v2 or higher

> That's it. Node.js and PostgreSQL do not need to be installed locally.

---

## How to Run

### <img src="https://skillicons.dev/icons?i=github" height="20" style="vertical-align: middle;" /> 1. Clone the repository

```bash
git clone <repository-url>
cd resilient-web-infrastructure
```

### ▶️ 2. Start using the script (recommended)

```bash
# Linux / macOS
bash script.sh

# Windows (PowerShell)
.\script.ps1
```

The script will:
- ✅ Detect whether Docker or Podman is running
- ✅ Check for already active containers (and offer to restart)
- ✅ Run `docker compose up -d`
- ✅ Display `docker compose ps` with all service statuses

### 🐳 Or start manually

```bash
docker compose up -d
docker compose ps
```

---

## Accessing the Services

| Service | URL | Credentials |
|---|---|---|
| Application | http://localhost | — |
| Prometheus | http://localhost/prometheus/ | — |
| Grafana | http://localhost/grafana/ | `admin` / `admin` |

> On first Grafana login you will be prompted to change the password. You may skip this step.

---

## Testing and Visualising Metrics

### 1. Prometheus Expressions
You can query raw metrics directly in Prometheus. Open **http://localhost/prometheus/**, type an expression in the search bar, and click **Execute** (use the "Graph" tab for a timeline view). 

Try these expressions:
- `nginx_http_requests_total` — Total HTTP requests received by Nginx.
- `nginx_connections_active` — Current active connections in Nginx.
- `pg_stat_database_xact_commit{datname="livrosdb"}` — Total transactions committed in PostgreSQL.

### 2. Setting Up Grafana Dashboards
To view these metrics in beautiful dashboards:

1. Open **http://localhost/grafana/** and log in with `admin` / `admin`
2. Go to **Connections → Data sources → Add data source**
3. Select **Prometheus** and set the URL to `http://prometheus:9090/prometheus`
4. Click **Save & test**
5. Go to **Dashboards → New → Import** and use one of these IDs from the Grafana gallery:
   - **`12708`** — Nginx (Requests, connections, traffic)
   - **`9628`** — PostgreSQL Database (Queries, locks, size)
   - **`1860`** — Node Exporter Full (General system metrics)
6. Select **Prometheus** in the data source dropdown at the bottom and click **Import**.

> **Tip:** Open a new tab and refresh `http://localhost` multiple times (or run `curl http://localhost` in a loop) to generate traffic and see the Nginx graphs move!

---

## Docker Commands

| Command | Description |
|---|---|
| `bash script.sh` | Start using the automated script (Linux/Mac) |
| `.\script.ps1` | Start using the automated script (Windows) |
| `docker compose up -d` | Start all services in background |
| `docker compose up --build -d` | Rebuild images and start |
| `docker compose ps` | Show status of all containers |
| `docker compose down` | Stop and remove containers (data preserved) |
| `docker compose down -v` | Stop and **delete all data** (volumes removed) |
| `docker compose logs -f` | Follow logs from all services |
| `docker compose logs -f nginx` | Follow logs from nginx only |
| `docker compose logs -f app1` | Follow logs from app1 only |
| `docker compose exec postgres psql -U postgres -d livrosdb` | Open a psql session |

---

## API Overview

Both `app1` and `app2` expose the same REST API. Nginx distributes requests between them via round-robin.

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `GET` | `/` | No | Serves the HTML frontend |
| `GET` | `/livros` | No | Lists all books |
| `POST` | `/auth/login` | No | Login — returns JWT token |
| `GET` | `/users/me/livros` | JWT | Lists books owned by the authenticated user |
| `POST` | `/livros` | JWT | Creates a new book |

**Default seed user** (created automatically on first start):

| Field | Value |
|---|---|
| Email | `admin@admin.com` |
| Password | `adminpassword` |

---

## Troubleshooting

**Port 80 already in use:**
```bash
# Find out what is using port 80
sudo fuser -n tcp 80

# Stop the system nginx if running
sudo systemctl stop nginx
```

**Containers not healthy / database not ready:**
```bash
# Check logs
docker compose logs postgres
docker compose logs app1
```

---

<br>

---

<div align="center">
  <h1>
    <img src="https://skillicons.dev/icons?i=nginx,docker,prometheus,grafana" /><br>
    Resilient Web Infrastructure 🇧🇷
  </h1>
  <p>
    <img src="https://img.shields.io/badge/Node.js-20-339933?style=flat&logo=node.js&logoColor=white" />
    <img src="https://img.shields.io/badge/Nginx-alpine-009639?style=flat&logo=nginx&logoColor=white" />
    <img src="https://img.shields.io/badge/PostgreSQL-16-336791?style=flat&logo=postgresql&logoColor=white" />
    <img src="https://img.shields.io/badge/Docker-Compose-2496ED?style=flat&logo=docker&logoColor=white" />
    <img src="https://img.shields.io/badge/Prometheus-enabled-E6522C?style=flat&logo=prometheus&logoColor=white" />
    <img src="https://img.shields.io/badge/Grafana-enabled-F46800?style=flat&logo=grafana&logoColor=white" />
  </p>
</div>

Este repositório contém uma infraestrutura web resiliente construída com Docker Compose, com aplicações Node.js balanceadas por carga atrás de um proxy reverso Nginx, banco de dados PostgreSQL, e um stack completo de observabilidade com Prometheus e Grafana.

---

## Estrutura do Projeto

```
resilient-web-infrastructure/
│
├── docker-compose.yml          # Orquestra todos os serviços
├── nginx.conf                  # Configuração do proxy reverso + balanceador de carga
│
├── apps/
│   ├── app1/                   # Instância 1 da aplicação Node.js
│   │   ├── Dockerfile
│   │   ├── server.js           # API Express (auth, CRUD de livros)
│   │   ├── index.html
│   │   └── package.json
│   └── app2/                   # Instância 2 da aplicação Node.js (idêntica)
│       ├── Dockerfile
│       ├── server.js
│       ├── index.html
│       └── package.json
│
├── prometheus/
│   └── prometheus.yml          # Configuração dos alvos de scraping
│
├── script.sh                   # Script de inicialização automatizada (Linux/Mac)
└── script.ps1                  # Script de inicialização automatizada (Windows)
```

---

## Tecnologias Utilizadas

| Tecnologia | Versão | Finalidade |
|---|---|---|
| [Node.js](https://nodejs.org/) | 20 (Alpine) | Runtime da aplicação |
| [Express](https://expressjs.com/) | — | Framework web |
| [Nginx](https://nginx.org/) | Alpine | Proxy reverso e balanceador de carga |
| [PostgreSQL](https://www.postgresql.org/) | 16 | Banco de dados relacional |
| [Docker](https://www.docker.com/) | — | Containerização |
| [Prometheus](https://prometheus.io/) | latest | Coleta de métricas |
| [Grafana](https://grafana.com/) | latest | Visualização de métricas e dashboards |
| [nginx-prometheus-exporter](https://github.com/nginx/nginx-prometheus-exporter) | 1.1 | Exportador de métricas do Nginx |
| [postgres_exporter](https://github.com/prometheus-community/postgres_exporter) | latest | Exportador de métricas do PostgreSQL |

---

## Visão Geral da Arquitetura

```
Internet
    │
    ▼
 Nginx :80          ← Proxy reverso (balanceamento round-robin)
  ├── app1 :80      ← Instância 1 Node.js
  └── app2 :80      ← Instância 2 Node.js
         │
         ▼
    PostgreSQL       ← Banco compartilhado (livrosdb)

Observabilidade
  ├── Prometheus :9090   ← Coleta métricas de todos os serviços
  │     ├── nginx-exporter :9113
  │     └── postgres-exporter :9187
  └── Grafana :3000      ← Dashboards e visualização
```

---

## Serviços e Portas

| Serviço | Porta no Host | Descrição |
|---|---|---|
| nginx | `80` | Ponto de entrada — distribui requisições para app1/app2 |
| app1 | interna | Instância 1 Node.js |
| app2 | interna | Instância 2 Node.js |
| postgres | interna | Banco de dados PostgreSQL |
| prometheus | interna | Coletor de métricas |
| grafana | interna | Interface de dashboards |
| cadvisor | interna | Métricas de recursos de contêineres |
| nginx-exporter | interna | Exporta métricas do Nginx para o Prometheus |
| postgres-exporter | interna | Exporta métricas do PostgreSQL para o Prometheus |

---

## Requisitos

- **Docker** 24.x ou superior
- **Docker Compose** v2 ou superior

> Só isso. Não é necessário instalar Node.js ou PostgreSQL localmente.

---

## Como Executar

### <img src="https://skillicons.dev/icons?i=github" height="20" style="vertical-align: middle;" /> 1. Clone o repositório

```bash
git clone <url-do-repositório>
cd resilient-web-infrastructure
```

### ▶️ 2. Inicie com o script (recomendado)

```bash
# Linux / macOS
bash script.sh

# Windows (PowerShell)
.\script.ps1
```

O script irá:
- ✅ Detectar se Docker ou Podman está em execução
- ✅ Verificar se já existem containers ativos (e oferecer reinicialização)
- ✅ Executar `docker compose up -d`
- ✅ Exibir `docker compose ps` com o status de todos os serviços

### 🐳 Ou inicie manualmente

```bash
docker compose up -d
docker compose ps
```

---

## Acessando os Serviços

| Serviço | URL | Credenciais |
|---|---|---|
| Aplicação | http://localhost | — |
| Prometheus | http://localhost/prometheus/ | — |
| Grafana | http://localhost/grafana/ | `admin` / `admin` |

> No primeiro login no Grafana será pedido para trocar a senha. É possível pular esta etapa.

---

## Testando e Visualizando Métricas

### 1. Consultas no Prometheus
Você pode consultar as métricas "cruas" diretamente no Prometheus. Abra **http://localhost/prometheus/**, digite uma expressão na barra de pesquisa e clique em **Execute** (use a aba "Graph" para ver em formato de linha do tempo).

Tente estas expressões:
- `nginx_http_requests_total` — Total de requisições HTTP recebidas pelo Nginx.
- `nginx_connections_active` — Conexões ativas no Nginx no momento.
- `pg_stat_database_xact_commit{datname="livrosdb"}` — Total de transações com commit no PostgreSQL.

### 2. Configurando Dashboards no Grafana
Para ver essas métricas em painéis visuais:

1. Acesse **http://localhost/grafana/** e faça login com `admin` / `admin`
2. Vá em **Connections → Data sources → Add data source**
3. Selecione **Prometheus** e defina a URL como `http://prometheus:9090/prometheus`
4. Clique em **Save & test**
5. Vá em **Dashboards → New → Import** e use um dos IDs abaixo da galeria do Grafana:
   - **`12708`** — Nginx (Requisições, conexões, tráfego)
   - **`9628`** — PostgreSQL Database (Queries, conexões, tamanho)
   - **`1860`** — Node Exporter Full (Métricas gerais do sistema)
6. Selecione **Prometheus** na caixa de seleção no final da tela e clique em **Import**.

> **Dica:** Abra uma nova aba e aperte F5 várias vezes em `http://localhost` (ou rode `curl http://localhost` em loop no terminal) para gerar tráfego e ver os gráficos do Nginx se mexerem!

---

## Comandos Docker

| Comando | Descrição |
|---|---|
| `bash script.sh` | Iniciar com o script automatizado (Linux/Mac) |
| `.\script.ps1` | Iniciar com o script automatizado (Windows) |
| `docker compose up -d` | Subir todos os serviços em segundo plano |
| `docker compose up --build -d` | Rebuildar imagens e subir |
| `docker compose ps` | Ver status de todos os containers |
| `docker compose down` | Parar e remover containers (dados preservados) |
| `docker compose down -v` | Parar e **apagar todos os dados** (volumes removidos) |
| `docker compose logs -f` | Acompanhar logs de todos os serviços |
| `docker compose logs -f nginx` | Acompanhar logs somente do nginx |
| `docker compose logs -f app1` | Acompanhar logs somente do app1 |
| `docker compose exec postgres psql -U postgres -d livrosdb` | Abrir sessão psql |

---

## Visão Geral da API

Ambas as instâncias `app1` e `app2` expõem a mesma API REST. O Nginx distribui as requisições entre elas em round-robin.

| Método | Endpoint | Auth | Descrição |
|---|---|---|---|
| `GET` | `/` | Não | Serve o frontend HTML |
| `GET` | `/livros` | Não | Lista todos os livros |
| `POST` | `/auth/login` | Não | Login — retorna token JWT |
| `GET` | `/users/me/livros` | JWT | Lista livros do usuário autenticado |
| `POST` | `/livros` | JWT | Cria um novo livro |

**Usuário padrão** (criado automaticamente na primeira inicialização):

| Campo | Valor |
|---|---|
| E-mail | `admin@admin.com` |
| Senha | `adminpassword` |

---

## Solução de Problemas

**Porta 80 já em uso:**
```bash
# Descobrir o que está usando a porta 80
sudo fuser -n tcp 80

# Parar o nginx do sistema, se estiver rodando
sudo systemctl stop nginx
```

**Containers não ficam healthy / banco não responde:**
```bash
# Verificar logs
docker compose logs postgres
docker compose logs app1
```