module Types
  class ArtigoType < Types::BaseObject
    # Campos do artigo
    field :id, ID, null: false
    field :doi, String, null: false
    field :doi_url, String, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    
    # Relacionamento com material
    field :material, Types::MaterialType, null: false

    # Métodos de instância

    # Retorna a URL do DOI
    def doi_url
      object.doi_url
    end
  end
end
