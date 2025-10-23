module Types
  class VideoType < Types::BaseObject
    # Campos do vídeo
    field :id, ID, null: false
    field :duracao_minutos, Integer, null: false
    field :duracao_formatada, String, null: true
    field :duracao_segundos, Integer, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    # Relacionamento com material
    field :material, Types::MaterialType, null: false

    # Métodos de instância

    # Retorna a duração formatada
    def duracao_formatada
      object.duracao_formatada
    end

    # Retorna a duração em segundos
    def duracao_segundos
      object.duracao_segundos
    end
  end
end
