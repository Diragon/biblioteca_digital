class MaterialsController < ApplicationController
  # Inclui o concern de autenticação JWT
  include AutenticacaoJwt

  # Desabilita autenticação para listagem e visualização (apenas para operações de escrita)
  skip_before_action :autenticar_usuario!, only: [ :index, :show, :buscar, :estatisticas ]

  # GET /materials
  # Lista todos os materiais com paginação e filtros
  def index
    # Parâmetros de paginação
    page = params[:page] || 1
    per_page = params[:per_page] || 10

    # Filtros opcionais
    tipo = params[:tipo]
    status = params[:status]
    autor_id = params[:autor_id]
    termo_busca = params[:q]

    # Busca materiais com paginação
    materiais = Material.buscar_com_paginacao(
      termo_busca: termo_busca,
      tipo: tipo,
      status: status,
      autor_id: autor_id,
      page: page,
      per_page: per_page
    )

    # Serializa os dados
    dados_materiais = materiais.includes(:autor, :usuario).map do |material|
      {
        id: material.id,
        titulo: material.titulo,
        descricao: material.descricao,
        tipo: material.tipo,
        status: material.status,
        autor: {
          id: material.autor.id,
          nome: material.autor.nome,
          tipo: material.autor.tipo
        },
        criado_por: material.usuario.email,
        criado_em: material.created_at,
        atualizado_em: material.updated_at,
        informacoes_especificas: material.informacoes_especificas
      }
    end

    # Retorna resposta com paginação
    render json: {
      sucesso: true,
      dados: dados_materiais,
      paginacao: metadados_paginacao(Material.all, page: page, per_page: per_page)
    }
  end

  # GET /materials/:id
  # Mostra detalhes de um material específico
  def show
    # Busca o material pelo ID
    material = Material.find(params[:id])

    # Serializa os dados do material
    dados_material = {
      id: material.id,
      titulo: material.titulo,
      descricao: material.descricao,
      tipo: material.tipo,
      status: material.status,
      autor: {
        id: material.autor.id,
        nome: material.autor.nome,
        tipo: material.autor.tipo,
        nome_completo: material.autor.nome_completo
      },
      criado_por: {
        id: material.usuario.id,
        email: material.usuario.email
      },
      criado_em: material.created_at,
      atualizado_em: material.updated_at,
      informacoes_especificas: material.informacoes_especificas,
      pode_editar: usuario_autenticado? ? material.pode_ser_editado_por?(usuario_atual) : false,
      pode_excluir: usuario_autenticado? ? material.pode_ser_excluido_por?(usuario_atual) : false
    }

    render_sucesso(dados_material)
  end

  # POST /materials
  # Cria um novo material
  def create
    # Valida parâmetros obrigatórios
    campos_obrigatorios = [ :tipo, :titulo, :autor_id ]
    unless validar_parametros_obrigatorios(material_params, campos_obrigatorios)
      return
    end

    # Cria o material usando o serviço
    resultado = MaterialService.criar_material(usuario_atual, material_params)

    if resultado.persisted?
      # Serializa os dados do material criado
      dados_material = serializar_material(resultado)

      render_sucesso_criacao(dados_material, "Material criado com sucesso")
    else
      render_erro_validacao(resultado)
    end
  end

  # PUT /materials/:id
  # Atualiza um material existente
  def update
    # Busca o material pelo ID
    material = Material.find(params[:id])

    # Atualiza o material usando o serviço
    resultado = MaterialService.atualizar_material(material, usuario_atual, material_params)

    if resultado.persisted?
      # Serializa os dados do material atualizado
      dados_material = serializar_material(resultado)

      render_sucesso_atualizacao(dados_material, "Material atualizado com sucesso")
    else
      render_erro_validacao(resultado)
    end
  end

  # DELETE /materials/:id
  # Exclui um material
  def destroy
    # Busca o material pelo ID
    material = Material.find(params[:id])

    # Exclui o material usando o serviço
    resultado = MaterialService.excluir_material(material, usuario_atual)

    if resultado.sucesso
      render_sucesso_exclusao("Material excluído com sucesso")
    else
      render json: {
        erro: resultado.erro,
        codigo: "ERRO_EXCLUSAO"
      }, status: :unprocessable_entity
    end
  end

  # GET /materials/:id/detalhes
  # Retorna detalhes específicos do tipo de material
  def detalhes
    # Busca o material pelo ID
    material = Material.find(params[:id])

    # Retorna detalhes específicos baseado no tipo
    case material.tipo
    when "Livro"
      render_sucesso(material.livro&.informacoes_completas)
    when "Artigo"
      render_sucesso(material.artigo&.informacoes_completas)
    when "Video"
      render_sucesso(material.video&.informacoes_completas)
    else
      render_erro_nao_encontrado("Tipo de material não suportado")
    end
  end

  # GET /buscar
  # Busca materiais por termo
  def buscar
    # Parâmetros de busca
    termo = params[:q]
    tipo = params[:tipo]
    status = params[:status]
    autor_id = params[:autor_id]
    page = params[:page] || 1
    per_page = params[:per_page] || 10

    # Valida se termo de busca foi fornecido
    unless termo.present?
      render json: {
        erro: "Termo de busca é obrigatório",
        codigo: "ERRO_TERMO_BUSCA"
      }, status: :bad_request
      return
    end

    # Busca materiais
    materiais = Material.buscar_com_paginacao(
      termo_busca: termo,
      tipo: tipo,
      status: status,
      autor_id: autor_id,
      page: page,
      per_page: per_page
    )

    # Serializa os dados
    dados_materiais = materiais.includes(:autor, :usuario).map do |material|
      serializar_material(material)
    end

    # Retorna resposta com paginação
    render json: {
      sucesso: true,
      termo_busca: termo,
      dados: dados_materiais,
      paginacao: metadados_paginacao(Material.all, page: page, per_page: per_page)
    }
  end

  # GET /estatisticas
  # Retorna estatísticas dos materiais
  def estatisticas
    # Calcula estatísticas gerais
    estatisticas = {
      total_materiais: Material.count,
      por_tipo: {
        livros: Material.por_tipo("Livro").count,
        artigos: Material.por_tipo("Artigo").count,
        videos: Material.por_tipo("Video").count
      },
      por_status: {
        rascunho: Material.por_status("rascunho").count,
        publicado: Material.por_status("publicado").count,
        arquivado: Material.por_status("arquivado").count
      },
      total_autores: Autor.count,
      total_usuarios: Usuario.count,
      materiais_recentes: Material.order(created_at: :desc).limit(5).map do |material|
        {
          id: material.id,
          titulo: material.titulo,
          tipo: material.tipo,
          autor: material.autor.nome,
          criado_em: material.created_at
        }
      end
    }

    render_sucesso(estatisticas)
  end

  private

  # Parâmetros permitidos para material
  def material_params
    params.permit(
      :tipo, :titulo, :descricao, :status, :autor_id,
      :isbn, :numero_paginas, :doi, :duracao_minutos
    )
  end

  # Serializa um material para resposta JSON
  def serializar_material(material)
    {
      id: material.id,
      titulo: material.titulo,
      descricao: material.descricao,
      tipo: material.tipo,
      status: material.status,
      autor: {
        id: material.autor.id,
        nome: material.autor.nome,
        tipo: material.autor.tipo
      },
      criado_por: material.usuario.email,
      criado_em: material.created_at,
      atualizado_em: material.updated_at,
      informacoes_especificas: material.informacoes_especificas
    }
  end
end
