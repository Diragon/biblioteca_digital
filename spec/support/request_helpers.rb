module RequestHelpers
  # Helper para autenticar usuário em testes de request
  def autenticar_usuario(usuario)
    # Gera token JWT para o usuário
    token = usuario.gerar_token_jwt

    # Adiciona o token no header Authorization
    request.headers['Authorization'] = "Bearer #{token}"
  end

  # Helper para fazer login e retornar token
  def fazer_login(email, senha)
    post '/autenticacao/login', params: { email: email, senha: senha }

    if response.status == 200
      JSON.parse(response.body)['dados']['token']
    else
      nil
    end
  end

  # Helper para criar usuário e fazer login
  def criar_usuario_e_fazer_login(email = 'teste@example.com', senha = '123456')
    # Cria usuário
    usuario = Usuario.create!(email: email, senha: senha)

    # Faz login e retorna token
    token = fazer_login(email, senha)

    { usuario: usuario, token: token }
  end

  # Helper para fazer requisição autenticada
  def get_autenticado(url, token, params = {})
    get url, params: params, headers: { 'Authorization' => "Bearer #{token}" }
  end

  def post_autenticado(url, token, params = {})
    post url, params: params, headers: { 'Authorization' => "Bearer #{token}" }
  end

  def put_autenticado(url, token, params = {})
    put url, params: params, headers: { 'Authorization' => "Bearer #{token}" }
  end

  def delete_autenticado(url, token, params = {})
    delete url, params: params, headers: { 'Authorization' => "Bearer #{token}" }
  end

  # Helper para verificar resposta de sucesso
  def expectar_resposta_sucesso
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)['sucesso']).to be true
  end

  # Helper para verificar resposta de criação
  def expectar_resposta_criacao
    expect(response).to have_http_status(:created)
    expect(JSON.parse(response.body)['sucesso']).to be true
  end

  # Helper para verificar resposta de erro
  def expectar_resposta_erro(status = :unprocessable_entity)
    expect(response).to have_http_status(status)
    response_body = JSON.parse(response.body)
    expect(response_body['erro']).to be_present
  end

  # Helper para verificar resposta de não autorizado
  def expectar_resposta_nao_autorizado
    expect(response).to have_http_status(:unauthorized)
    expect(JSON.parse(response.body)['codigo']).to eq('ERRO_AUTENTICACAO')
  end

  # Helper para verificar resposta de não encontrado
  def expectar_resposta_nao_encontrado
    expect(response).to have_http_status(:not_found)
    expect(JSON.parse(response.body)['codigo']).to eq('ERRO_NAO_ENCONTRADO')
  end
end

# Inclui o helper em todos os testes de request
RSpec.configure do |config|
  config.include RequestHelpers, type: :request
end
