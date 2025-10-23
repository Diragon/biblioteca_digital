# 🚀 Biblioteca Digital - Deploy Rápido

## ⚡ Como Subir o Projeto

### 1. Deploy Automático (Recomendado)
```bash
cd biblioteca_digital
./deploy-complete.sh
```

### 2. Deploy Manual
```bash
# Backend
cd biblioteca_digital
bundle install
rails db:create db:migrate db:seed
rails server -p 3000

# Frontend (novo terminal)
cd biblioteca_digital/frontend
npm install
npm start
```

## 🌐 Acessar Aplicação
- **Frontend**: http://localhost:3001
- **Backend API**: http://localhost:3000
- **Documentação**: http://localhost:3000/api-docs

## 🔑 Credenciais de Teste
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
- **DEPLOY_QUICK.md** - Deploy rápido
- **PRODUCTION_DEPLOY.md** - Deploy em produção
- **DOCUMENTATION_SUMMARY.md** - Resumo da documentação

---

**✅ Pronto! Acesse http://localhost:3001**