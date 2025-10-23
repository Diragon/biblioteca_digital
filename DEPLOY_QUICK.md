# 🚀 Deploy Rápido - Biblioteca Digital

## ⚡ Início Rápido (Desenvolvimento)

### 1. Backend (Rails API)
```bash
# Navegar para o diretório
cd biblioteca_digital

# Instalar dependências
bundle install

# Configurar banco
rails db:create db:migrate db:seed

# Iniciar servidor
rails server -p 3000
```

### 2. Frontend (React)
```bash
# Navegar para o frontend
cd biblioteca_digital/frontend

# Instalar dependências
npm install

# Iniciar aplicação
npm start
```

### 3. Acessar Aplicação
- **Frontend**: http://localhost:3001
- **Backend API**: http://localhost:3000
- **Documentação Swagger**: http://localhost:3000/api-docs
- **GraphQL**: http://localhost:3000/graphql

## 🔧 Scripts de Deploy Automatizado

### Script Completo (Backend + Frontend)
```bash
#!/bin/bash
# deploy-complete.sh

echo "🚀 Deploy completo da Biblioteca Digital..."

# Parar processos existentes
echo "🛑 Parando processos existentes..."
pkill -f "rails server" || true
pkill -f "npm start" || true

# Backend
echo "📦 Configurando backend..."
cd biblioteca_digital
bundle install
rails db:migrate
rails db:seed

# Frontend
echo "📦 Configurando frontend..."
cd frontend
npm install

# Iniciar aplicações
echo "🚀 Iniciando aplicações..."

# Backend em background
rails server -d -p 3000
echo "✅ Backend iniciado em http://localhost:3000"

# Frontend em background
npm start &
echo "✅ Frontend iniciado em http://localhost:3001"

echo "🎉 Deploy completo! Acesse http://localhost:3001"
```

### Script de Parada
```bash
#!/bin/bash
# stop-all.sh

echo "🛑 Parando todas as aplicações..."
pkill -f "rails server"
pkill -f "npm start"
echo "✅ Aplicações paradas"
```

## 🐳 Deploy com Docker

### Deploy Completo
```bash
# Subir tudo
docker-compose -f docker-compose.full.yml up -d

# Verificar status
docker-compose -f docker-compose.full.yml ps

# Ver logs
docker-compose -f docker-compose.full.yml logs -f
```

### Deploy Individual
```bash
# Apenas backend
docker-compose up backend -d

# Apenas frontend
docker-compose up frontend -d
```

## 🔍 Verificação de Saúde

### Testar Backend
```bash
# Testar API
curl http://localhost:3000/estatisticas

# Testar autenticação
curl -X POST http://localhost:3000/autenticacao/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@biblioteca.com","senha":"123456"}'
```

### Testar Frontend
```bash
# Verificar se está rodando
curl http://localhost:3001
```

## 🚨 Solução de Problemas Rápidos

### Porta 3000 ocupada
```bash
# Encontrar processo
lsof -ti:3000

# Matar processo
kill -9 $(lsof -ti:3000)
```

### Porta 3001 ocupada
```bash
# Encontrar processo
lsof -ti:3001

# Matar processo
kill -9 $(lsof -ti:3001)
```

### Erro de dependências
```bash
# Backend
bundle install

# Frontend
cd frontend && npm install
```

### Erro de banco
```bash
rails db:drop db:create db:migrate db:seed
```

## 📊 Comandos Úteis

### Logs em Tempo Real
```bash
# Backend
tail -f log/development.log

# Frontend (se usando PM2)
pm2 logs
```

### Status dos Processos
```bash
# Verificar processos Rails
ps aux | grep rails

# Verificar processos Node
ps aux | grep node
```

### Limpeza Completa
```bash
# Parar tudo
pkill -f "rails server"
pkill -f "npm start"

# Limpar cache
cd biblioteca_digital && bundle clean
cd frontend && npm cache clean --force
```

---

**💡 Dica**: Use `./deploy-complete.sh` para deploy automático!
