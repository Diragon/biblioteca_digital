require 'rails_helper'

RSpec.describe "Autenticacao::Autenticacao", type: :request do
  describe "POST /autenticacao/registrar" do
    context "com parâmetros válidos" do
      it "cria um novo usuário" do
        expect {
        post "/autenticacao/registrar", params: {
          email: "novo@example.com",
          password: "123456"
        }
        }.to change(Usuario, :count).by(1)
        
        expectar_resposta_criacao
        expect(JSON.parse(response.body)['dados']['usuario']['email']).to eq('novo@example.com')
      end

    end

    context "com parâmetros inválidos" do
      it "não cria usuário com email inválido" do
        post "/autenticacao/registrar", params: {
          email: "email_invalido",
          password: "123456"
        }
        
        expectar_resposta_erro
        expect(JSON.parse(response.body)['detalhes']).to include('Email deve ter um formato válido')
      end

      it "não cria usuário com senha muito curta" do
        post "/autenticacao/registrar", params: {
          email: "teste@example.com",
          password: "123"
        }
        
        expectar_resposta_erro
        expect(JSON.parse(response.body)['detalhes']).to include('Password deve ter pelo menos 6 caracteres')
      end

      it "não cria usuário com email duplicado" do
        create(:usuario, email: "teste@example.com")
        
        post "/autenticacao/registrar", params: {
          email: "teste@example.com",
          password: "123456"
        }
        
        expectar_resposta_erro
        expect(JSON.parse(response.body)['detalhes']).to include('Email já está em uso')
      end
    end
  end

  describe "POST /autenticacao/login" do
    context "com credenciais válidas" do
      it "faz login com sucesso" do
        # Cria o usuário explicitamente
        usuario = create(:usuario, email: "teste@example.com", password: "123456")
        
        post "/autenticacao/login", params: {
          email: "teste@example.com",
          password: "123456"
        }
        
        expectar_resposta_sucesso
        expect(JSON.parse(response.body)['dados']['token']).to be_present
        expect(JSON.parse(response.body)['dados']['usuario']['email']).to eq('teste@example.com')
      end
    end

    context "com credenciais inválidas" do
      it "não faz login com email incorreto" do
        post "/autenticacao/login", params: {
          email: "email_errado@example.com",
          password: "123456"
        }
        
        expectar_resposta_nao_autorizado
      end

      it "não faz login com senha incorreta" do
        post "/autenticacao/login", params: {
          email: "teste@example.com",
          password: "senha_errada"
        }
        
        expectar_resposta_nao_autorizado
      end
    end
  end

  describe "GET /autenticacao/perfil" do
    let(:usuario) { create(:usuario) }
    let(:token) { usuario.gerar_token_jwt }

    it "retorna dados do usuário autenticado" do
      get_autenticado "/autenticacao/perfil", token
      
      expectar_resposta_sucesso
      expect(JSON.parse(response.body)['dados']['id']).to eq(usuario.id)
      expect(JSON.parse(response.body)['dados']['email']).to eq(usuario.email)
    end

    it "não retorna perfil sem autenticação" do
      get "/autenticacao/perfil"
      
      expectar_resposta_nao_autorizado
    end
  end

  describe "PUT /autenticacao/perfil" do
    context "com parâmetros válidos" do
      it "atualiza perfil do usuário" do
        # Cria o usuário explicitamente
        usuario = create(:usuario, email: "teste@example.com")
        token = usuario.gerar_token_jwt
        
        put_autenticado "/autenticacao/perfil", token, params: {
          email: "novo@example.com"
        }
        
        expectar_resposta_sucesso
        expect(JSON.parse(response.body)['dados']['email']).to eq('novo@example.com')
      end
    end

    context "com parâmetros inválidos" do
      it "não atualiza com email inválido" do
        # Cria o usuário explicitamente
        usuario = create(:usuario, email: "teste@example.com")
        token = usuario.gerar_token_jwt
        
        put_autenticado "/autenticacao/perfil", token, params: {
          email: "email_invalido"
        }
        
        expectar_resposta_erro
      end
    end
  end

  describe "GET /autenticacao/validar_token" do
    let(:usuario) { create(:usuario) }
    let(:token) { usuario.gerar_token_jwt }

    it "valida token válido" do
      get_autenticado "/autenticacao/validar_token", token
      
      expectar_resposta_sucesso
      expect(JSON.parse(response.body)['dados']['valido']).to be true
    end

    it "não valida token inválido" do
      get "/autenticacao/validar_token", headers: { 'Authorization' => 'Bearer token_invalido' }
      
      expectar_resposta_nao_autorizado
    end
  end
end
