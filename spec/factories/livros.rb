FactoryBot.define do
  factory :livro do
    # Gera ISBN único para cada livro
    sequence(:isbn) { |n| "978#{n.to_s.rjust(10, '0')}" }

    # Número de páginas padrão
    numero_paginas { 200 }

    # Associação com material
    association :material, factory: [ :material, :livro ]

    # Trait para livro com ISBN específico
    trait :com_isbn do
      isbn { "9788535914849" }
    end

    # Trait para livro com muitas páginas
    trait :muitas_paginas do
      numero_paginas { 1000 }
    end

    # Trait para livro com poucas páginas
    trait :poucas_paginas do
      numero_paginas { 50 }
    end
  end
end
