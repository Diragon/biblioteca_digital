#!/bin/bash

# Script para iniciar o frontend da Biblioteca Digital

echo "🚀 Iniciando Frontend da Biblioteca Digital..."

# Navega para o diretório do frontend
cd frontend

# Verifica se o node_modules existe
if [ ! -d "node_modules" ]; then
    echo "📦 Instalando dependências..."
    npm install
fi

# Cria arquivo .env se não existir
if [ ! -f ".env" ]; then
    echo "⚙️ Criando arquivo de configuração..."
    cat > .env << EOF
# URL da API Rails
REACT_APP_API_URL=http://localhost:3000

# Configurações de desenvolvimento
GENERATE_SOURCEMAP=false

# Porta do frontend (para evitar conflito com a API)
PORT=3001
EOF
fi

echo "🎨 Iniciando servidor de desenvolvimento..."
echo "📱 Frontend estará disponível em: http://localhost:3001"
echo "🔗 API deve estar rodando em: http://localhost:3000"
echo ""
echo "Pressione Ctrl+C para parar o servidor"
echo ""

# Inicia o servidor
npm start
