# frozen_string_literal: true

class GraphqlSimpleController < ActionController::API
  # Controller simples para GraphQL sem verificação de migrações

  def execute
    variables = prepare_variables(params[:variables])
    query = params[:query]
    operation_name = params[:operationName]

    # Contexto simples
    context = {
      current_user: nil,
      request: request
    }

    result = BibliotecaDigitalSchema.execute(query, variables: variables, context: context, operation_name: operation_name)
    render json: result
  rescue StandardError => e
    render json: {
      errors: [ { message: e.message, backtrace: e.backtrace } ],
      data: {}
    }, status: 500
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
      variables_param.to_unsafe_hash
    when nil
      {}
    else
      raise ArgumentError, "Unexpected parameter: #{variables_param}"
    end
  end
end
