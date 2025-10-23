class ApplicationController < ActionController::API
  # Inclui o concern de autenticação JWT
  include AutenticacaoJwt

  # Configura autenticação obrigatória para todos os controllers (exceto OPTIONS)
  before_action :autenticar_usuario!, unless: :options_request?

  # CORS configurado via rack-cors no initializer

  # Desabilita verificação de migrações pendentes para desenvolvimento
  # before_action :desabilitar_verificacao_migracoes, if: -> { Rails.env.development? }

  # Configura tratamento de exceções
  rescue_from StandardError, with: :tratar_erro_generico
  rescue_from ActiveRecord::RecordNotFound, with: :tratar_nao_encontrado
  rescue_from ActiveRecord::RecordInvalid, with: :tratar_erro_validacao

  # Método para tratar requisições OPTIONS (CORS preflight)
  def options
    head :ok
  end

  private

  # Verifica se é uma requisição OPTIONS (CORS preflight)
  def options_request?
    request.options?
  end

  # CORS configurado via rack-cors no initializer

  # Trata erros genéricos
  def tratar_erro_generico(erro)
    # Log do erro para debug
    Rails.logger.error "Erro genérico: #{erro.message}"
    Rails.logger.error erro.backtrace.join("\n")
    
    # Retorna erro genérico para o cliente
    render json: {
      erro: 'Erro interno do servidor',
      codigo: 'ERRO_INTERNO'
    }, status: :internal_server_error
  end

  # Trata registro não encontrado
  def tratar_nao_encontrado(erro)
    render_erro_nao_encontrado('Recurso não encontrado')
  end

  # Trata erro de validação
  def tratar_erro_validacao(erro)
    render_erro_validacao(erro.record)
  end
end
