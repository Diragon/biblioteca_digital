FactoryBot.define do
  factory :autor do
    # Gera nome único para cada autor
    sequence(:nome) { |n| "Autor #{n}" }
    
    # Trait para autor pessoa
    trait :pessoa do
      tipo { "Pessoa" }
      data_nascimento { Date.new(1980, 1, 1) }
      cidade { nil }
    end

    # Trait para autor instituição
    trait :instituicao do
      tipo { "Instituicao" }
      data_nascimento { nil }
      cidade { "São Paulo" }
    end

    # Factory padrão é pessoa
    pessoa
  end
end
