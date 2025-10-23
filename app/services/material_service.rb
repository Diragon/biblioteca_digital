require "ostruct"

class MaterialService
  # Método de classe para criar um material com seus dados específicos
  def self.criar_material(usuario, parametros)
    # Inicia uma transação para garantir consistência
    ActiveRecord::Base.transaction do
      # Cria o material base
      material = criar_material_base(usuario, parametros)

      # Se o material foi criado com sucesso, cria o tipo específico
      if material.persisted?
        criar_tipo_especifico(material, parametros)
      end

      # Retorna o material com os dados específicos carregados
      material.reload
    end
  rescue StandardError => e
    # Em caso de erro, retorna um objeto com erro
    OpenStruct.new(
      persisted?: false,
      errors: { base: [ e.message ] }
    )
  end

  # Método de classe para criar um livro com busca automática de dados
  def self.criar_livro_com_isbn(usuario, parametros)
    # Inicia uma transação para garantir consistência
    ActiveRecord::Base.transaction do
      # Se ISBN foi fornecido, busca dados na API OpenLibrary
      if parametros[:isbn].present?
        dados_api = buscar_dados_livro_isbn(parametros[:isbn])

        # Se encontrou dados na API, preenche campos não fornecidos
        if dados_api[:sucesso]
          preencher_dados_api(parametros, dados_api)
        end
      end

      # Cria o material e o livro
      criar_material(usuario, parametros.merge(tipo: "Livro"))
    end
  end

  # Método de classe para atualizar um material
  def self.atualizar_material(material, usuario, parametros)
    # Verifica se o usuário pode editar o material
    unless material.pode_ser_editado_por?(usuario)
      return OpenStruct.new(
        persisted?: false,
        errors: { base: [ "Você não tem permissão para editar este material" ] }
      )
    end

    # Inicia uma transação para garantir consistência
    ActiveRecord::Base.transaction do
      # Atualiza o material base
      material.update!(parametros.except(:isbn, :doi, :duracao_minutos, :numero_paginas))

      # Atualiza o tipo específico se necessário
      atualizar_tipo_especifico(material, parametros)

      # Retorna o material atualizado
      material.reload
    end
  rescue StandardError => e
    # Em caso de erro, retorna um objeto com erro
    OpenStruct.new(
      persisted?: false,
      errors: { base: [ e.message ] }
    )
  end

  # Método de classe para excluir um material
  def self.excluir_material(material, usuario)
    # Verifica se o usuário pode excluir o material
    unless material.pode_ser_excluido_por?(usuario)
      return OpenStruct.new(
        sucesso: false,
        erro: "Você não tem permissão para excluir este material"
      )
    end

    # Exclui o material (cascade excluirá o tipo específico)
    material.destroy!

    OpenStruct.new(sucesso: true)
  rescue StandardError => e
    # Em caso de erro, retorna um objeto com erro
    OpenStruct.new(
      sucesso: false,
      erro: e.message
    )
  end

  private

  # Cria o material base
  def self.criar_material_base(usuario, parametros)
    # Parâmetros específicos do material base
    parametros_material = parametros.slice(
      :tipo, :titulo, :descricao, :status, :autor_id
    )

    # Adiciona o usuário criador
    parametros_material[:usuario] = usuario

    # Cria o material
    Material.create!(parametros_material)
  end

  # Cria o tipo específico do material
  def self.criar_tipo_especifico(material, parametros)
    case material.tipo
    when "Livro"
      criar_livro(material, parametros)
    when "Artigo"
      criar_artigo(material, parametros)
    when "Video"
      criar_video(material, parametros)
    end
  end

  # Cria um livro
  def self.criar_livro(material, parametros)
    Livro.create!(
      material: material,
      isbn: parametros[:isbn],
      numero_paginas: parametros[:numero_paginas]
    )
  end

  # Cria um artigo
  def self.criar_artigo(material, parametros)
    Artigo.create!(
      material: material,
      doi: parametros[:doi]
    )
  end

  # Cria um vídeo
  def self.criar_video(material, parametros)
    Video.create!(
      material: material,
      duracao_minutos: parametros[:duracao_minutos]
    )
  end

  # Busca dados do livro por ISBN na API OpenLibrary
  def self.buscar_dados_livro_isbn(isbn)
    OpenLibraryService.buscar_livro_por_isbn(isbn)
  end

  # Preenche parâmetros com dados da API se não foram fornecidos
  def self.preencher_dados_api(parametros, dados_api)
    # Preenche título se não foi fornecido
    parametros[:titulo] ||= dados_api[:titulo]

    # Preenche número de páginas se não foi fornecido
    parametros[:numero_paginas] ||= dados_api[:numero_paginas]

    # Preenche descrição se não foi fornecida
    parametros[:descricao] ||= dados_api[:descricao]

    # Se não foi fornecido autor e encontrou autores na API, cria o primeiro autor
    if parametros[:autor_id].blank? && dados_api[:autores].present?
      autor = criar_autor_automatico(dados_api[:autores].first)
      parametros[:autor_id] = autor.id if autor
    end
  end

  # Cria um autor automaticamente baseado no nome da API
  def self.criar_autor_automatico(nome_autor)
    # Busca se já existe um autor com esse nome
    autor_existente = Autor.find_by(nome: nome_autor, tipo: "Pessoa")

    if autor_existente
      autor_existente
    else
      # Cria um novo autor como pessoa
      Autor.create!(
        nome: nome_autor,
        tipo: "Pessoa",
        data_nascimento: Date.new(1900, 1, 1) # Data padrão
      )
    end
  rescue StandardError
    # Se não conseguir criar o autor, retorna nil
    nil
  end

  # Atualiza o tipo específico do material
  def self.atualizar_tipo_especifico(material, parametros)
    case material.tipo
    when "Livro"
      atualizar_livro(material, parametros)
    when "Artigo"
      atualizar_artigo(material, parametros)
    when "Video"
      atualizar_video(material, parametros)
    end
  end

  # Atualiza um livro
  def self.atualizar_livro(material, parametros)
    livro = material.livro
    if livro
      update_params = {}
      update_params[:isbn] = parametros[:isbn] if parametros[:isbn].present?
      update_params[:numero_paginas] = parametros[:numero_paginas] if parametros[:numero_paginas].present?

      livro.update!(update_params) if update_params.any?
    end
  end

  # Atualiza um artigo
  def self.atualizar_artigo(material, parametros)
    artigo = material.artigo
    if artigo && parametros[:doi].present?
      artigo.update!(doi: parametros[:doi])
    end
  end

  # Atualiza um vídeo
  def self.atualizar_video(material, parametros)
    video = material.video
    if video && parametros[:duracao_minutos].present?
      video.update!(duracao_minutos: parametros[:duracao_minutos])
    end
  end
end
