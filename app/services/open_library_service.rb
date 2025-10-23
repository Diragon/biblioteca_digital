class OpenLibraryService
  # URL base da API OpenLibrary
  BASE_URL = 'https://openlibrary.org/api/books'

  # Método de classe para buscar informações de um livro por ISBN
  def self.buscar_livro_por_isbn(isbn)
    # Remove caracteres não numéricos do ISBN
    isbn_limpo = isbn.to_s.gsub(/\D/, '')
    
    # Valida se o ISBN tem 13 dígitos
    return { erro: 'ISBN deve ter exatamente 13 dígitos' } unless isbn_limpo.length == 13
    
    begin
      # Faz a requisição para a API OpenLibrary
      resposta = HTTParty.get(
        "#{BASE_URL}?bibkeys=ISBN:#{isbn_limpo}&format=json&jscmd=data",
        timeout: 10
      )
      
      # Verifica se a requisição foi bem-sucedida
      if resposta.success?
        # Processa a resposta da API
        processar_resposta_api(resposta, isbn_limpo)
      else
        # Retorna erro se a requisição falhou
        { erro: "Erro na API OpenLibrary: #{resposta.code}" }
      end
      
    rescue HTTParty::Error => e
      # Retorna erro de conexão
      { erro: "Erro de conexão com OpenLibrary: #{e.message}" }
    rescue StandardError => e
      # Retorna erro genérico
      { erro: "Erro inesperado: #{e.message}" }
    end
  end

  private

  # Processa a resposta da API OpenLibrary
  def self.processar_resposta_api(resposta, isbn)
    # Converte a resposta JSON
    dados = JSON.parse(resposta.body)
    
    # Chave do livro na resposta (formato: ISBN:XXXXXXXXXXXXX)
    chave_livro = "ISBN:#{isbn}"
    
    # Verifica se o livro foi encontrado
    if dados[chave_livro].present?
      livro_dados = dados[chave_livro]
      
      # Extrai as informações do livro
      {
        sucesso: true,
        titulo: extrair_titulo(livro_dados),
        numero_paginas: extrair_numero_paginas(livro_dados),
        autores: extrair_autores(livro_dados),
        data_publicacao: extrair_data_publicacao(livro_dados),
        editora: extrair_editora(livro_dados),
        idioma: extrair_idioma(livro_dados),
        descricao: extrair_descricao(livro_dados),
        isbn: isbn
      }
    else
      # Livro não encontrado
      { erro: 'Livro não encontrado na base de dados OpenLibrary' }
    end
  end

  # Extrai o título do livro
  def self.extrair_titulo(dados)
    dados['title']&.strip
  end

  # Extrai o número de páginas
  def self.extrair_numero_paginas(dados)
    # Tenta extrair de diferentes campos possíveis
    numero_paginas = dados['number_of_pages'] || 
                     dados['pagination'] || 
                     dados['pages']
    
    # Converte para inteiro se for uma string numérica
    if numero_paginas.is_a?(String) && numero_paginas.match?(/\A\d+\z/)
      numero_paginas.to_i
    elsif numero_paginas.is_a?(Integer)
      numero_paginas
    else
      nil
    end
  end

  # Extrai os autores do livro
  def self.extrair_autores(dados)
    return [] unless dados['authors'].present?
    
    # Mapeia os autores para um array de nomes
    dados['authors'].map do |autor|
      autor['name']&.strip
    end.compact
  end

  # Extrai a data de publicação
  def self.extrair_data_publicacao(dados)
    # Tenta extrair de diferentes campos possíveis
    data_publicacao = dados['publish_date'] || 
                      dados['publication_date'] || 
                      dados['date']
    
    data_publicacao&.strip
  end

  # Extrai a editora
  def self.extrair_editora(dados)
    # Tenta extrair de diferentes campos possíveis
    editora = dados['publishers']&.first&.dig('name') || 
              dados['publisher']&.first&.dig('name') ||
              dados['publisher']
    
    editora&.strip
  end

  # Extrai o idioma
  def self.extrair_idioma(dados)
    # Tenta extrair de diferentes campos possíveis
    idioma = dados['languages']&.first&.dig('key') || 
             dados['language']&.first&.dig('key') ||
             dados['language']
    
    # Remove prefixo '/languages/' se presente
    idioma&.gsub('/languages/', '')&.strip
  end

  # Extrai a descrição
  def self.extrair_descricao(dados)
    # Tenta extrair de diferentes campos possíveis
    descricao = dados['description'] || 
                dados['summary'] || 
                dados['excerpt']
    
    # Se for um hash, tenta extrair o valor
    if descricao.is_a?(Hash)
      descricao['value'] || descricao['text']
    else
      descricao&.strip
    end
  end
end
