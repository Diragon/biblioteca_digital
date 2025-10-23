FactoryBot.define do
  factory :usuario do
    # Gera email único para cada usuário
    sequence(:email) { |n| "usuario#{n}@example.com" }

    # Senha padrão para testes
    password { "123456" }
    password_confirmation { "123456" }

    # Trait para usuário com email específico
    trait :com_email do
      email { "teste@example.com" }
    end

    # Trait para usuário com senha específica
    trait :com_senha do
      password { "senha123" }
      password_confirmation { "senha123" }
    end
  end
end
