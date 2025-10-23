class Livro < ApplicationRecord
  # Relacionamentos
  # Livro pertence a um material
  belongs_to :material

  # Validações
  # ISBN é obrigatório e deve ser único
  validates :isbn,
            presence: { message: "não pode estar em branco" },
            uniqueness: { message: "já está em uso" },
            length: {
              is: 13,
              message: "deve ter exatamente 13 caracteres"
            },
            format: {
              with: /\A\d{13}\z/,
              message: "deve conter apenas números"
            }

  # Número de páginas é obrigatório e deve ser maior que zero
  validates :numero_paginas,
            presence: { message: "não pode estar em branco" },
            numericality: {
              greater_than: 0,
              message: "deve ser maior que zero"
            }

  # Validação de relacionamento
  validates :material, presence: { message: "é obrigatório" }

  # Métodos de instância

  # Retorna o ISBN formatado (XXX-XX-XXXXX-XX-X)
  def isbn_formatado
    return nil unless isbn.present?

    # Formata o ISBN no padrão XXX-XX-XXXXX-XX-X
    "#{isbn[0..2]}-#{isbn[3..4]}-#{isbn[5..9]}-#{isbn[10..11]}-#{isbn[12]}"
  end

  # Retorna informações do livro para exibição
  def informacoes_completas
    {
      isbn: isbn,
      isbn_formatado: isbn_formatado,
      numero_paginas: numero_paginas,
      material: {
        titulo: material.titulo,
        descricao: material.descricao,
        status: material.status,
        autor: material.autor.nome_completo
      }
    }
  end

  # Métodos de classe

  # Busca livro por ISBN
  def self.buscar_por_isbn(isbn)
    # Remove caracteres não numéricos do ISBN
    isbn_limpo = isbn.to_s.gsub(/\D/, "")

    # Busca o livro pelo ISBN limpo
    find_by(isbn: isbn_limpo)
  end

  # Valida se o ISBN tem o formato correto
  def self.isbn_valido?(isbn)
    # Remove caracteres não numéricos
    isbn_limpo = isbn.to_s.gsub(/\D/, "")

    # Verifica se tem exatamente 13 dígitos
    isbn_limpo.length == 13 && isbn_limpo.match?(/\A\d{13}\z/)
  end

  private

  # Callback para limpar o ISBN antes de salvar
  def limpar_isbn
    # Remove caracteres não numéricos do ISBN
    self.isbn = isbn.to_s.gsub(/\D/, "") if isbn.present?
  end

  # Executa a limpeza do ISBN antes da validação
  before_validation :limpar_isbn
end
