require 'rails_helper'

RSpec.describe Usuario, type: :model do
  # Testa associações
  describe 'associações' do
    it { should have_many(:materials).dependent(:destroy) }
  end

  # Testa validações
  describe 'validações' do
    it { should validate_presence_of(:email).with_message('não pode estar em branco') }
    it 'valida unicidade do email' do
      create(:usuario, email: 'teste@example.com')
      usuario_duplicado = build(:usuario, email: 'teste@example.com')

      expect(usuario_duplicado).not_to be_valid
      expect(usuario_duplicado.errors[:email]).to include('já está em uso')
    end
    it { should validate_presence_of(:password).with_message('não pode estar em branco') }
    it { should validate_length_of(:password).is_at_least(6).with_message('deve ter pelo menos 6 caracteres') }
  end

  # Testa formato do email
  describe 'formato do email' do
    it 'aceita email válido' do
      usuario = build(:usuario, email: 'teste@example.com')
      expect(usuario).to be_valid
    end

    it 'rejeita email inválido' do
      usuario = build(:usuario, email: 'email_invalido')
      expect(usuario).not_to be_valid
      expect(usuario.errors[:email]).to include('deve ter um formato válido')
    end
  end

  # Testa métodos de autenticação
  describe 'autenticação' do
    let(:usuario) { create(:usuario, email: 'teste@example.com', password: '123456') }

    describe '.autenticar' do
      it 'autentica usuário com credenciais corretas' do
        # Garante que o usuário foi salvo
        expect(usuario).to be_persisted

        resultado = Usuario.autenticar('teste@example.com', '123456')
        expect(resultado).to eq(usuario)
      end

      it 'não autentica usuário com email incorreto' do
        resultado = Usuario.autenticar('email_errado@example.com', '123456')
        expect(resultado).to be_nil
      end

      it 'não autentica usuário com senha incorreta' do
        resultado = Usuario.autenticar('teste@example.com', 'senha_errada')
        expect(resultado).to be_nil
      end
    end

    describe '#gerar_token_jwt' do
      it 'gera token JWT válido' do
        token = usuario.gerar_token_jwt
        expect(token).to be_present
        expect(token).to be_a(String)
      end
    end

    describe '.encontrar_por_token' do
      it 'encontra usuário por token válido' do
        token = usuario.gerar_token_jwt
        resultado = Usuario.encontrar_por_token(token)
        expect(resultado).to eq(usuario)
      end

      it 'não encontra usuário por token inválido' do
        resultado = Usuario.encontrar_por_token('token_invalido')
        expect(resultado).to be_nil
      end
    end
  end

  # Testa normalização do email
  describe 'normalização do email' do
    it 'converte email para minúsculo' do
      usuario = create(:usuario, email: 'TESTE@EXAMPLE.COM')
      expect(usuario.email).to eq('teste@example.com')
    end

    it 'remove espaços do email' do
      usuario = create(:usuario, email: '  teste@example.com  ')
      expect(usuario.email).to eq('teste@example.com')
    end
  end
end
