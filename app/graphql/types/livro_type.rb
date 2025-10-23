module Types
  class LivroType < Types::BaseObject
    # Campos do livro
    field :id, ID, null: false
    field :isbn, String, null: false
    field :isbn_formatado, String, null: true
    field :numero_paginas, Integer, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    
    # Relacionamento com material
    field :material, Types::MaterialType, null: false

    # Métodos de instância

    # Retorna o ISBN formatado
    def isbn_formatado
      object.isbn_formatado
    end
  end
end
