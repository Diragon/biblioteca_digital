class Artigo < ApplicationRecord
  # Relacionamentos
  # Artigo pertence a um material
  belongs_to :material

  # Validações
  # DOI é obrigatório e deve ser único
  validates :doi,
            presence: { message: "não pode estar em branco" },
            uniqueness: { message: "já está em uso" },
            format: {
              with: /\A10\.\d{4,}\/[^\s]+\z/,
              message: "deve seguir o formato padrão DOI (ex: 10.1000/xyz123)"
            }

  # Validação de relacionamento
  validates :material, presence: { message: "é obrigatório" }

  # Métodos de instância

  # Retorna o DOI formatado com URL
  def doi_url
    return nil unless doi.present?

    # Retorna o DOI como URL completa
    "https://doi.org/#{doi}"
  end

  # Retorna informações do artigo para exibição
  def informacoes_completas
    {
      doi: doi,
      doi_url: doi_url,
      material: {
        titulo: material.titulo,
        descricao: material.descricao,
        status: material.status,
        autor: material.autor.nome_completo
      }
    }
  end

  # Métodos de classe

  # Busca artigo por DOI
  def self.buscar_por_doi(doi)
    # Remove espaços e converte para minúsculo
    doi_limpo = doi.to_s.strip.downcase

    # Busca o artigo pelo DOI limpo
    find_by(doi: doi_limpo)
  end

  # Valida se o DOI tem o formato correto
  def self.doi_valido?(doi)
    # Remove espaços e converte para minúsculo
    doi_limpo = doi.to_s.strip.downcase

    # Verifica se segue o padrão DOI
    doi_limpo.match?(/\A10\.\d{4,}\/[^\s]+\z/)
  end

  private

  # Callback para normalizar o DOI antes de salvar
  def normalizar_doi
    # Remove espaços e converte para minúsculo
    self.doi = doi.to_s.strip.downcase if doi.present?
  end

  # Executa a normalização do DOI antes da validação
  before_validation :normalizar_doi
end
