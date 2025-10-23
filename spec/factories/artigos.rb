FactoryBot.define do
  factory :artigo do
    # Gera DOI único para cada artigo
    sequence(:doi) { |n| "10.1000/xyz#{n}" }

    # Associação com material
    association :material, factory: [ :material, :artigo ]

    # Trait para artigo com DOI específico
    trait :com_doi do
      doi { "10.1000/xyz123" }
    end
  end
end
