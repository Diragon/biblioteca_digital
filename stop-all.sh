#!/bin/bash
# stop-all.sh - Script para parar todas as aplicações

echo "🛑 Parando todas as aplicações da Biblioteca Digital..."

# Parar Rails server
echo "🔄 Parando backend (Rails)..."
pkill -f "rails server" || echo "   Backend já estava parado"

# Parar npm start
echo "🔄 Parando frontend (React)..."
pkill -f "npm start" || echo "   Frontend já estava parado"

# Parar processos Node.js relacionados ao React
echo "🔄 Parando processos Node.js..."
pkill -f "react-scripts" || echo "   Processos React já estavam parados"

# Aguardar um momento
sleep 2

# Verificar se ainda há processos rodando
RAILS_PID=$(lsof -ti:3000)
NODE_PID=$(lsof -ti:3001)

if [ ! -z "$RAILS_PID" ]; then
    echo "🔪 Forçando parada do processo na porta 3000 (PID: $RAILS_PID)..."
    kill -9 $RAILS_PID
fi

if [ ! -z "$NODE_PID" ]; then
    echo "🔪 Forçando parada do processo na porta 3001 (PID: $NODE_PID)..."
    kill -9 $NODE_PID
fi

# Verificar se as portas estão livres
echo "🔍 Verificando portas..."

if lsof -ti:3000 > /dev/null 2>&1; then
    echo "⚠️  Porta 3000 ainda está ocupada"
else
    echo "✅ Porta 3000 liberada"
fi

if lsof -ti:3001 > /dev/null 2>&1; then
    echo "⚠️  Porta 3001 ainda está ocupada"
else
    echo "✅ Porta 3001 liberada"
fi

echo ""
echo "✅ Todas as aplicações foram paradas!"
echo ""
echo "🚀 Para iniciar novamente:"
echo "   ./deploy-complete.sh"
echo ""
echo "🔍 Para verificar processos:"
echo "   ps aux | grep rails"
echo "   ps aux | grep node"
