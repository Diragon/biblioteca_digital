module Types
  class UsuarioType < Types::BaseObject
    # Campos do usuário
    field :id, ID, null: false
    field :email, String, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    # Contagem de materiais
    field :total_materiais, Integer, null: false

    # Lista de materiais do usuário
    field :materials, [ Types::MaterialType ], null: true

    # Métodos de instância

    # Retorna o total de materiais do usuário
    def total_materiais
      object.materials.count
    end

    # Retorna os materiais do usuário
    def materials
      object.materials.includes(:autor, :livro, :artigo, :video)
    end
  end
end
