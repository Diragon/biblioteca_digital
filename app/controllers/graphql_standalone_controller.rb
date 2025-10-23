# frozen_string_literal: true

class GraphqlStandaloneController < ActionController::API
  # Controller completamente independente para GraphQL

  def execute
    # Resposta simples sem usar o banco de dados
    render json: {
      data: {
        teste: "GraphQL está funcionando! #{Time.current}"
      }
    }
  rescue StandardError => e
    render json: {
      errors: [ { message: e.message } ],
      data: {}
    }, status: 500
  end
end
