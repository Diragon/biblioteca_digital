// Configurações de ambiente da aplicação

export const config = {
  // URL da API Rails
  apiUrl: 'http://localhost:3000',
  
  // Configurações de desenvolvimento
  isDevelopment: process.env.NODE_ENV === 'development',
  isProduction: process.env.NODE_ENV === 'production',
  
  // Configurações de paginação
  defaultPageSize: 10,
  maxPageSize: 100,
  
  // Configurações de timeout
  requestTimeout: 30000, // 30 segundos
};

export default config;
