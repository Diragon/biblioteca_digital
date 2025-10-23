class Usuario < ApplicationRecord
  # Configuração do bcrypt para hash de senhas
  has_secure_password

  # Relacionamentos
  # Um usuário pode ter muitos materiais
  has_many :materials, dependent: :destroy

  # Validações
  # Email é obrigatório, deve ser único e ter formato válido
  validates :email,
            presence: { message: "não pode estar em branco" },
            uniqueness: { message: "já está em uso" },
            format: {
              with: URI::MailTo::EMAIL_REGEXP,
              message: "deve ter um formato válido"
            }

  # Senha é obrigatória e deve ter no mínimo 6 caracteres (apenas na criação)
  validates :password,
            presence: { message: "não pode estar em branco" },
            length: {
              minimum: 6,
              message: "deve ter pelo menos 6 caracteres"
            },
            if: :password_required?

  # Métodos de instância

  # Gera um token JWT para autenticação
  def gerar_token_jwt
    # Payload do token contendo o ID do usuário
    payload = {
      usuario_id: id,
      exp: 24.hours.from_now.to_i
    }

    # Gera o token usando a chave secreta da aplicação
    JWT.encode(payload, Rails.application.secret_key_base)
  end

  # Método de classe para autenticar usuário por email e senha
  def self.autenticar(email, password)
    # Busca o usuário pelo email
    usuario = find_by(email: email.downcase.strip)

    # Verifica se o usuário existe e se a senha está correta
    if usuario&.authenticate(password)
      usuario
    else
      nil
    end
  end

  # Método de classe para encontrar usuário pelo token JWT
  def self.encontrar_por_token(token)
    begin
      # Decodifica o token JWT
      payload = JWT.decode(token, Rails.application.secret_key_base)[0]

      # Busca o usuário pelo ID do payload
      find(payload["usuario_id"])
    rescue JWT::DecodeError, ActiveRecord::RecordNotFound
      # Retorna nil se o token for inválido ou usuário não encontrado
      nil
    end
  end

  private

  # Callback para normalizar o email antes de salvar
  def normalizar_email
    self.email = email.downcase.strip if email.present?
  end

  # Verifica se a senha é obrigatória (apenas na criação ou quando está sendo alterada)
  def password_required?
    new_record? || password.present?
  end

  # Executa a normalização do email antes da validação
  before_validation :normalizar_email
end
