# 📚 Frontend - Biblioteca Digital

Frontend React TypeScript para a API da Biblioteca Digital.

## 🚀 Tecnologias

- **React 18** com TypeScript
- **Tailwind CSS** para estilização
- **Axios** para requisições HTTP
- **Lucide React** para ícones
- **React Router DOM** para navegação

## 📦 Instalação

```bash
# Instalar dependências
npm install

# Iniciar servidor de desenvolvimento
npm start
```

## 🔧 Configuração

### Variáveis de Ambiente

Crie um arquivo `.env` na raiz do projeto:

```env
# URL da API Rails
REACT_APP_API_URL=http://localhost:3000

# Configurações de desenvolvimento
GENERATE_SOURCEMAP=false
```

### Configuração da API

A URL da API é configurada em `src/config/environment.ts`:

```typescript
export const config = {
  apiUrl: process.env.REACT_APP_API_URL || 'http://localhost:3000',
  // ... outras configurações
};
```

## 🏗️ Estrutura do Projeto

```
src/
├── components/          # Componentes React
│   ├── Login.tsx       # Tela de login
│   ├── Register.tsx    # Tela de registro
│   └── Dashboard.tsx   # Dashboard principal
├── contexts/           # Contextos React
│   └── AuthContext.tsx # Contexto de autenticação
├── services/           # Serviços
│   └── api.ts         # Cliente da API
├── types/             # Tipos TypeScript
│   └── api.ts         # Tipos da API
├── config/            # Configurações
│   └── environment.ts # Configurações de ambiente
└── App.tsx            # Componente principal
```

## 🎨 Funcionalidades

### ✅ Autenticação
- Login com email e senha
- Registro de novos usuários
- Gerenciamento de tokens JWT
- Logout automático

### ✅ Dashboard
- Visualização de estatísticas
- Listagem de materiais
- Filtros por tipo e status
- Busca textual
- Visualização em grid ou lista

### ✅ Interface
- Design responsivo
- Tema moderno com Tailwind CSS
- Ícones com Lucide React
- Loading states
- Tratamento de erros

## 🔌 Integração com a API

O frontend se conecta com a API Rails através do serviço `apiService`:

```typescript
// Exemplo de uso
import apiService from './services/api';

// Listar materiais
const materiais = await apiService.listarMateriais({
  tipo: 'Livro',
  status: 'publicado',
  page: 1,
  per_page: 10
});

// Criar material
const novoMaterial = await apiService.criarMaterial({
  tipo: 'Livro',
  titulo: 'Meu Livro',
  autor_id: 1,
  isbn: '9781234567890',
  numero_paginas: 200
});
```

## 🎯 Endpoints Utilizados

### Autenticação
- `POST /autenticacao/login` - Login
- `POST /autenticacao/registrar` - Registro
- `POST /autenticacao/logout` - Logout
- `GET /autenticacao/perfil` - Perfil do usuário
- `PUT /autenticacao/perfil` - Atualizar perfil
- `GET /autenticacao/validar_token` - Validar token

### Materiais
- `GET /materials` - Listar materiais
- `GET /materials/:id` - Obter material
- `POST /materials` - Criar material
- `PUT /materials/:id` - Atualizar material
- `DELETE /materials/:id` - Excluir material
- `GET /buscar` - Buscar materiais
- `GET /estatisticas` - Estatísticas

### Autores
- `GET /autores` - Listar autores
- `GET /autores/:id` - Obter autor
- `POST /autores` - Criar autor
- `PUT /autores/:id` - Atualizar autor
- `DELETE /autores/:id` - Excluir autor

### Tipos Específicos
- `GET /livros` - Listar livros
- `GET /artigos` - Listar artigos
- `GET /videos` - Listar vídeos

## 🚀 Scripts Disponíveis

```bash
# Desenvolvimento
npm start          # Inicia servidor de desenvolvimento
npm run build      # Build para produção
npm test           # Executa testes
npm run eject      # Ejecta configurações (irreversível)

# Análise
npm run analyze    # Analisa bundle
```

## 🎨 Customização

### Cores do Tema

As cores podem ser customizadas em `tailwind.config.js`:

```javascript
module.exports = {
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#eff6ff',
          100: '#dbeafe',
          // ... outras cores
        }
      }
    }
  }
}
```

### Componentes

Os componentes estão em `src/components/` e podem ser facilmente customizados:

- **Login.tsx** - Tela de login
- **Register.tsx** - Tela de registro  
- **Dashboard.tsx** - Dashboard principal

## 🔒 Segurança

- Tokens JWT armazenados no localStorage
- Interceptadores Axios para autenticação automática
- Validação de tokens com o servidor
- Logout automático em caso de token inválido

## 📱 Responsividade

O frontend é totalmente responsivo e funciona em:
- 📱 Mobile (320px+)
- 📱 Tablet (768px+)
- 💻 Desktop (1024px+)
- 🖥️ Large screens (1280px+)

## 🐛 Troubleshooting

### Problemas Comuns

1. **Erro de CORS**
   - Verifique se a API Rails está rodando
   - Confirme a URL da API em `.env`

2. **Token inválido**
   - Faça logout e login novamente
   - Verifique se o token não expirou

3. **Erro de conexão**
   - Verifique se a API está rodando na porta 3000
   - Confirme a URL da API

### Logs de Debug

Para debug, abra o DevTools do navegador e verifique:
- Console para erros JavaScript
- Network para requisições HTTP
- Application > Local Storage para tokens

## 🚀 Deploy

### Build para Produção

```bash
npm run build
```

### Deploy no Netlify

1. Conecte o repositório ao Netlify
2. Configure as variáveis de ambiente
3. Deploy automático a cada push

### Deploy no Vercel

1. Conecte o repositório ao Vercel
2. Configure as variáveis de ambiente
3. Deploy automático a cada push

## 📄 Licença

MIT License - veja o arquivo LICENSE para detalhes

---

**Desenvolvido com ❤️ para a Biblioteca Digital**