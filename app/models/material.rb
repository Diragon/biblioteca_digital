class Material < ApplicationRecord
  # Relacionamentos
  # Material pertence a um usuário (criador)
  belongs_to :usuario
  # Material pertence a um autor
  belongs_to :autor
  
  # Relacionamentos polimórficos para tipos específicos
  # Um material pode ter um livro, artigo ou vídeo
  has_one :livro, dependent: :destroy
  has_one :artigo, dependent: :destroy
  has_one :video, dependent: :destroy

  # Validações
  # Tipo é obrigatório e deve ser um dos tipos válidos
  validates :tipo, 
            presence: { message: 'não pode estar em branco' },
            inclusion: { 
              in: %w[Livro Artigo Video], 
              message: 'deve ser Livro, Artigo ou Video' 
            }

  # Título é obrigatório e deve ter entre 3 e 100 caracteres
  validates :titulo, 
            presence: { message: 'não pode estar em branco' },
            length: { 
              in: 3..100, 
              message: 'deve ter entre 3 e 100 caracteres' 
            }

  # Descrição é opcional, mas se informada deve ter no máximo 1000 caracteres
  validates :descricao, 
            length: { 
              maximum: 1000, 
              message: 'deve ter no máximo 1000 caracteres' 
            },
            allow_blank: true

  # Status é obrigatório e deve ser um dos valores válidos
  validates :status, 
            presence: { message: 'não pode estar em branco' },
            inclusion: { 
              in: %w[rascunho publicado arquivado], 
              message: 'deve ser rascunho, publicado ou arquivado' 
            }

  # Validações de relacionamentos
  validates :usuario, presence: { message: 'é obrigatório' }
  validates :autor, presence: { message: 'é obrigatório' }

  # Scopes para consultas comuns
  # Busca materiais por status
  scope :por_status, ->(status) { where(status: status) }
  
  # Busca materiais publicados
  scope :publicados, -> { where(status: 'publicado') }
  
  # Busca materiais por tipo
  scope :por_tipo, ->(tipo) { where(tipo: tipo) }
  
  # Busca materiais por autor
  scope :por_autor, ->(autor_id) { where(autor_id: autor_id) }
  
  # Busca materiais por usuário criador
  scope :por_usuario, ->(usuario_id) { where(usuario_id: usuario_id) }

  # Busca textual por título ou descrição
  scope :buscar_por_texto, ->(termo) {
    where(
      "titulo ILIKE ? OR descricao ILIKE ?", 
      "%#{termo}%", 
      "%#{termo}%"
    )
  }

  # Métodos de instância

  # Retorna o objeto específico do tipo (livro, artigo ou vídeo)
  def objeto_especifico
    case tipo
    when 'Livro'
      livro
    when 'Artigo'
      artigo
    when 'Video'
      video
    end
  end

  # Verifica se o material pode ser editado por um usuário
  def pode_ser_editado_por?(usuario)
    # Apenas o usuário que criou o material pode editá-lo
    self.usuario == usuario
  end

  # Verifica se o material pode ser excluído por um usuário
  def pode_ser_excluido_por?(usuario)
    # Apenas o usuário que criou o material pode excluí-lo
    self.usuario == usuario
  end

  # Verifica se o material está publicado
  def publicado?
    status == 'publicado'
  end

  # Verifica se o material é um rascunho
  def rascunho?
    status == 'rascunho'
  end

  # Verifica se o material está arquivado
  def arquivado?
    status == 'arquivado'
  end

  # Retorna informações específicas do tipo
  def informacoes_especificas
    case tipo
    when 'Livro'
      {
        isbn: livro&.isbn,
        numero_paginas: livro&.numero_paginas
      }
    when 'Artigo'
      {
        doi: artigo&.doi
      }
    when 'Video'
      {
        duracao_minutos: video&.duracao_minutos
      }
    end
  end

  # Métodos de classe

  # Busca materiais com paginação
  def self.buscar_com_paginacao(termo_busca: nil, tipo: nil, status: nil, autor_id: nil, page: 1, per_page: 10)
    # Inicia com todos os materiais
    materiais = all
    
    # Aplica filtros se fornecidos
    materiais = materiais.buscar_por_texto(termo_busca) if termo_busca.present?
    materiais = materiais.por_tipo(tipo) if tipo.present?
    materiais = materiais.por_status(status) if status.present?
    materiais = materiais.por_autor(autor_id) if autor_id.present?
    
    # Ordena por data de criação (mais recentes primeiro)
    materiais = materiais.order(created_at: :desc)
    
    # Aplica paginação
    offset = (page.to_i - 1) * per_page.to_i
    materiais.limit(per_page.to_i).offset(offset)
  end

  private

  # Callback para validar se o tipo específico foi criado
  def validar_objeto_especifico
    case tipo
    when 'Livro'
      errors.add(:base, 'Livro deve ser criado') unless livro.present?
    when 'Artigo'
      errors.add(:base, 'Artigo deve ser criado') unless artigo.present?
    when 'Video'
      errors.add(:base, 'Vídeo deve ser criado') unless video.present?
    end
  end

  # Executa a validação do objeto específico após salvar
  after_save :validar_objeto_especifico
end
