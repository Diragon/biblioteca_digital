# 🚀 Biblioteca Digital - Deploy

## ⚡ Subir o Projeto

### 1. Deploy Automático
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

## 🌐 Acessar
- **Frontend**: http://localhost:3001
- **Backend**: http://localhost:3000
- **Documentação**: http://localhost:3000/api-docs

## 🔑 Login
- **Email**: admin@biblioteca.com
- **Senha**: 123456

## 🛑 Parar
```bash
./stop-all.sh
```

## 🐳 Docker
```bash
docker-compose -f docker-compose.full.yml up -d
```

---

**✅ Pronto! Acesse http://localhost:3001**
