class Autor < ApplicationRecord
  # Relacionamentos
  # Um autor pode ter muitos materiais
  has_many :materials, dependent: :restrict_with_error

  # Validações básicas
  # Nome é obrigatório
  validates :nome, 
            presence: { message: 'não pode estar em branco' }

  # Tipo é obrigatório e deve ser 'Pessoa' ou 'Instituicao'
  validates :tipo, 
            presence: { message: 'não pode estar em branco' },
            inclusion: { 
              in: %w[Pessoa Instituicao], 
              message: 'deve ser Pessoa ou Instituicao' 
            }

  # Validações específicas por tipo
  # Para pessoas: nome entre 3-80 caracteres, data de nascimento obrigatória
  validates :nome, 
            length: { 
              in: 3..80, 
              message: 'deve ter entre 3 e 80 caracteres' 
            }, 
            if: :pessoa?

  validates :data_nascimento, 
            presence: { message: 'é obrigatória para pessoas' },
            if: :pessoa?

  # Para instituições: nome entre 3-120 caracteres, cidade obrigatória
  validates :nome, 
            length: { 
              in: 3..120, 
              message: 'deve ter entre 3 e 120 caracteres' 
            }, 
            if: :instituicao?

  validates :cidade, 
            presence: { message: 'é obrigatória para instituições' },
            length: { 
              in: 2..80, 
              message: 'deve ter entre 2 e 80 caracteres' 
            },
            if: :instituicao?

  # Validação de data de nascimento não pode ser futura
  validates :data_nascimento, 
            comparison: { 
              less_than: Date.current, 
              message: 'não pode ser uma data futura' 
            },
            if: :data_nascimento_presente?

  # Métodos de instância

  # Verifica se o autor é uma pessoa
  def pessoa?
    tipo == 'Pessoa'
  end

  # Verifica se o autor é uma instituição
  def instituicao?
    tipo == 'Instituicao'
  end

  # Retorna o nome formatado com tipo
  def nome_completo
    if pessoa?
      "#{nome} (Pessoa)"
    else
      "#{nome} (Instituição)"
    end
  end

  # Calcula a idade se for uma pessoa
  def idade
    return nil unless pessoa? && data_nascimento.present?
    
    hoje = Date.current
    idade = hoje.year - data_nascimento.year
    idade -= 1 if hoje < data_nascimento + idade.years
    idade
  end

  private

  # Verifica se data de nascimento está presente
  def data_nascimento_presente?
    data_nascimento.present?
  end
end
