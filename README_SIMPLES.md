# 🚀 Biblioteca Digital - Deploy Rápido

## ⚡ Como Subir o Projeto

### 1. Pré-requisitos
- Ruby 3.2+
- Rails 8.1.0
- PostgreSQL
- Node.js 18+

### 2. Deploy Automático (Recomendado)
```bash
# Navegar para o projeto
cd biblioteca_digital

# Executar script de deploy
./deploy-complete.sh
```

### 3. Deploy Manual

#### Backend (Rails API)
```bash
cd biblioteca_digital
bundle install
rails db:create db:migrate db:seed
rails server -p 3000
```

#### Frontend (React)
```bash
cd biblioteca_digital/frontend
npm install
npm start
```

### 4. Acessar Aplicação
- **Frontend**: http://localhost:3001
- **Backend API**: http://localhost:3000
- **Documentação**: http://localhost:3000/api-docs

### 5. Credenciais de Teste
- **Email**: admin@biblioteca.com
- **Senha**: 123456

## 🛑 Parar Aplicações
```bash
./stop-all.sh
```

## 🐳 Deploy com Docker
```bash
docker-compose -f docker-compose.full.yml up -d
```

## 📚 Documentação Completa
- **README.md** - Documentação completa
- **DEPLOY_QUICK.md** - Deploy rápido
- **PRODUCTION_DEPLOY.md** - Deploy em produção

---

**🎉 Pronto! Acesse http://localhost:3001**
