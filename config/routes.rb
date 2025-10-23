Rails.application.routes.draw do
  # Rota para CORS preflight requests
  match "*path", to: "application#options", via: :options

  post "/graphql", to: "graphql#execute"
  post "/graphql-simple", to: "graphql_simple#execute"
  post "/graphql-standalone", to: "graphql_standalone#execute"
  get "/teste", to: "teste#index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Rotas de autenticação
  namespace :autenticacao do
    post "login", to: "autenticacao#login"
    post "registrar", to: "autenticacao#registrar"
    post "logout", to: "autenticacao#logout"
    get "perfil", to: "autenticacao#perfil"
    put "perfil", to: "autenticacao#atualizar_perfil"
    get "validar_token", to: "autenticacao#validar_token"
  end

  # Rotas de autores
  resources :autores, only: [ :index, :show, :create, :update, :destroy ] do
    # Rotas aninhadas para materiais do autor
    resources :materials, only: [ :index ], module: :autores
  end

  # Rotas de materiais
  resources :materials, only: [ :index, :show, :create, :update, :destroy ] do
    # Rotas aninhadas para tipos específicos
    member do
      get "detalhes" # Retorna detalhes específicos do tipo
    end
  end

  # Rotas específicas para cada tipo de material
  resources :livros, only: [ :index, :show, :create, :update, :destroy ] do
    member do
      get "buscar_isbn/:isbn", to: "livros#buscar_por_isbn", as: :buscar_isbn
    end
  end

  resources :artigos, only: [ :index, :show, :create, :update, :destroy ]
  resources :videos, only: [ :index, :show, :create, :update, :destroy ]

  # Rota para busca geral
  get "buscar", to: "materials#buscar"

  # Rota para estatísticas
  get "estatisticas", to: "materials#estatisticas"

  # Rota para documentação da API
  get "api-docs", to: redirect("/api-docs.html")

  # Defines the root path route ("/")
  root "materials#index"
end
