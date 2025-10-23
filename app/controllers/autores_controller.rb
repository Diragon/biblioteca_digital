class AutoresController < ApplicationController
  # Inclui o concern de autenticação JWT
  include AutenticacaoJwt

  # Desabilita autenticação para listagem e visualização (apenas para operações de escrita)
  skip_before_action :autenticar_usuario!, only: [ :index, :show ]

  # GET /autores
  # Lista todos os autores com paginação
  def index
    # Parâmetros de paginação
    page = params[:page] || 1
    per_page = params[:per_page] || 10

    # Filtros opcionais
    tipo = params[:tipo]
    termo_busca = params[:q]

    # Inicia com todos os autores
    autores = Autor.all

    # Aplica filtros se fornecidos
    autores = autores.where(tipo: tipo) if tipo.present?
    autores = autores.where("nome ILIKE ?", "%#{termo_busca}%") if termo_busca.present?

    # Ordena por nome
    autores = autores.order(:nome)

    # Aplica paginação
    autores_paginados = aplicar_paginacao(autores, page: page, per_page: per_page)

    # Serializa os dados
    dados_autores = autores_paginados.map do |autor|
      {
        id: autor.id,
        nome: autor.nome,
        tipo: autor.tipo,
        nome_completo: autor.nome_completo,
        data_nascimento: autor.data_nascimento,
        cidade: autor.cidade,
        idade: autor.idade,
        total_materiais: autor.materials.count,
        criado_em: autor.created_at
      }
    end

    # Retorna resposta com paginação
    render json: {
      sucesso: true,
      dados: dados_autores,
      paginacao: metadados_paginacao(autores, page: page, per_page: per_page)
    }
  end

  # GET /autores/:id
  # Mostra detalhes de um autor específico
  def show
    # Busca o autor pelo ID
    autor = Autor.find(params[:id])

    # Serializa os dados do autor
    dados_autor = {
      id: autor.id,
      nome: autor.nome,
      tipo: autor.tipo,
      nome_completo: autor.nome_completo,
      data_nascimento: autor.data_nascimento,
      cidade: autor.cidade,
      idade: autor.idade,
      total_materiais: autor.materials.count,
      criado_em: autor.created_at,
      atualizado_em: autor.updated_at,
      materiais: autor.materials.includes(:usuario).map do |material|
        {
          id: material.id,
          titulo: material.titulo,
          tipo: material.tipo,
          status: material.status,
          criado_por: material.usuario.email,
          criado_em: material.created_at
        }
      end
    }

    render_sucesso(dados_autor)
  end

  # POST /autores
  # Cria um novo autor
  def create
    # Valida parâmetros obrigatórios
    campos_obrigatorios = [ :nome, :tipo ]
    unless validar_parametros_obrigatorios(autor_params, campos_obrigatorios)
      return
    end

    # Cria o autor
    autor = Autor.new(autor_params)

    if autor.save
      # Serializa os dados do autor criado
      dados_autor = {
        id: autor.id,
        nome: autor.nome,
        tipo: autor.tipo,
        nome_completo: autor.nome_completo,
        data_nascimento: autor.data_nascimento,
        cidade: autor.cidade,
        idade: autor.idade,
        criado_em: autor.created_at
      }

      render_sucesso_criacao(dados_autor, "Autor criado com sucesso")
    else
      render_erro_validacao(autor)
    end
  end

  # PUT /autores/:id
  # Atualiza um autor existente
  def update
    # Busca o autor pelo ID
    autor = Autor.find(params[:id])

    # Atualiza o autor
    if autor.update(autor_params)
      # Serializa os dados do autor atualizado
      dados_autor = {
        id: autor.id,
        nome: autor.nome,
        tipo: autor.tipo,
        nome_completo: autor.nome_completo,
        data_nascimento: autor.data_nascimento,
        cidade: autor.cidade,
        idade: autor.idade,
        atualizado_em: autor.updated_at
      }

      render_sucesso_atualizacao(dados_autor, "Autor atualizado com sucesso")
    else
      render_erro_validacao(autor)
    end
  end

  # DELETE /autores/:id
  # Exclui um autor
  def destroy
    # Busca o autor pelo ID
    autor = Autor.find(params[:id])

    # Verifica se o autor tem materiais associados
    if autor.materials.any?
      render json: {
        erro: "Não é possível excluir autor que possui materiais associados",
        codigo: "ERRO_AUTOR_COM_MATERIAIS"
      }, status: :unprocessable_entity
      return
    end

    # Exclui o autor
    autor.destroy!

    render_sucesso_exclusao("Autor excluído com sucesso")
  end

  private

  # Parâmetros permitidos para autor
  def autor_params
    params.permit(:nome, :tipo, :data_nascimento, :cidade)
  end
end
