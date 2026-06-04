# Resilient Web Infrastructure

## Como rodar a aplicacao

Certifique-se de que o Docker ou Podman esta em execucao no host.

1. Construa as imagens da aplicacao:
   docker compose build

2. Inicie os servicos em segundo plano:
   docker compose up -d

3. Verifique o status dos servicos:
   docker compose ps

4. Para parar os servicos:
   docker compose down

A aplicacao estara acessivel em http://localhost/ através do proxy reverso.