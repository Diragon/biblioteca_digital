FactoryBot.define do
  factory :material do
    # Gera título único para cada material
    sequence(:titulo) { |n| "Material #{n}" }
    
    # Descrição padrão
    descricao { "Descrição do material" }
    
    # Tipo padrão
    tipo { "Livro" }
    
    # Status padrão
    status { "rascunho" }
    
    # Associações
    association :usuario
    association :autor

    # Trait para material publicado
    trait :publicado do
      status { "publicado" }
    end

    # Trait para material arquivado
    trait :arquivado do
      status { "arquivado" }
    end

    # Trait para livro
    trait :livro do
      tipo { "Livro" }
    end

    # Trait para artigo
    trait :artigo do
      tipo { "Artigo" }
    end

    # Trait para vídeo
    trait :video do
      tipo { "Video" }
    end
  end
end
