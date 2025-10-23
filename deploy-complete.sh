#!/bin/bash
# deploy-complete.sh - Script de deploy completo da Biblioteca Digital

echo "🚀 Deploy completo da Biblioteca Digital..."

# Parar processos existentes
echo "🛑 Parando processos existentes..."
pkill -f "rails server" || true
pkill -f "npm start" || true

# Aguardar um momento para os processos terminarem
sleep 2

# Backend
echo "📦 Configurando backend..."
cd biblioteca_digital

# Verificar se bundle está instalado
if ! command -v bundle &> /dev/null; then
    echo "❌ Bundle não encontrado. Instalando..."
    gem install bundler
fi

# Instalar dependências
echo "📥 Instalando dependências do backend..."
bundle install

# Configurar banco de dados
echo "🗄️ Configurando banco de dados..."
rails db:migrate
rails db:seed

# Frontend
echo "📦 Configurando frontend..."
cd frontend

# Verificar se npm está instalado
if ! command -v npm &> /dev/null; then
    echo "❌ NPM não encontrado. Instalando Node.js..."
    echo "Por favor, instale o Node.js manualmente: https://nodejs.org/"
    exit 1
fi

# Instalar dependências
echo "📥 Instalando dependências do frontend..."
npm install

# Voltar para o diretório raiz
cd ..

# Iniciar aplicações
echo "🚀 Iniciando aplicações..."

# Backend em background
echo "🔄 Iniciando backend..."
rails server -d -p 3000
sleep 3

# Verificar se o backend está rodando
if curl -s http://localhost:3000/estatisticas > /dev/null; then
    echo "✅ Backend iniciado com sucesso em http://localhost:3000"
else
    echo "❌ Erro ao iniciar backend. Verifique os logs."
    exit 1
fi

# Frontend em background
echo "🔄 Iniciando frontend..."
cd frontend
npm start &
sleep 5

# Verificar se o frontend está rodando
if curl -s http://localhost:3001 > /dev/null; then
    echo "✅ Frontend iniciado com sucesso em http://localhost:3001"
else
    echo "❌ Erro ao iniciar frontend. Verifique os logs."
    exit 1
fi

echo ""
echo "🎉 Deploy completo realizado com sucesso!"
echo ""
echo "📱 Acesse a aplicação:"
echo "   Frontend: http://localhost:3001"
echo "   Backend API: http://localhost:3000"
echo "   Documentação: http://localhost:3000/api-docs"
echo "   GraphQL: http://localhost:3000/graphql"
echo ""
echo "🔑 Credenciais de teste:"
echo "   Email: admin@biblioteca.com"
echo "   Senha: 123456"
echo ""
echo "📊 Para verificar logs:"
echo "   Backend: tail -f log/development.log"
echo "   Frontend: Ver terminal do npm start"
echo ""
echo "🛑 Para parar as aplicações:"
echo "   ./stop-all.sh"
