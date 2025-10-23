# frozen_string_literal: true

# Este arquivo contém dados de exemplo para popular o banco de dados
# Execute com: rails db:seed

puts "🌱 Iniciando seeds da Biblioteca Digital..."

# Criar usuários de exemplo
puts "👤 Criando usuários..."

usuario1 = Usuario.create!(
  email: "admin@biblioteca.com",
  password: "admin123"
)

usuario2 = Usuario.create!(
  email: "editor@biblioteca.com",
  password: "editor123"
)

usuario3 = Usuario.create!(
  email: "pesquisador@biblioteca.com",
  password: "pesquisador123"
)

puts "✅ #{Usuario.count} usuários criados"

# Criar autores (pessoas)
puts "👥 Criando autores (pessoas)..."

autor1 = Autor.create!(
  nome: "João Silva",
  tipo: "Pessoa",
  data_nascimento: Date.new(1980, 5, 15)
)

autor2 = Autor.create!(
  nome: "Maria Santos",
  tipo: "Pessoa",
  data_nascimento: Date.new(1975, 8, 22)
)

autor3 = Autor.create!(
  nome: "Pedro Oliveira",
  tipo: "Pessoa",
  data_nascimento: Date.new(1990, 3, 10)
)

autor4 = Autor.create!(
  nome: "Ana Costa",
  tipo: "Pessoa",
  data_nascimento: Date.new(1985, 12, 5)
)

# Criar autores (instituições)
puts "🏛️ Criando autores (instituições)..."

autor5 = Autor.create!(
  nome: "Universidade Federal do Rio de Janeiro",
  tipo: "Instituicao",
  cidade: "Rio de Janeiro"
)

autor6 = Autor.create!(
  nome: "Instituto de Pesquisas Tecnológicas",
  tipo: "Instituicao",
  cidade: "São Paulo"
)

autor7 = Autor.create!(
  nome: "Fundação Getúlio Vargas",
  tipo: "Instituicao",
  cidade: "Rio de Janeiro"
)

puts "✅ #{Autor.count} autores criados"

# Criar materiais (livros)
puts "📚 Criando livros..."

material1 = Material.create!(
  tipo: "Livro",
  titulo: "Ruby on Rails: Guia Completo",
  descricao: "Um guia abrangente sobre desenvolvimento web com Ruby on Rails, cobrindo desde conceitos básicos até técnicas avançadas.",
  status: "publicado",
  usuario: usuario1,
  autor: autor1
)

Livro.create!(
  material: material1,
  isbn: "9780321765723",
  numero_paginas: 450
)

material2 = Material.create!(
  tipo: "Livro",
  titulo: "Programação Orientada a Objetos em Ruby",
  descricao: "Fundamentos e práticas de programação orientada a objetos usando a linguagem Ruby.",
  status: "publicado",
  usuario: usuario2,
  autor: autor2
)

Livro.create!(
  material: material2,
  isbn: "9780596516178",
  numero_paginas: 320
)

material3 = Material.create!(
  tipo: "Livro",
  titulo: "Desenvolvimento de APIs RESTful",
  descricao: "Como criar APIs RESTful robustas e escaláveis usando Ruby on Rails e boas práticas de desenvolvimento.",
  status: "rascunho",
  usuario: usuario1,
  autor: autor3
)

Livro.create!(
  material: material3,
  isbn: "9781491921706",
  numero_paginas: 280
)

# Criar materiais (artigos)
puts "📄 Criando artigos..."

material4 = Material.create!(
  tipo: "Artigo",
  titulo: "Análise de Performance em Aplicações Rails",
  descricao: "Estudo sobre técnicas de otimização e análise de performance em aplicações Ruby on Rails em produção.",
  status: "publicado",
  usuario: usuario3,
  autor: autor4
)

Artigo.create!(
  material: material4,
  doi: "10.1000/xyz123"
)

material5 = Material.create!(
  tipo: "Artigo",
  titulo: "Tendências em Desenvolvimento Web Moderno",
  descricao: "Análise das principais tendências e tecnologias emergentes no desenvolvimento web moderno.",
  status: "publicado",
  usuario: usuario2,
  autor: autor5
)

Artigo.create!(
  material: material5,
  doi: "10.1000/abc456"
)

material6 = Material.create!(
  tipo: "Artigo",
  titulo: "Segurança em APIs: Melhores Práticas",
  descricao: "Revisão das melhores práticas de segurança para desenvolvimento de APIs RESTful.",
  status: "arquivado",
  usuario: usuario1,
  autor: autor6
)

Artigo.create!(
  material: material6,
  doi: "10.1000/def789"
)

# Criar materiais (vídeos)
puts "🎥 Criando vídeos..."

material7 = Material.create!(
  tipo: "Video",
  titulo: "Introdução ao Ruby on Rails",
  descricao: "Vídeo tutorial introdutório sobre Ruby on Rails, cobrindo instalação, configuração e primeiros passos.",
  status: "publicado",
  usuario: usuario1,
  autor: autor1
)

Video.create!(
  material: material7,
  duracao_minutos: 45
)

material8 = Material.create!(
  tipo: "Video",
  titulo: "Testes Automatizados com RSpec",
  descricao: "Workshop sobre como implementar testes automatizados em aplicações Rails usando RSpec.",
  status: "publicado",
  usuario: usuario2,
  autor: autor2
)

Video.create!(
  material: material8,
  duracao_minutos: 90
)

material9 = Material.create!(
  tipo: "Video",
  titulo: "Deploy de Aplicações Rails",
  descricao: "Tutorial completo sobre deploy de aplicações Rails em diferentes ambientes de produção.",
  status: "rascunho",
  usuario: usuario3,
  autor: autor7
)

Video.create!(
  material: material9,
  duracao_minutos: 120
)

material10 = Material.create!(
  tipo: "Video",
  titulo: "GraphQL vs REST: Comparação Prática",
  descricao: "Análise comparativa entre GraphQL e REST APIs, com exemplos práticos de implementação.",
  status: "publicado",
  usuario: usuario1,
  autor: autor3
)

Video.create!(
  material: material10,
  duracao_minutos: 60
)

puts "✅ #{Material.count} materiais criados"
puts "   - #{Material.por_tipo('Livro').count} livros"
puts "   - #{Material.por_tipo('Artigo').count} artigos"
puts "   - #{Material.por_tipo('Video').count} vídeos"

# Estatísticas finais
puts "\n📊 Estatísticas finais:"
puts "   - Usuários: #{Usuario.count}"
puts "   - Autores: #{Autor.count} (#{Autor.where(tipo: 'Pessoa').count} pessoas, #{Autor.where(tipo: 'Instituicao').count} instituições)"
puts "   - Materiais: #{Material.count}"
puts "   - Livros: #{Livro.count}"
puts "   - Artigos: #{Artigo.count}"
puts "   - Vídeos: #{Video.count}"

puts "\n🎉 Seeds concluídos com sucesso!"
puts "\n📝 Credenciais de acesso:"
puts "   Admin: admin@biblioteca.com / admin123"
puts "   Editor: editor@biblioteca.com / editor123"
puts "   Pesquisador: pesquisador@biblioteca.com / pesquisador123"
puts "\n🌐 Acesse a documentação em: http://localhost:3000/api-docs"
