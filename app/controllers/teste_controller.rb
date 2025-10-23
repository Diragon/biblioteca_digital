# frozen_string_literal: true

class TesteController < ActionController::API
  # Controller simples para testar se o problema é específico do GraphQL
  
  def index
    render json: { 
      mensagem: "API REST está funcionando!",
      timestamp: Time.current,
      status: "ok"
    }
  end
end
