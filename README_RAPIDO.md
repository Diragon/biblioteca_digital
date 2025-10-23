# 🚀 Biblioteca Digital - Deploy Rápido

## ⚡ Subir o Projeto

### Opção 1: Automático (Recomendado)
```bash
cd biblioteca_digital
./deploy-complete.sh
```

### Opção 2: Manual
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

## 🔑 Login
- **Email**: admin@biblioteca.com
- **Senha**: 123456

## 🛑 Parar
```bash
./stop-all.sh
```

---

**✅ Pronto!**
