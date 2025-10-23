module Types
  class AutorType < Types::BaseObject
    # Campos do autor
    field :id, ID, null: false
    field :nome, String, null: false
    field :tipo, String, null: false
    field :data_nascimento, GraphQL::Types::ISO8601Date, null: true
    field :cidade, String, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    # Campos calculados
    field :nome_completo, String, null: false
    field :idade, Integer, null: true
    field :total_materiais, Integer, null: false

    # Lista de materiais do autor
    field :materials, [ Types::MaterialType ], null: true

    # Métodos de instância

    # Retorna o nome completo formatado
    def nome_completo
      object.nome_completo
    end

    # Retorna a idade se for pessoa
    def idade
      object.idade
    end

    # Retorna o total de materiais do autor
    def total_materiais
      object.materials.count
    end

    # Retorna os materiais do autor
    def materials
      object.materials.includes(:usuario, :livro, :artigo, :video)
    end
  end
end
