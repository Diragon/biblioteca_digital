class LivrosController < ApplicationController
  # Inclui o concern de autenticação JWT
  include AutenticacaoJwt

  # Desabilita autenticação para listagem e visualização (apenas para operações de escrita)
  skip_before_action :autenticar_usuario!, only: [:index, :show, :buscar_por_isbn]

  # GET /livros
  # Lista todos os livros com paginação
  def index
    # Parâmetros de paginação
    page = params[:page] || 1
    per_page = params[:per_page] || 10
    
    # Filtros opcionais
    status = params[:status]
    autor_id = params[:autor_id]
    termo_busca = params[:q]
    
    # Busca livros
    livros = Livro.joins(:material)
                  .includes(material: [:autor, :usuario])
    
    # Aplica filtros
    livros = livros.where(materials: { status: status }) if status.present?
    livros = livros.where(materials: { autor_id: autor_id }) if autor_id.present?
    
    if termo_busca.present?
      livros = livros.where(
        "materials.titulo ILIKE ? OR materials.descricao ILIKE ?",
        "%#{termo_busca}%", "%#{termo_busca}%"
      )
    end
    
    # Ordena por data de criação
    livros = livros.order('materials.created_at DESC')
    
    # Aplica paginação
    livros_paginados = aplicar_paginacao(livros, page: page, per_page: per_page)
    
    # Serializa os dados
    dados_livros = livros_paginados.map do |livro|
      {
        id: livro.id,
        isbn: livro.isbn,
        isbn_formatado: livro.isbn_formatado,
        numero_paginas: livro.numero_paginas,
        material: {
          id: livro.material.id,
          titulo: livro.material.titulo,
          descricao: livro.material.descricao,
          status: livro.material.status,
          autor: {
            id: livro.material.autor.id,
            nome: livro.material.autor.nome,
            tipo: livro.material.autor.tipo
          },
          criado_por: livro.material.usuario.email,
          criado_em: livro.material.created_at
        }
      }
    end
    
    # Retorna resposta com paginação
    render json: {
      sucesso: true,
      dados: dados_livros,
      paginacao: metadados_paginacao(livros, page: page, per_page: per_page)
    }
  end

  # GET /livros/:id
  # Mostra detalhes de um livro específico
  def show
    # Busca o livro pelo ID
    livro = Livro.find(params[:id])
    
    # Serializa os dados do livro
    dados_livro = {
      id: livro.id,
      isbn: livro.isbn,
      isbn_formatado: livro.isbn_formatado,
      numero_paginas: livro.numero_paginas,
      material: {
        id: livro.material.id,
        titulo: livro.material.titulo,
        descricao: livro.material.descricao,
        status: livro.material.status,
        autor: {
          id: livro.material.autor.id,
          nome: livro.material.autor.nome,
          tipo: livro.material.autor.tipo,
          nome_completo: livro.material.autor.nome_completo
        },
        criado_por: {
          id: livro.material.usuario.id,
          email: livro.material.usuario.email
        },
        criado_em: livro.material.created_at,
        atualizado_em: livro.material.updated_at,
        pode_editar: usuario_autenticado? ? livro.material.pode_ser_editado_por?(usuario_atual) : false,
        pode_excluir: usuario_autenticado? ? livro.material.pode_ser_excluido_por?(usuario_atual) : false
      }
    }
    
    render_sucesso(dados_livro)
  end

  # POST /livros
  # Cria um novo livro
  def create
    # Valida parâmetros obrigatórios
    campos_obrigatorios = [:titulo, :autor_id, :isbn, :numero_paginas]
    unless validar_parametros_obrigatorios(livro_params, campos_obrigatorios)
      return
    end

    # Cria o livro usando o serviço
    resultado = MaterialService.criar_livro_com_isbn(usuario_atual, livro_params)
    
    if resultado.persisted?
      # Serializa os dados do livro criado
      dados_livro = serializar_livro(resultado)
      
      render_sucesso_criacao(dados_livro, 'Livro criado com sucesso')
    else
      render_erro_validacao(resultado)
    end
  end

  # PUT /livros/:id
  # Atualiza um livro existente
  def update
    # Busca o livro pelo ID
    livro = Livro.find(params[:id])
    
    # Atualiza o livro usando o serviço
    resultado = MaterialService.atualizar_material(livro.material, usuario_atual, livro_params)
    
    if resultado.persisted?
      # Serializa os dados do livro atualizado
      dados_livro = serializar_livro(resultado)
      
      render_sucesso_atualizacao(dados_livro, 'Livro atualizado com sucesso')
    else
      render_erro_validacao(resultado)
    end
  end

  # DELETE /livros/:id
  # Exclui um livro
  def destroy
    # Busca o livro pelo ID
    livro = Livro.find(params[:id])
    
    # Exclui o livro usando o serviço
    resultado = MaterialService.excluir_material(livro.material, usuario_atual)
    
    if resultado.sucesso
      render_sucesso_exclusao('Livro excluído com sucesso')
    else
      render json: {
        erro: resultado.erro,
        codigo: 'ERRO_EXCLUSAO'
      }, status: :unprocessable_entity
    end
  end

  # GET /livros/:id/buscar_isbn/:isbn
  # Busca informações de um livro por ISBN na API OpenLibrary
  def buscar_por_isbn
    # Obtém o ISBN dos parâmetros
    isbn = params[:isbn]
    
    # Valida se o ISBN foi fornecido
    unless isbn.present?
      render json: {
        erro: 'ISBN é obrigatório',
        codigo: 'ERRO_ISBN_OBRIGATORIO'
      }, status: :bad_request
      return
    end
    
    # Valida formato do ISBN
    unless Livro.isbn_valido?(isbn)
      render json: {
        erro: 'ISBN deve ter exatamente 13 dígitos numéricos',
        codigo: 'ERRO_ISBN_INVALIDO'
      }, status: :bad_request
      return
    end
    
    # Busca dados na API OpenLibrary
    dados_api = OpenLibraryService.buscar_livro_por_isbn(isbn)
    
    if dados_api[:sucesso]
      render_sucesso(dados_api)
    else
      render json: {
        erro: dados_api[:erro],
        codigo: 'ERRO_API_OPENLIBRARY'
      }, status: :unprocessable_entity
    end
  end

  private

  # Parâmetros permitidos para livro
  def livro_params
    params.permit(
      :titulo, :descricao, :status, :autor_id,
      :isbn, :numero_paginas
    )
  end

  # Serializa um livro para resposta JSON
  def serializar_livro(material)
    livro = material.livro
    {
      id: livro.id,
      isbn: livro.isbn,
      isbn_formatado: livro.isbn_formatado,
      numero_paginas: livro.numero_paginas,
      material: {
        id: material.id,
        titulo: material.titulo,
        descricao: material.descricao,
        status: material.status,
        autor: {
          id: material.autor.id,
          nome: material.autor.nome,
          tipo: material.autor.tipo
        },
        criado_por: material.usuario.email,
        criado_em: material.created_at,
        atualizado_em: material.updated_at
      }
    }
  end
end
