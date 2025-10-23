module Autenticacao
  class AutenticacaoController < ApplicationController
  # Inclui o concern de autenticação JWT
  include AutenticacaoJwt

  # Desabilita autenticação para este controller (exceto para logout)
  skip_before_action :autenticar_usuario!, only: [:login, :registrar]

  # POST /autenticacao/login
  # Endpoint para fazer login do usuário
  def login
    # Valida parâmetros obrigatórios
    unless validar_parametros_obrigatorios(login_params, [:email, :password])
      return
    end

    # Autentica o usuário
    usuario = Usuario.autenticar(login_params[:email], login_params[:password])
    
    if usuario
      # Gera token JWT para o usuário
      token = gerar_token_para_usuario(usuario)
      
      # Retorna sucesso com token
      render json: {
        sucesso: true,
        mensagem: 'Login realizado com sucesso',
        dados: {
          token: token,
          usuario: {
            id: usuario.id,
            email: usuario.email,
            criado_em: usuario.created_at
          }
        }
      }, status: :ok
    else
      # Retorna erro de autenticação
      render_erro_autenticacao('Email ou senha inválidos')
    end
  end

  # POST /autenticacao/registrar
  # Endpoint para registrar novo usuário
  def registrar
    # Valida parâmetros obrigatórios
    unless validar_parametros_obrigatorios(registro_params, [:email, :password])
      return
    end

    # Cria novo usuário
    usuario = Usuario.new(registro_params)
    
    if usuario.save
      # Gera token JWT para o novo usuário
      token = gerar_token_para_usuario(usuario)
      
      # Retorna sucesso com token
      render_sucesso_criacao({
        token: token,
        usuario: {
          id: usuario.id,
          email: usuario.email,
          criado_em: usuario.created_at
        }
      }, 'Usuário registrado com sucesso')
    else
      # Retorna erro de validação
      render_erro_validacao(usuario)
    end
  end

  # POST /autenticacao/logout
  # Endpoint para fazer logout do usuário
  def logout
    # Como estamos usando JWT stateless, o logout é apenas informativo
    # Em uma implementação mais robusta, poderíamos manter uma blacklist de tokens
    
    render_sucesso(nil, 'Logout realizado com sucesso')
  end

  # GET /autenticacao/perfil
  # Endpoint para obter dados do usuário autenticado
  def perfil
    # Retorna dados do usuário atual
    render_sucesso({
      id: usuario_atual.id,
      email: usuario_atual.email,
      criado_em: usuario_atual.created_at,
      total_materiais: usuario_atual.materials.count
    })
  end

  # PUT /autenticacao/perfil
  # Endpoint para atualizar dados do usuário autenticado
  def atualizar_perfil
    # Parâmetros permitidos para atualização
    parametros_permitidos = sanitizar_parametros(
      atualizacao_perfil_params, 
      [:email, :password]
    )
    
    # Remove apenas campos de senha vazios para evitar validações desnecessárias
    parametros_permitidos = parametros_permitidos.reject { |k, v| k == :password && v.blank? }
    
    # Atualiza o usuário
    if usuario_atual.update(parametros_permitidos)
      render_sucesso_atualizacao({
        id: usuario_atual.id,
        email: usuario_atual.email,
        criado_em: usuario_atual.created_at
      }, 'Perfil atualizado com sucesso')
    else
      render_erro_validacao(usuario_atual)
    end
  end

  # GET /autenticacao/validar_token
  # Endpoint para validar se o token ainda é válido
  def validar_token
    # Se chegou até aqui, o token é válido (middleware já validou)
    render_sucesso({
      valido: true,
      usuario: {
        id: usuario_atual.id,
        email: usuario_atual.email
      }
    })
  end

  private

  # Parâmetros permitidos para login
  def login_params
    params.permit(:email, :password)
  end

  # Parâmetros permitidos para registro
  def registro_params
    params.permit(:email, :password)
  end

  # Parâmetros permitidos para atualização de perfil
  def atualizacao_perfil_params
    params.permit(:email, :password)
  end
  end
end
