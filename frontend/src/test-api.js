// Teste simples para verificar se a API está acessível
const testAPI = async () => {
  try {
    const response = await fetch('http://localhost:3000/autores');
    const data = await response.json();
    console.log('API funcionando:', data);
    return true;
  } catch (error) {
    console.error('Erro na API:', error);
    return false;
  }
};

// Teste de login
const testLogin = async () => {
  try {
    const response = await fetch('http://localhost:3000/autenticacao/login', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        email: 'admin@biblioteca.com',
        password: 'admin123'
      })
    });
    const data = await response.json();
    console.log('Login funcionando:', data);
    return true;
  } catch (error) {
    console.error('Erro no login:', error);
    return false;
  }
};

// Executar testes
testAPI();
testLogin();
