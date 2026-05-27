# DashLab

Visão geral
-----------------------

DashLab é um repositório monolítico (monorepo) que reúne uma aplicação construída com Vite + React (`FrontEnd/`) e um servidor de API em Node.js/Express (`BackEnd/`). O projeto foi estruturado para aprender mais a fundo sobre desenvolvimento local, integração contínua e implantação em containers.

Objetivos deste documento
- Fornecer instruções claras sobre instalação, execução e implantação
- Descrever a arquitetura e os arquivos principais do repositório
- Registrar práticas recomendadas para desenvolvimento e operação

Arquitetura do repositório
--------------------------

- `BackEnd/` -> servidor Node.js, rotas e configurações de API
  - `src/` -> código-fonte do servidor
  - `src/routes/` -> rotas expostas (`health.js`, `api.js`)
- `FrontEnd/` -> aplicação React (Vite)
  - `src/` -> código-fonte React
  - `public/` -> ativos públicos
- `Terraform/` -> configuração de infraestrutura como código (opcional)
- `docker-compose.yml` -> composição para execução em containers

Pré-requisitos
--------------

- Node.js (recomendado LTS recente)
- npm ou yarn
- Docker e Docker Compose (para execução em containers)
- Terraform (apenas se for utilizar a pasta `Terraform/`)

Instalação e execução (desenvolvimento)
--------------------------------------

Siga estas etapas para executar os serviços localmente em modo de desenvolvimento.

1) BackEnd

```bash
cd BackEnd
npm install
# Modo desenvolvimento (com nodemon)
npm run dev
```

O servidor utiliza a variável `PORT` quando definida; por padrão, escuta na porta `3001`.

2) FrontEnd

```bash
cd FrontEnd
npm install
# Executar Vite em modo de desenvolvimento
npm run dev
```

O Vite exibirá a URL de desenvolvimento no terminal (por exemplo, `http://localhost:5173`).

Execução conjunta (desenvolvimento)
----------------------------------

Opções recomendadas para executar ambos os serviços simultaneamente:

- Terminais separados (rápido e direto):

```bash
cd BackEnd && npm run dev
cd FrontEnd && npm run dev
```

- Docker Compose (recomendado para simular ambiente de containers):

```bash
docker compose up --build
```

Automação de scripts
---------------------

Você pode optar por adicionar um `package.json` raiz que execute ambos os serviços com `concurrently` para conveniência em desenvolvimento.

Variáveis de ambiente
---------------------

O repositório inclui um arquivo de exemplo em `BackEnd/.env.example`. Recomenda-se copiar esse arquivo para `BackEnd/.env` e ajustar conforme necessário (PORT, credenciais externas, strings de conexão, chaves de API):

```bash
cp BackEnd/.env.example BackEnd/.env
```

APIs e contratos expostos
------------------------

Endpoints principais (exposição pública de desenvolvimento):

- `GET /health` -> verificação de integridade. Resposta de exemplo:

```json
{ "status": "ok", "timestamp": "2026-05-26T12:34:56.789Z" }
```

- `GET /api` - endpoint principal da API. Resposta de exemplo:

```json
{ "message": "DashLab API", "version": "0.1.0" }
```

Exemplo de verificação rápida via `curl`:

```bash
curl http://localhost:3001/health
curl http://localhost:3001/api
```

Docker e implantação em containers
---------------------------------

Este repositório inclui os arquivos necessários para construção e execução em containers:

- `docker-compose.yml` - orquestra os serviços do FrontEnd e do BackEnd para execução local ou em ambientes de homologação
- `BackEnd/Dockerfile` - imagem do servidor Node.js
- `FrontEnd/Dockerfile` - imagem da aplicação Vite/React

Comando de implantação local em containers:

```bash
docker-compose up --build -d
```

Infraestrutura como código (Terraform)
-------------------------------------

A pasta `Terraform/` contém arquivos de exemplo para provisionamento de infraestrutura. Antes de executar em uma conta real, revise os arquivos `main.tf`, `variables.tf` e `outputs.tf` e confirme as credenciais e políticas de acesso.

Fluxo recomendado:

```bash
cd Terraform
terraform init
terraform plan
terraform apply
```

Práticas de segurança e operação
--------------------------------

- Não versionar credenciais ou `.env` em repositórios públicos
- Utilize variáveis de ambiente ou serviços de secret management em ambientes de produção
- Monitore logs e configure health checks para containers e serviços

Suporte e contatos
-------------------

Para dúvidas, reporte issues no repositório Git ou me contate (pedrolucasfonseca98@gmail.com).