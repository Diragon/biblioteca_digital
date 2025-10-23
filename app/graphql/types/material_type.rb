module Types
  class MaterialType < Types::BaseObject
    # Campos do material
    field :id, ID, null: false
    field :titulo, String, null: false
    field :descricao, String, null: true
    field :tipo, String, null: false
    field :status, String, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    # Relacionamentos
    field :autor, Types::AutorType, null: false
    field :usuario, Types::UsuarioType, null: false

    # Campos específicos do tipo
    field :livro, Types::LivroType, null: true
    field :artigo, Types::ArtigoType, null: true
    field :video, Types::VideoType, null: true

    # Campos calculados
    field :informacoes_especificas, GraphQL::Types::JSON, null: true
    field :pode_editar, Boolean, null: false
    field :pode_excluir, Boolean, null: false

    # Métodos de instância

    # Retorna informações específicas do tipo
    def informacoes_especificas
      object.informacoes_especificas
    end

    # Verifica se pode ser editado (requer contexto do usuário)
    def pode_editar
      return false unless context[:current_user]
      object.pode_ser_editado_por?(context[:current_user])
    end

    # Verifica se pode ser excluído (requer contexto do usuário)
    def pode_excluir
      return false unless context[:current_user]
      object.pode_ser_excluido_por?(context[:current_user])
    end
  end
end
