# TESTS.md — DashLab
 
Documento de referência para validação do projeto. Organizado por criticidade e camada, do mais simples ao mais complexo. Inclui comandos exatos e resultados esperados. 

 
---
 
## Índice
 
- [Pré-requisitos](#pré-requisitos)
- [1. Segurança — Git e secrets](#1-segurança--git-e-secrets)
- [2. Docker](#2-docker)
- [3. Infraestrutura — Terraform](#3-infraestrutura--terraform)
- [4. Rede e VPC](#4-rede-e-vpc)
- [5. ECR](#5-ecr)
- [6. EKS e Kubernetes](#6-eks-e-kubernetes)
- [7. Aplicação](#7-aplicação)
- [8. Fluent Bit e CloudWatch](#8-fluent-bit-e-cloudwatch)
- [9. CI/CD](#9-cicd)
---
 
## Pré-requisitos
 
Antes de executar qualquer teste com infra ativa:
 
```bash
aws eks update-kubeconfig --region us-east-1 --name dashlab-cluster
kubectl get nodes
```
 
Resultado esperado: 2 nodes em status `Ready`.
 
---
 
## 1. Segurança — Git e secrets
 
Esses testes são executados localmente, sem infra ativa. Devem passar sempre.
 
### 1.1 `.env` nunca foi commitado
 
```bash
git log --all --full-history -- backend/.env
```
 
Resultado esperado: nenhuma saída. Histórico vazio.
 
### 1.2 Arquivos sensíveis não estão no repositório
 
```bash
git ls-files | grep -E "\.env$|tfvars|backend-secret|fluent-bit\.yml$"
```
 
Resultado esperado: nenhuma saída.
 
### 1.3 Nenhum secret ou credencial hardcoded no código
 
```bash
git grep -i "secret\|password\|key" -- '*.yml' '*.tf' '*.js'
```
 
Resultado esperado: apenas referências a variáveis de ambiente (`${{ secrets.AWS_ACCOUNT_ID }}`, `${DB_PASSWORD}`, `secretKeyRef`) e nomes de recursos. Nenhum valor real.
 
### 1.4 `fluent-bit.yml` gerado está no `.gitignore`
 
```bash
git check-ignore -v --no-index k8s/fluent-bit.yml
```
 
Resultado esperado:
```
.gitignore:28:k8s/fluent-bit.yml	k8s/fluent-bit.yml
```
 
---
 
## 2. Docker
 
Esses testes são executados localmente, sem infra ativa.
 
### 2.1 Build do backend completa sem erros
 
```bash
docker build -t dashlab-backend:local ./backend
```
 
Resultado esperado: `FINISHED` sem erros. Todas as layers cacheadas a partir do segundo build.
 
### 2.2 Build do frontend completa sem erros
 
```bash
docker build -t dashlab-frontend:local ./frontend
```
 
Resultado esperado: `FINISHED` sem erros. Warning de `FromAsCasing` é esperado e não afeta o build.
 
### 2.3 Tamanho das imagens
 
```bash
docker images | grep dashlab
```
 
Resultado esperado:
```
dashlab-backend    ~200MB comprimido    ~50MB
dashlab-frontend   ~94MB comprimido     ~26MB
```
 
### 2.4 Container do backend não roda como root
 
```bash
docker run --rm dashlab-backend:local whoami
```
 
Resultado esperado: `appuser`
 
### 2.5 Aplicação sobe via Docker Compose
 
```bash
cp backend/.env.example backend/.env
docker compose up --build
```
 
Em outro terminal:
 
```bash
curl http://localhost:3001/health
```
 
Resultado esperado:
```json
{"status":"ok","timestamp":"..."}
```
 
---
 
## 3. Infraestrutura — Terraform
 
Requer credenciais AWS configuradas.
 
### 3.1 Validação de sintaxe
 
```bash
cd terraform
terraform validate
```
 
Resultado esperado: `Success! The configuration is valid.`
 
### 3.2 Apply completa sem erros
 
```bash
terraform apply -auto-approve
```
 
Resultado esperado: `Apply complete! Resources: 43 added, 0 changed, 0 destroyed.`
 
### 3.3 Idempotência — segundo apply não altera nada
 
```bash
terraform apply -auto-approve
```
 
Resultado esperado: `No changes. Your infrastructure matches the configuration.`
 
### 3.4 Manifest do Fluent Bit gerado com ARN correto
 
```bash
grep "role-arn" ../k8s/fluent-bit.yml
```
 
Resultado esperado:
```
eks.amazonaws.com/role-arn: arn:aws:iam::ACCOUNT_ID:role/dashlab-fluent-bit
```
 
Nenhum placeholder como `REPLACE_WITH_*`.
 
### 3.5 Destroy completa sem erros
 
Antes do destroy, limpar recursos externos ao Terraform:
 
```bash
kubectl delete -f ../k8s/
sleep 60
terraform destroy -auto-approve
```
 
Resultado esperado: `Destroy complete! Resources: 43 destroyed.`
 
---
 
## 4. Rede e VPC
 
Requer infra ativa.
 
### 4.1 Nodes EKS não têm IP público
 
```bash
kubectl get nodes -o wide
```
 
Resultado esperado: coluna `EXTERNAL-IP` com valor `<none>` para todos os nodes.
 
### 4.2 Nodes estão em subnets privadas
 
```bash
kubectl get nodes -o wide
```
 
Resultado esperado: coluna `INTERNAL-IP` com endereços no range `10.0.10.x` ou `10.0.11.x` (subnets privadas).
 
---
 
## 5. ECR
 
Requer infra ativa.
 
### 5.1 Repositórios existem
 
```bash
aws ecr describe-repositories --region us-east-1 \
  --query 'repositories[*].{name:repositoryName,mutability:imageTagMutability,scan:imageScanningConfiguration.scanOnPush}'
```
 
Resultado esperado:
```json
[
  {"name": "dashlab-backend",  "mutability": "IMMUTABLE", "scan": true},
  {"name": "dashlab-frontend", "mutability": "IMMUTABLE", "scan": true}
]
```
 
### 5.2 Tag IMMUTABLE bloqueia sobrescrita
 
```bash
docker tag dashlab-backend:local \
  $(terraform output -raw ecr_backend_url):v1.0.0
 
docker push $(terraform output -raw ecr_backend_url):v1.0.0
 
# Tentar push novamente com a mesma tag
docker push $(terraform output -raw ecr_backend_url):v1.0.0
```
 
Resultado esperado: segundo push retorna erro `ImageAlreadyExistsException`.
 
### 5.3 Imagens existem após push
 
```bash
aws ecr describe-images --repository-name dashlab-backend --region us-east-1 \
  --query 'imageDetails[*].{tags:imageTags,pushed:imagePushedAt,size:imageSizeInBytes}'
```
 
Resultado esperado: objeto com `imageTags`, `imagePushedAt` e `imageSizeInBytes` preenchidos.
 
---
 
## 6. EKS e Kubernetes
 
Requer infra ativa e `kubectl apply -f k8s/` executado.
 
### 6.1 Todos os pods do namespace dashlab em Running
 
```bash
kubectl get pods -n dashlab
```
 
Resultado esperado: 4 pods (2 backend, 2 frontend) com `STATUS=Running` e `READY=1/1`.
 
### 6.2 Fluent Bit rodando em todos os nodes
 
```bash
kubectl get pods -n kube-system | grep fluent-bit
```
 
Resultado esperado: um pod por node (2 pods) com `STATUS=Running` e `READY=1/1`.
 
### 6.3 Resource limits aplicados
 
```bash
kubectl describe pod -n dashlab -l app=backend | grep -A 4 "Limits:"
```
 
Resultado esperado:
```
Limits:
  cpu:     250m
  memory:  256Mi
```
 
### 6.4 Secret injetado corretamente no backend
 
```bash
kubectl exec -n dashlab deploy/backend -- env | grep DB_PASSWORD
```
 
Resultado esperado: `DB_PASSWORD=` com o valor configurado no Secret, sem expor o valor no YAML do Deployment.
 
### 6.5 Container do backend não roda como root no cluster
 
```bash
kubectl exec -n dashlab deploy/backend -- id
```
 
Resultado esperado: `uid=10001(appuser)` (ou qualquer ID numérico diferente de 0).
 
### 6.6 Fluent Bit conectado ao API server do K8s
 
```bash
kubectl logs -n kube-system -l k8s-app=fluent-bit --tail=20 | grep -E "connectivity|error"
```
 
Resultado esperado:
```
[info] [filter:kubernetes] connectivity OK
```
 
Nenhuma linha com `error`.
 
### 6.7 IRSA do Fluent Bit — sem credenciais do node
 
```bash
kubectl exec -n kube-system $(kubectl get pod -n kube-system -l k8s-app=fluent-bit -o name | head -1) \
  -- env | grep -E "AWS_ROLE|AWS_WEB_IDENTITY"
```
 
Resultado esperado:
```
AWS_ROLE_ARN=arn:aws:iam::ACCOUNT_ID:role/dashlab-fluent-bit
AWS_WEB_IDENTITY_TOKEN_FILE=/var/run/secrets/eks.amazonaws.com/serviceaccount/token
```
 
---
 
## 7. Aplicação
 
Requer infra ativa e pods em Running.
 
### 7.1 Validação local da API via Port-Forward
 
 ```bash
# Abra o túnel para o seu PC (deixe rodando em background)
kubectl port-forward deploy/backend -n dashlab 3001:3001 &

# Teste os endpoints direto da sua máquina local
curl http://localhost:3001/health
curl http://localhost:3001/api

# Encerre o túnel local ao finalizar
kill %1
```
 
Resultado esperado:
```json
{"status":"ok","timestamp":"2026-..."}
{"message":"DashLab API","version":"0.3.0"}
```
 
### 7.2 Aplicação acessível via ALB
 
 ```bash
# Pega o DNS do Ingress
kubectl get ingress -n dashlab
 
# Testa externamente usando o endereço retornado na coluna ADDRESS
curl http://INGRESS_DNS/health
curl http://INGRESS_DNS/api
```
 
Resultado esperado: mesmas respostas obtidas no teste anterior.
 
### 7.3 Aplicação acessível via ALB
 
```bash
# Pega o DNS do Ingress
kubectl get ingress -n dashlab
 
# Testa externamente
curl http://INGRESS_DNS/health
curl http://INGRESS_DNS/api
```
 
Resultado esperado: mesmas respostas dos testes 7.1 e 7.2.
 
---
 
## 8. Fluent Bit e CloudWatch
 
Requer infra ativa e pods em Running.
 
### 8.1 Log groups existem com retenção de 30 dias
 
```bash
aws logs describe-log-groups --log-group-name-prefix /dashlab --region us-east-1 \
  --query 'logGroups[*].{name:logGroupName,retention:retentionInDays}'
```
 
Resultado esperado:
```json
[
  {"name": "/dashlab/backend",  "retention": 30},
  {"name": "/dashlab/frontend", "retention": 30}
]
```
 
### 8.2 Log streams sendo criados no grupo do backend
 
```bash
aws logs describe-log-streams \
  --log-group-name /dashlab/backend \
  --region us-east-1 \
  --order-by LastEventTime \
  --descending \
  --max-items 3
```
 
Resultado esperado: lista de streams com prefixo `backend-` e `lastEventTimestamp` recente.
 
### 8.3 Logs chegando com metadados do K8s
 
```bash
aws logs get-log-events \
  --log-group-name /dashlab/backend \
  --log-stream-name "$(aws logs describe-log-streams \
    --log-group-name /dashlab/backend \
    --region us-east-1 \
    --order-by LastEventTime \
    --descending \
    --max-items 1 \
    --query 'logStreams[0].logStreamName' \
    --output text)" \
  --region us-east-1 \
  --limit 5
```
 
Resultado esperado: eventos com campo `message` contendo JSON com `kubernetes.pod_name`, `kubernetes.namespace_name` e `kubernetes.labels.app=backend`.
 
### 8.4 Logs de outros namespaces não aparecem nos grupos do dashlab
 
```bash
aws logs filter-log-events \
  --log-group-name /dashlab/backend \
  --region us-east-1 \
  --filter-pattern "kube-system"
```
 
Resultado esperado: `{"events": []}` — nenhum log do kube-system no grupo do backend.
 
---
 
## 9. CI/CD
 
Requer push na branch `main` e infra ativa.
 
### 9.1 Pipeline executa ao fazer push
 
Fazer um commit qualquer e verificar no GitHub Actions que a pipeline foi disparada automaticamente.
 
### 9.2 Job de testes bloqueia o deploy em caso de falha
 
Inserir um teste quebrado temporariamente:
 
```javascript
// backend/src/routes/health.test.js
test('teste que vai falhar', () => {
  expect(true).toBe(false);
});
```
 
Fazer push e verificar que o job `build-and-push` não executa.
 
Reverter após o teste.
 
### 9.3 Imagem no ECR tem tag do SHA do commit
 
Após pipeline executar com sucesso:
 
```bash
aws ecr describe-images --repository-name dashlab-backend --region us-east-1 \
  --query 'imageDetails[*].imageTags'
```
 
Resultado esperado: tag com o SHA do commit (ex: `a1b2c3d`) além da tag `latest`.
 
### 9.4 OIDC sendo usado — sem chaves estáticas
 
Nos logs do job `build-and-push` do GitHub Actions, verificar a presença de:
 
```
Assuming role with OIDC
AssumeRoleWithWebIdentity
```
 
E ausência de qualquer referência a `AWS_ACCESS_KEY_ID`.
 
### 9.5 Deploy atualiza o Deployment no EKS
 
Após pipeline executar:
 
```bash
kubectl rollout history deployment/backend -n dashlab
kubectl rollout history deployment/frontend -n dashlab
```
 
Resultado esperado: nova revisão registrada com a imagem do commit mais recente.
 
### 9.6 Rollout verify confirma sucesso
 
Verificar nos logs do job `deploy` que o passo `Rollout Verify` completou sem erro:
 
```
deployment "backend" successfully rolled out
deployment "frontend" successfully rolled out
```
 
---
 
## Observações
 
- Testes das seções 3 a 9 requerem infra ativa. Lembre de destruir após os testes para evitar custos: `kubectl delete -f k8s/ && sleep 60 && cd terraform && terraform destroy -auto-approve`
- O arquivo `k8s/fluent-bit.yml` é gerado automaticamente pelo Terraform e não deve ser editado manualmente