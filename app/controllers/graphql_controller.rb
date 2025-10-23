# frozen_string_literal: true

class GraphqlController < ApplicationController
  # Desabilita autenticação obrigatória para permitir consultas públicas
  skip_before_action :autenticar_usuario!

  def execute
        # Desabilita temporariamente a verificação de migrações pendentes para GraphQL
        # ActiveRecord::Base.connection.migration_context.check_pending_migrations = false
    
    variables = prepare_variables(params[:variables])
    query = params[:query]
    operation_name = params[:operationName]
    
    # Contexto com usuário atual (se autenticado)
    context = {
      current_user: usuario_atual,
      request: request
    }
    
    result = BibliotecaDigitalSchema.execute(query, variables: variables, context: context, operation_name: operation_name)
    render json: result
  rescue StandardError => e
    raise e unless Rails.env.development?
    handle_error_in_development(e)
  end

  private

  # Handle variables in form data, JSON body, or a blank value
  def prepare_variables(variables_param)
    case variables_param
    when String
      if variables_param.present?
        JSON.parse(variables_param) || {}
      else
        {}
      end
    when Hash
      variables_param
    when ActionController::Parameters
      variables_param.to_unsafe_hash # GraphQL-Ruby will validate name and type of incoming variables.
    when nil
      {}
    else
      raise ArgumentError, "Unexpected parameter: #{variables_param}"
    end
  end

  def handle_error_in_development(e)
    logger.error e.message
    logger.error e.backtrace.join("\n")

    render json: { errors: [{ message: e.message, backtrace: e.backtrace }], data: {} }, status: 500
  end
end
