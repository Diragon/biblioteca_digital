# 🚀 Deploy em Produção - Biblioteca Digital

## 📋 Pré-requisitos

### Servidor
- Ubuntu 20.04+ ou CentOS 8+
- 2GB RAM mínimo (4GB recomendado)
- 20GB espaço em disco
- Acesso root/sudo

### Software Necessário
- Ruby 3.2+
- Rails 8.1.0
- PostgreSQL 14+
- Node.js 18+
- Nginx
- PM2 (opcional)

## 🔧 Configuração do Servidor

### 1. Atualizar Sistema
```bash
sudo apt update && sudo apt upgrade -y
```

### 2. Instalar Dependências
```bash
# Ruby e Rails
sudo apt install -y ruby-dev build-essential libpq-dev postgresql-client

# Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# PostgreSQL
sudo apt install -y postgresql postgresql-contrib

# Nginx
sudo apt install -y nginx

# PM2 (opcional)
sudo npm install -g pm2
```

### 3. Configurar PostgreSQL
```bash
# Acessar PostgreSQL
sudo -u postgres psql

# Criar usuário e banco
CREATE USER biblioteca_user WITH PASSWORD 'senha_super_segura';
CREATE DATABASE biblioteca_digital_production OWNER biblioteca_user;
GRANT ALL PRIVILEGES ON DATABASE biblioteca_digital_production TO biblioteca_user;
\q
```

## 📦 Deploy da Aplicação

### 1. Clonar Repositório
```bash
cd /var/www
sudo git clone <url-do-repositorio> biblioteca-digital
sudo chown -R $USER:$USER biblioteca-digital
cd biblioteca-digital
```

### 2. Configurar Backend
```bash
# Instalar dependências
bundle install --deployment --without development test

# Configurar variáveis de ambiente
cp config.env.example .env
nano .env
```

**Conteúdo do .env para produção:**
```env
RAILS_ENV=production
DATABASE_URL=postgresql://biblioteca_user:senha_super_segura@localhost/biblioteca_digital_production
JWT_SECRET=jwt_secret_super_seguro_producao
SECRET_KEY_BASE=secret_key_base_producao
FRONTEND_URL=https://seu-dominio.com
```

### 3. Configurar Banco de Dados
```bash
# Executar migrações
RAILS_ENV=production rails db:create
RAILS_ENV=production rails db:migrate
RAILS_ENV=production rails db:seed

# Compilar assets
RAILS_ENV=production rails assets:precompile
```

### 4. Configurar Frontend
```bash
cd frontend

# Instalar dependências
npm install

# Build de produção
npm run build

# Configurar variáveis
echo "REACT_APP_API_URL=https://seu-dominio.com" > .env.production
```

## 🔧 Configuração do Nginx

### 1. Criar Configuração
```bash
sudo cp nginx.conf.example /etc/nginx/sites-available/biblioteca-digital
sudo nano /etc/nginx/sites-available/biblioteca-digital
```

### 2. Ativar Site
```bash
sudo ln -s /etc/nginx/sites-available/biblioteca-digital /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### 3. Configurar SSL (Let's Encrypt)
```bash
# Instalar Certbot
sudo apt install -y certbot python3-certbot-nginx

# Obter certificado
sudo certbot --nginx -d seu-dominio.com -d www.seu-dominio.com
```

## 🚀 Iniciar Aplicação

### Opção 1: PM2 (Recomendado)
```bash
# Configurar PM2
cp ecosystem.config.js.example ecosystem.config.js
nano ecosystem.config.js

# Ajustar caminhos no arquivo
# Iniciar aplicação
pm2 start ecosystem.config.js --env production
pm2 save
pm2 startup
```

### Opção 2: Systemd
```bash
# Criar serviço para backend
sudo nano /etc/systemd/system/biblioteca-backend.service
```

**Conteúdo do serviço:**
```ini
[Unit]
Description=Biblioteca Digital Backend
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/var/www/biblioteca-digital
Environment=RAILS_ENV=production
ExecStart=/usr/local/bin/bundle exec rails server -e production -p 3000
Restart=always

[Install]
WantedBy=multi-user.target
```

```bash
# Ativar serviço
sudo systemctl enable biblioteca-backend
sudo systemctl start biblioteca-backend
```

## 🔍 Monitoramento

### 1. Logs
```bash
# Backend
tail -f log/production.log

# Nginx
sudo tail -f /var/log/nginx/biblioteca-digital.access.log
sudo tail -f /var/log/nginx/biblioteca-digital.error.log

# PM2
pm2 logs
```

### 2. Status dos Serviços
```bash
# PM2
pm2 status

# Systemd
sudo systemctl status biblioteca-backend

# Nginx
sudo systemctl status nginx

# PostgreSQL
sudo systemctl status postgresql
```

### 3. Verificar Aplicação
```bash
# Testar API
curl https://seu-dominio.com/estatisticas

# Testar Frontend
curl https://seu-dominio.com
```

## 🔒 Segurança

### 1. Firewall
```bash
sudo ufw allow 22
sudo ufw allow 80
sudo ufw allow 443
sudo ufw enable
```

### 2. Backup
```bash
# Script de backup
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
pg_dump biblioteca_digital_production > backup_$DATE.sql
```

### 3. Atualizações
```bash
# Script de atualização
#!/bin/bash
cd /var/www/biblioteca-digital
git pull origin main
bundle install
rails db:migrate
rails assets:precompile
pm2 restart all
```

## 🚨 Troubleshooting

### Problemas Comuns

#### 1. Erro 502 Bad Gateway
```bash
# Verificar se Rails está rodando
ps aux | grep rails

# Verificar logs
tail -f log/production.log
```

#### 2. Erro de Banco de Dados
```bash
# Verificar conexão
sudo -u postgres psql -c "SELECT 1;"

# Verificar configuração
rails db:version
```

#### 3. Erro de Assets
```bash
# Recompilar assets
rails assets:precompile RAILS_ENV=production
```

#### 4. Erro de Permissões
```bash
# Ajustar permissões
sudo chown -R www-data:www-data /var/www/biblioteca-digital
sudo chmod -R 755 /var/www/biblioteca-digital
```

## 📊 Performance

### 1. Otimizações Rails
```ruby
# config/environments/production.rb
config.force_ssl = true
config.cache_classes = true
config.eager_load = true
config.consider_all_requests_local = false
config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?
```

### 2. Otimizações Nginx
```nginx
# Gzip compression
gzip on;
gzip_vary on;
gzip_min_length 1024;
gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
```

### 3. Cache
```bash
# Redis para cache
sudo apt install -y redis-server
```

## 🔄 Deploy Contínuo

### 1. Webhook GitHub
```bash
# Criar webhook no GitHub
# URL: https://seu-dominio.com/deploy
# Secret: seu_secret_aqui
```

### 2. Script de Deploy
```bash
#!/bin/bash
# deploy.sh
cd /var/www/biblioteca-digital
git pull origin main
bundle install
rails db:migrate
rails assets:precompile
pm2 restart all
```

---

**🎉 Deploy em produção concluído!**

