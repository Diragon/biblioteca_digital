class Video < ApplicationRecord
  # Relacionamentos
  # Vídeo pertence a um material
  belongs_to :material

  # Validações
  # Duração é obrigatória e deve ser um número inteiro maior que zero
  validates :duracao_minutos,
            presence: { message: "não pode estar em branco" },
            numericality: {
              only_integer: true,
              greater_than: 0,
              message: "deve ser um número inteiro maior que zero"
            }

  # Validação de relacionamento
  validates :material, presence: { message: "é obrigatório" }

  # Métodos de instância

  # Retorna a duração formatada em horas e minutos
  def duracao_formatada
    return nil unless duracao_minutos.present?

    horas = duracao_minutos / 60
    minutos = duracao_minutos % 60

    if horas > 0
      "#{horas}h #{minutos}min"
    else
      "#{minutos}min"
    end
  end

  # Retorna a duração em segundos
  def duracao_segundos
    return nil unless duracao_minutos.present?

    duracao_minutos * 60
  end

  # Retorna informações do vídeo para exibição
  def informacoes_completas
    {
      duracao_minutos: duracao_minutos,
      duracao_formatada: duracao_formatada,
      duracao_segundos: duracao_segundos,
      material: {
        titulo: material.titulo,
        descricao: material.descricao,
        status: material.status,
        autor: material.autor.nome_completo
      }
    }
  end

  # Métodos de classe

  # Busca vídeos por faixa de duração
  def self.por_duracao(min_minutos: nil, max_minutos: nil)
    videos = all

    # Aplica filtro de duração mínima se fornecido
    videos = videos.where("duracao_minutos >= ?", min_minutos) if min_minutos.present?

    # Aplica filtro de duração máxima se fornecido
    videos = videos.where("duracao_minutos <= ?", max_minutos) if max_minutos.present?

    videos
  end

  # Busca vídeos por categoria de duração
  def self.por_categoria_duracao(categoria)
    case categoria
    when "curto"
      where("duracao_minutos <= 10")
    when "medio"
      where("duracao_minutos > 10 AND duracao_minutos <= 60")
    when "longo"
      where("duracao_minutos > 60")
    else
      all
    end
  end

  # Retorna estatísticas de duração dos vídeos
  def self.estatisticas_duracao
    {
      total_videos: count,
      duracao_media: average(:duracao_minutos)&.round(2),
      duracao_minima: minimum(:duracao_minutos),
      duracao_maxima: maximum(:duracao_minutos),
      duracao_total: sum(:duracao_minutos)
    }
  end

  private

  # Callback para validar duração razoável
  def validar_duracao_razoavel
    # Limita a duração máxima a 24 horas (1440 minutos)
    if duracao_minutos.present? && duracao_minutos > 1440
      errors.add(:duracao_minutos, "não pode ser maior que 24 horas")
    end
  end

  # Executa a validação de duração razoável
  validate :validar_duracao_razoavel
end
