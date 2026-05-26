# DashLab

Projeto monorepo contendo o FrontEnd (Vite + React) e o BackEnd (Node.js/Express).

## Visão geral

- FrontEnd: aplicação React construída com Vite.
- BackEnd: servidor Node.js com rotas Express em `BackEnd/src/routes`.

## Estrutura do projeto

- `BackEnd/` - servidor e APIs
  - `src/` - código fonte do servidor
    - `routes/` - rotas (`api.js`, `health.js`)
- `FrontEnd/` - aplicação cliente (Vite + React)
  - `src/` - código fonte React
  - `public/` - ativos públicos

## Pré-requisitos

- Node.js (recomendado v14+)
- npm ou yarn
## Instalação e execução

Siga os passos abaixo para instalar dependências e executar cada parte do monorepo.

1) Backend

```bash
cd BackEnd
npm install
# Modo desenvolvimento (recarrega com alterações)
npm run dev
# Ou executar em produção
npm start
```

O BackEnd usa a porta padrão `3001` (variável `PORT`). A rota de health estará disponível em `http://localhost:3001/health`.

2) Frontend

```bash
cd FrontEnd
npm install
# Executar app em desenvolvimento (Vite)
npm run dev
```

Por padrão o Vite mostra a porta no terminal (ex.: `http://localhost:5173`).

## Exemplos de API

As rotas atualmente implementadas no BackEnd são simples e servem como exemplo:

- `GET /health` — resposta de verificação de saúde:

```json
{ "status": "ok", "timestamp": "2026-05-26T12:34:56.789Z" }
```

- `GET /api` — endpoint principal da API:

```json
{ "message": "DashLab API", "version": "0.1.0" }
```

Exemplo de chamada com `curl`:

```bash
curl http://localhost:3001/health
curl http://localhost:3001/api
```

Você pode estender `BackEnd/src/routes/api.js` adicionando mais rotas REST (GET/POST/PUT/DELETE) e conectar a um banco de dados conforme necessário.

## Executando FrontEnd e BackEnd ao mesmo tempo

Opções rápidas para rodar ambos simultaneamente:

- Em terminais separados (mínimo esforço):

  - Terminal 1:

  ```bash
  cd BackEnd
  npm run dev
  ```

  - Terminal 2:

  ```bash
  cd FrontEnd
  npm run dev
  ```

- Usando `npx concurrently` (uma linha, sem alterar arquivos):

```bash
npx concurrently "npm --prefix BackEnd run dev" "npm --prefix FrontEnd run dev"
```

Esse comando executa os scripts `dev` nas duas pastas ao mesmo tempo e mostra ambos os logs no mesmo terminal.

- Criar um `package.json` raiz com um script `dev` (opcional):

```json
{
  "name": "dashlab-root",
  "private": true,
  "scripts": {
    "dev": "npx concurrently \"npm --prefix BackEnd run dev\" \"npm --prefix FrontEnd run dev\""
  },
  "devDependencies": {
    "concurrently": "^8.0.0"
  }
}
```

Depois de criar o `package.json` raiz, rode:

```bash
npm install
npm run dev
```

## Observações

- Ajuste variáveis de ambiente no BackEnd (`.env`) para configurar a `PORT` ou outras credenciais.
- Se o FrontEnd precisa chamar a API, use a URL completa (ex.: `http://localhost:3001/api`) ou configure um proxy durante o desenvolvimento.

> Dica: para integração local rápida, defina `VITE_API_BASE` no `FrontEnd` e use `import.meta.env.VITE_API_BASE` no código React.

## Rotas principais

- `BackEnd/src/routes/health.js` — rota de verificação (health).
- `BackEnd/src/routes/api.js` — rotas da API.