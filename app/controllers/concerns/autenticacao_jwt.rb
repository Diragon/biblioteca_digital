module AutenticacaoJwt
  extend ActiveSupport::Concern

  # Método para autenticar usuário via JWT
  def autenticar_usuario!
    # Extrai o token do header Authorization
    token = extrair_token_do_header

    # Verifica se o token foi fornecido
    unless token
      render_erro_autenticacao("Token de autenticação não fornecido")
      return
    end

    # Busca o usuário pelo token
    @usuario_atual = Usuario.encontrar_por_token(token)

    # Verifica se o usuário foi encontrado
    unless @usuario_atual
      render_erro_autenticacao("Token de autenticação inválido ou expirado")
      nil
    end
  end

  # Método para autenticar usuário opcionalmente (não bloqueia se não autenticado)
  def autenticar_usuario_opcional
    # Extrai o token do header Authorization
    token = extrair_token_do_header

    # Se não há token, define usuário como nil
    unless token
      @usuario_atual = nil
      return
    end

    # Busca o usuário pelo token
    @usuario_atual = Usuario.encontrar_por_token(token)
  end

  # Método para verificar se o usuário está autenticado
  def usuario_autenticado?
    @usuario_atual.present?
  end

  # Método para obter o usuário atual
  def usuario_atual
    @usuario_atual
  end

  # Método para gerar token JWT para um usuário
  def gerar_token_para_usuario(usuario)
    usuario.gerar_token_jwt
  end

  # Método para renderizar erro de autenticação
  def render_erro_autenticacao(mensagem)
    render json: {
      erro: mensagem,
      codigo: "ERRO_AUTENTICACAO"
    }, status: :unauthorized
  end

  # Método para renderizar erro de autorização
  def render_erro_autorizacao(mensagem = "Você não tem permissão para realizar esta ação")
    render json: {
      erro: mensagem,
      codigo: "ERRO_AUTORIZACAO"
    }, status: :forbidden
  end

  # Método para renderizar erro de validação
  def render_erro_validacao(objeto)
    if objeto.respond_to?(:errors) && objeto.errors.respond_to?(:full_messages)
      render json: {
        erro: "Dados inválidos",
        codigo: "ERRO_VALIDACAO",
        detalhes: objeto.errors.full_messages
      }, status: :unprocessable_entity
    else
      # Se for um Hash ou outro tipo de objeto
      render json: {
        erro: "Dados inválidos",
        codigo: "ERRO_VALIDACAO",
        detalhes: objeto.is_a?(Hash) ? objeto.values.flatten : [ objeto.to_s ]
      }, status: :unprocessable_entity
    end
  end

  # Método para renderizar erro não encontrado
  def render_erro_nao_encontrado(mensagem = "Recurso não encontrado")
    render json: {
      erro: mensagem,
      codigo: "ERRO_NAO_ENCONTRADO"
    }, status: :not_found
  end

  # Método para renderizar sucesso
  def render_sucesso(dados, mensagem = "Operação realizada com sucesso")
    render json: {
      sucesso: true,
      mensagem: mensagem,
      dados: dados
    }, status: :ok
  end

  # Método para renderizar sucesso de criação
  def render_sucesso_criacao(dados, mensagem = "Recurso criado com sucesso")
    render json: {
      sucesso: true,
      mensagem: mensagem,
      dados: dados
    }, status: :created
  end

  # Método para renderizar sucesso de atualização
  def render_sucesso_atualizacao(dados, mensagem = "Recurso atualizado com sucesso")
    render json: {
      sucesso: true,
      mensagem: mensagem,
      dados: dados
    }, status: :ok
  end

  # Método para renderizar sucesso de exclusão
  def render_sucesso_exclusao(mensagem = "Recurso excluído com sucesso")
    render json: {
      sucesso: true,
      mensagem: mensagem
    }, status: :ok
  end

  private

  # Extrai o token JWT do header Authorization
  def extrair_token_do_header
    # Obtém o header Authorization
    auth_header = request.headers["Authorization"]

    # Verifica se o header está presente e no formato correto
    if auth_header&.start_with?("Bearer ")
      # Remove o prefixo 'Bearer ' e retorna o token
      auth_header[7..-1]
    else
      nil
    end
  end

  # Método para validar parâmetros obrigatórios
  def validar_parametros_obrigatorios(parametros, campos_obrigatorios)
    campos_faltando = campos_obrigatorios.select { |campo| parametros[campo].blank? }

    if campos_faltando.any?
      render json: {
        erro: "Parâmetros obrigatórios não fornecidos",
        codigo: "ERRO_PARAMETROS",
        campos_faltando: campos_faltando
      }, status: :bad_request
      return false
    end

    true
  end

  # Método para sanitizar parâmetros
  def sanitizar_parametros(parametros, campos_permitidos)
    # Filtra apenas os campos permitidos
    parametros.slice(*campos_permitidos)
  end

  # Método para aplicar paginação
  def aplicar_paginacao(colecao, page: 1, per_page: 10)
    # Converte parâmetros para inteiros
    pagina = page.to_i
    por_pagina = per_page.to_i

    # Valida parâmetros de paginação
    pagina = 1 if pagina < 1
    por_pagina = 10 if por_pagina < 1
    por_pagina = 100 if por_pagina > 100 # Limita máximo de 100 por página

    # Calcula offset
    offset = (pagina - 1) * por_pagina

    # Aplica paginação
    colecao.limit(por_pagina).offset(offset)
  end

  # Método para gerar metadados de paginação
  def metadados_paginacao(colecao, page: 1, per_page: 10)
    pagina = page.to_i
    por_pagina = per_page.to_i

    {
      pagina_atual: pagina,
      itens_por_pagina: por_pagina,
      total_itens: colecao.count,
      total_paginas: (colecao.count.to_f / por_pagina).ceil,
      tem_proxima_pagina: (pagina * por_pagina) < colecao.count,
      tem_pagina_anterior: pagina > 1
    }
  end
end
