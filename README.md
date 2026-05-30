# DashLab

Visão geral
-----------------------

DashLab é um repositório monolítico (monorepo) que reúne uma aplicação construída com Vite + React (`frontend/`) e um servidor de API em Node.js/Express (`backend/`). O projeto foi estruturado para aprender mais a fundo sobre desenvolvimento local, integração contínua e implantação em containers.

Objetivos deste documento
- Fornecer instruções claras sobre instalação, execução e implantação
- Descrever a arquitetura e os arquivos principais do repositório
- Registrar práticas recomendadas para desenvolvimento e operação

Stack utilizada
--------------

- Frontend: Vite + React
- Backend: Node.js + Express
- Containers: Docker + Docker Compose
- Infraestrutura: Terraform (AWS)
- Orquestração: Kubernetes (EKS) + Nginx (frontend)
- CI/CD: GitHub Actions + ECR

Arquitetura (diagrama simples)
------------------------------

```mermaid
flowchart LR
  user[Usuario] --> alb[ALB/Ingress]
  alb --> fe[Frontend (Nginx + React)]
  fe --> be[Backend (Node.js/Express)]
  gh[GitHub Actions] --> ecr[(ECR)]
  ecr --> eks[(EKS)]
  alb --> eks
```

Arquitetura do repositório
--------------------------

- `.github/workflows/` -> pipelines de CI/CD e infra
- `backend/` -> servidor Node.js, rotas e configurações de API
  - `src/` -> código-fonte do servidor
  - `src/routes/` -> rotas expostas (`health.js`, `api.js`)
- `frontend/` -> aplicação React (Vite)
  - `src/` -> código-fonte React
  - `public/` -> ativos públicos
  - `nginx.conf` -> configuração do Nginx como proxy reverso para o backend
- `terraform/` -> configuração de infraestrutura como código
  - `main.tf` -> configuração do provider AWS
  - `variables.tf` -> variáveis do projeto
  - `outputs.tf` -> saídas após provisionamento
  - `vpc.tf` -> VPC, subnets, internet gateway e route table
- `terraform-bootstrap/` -> bootstrap do backend remoto (S3 + DynamoDB)
- `k8s/` -> manifests do Kubernetes (deployments, services, ingress)
- `docker-compose.yml` -> composição para execução em containers

Pré-requisitos
--------------

- Node.js (recomendado LTS recente)
- npm ou yarn
- Docker e Docker Compose (para execução em containers)
- Terraform (apenas se for utilizar a pasta `terraform/`)
- AWS CLI configurado com usuário IAM com permissões adequadas

Instalação e execução (desenvolvimento)
--------------------------------------

Siga estas etapas para executar os serviços localmente em modo de desenvolvimento.

1) BackEnd

```bash
cd backend
npm install
# Modo desenvolvimento (com nodemon)
npm run dev
```

O servidor utiliza a variável `PORT` quando definida; por padrão, escuta na porta `3001`.

2) FrontEnd

```bash
cd frontend
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
cd backend && npm run dev
cd frontend && npm run dev
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

O repositório inclui um arquivo de exemplo em `backend/.env.example`. Recomenda-se copiar esse arquivo para `backend/.env` e ajustar conforme necessário:

```bash
cp backend/.env.example backend/.env
```

Variáveis disponíveis:

- `PORT` -> porta em que o servidor escuta (padrão: 3001)
- `NODE_ENV` -> ambiente de execução (`development` ou `production`)

APIs e contratos expostos
------------------------

Endpoints principais (exposição pública de desenvolvimento):

- `GET /health` -> verificação de integridade. Resposta de exemplo:

```json
{ 
"status": "ok",
"timestamp": "2026-05-26T12:34:56.789Z"
}
```

- `GET /api` -> endpoint principal da API. Resposta de exemplo:

```json
{
"message": "DashLab API", 
"version": "0.1.0"
}
```

Exemplo de verificação rápida via `curl`:

```bash
curl http://localhost:3001/health
curl http://localhost:3001/api
```

Docker e implantação em containers
---------------------------------

Este repositório inclui os arquivos necessários para construção e execução em containers:

- `docker-compose.yml` -> orquestra os serviços do FrontEnd e do BackEnd
- `backend/Dockerfile` -> imagem do servidor Node.js
- `frontend/Dockerfile` -> imagem da aplicação Vite/React com build multi-stage
- `frontend/nginx.conf` -> configura o Nginx para servir o frontend e redirecionar as chamadas `/health` e `/api` para o backend via proxy reverso

Comando de implantação local em containers:

```bash
docker compose up --build -d
```

Infraestrutura como código (Terraform)
-------------------------------------

A pasta `terraform/` contém a configuração de infraestrutura provisionada na AWS. A infraestrutura atual inclui:

- **VPC** `10.0.0.0/16` com DNS habilitado
- **Subnet pública A** `10.0.1.0/24` na zona `us-east-1a`
- **Subnet pública B** `10.0.2.0/24` na zona `us-east-1b`
- **Internet Gateway** para acesso público
- **Route Table** com roteamento para a internet

Backend remoto (S3 + DynamoDB)
------------------------------

Antes de rodar o Terraform principal, crie o bucket do state e a tabela de lock com o bootstrap:

```bash
cd terraform-bootstrap
terraform init
terraform plan
terraform apply
```

Com o backend criado, inicialize o Terraform principal usando o backend remoto:

```bash
cd terraform
terraform init
```

Se houver um state local anterior, o `terraform init` pode oferecer migração para o backend remoto.

Fluxo recomendado:

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

Para destruir a infraestrutura:

```bash
terraform destroy
```

Provisionamento de infraestrutura (ordem recomendada)
-----------------------------------------------------

Siga esta ordem para evitar falhas no state remoto e garantir que o cluster esteja pronto:

1) Bootstrap do backend remoto (S3 + DynamoDB):

```bash
cd terraform-bootstrap
terraform init
terraform apply
```

2) Provisionamento principal (Terraform):

```bash
cd terraform
terraform init
terraform apply
```

Se houver state local, confirme a migração quando o `terraform init` solicitar.

3) Aplicar configurações adicionais via GitHub Actions:

- Execute o workflow [infra.yml](.github/workflows/infra.yml) em Actions (workflow_dispatch).
- Este workflow instala o AWS Load Balancer Controller no cluster.

Kubernetes (k8s)
----------------

Com o cluster EKS criado, conecte o `kubectl` e aplique os manifests:

```bash
aws eks update-kubeconfig --region us-east-1 --name <nome-do-cluster>
kubectl apply -f k8s/namespace.yml
kubectl apply -f k8s/backend-deployment.yml
kubectl apply -f k8s/frontend-deployment.yml
```

Para verificar o status:

```bash
kubectl get pods -n dashlab
kubectl get svc -n dashlab
```

Deploy (CI/CD)
-------------

O deploy é feito automaticamente pelo workflow [ci-cd.yml](.github/workflows/ci-cd.yml):

- Build das imagens do backend e frontend
- Push para o ECR
- Atualização dos manifests em k8s com as tags do commit
- Aplicação no cluster EKS e verificação de rollout

Secrets necessários no GitHub
-----------------------------

Configure em Settings -> Secrets -> Actions:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_ACCOUNT_ID`

Práticas de segurança e operação
--------------------------------

- Não versionar credenciais ou `.env` em repositórios públicos
- Nao versionar `terraform.tfstate` e `terraform.tfstate.backup` (use o backend remoto)
- Utilize variáveis de ambiente ou serviços de secret management em produção
- Monitore logs e configure health checks para containers e serviços
- Destrua a infraestrutura AWS quando não estiver em uso para evitar cobranças

Antes do terraform destroy
--------------------------

Se o `terraform destroy` falhar por causa de imagens no ECR, esvazie os repositórios:

```bash
aws ecr batch-delete-image \
  --repository-name dashlab-backend \
  --image-ids "$(aws ecr list-images --repository-name dashlab-backend \
  --query 'imageIds[*]' --output json)" --region us-east-1

aws ecr batch-delete-image \
  --repository-name dashlab-frontend \
  --image-ids "$(aws ecr list-images --repository-name dashlab-frontend \
  --query 'imageIds[*]' --output json)" --region us-east-1
```

Suporte e contatos
-------------------

Para dúvidas, reporte issues no repositório Git ou entre em contato: [pedrolucasfonseca98@gmail.com](mailto:pedrolucasfonseca98@gmail.com)