# Use a imagem oficial do Ruby
FROM ruby:3.3.0

# Instalar dependências do sistema
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Definir diretório de trabalho
WORKDIR /app

# Copiar Gemfile e Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Instalar gems
RUN bundle install

# Copiar código da aplicação
COPY . .

# Criar diretórios necessários
RUN mkdir -p tmp/pids

# Expor porta
EXPOSE 3000

# Comando para iniciar a aplicação
CMD ["rails", "server", "-b", "0.0.0.0"]