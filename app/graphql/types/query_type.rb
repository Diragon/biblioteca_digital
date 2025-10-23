# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    field :node, Types::NodeType, null: true, description: "Fetches an object given its ID." do
      argument :id, ID, required: true, description: "ID of the object."
    end

    def node(id:)
      context.schema.object_from_id(id, context)
    end

    field :nodes, [Types::NodeType, null: true], null: true, description: "Fetches a list of objects given a list of IDs." do
      argument :ids, [ID], required: true, description: "IDs of the objects."
    end

    def nodes(ids:)
      ids.map { |id| context.schema.object_from_id(id, context) }
    end

    # Consultas para materiais
    field :materials, [Types::MaterialType], null: true, description: "Lista todos os materiais" do
      argument :tipo, String, required: false, description: "Filtro por tipo de material"
      argument :status, String, required: false, description: "Filtro por status"
      argument :autor_id, ID, required: false, description: "Filtro por autor"
      argument :termo_busca, String, required: false, description: "Busca por título ou descrição"
      argument :page, Integer, required: false, description: "Número da página", default_value: 1
      argument :per_page, Integer, required: false, description: "Itens por página", default_value: 10
    end

    def materials(tipo: nil, status: nil, autor_id: nil, termo_busca: nil, page: 1, per_page: 10)
      Material.buscar_com_paginacao(
        termo_busca: termo_busca,
        tipo: tipo,
        status: status,
        autor_id: autor_id,
        page: page,
        per_page: per_page
      ).includes(:autor, :usuario, :livro, :artigo, :video)
    end

    # Consulta para um material específico
    field :material, Types::MaterialType, null: true, description: "Busca um material por ID" do
      argument :id, ID, required: true, description: "ID do material"
    end

    def material(id:)
      Material.find_by(id: id)
    end

    # Consultas para autores
    field :autores, [Types::AutorType], null: true, description: "Lista todos os autores" do
      argument :tipo, String, required: false, description: "Filtro por tipo de autor"
      argument :termo_busca, String, required: false, description: "Busca por nome"
      argument :page, Integer, required: false, description: "Número da página", default_value: 1
      argument :per_page, Integer, required: false, description: "Itens por página", default_value: 10
    end

    def autores(tipo: nil, termo_busca: nil, page: 1, per_page: 10)
      autores = Autor.all
      autores = autores.where(tipo: tipo) if tipo.present?
      autores = autores.where("nome ILIKE ?", "%#{termo_busca}%") if termo_busca.present?
      
      offset = (page - 1) * per_page
      autores.order(:nome).limit(per_page).offset(offset)
    end

    # Consulta para um autor específico
    field :autor, Types::AutorType, null: true, description: "Busca um autor por ID" do
      argument :id, ID, required: true, description: "ID do autor"
    end

    def autor(id:)
      Autor.find_by(id: id)
    end

    # Consultas para livros
    field :livros, [Types::LivroType], null: true, description: "Lista todos os livros" do
      argument :status, String, required: false, description: "Filtro por status do material"
      argument :autor_id, ID, required: false, description: "Filtro por autor"
      argument :termo_busca, String, required: false, description: "Busca por título ou descrição"
      argument :page, Integer, required: false, description: "Número da página", default_value: 1
      argument :per_page, Integer, required: false, description: "Itens por página", default_value: 10
    end

    def livros(status: nil, autor_id: nil, termo_busca: nil, page: 1, per_page: 10)
      livros = Livro.joins(:material).includes(material: [:autor, :usuario])
      
      livros = livros.where(materials: { status: status }) if status.present?
      livros = livros.where(materials: { autor_id: autor_id }) if autor_id.present?
      
      if termo_busca.present?
        livros = livros.where(
          "materials.titulo ILIKE ? OR materials.descricao ILIKE ?",
          "%#{termo_busca}%", "%#{termo_busca}%"
        )
      end
      
      offset = (page - 1) * per_page
      livros.order('materials.created_at DESC').limit(per_page).offset(offset)
    end

    # Consulta para um livro específico
    field :livro, Types::LivroType, null: true, description: "Busca um livro por ID" do
      argument :id, ID, required: true, description: "ID do livro"
    end

    def livro(id:)
      Livro.find_by(id: id)
    end

    # Consulta para buscar livro por ISBN
    field :livro_por_isbn, Types::LivroType, null: true, description: "Busca um livro por ISBN" do
      argument :isbn, String, required: true, description: "ISBN do livro"
    end

    def livro_por_isbn(isbn:)
      Livro.buscar_por_isbn(isbn)
    end

    # Consultas para artigos
    field :artigos, [Types::ArtigoType], null: true, description: "Lista todos os artigos" do
      argument :status, String, required: false, description: "Filtro por status do material"
      argument :autor_id, ID, required: false, description: "Filtro por autor"
      argument :termo_busca, String, required: false, description: "Busca por título ou descrição"
      argument :page, Integer, required: false, description: "Número da página", default_value: 1
      argument :per_page, Integer, required: false, description: "Itens por página", default_value: 10
    end

    def artigos(status: nil, autor_id: nil, termo_busca: nil, page: 1, per_page: 10)
      artigos = Artigo.joins(:material).includes(material: [:autor, :usuario])
      
      artigos = artigos.where(materials: { status: status }) if status.present?
      artigos = artigos.where(materials: { autor_id: autor_id }) if autor_id.present?
      
      if termo_busca.present?
        artigos = artigos.where(
          "materials.titulo ILIKE ? OR materials.descricao ILIKE ?",
          "%#{termo_busca}%", "%#{termo_busca}%"
        )
      end
      
      offset = (page - 1) * per_page
      artigos.order('materials.created_at DESC').limit(per_page).offset(offset)
    end

    # Consulta para um artigo específico
    field :artigo, Types::ArtigoType, null: true, description: "Busca um artigo por ID" do
      argument :id, ID, required: true, description: "ID do artigo"
    end

    def artigo(id:)
      Artigo.find_by(id: id)
    end

    # Consulta para buscar artigo por DOI
    field :artigo_por_doi, Types::ArtigoType, null: true, description: "Busca um artigo por DOI" do
      argument :doi, String, required: true, description: "DOI do artigo"
    end

    def artigo_por_doi(doi:)
      Artigo.buscar_por_doi(doi)
    end

    # Consultas para vídeos
    field :videos, [Types::VideoType], null: true, description: "Lista todos os vídeos" do
      argument :status, String, required: false, description: "Filtro por status do material"
      argument :autor_id, ID, required: false, description: "Filtro por autor"
      argument :termo_busca, String, required: false, description: "Busca por título ou descrição"
      argument :min_duracao, Integer, required: false, description: "Duração mínima em minutos"
      argument :max_duracao, Integer, required: false, description: "Duração máxima em minutos"
      argument :page, Integer, required: false, description: "Número da página", default_value: 1
      argument :per_page, Integer, required: false, description: "Itens por página", default_value: 10
    end

    def videos(status: nil, autor_id: nil, termo_busca: nil, min_duracao: nil, max_duracao: nil, page: 1, per_page: 10)
      videos = Video.joins(:material).includes(material: [:autor, :usuario])
      
      videos = videos.where(materials: { status: status }) if status.present?
      videos = videos.where(materials: { autor_id: autor_id }) if autor_id.present?
      
      if termo_busca.present?
        videos = videos.where(
          "materials.titulo ILIKE ? OR materials.descricao ILIKE ?",
          "%#{termo_busca}%", "%#{termo_busca}%"
        )
      end
      
      videos = Video.por_duracao(min_minutos: min_duracao, max_minutos: max_duracao) if min_duracao.present? || max_duracao.present?
      
      offset = (page - 1) * per_page
      videos.order('materials.created_at DESC').limit(per_page).offset(offset)
    end

    # Consulta para um vídeo específico
    field :video, Types::VideoType, null: true, description: "Busca um vídeo por ID" do
      argument :id, ID, required: true, description: "ID do vídeo"
    end

    def video(id:)
      Video.find_by(id: id)
    end

    # Consulta para estatísticas
    field :estatisticas, GraphQL::Types::JSON, null: false, description: "Retorna estatísticas da biblioteca"

    def estatisticas
      {
        total_materiais: Material.count,
        por_tipo: {
          livros: Material.por_tipo('Livro').count,
          artigos: Material.por_tipo('Artigo').count,
          videos: Material.por_tipo('Video').count
        },
        por_status: {
          rascunho: Material.por_status('rascunho').count,
          publicado: Material.por_status('publicado').count,
          arquivado: Material.por_status('arquivado').count
        },
        total_autores: Autor.count,
        total_usuarios: Usuario.count
      }
    end

    # Teste simples para verificar se GraphQL está funcionando
    field :teste, String, null: false, description: "Teste simples do GraphQL"

    def teste
      "GraphQL está funcionando! #{Time.current}"
    end
  end
end
