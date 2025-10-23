# 📘 Exemplos de Uso da API

Exemplos práticos de como usar a API da Biblioteca Digital.

---

## 🔐 1. Autenticação

### Registrar Novo Usuário
```bash
curl -X POST http://localhost:3000/autenticacao/registrar \
  -H "Content-Type: application/json" \
  -d '{
    "email": "teste@exemplo.com",
    "password": "senha123"
  }'
```

**Resposta:**
```json
{
  "sucesso": true,
  "mensagem": "Usuário registrado com sucesso",
  "dados": {
    "token": "eyJhbGciOiJIUzI1NiJ9...",
    "usuario": {
      "id": 1,
      "email": "teste@exemplo.com",
      "criado_em": "2025-10-23T10:30:00Z"
    }
  }
}
```

### Fazer Login
```bash
curl -X POST http://localhost:3000/autenticacao/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "teste@exemplo.com",
    "password": "senha123"
  }'
```

### Obter Perfil
```bash
curl -X GET http://localhost:3000/autenticacao/perfil \
  -H "Authorization: Bearer <seu-token>"
```

---

## 👥 2. Autores

### Criar Autor Pessoa
```bash
curl -X POST http://localhost:3000/autores \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <seu-token>" \
  -d '{
    "nome": "João Silva",
    "tipo": "Pessoa",
    "data_nascimento": "1980-05-15"
  }'
```

### Criar Autor Instituição
```bash
curl -X POST http://localhost:3000/autores \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <seu-token>" \
  -d '{
    "nome": "Universidade de São Paulo",
    "tipo": "Instituicao",
    "cidade": "São Paulo"
  }'
```

### Listar Autores com Filtros
```bash
# Todos os autores
curl "http://localhost:3000/autores"

# Apenas pessoas
curl "http://localhost:3000/autores?tipo=Pessoa"

# Buscar por nome
curl "http://localhost:3000/autores?q=Silva"

# Com paginação
curl "http://localhost:3000/autores?page=1&per_page=5"
```

### Obter Autor Específico
```bash
curl "http://localhost:3000/autores/1"
```

---

## 📚 3. Materiais

### Criar Livro
```bash
curl -X POST http://localhost:3000/materials \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <seu-token>" \
  -d '{
    "tipo": "Livro",
    "titulo": "Ruby on Rails: Guia Completo",
    "descricao": "Um guia abrangente sobre Ruby on Rails",
    "status": "publicado",
    "autor_id": 1,
    "isbn": "9780321765723",
    "numero_paginas": 450
  }'
```

### Criar Artigo
```bash
curl -X POST http://localhost:3000/materials \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <seu-token>" \
  -d '{
    "tipo": "Artigo",
    "titulo": "Análise de Performance em Rails",
    "descricao": "Estudo sobre otimização de aplicações Rails",
    "status": "publicado",
    "autor_id": 2,
    "doi": "10.1000/xyz123"
  }'
```

### Criar Vídeo
```bash
curl -X POST http://localhost:3000/materials \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <seu-token>" \
  -d '{
    "tipo": "Video",
    "titulo": "Introdução ao Ruby on Rails",
    "descricao": "Tutorial completo para iniciantes",
    "status": "publicado",
    "autor_id": 1,
    "duracao_minutos": 45
  }'
```

### Listar Materiais com Filtros
```bash
# Todos os materiais
curl "http://localhost:3000/materials"

# Apenas livros
curl "http://localhost:3000/materials?tipo=Livro"

# Apenas publicados
curl "http://localhost:3000/materials?status=publicado"

# Por autor
curl "http://localhost:3000/materials?autor_id=1"

# Buscar por texto
curl "http://localhost:3000/materials?q=rails"

# Múltiplos filtros
curl "http://localhost:3000/materials?tipo=Livro&status=publicado&page=1&per_page=5"
```

### Atualizar Material
```bash
curl -X PUT http://localhost:3000/materials/1 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <seu-token>" \
  -d '{
    "titulo": "Ruby on Rails: Guia Completo - 2ª Edição",
    "status": "arquivado"
  }'
```

### Excluir Material
```bash
curl -X DELETE http://localhost:3000/materials/1 \
  -H "Authorization: Bearer <seu-token>"
```

---

## 🔍 4. Busca

### Busca Simples
```bash
curl "http://localhost:3000/buscar?q=ruby"
```

### Busca com Filtros
```bash
curl "http://localhost:3000/buscar?q=rails&tipo=Livro&status=publicado&page=1&per_page=10"
```

---

## 📊 5. Estatísticas

```bash
curl "http://localhost:3000/estatisticas"
```

**Resposta:**
```json
{
  "sucesso": true,
  "dados": {
    "total_materiais": 10,
    "por_tipo": {
      "livros": 3,
      "artigos": 3,
      "videos": 4
    },
    "por_status": {
      "rascunho": 2,
      "publicado": 7,
      "arquivado": 1
    },
    "total_autores": 7,
    "total_usuarios": 3,
    "materiais_recentes": [...]
  }
}
```

---

## 🎯 6. Livros (Rotas Específicas)

### Criar Livro com ISBN (Auto-preenchimento)
```bash
curl -X POST http://localhost:3000/livros \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <seu-token>" \
  -d '{
    "autor_id": 1,
    "status": "publicado",
    "isbn": "9780321765723"
  }'
```

> **Nota**: O título e número de páginas serão buscados automaticamente na OpenLibrary API.

### Buscar Livro por ISBN na OpenLibrary
```bash
curl "http://localhost:3000/livros/1/buscar_isbn/9780321765723"
```

### Listar Livros
```bash
curl "http://localhost:3000/livros?status=publicado&page=1&per_page=5"
```

---

## 🔷 7. GraphQL

### Query Simples
```bash
curl -X POST http://localhost:3000/graphql \
  -H "Content-Type: application/json" \
  -d '{
    "query": "{ materials { id titulo tipo status } }"
  }'
```

### Query com Filtros
```bash
curl -X POST http://localhost:3000/graphql \
  -H "Content-Type: application/json" \
  -d '{
    "query": "query { materials(tipo: \"Livro\", status: \"publicado\") { id titulo autor { nome } } }"
  }'
```

### Query Completa
```bash
curl -X POST http://localhost:3000/graphql \
  -H "Content-Type: application/json" \
  -d '{
    "query": "query { materials { id titulo descricao tipo status autor { id nome tipo } informacoesEspecificas criado_em } }"
  }'
```

### Query de Autores
```bash
curl -X POST http://localhost:3000/graphql \
  -H "Content-Type: application/json" \
  -d '{
    "query": "{ autores { id nome tipo nomeCompleto totalMateriais } }"
  }'
```

### Query de Estatísticas
```bash
curl -X POST http://localhost:3000/graphql \
  -H "Content-Type: application/json" \
  -d '{
    "query": "{ estatisticas }"
  }'
```

### Query com Variáveis
```bash
curl -X POST http://localhost:3000/graphql \
  -H "Content-Type: application/json" \
  -d '{
    "query": "query getMaterial($id: ID!) { material(id: $id) { id titulo autor { nome } } }",
    "variables": { "id": "1" }
  }'
```

---

## 🐍 8. Exemplos com Python

### Usando requests
```python
import requests
import json

# URL base
BASE_URL = "http://localhost:3000"

# 1. Registrar usuário
response = requests.post(
    f"{BASE_URL}/autenticacao/registrar",
    json={
        "email": "python@exemplo.com",
        "password": "python123"
    }
)
data = response.json()
token = data["dados"]["token"]

# 2. Criar autor
headers = {"Authorization": f"Bearer {token}"}
response = requests.post(
    f"{BASE_URL}/autores",
    json={
        "nome": "Python Developer",
        "tipo": "Pessoa",
        "data_nascimento": "1990-01-01"
    },
    headers=headers
)
autor_id = response.json()["dados"]["id"]

# 3. Criar livro
response = requests.post(
    f"{BASE_URL}/materials",
    json={
        "tipo": "Livro",
        "titulo": "Python para Iniciantes",
        "descricao": "Aprenda Python do zero",
        "status": "publicado",
        "autor_id": autor_id,
        "isbn": "9781234567890",
        "numero_paginas": 300
    },
    headers=headers
)
print(json.dumps(response.json(), indent=2))

# 4. Buscar materiais
response = requests.get(
    f"{BASE_URL}/materials",
    params={"q": "python", "tipo": "Livro"}
)
print(json.dumps(response.json(), indent=2))
```

---

## 🟢 9. Exemplos com JavaScript/Node.js

### Usando fetch
```javascript
const BASE_URL = 'http://localhost:3000';

// 1. Registrar usuário
async function registrar() {
  const response = await fetch(`${BASE_URL}/autenticacao/registrar`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      email: 'js@exemplo.com',
      password: 'js123456'
    })
  });
  
  const data = await response.json();
  return data.dados.token;
}

// 2. Criar material
async function criarMaterial(token) {
  const response = await fetch(`${BASE_URL}/materials`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`
    },
    body: JSON.stringify({
      tipo: 'Livro',
      titulo: 'JavaScript: The Good Parts',
      descricao: 'Um guia sobre as melhores práticas em JavaScript',
      status: 'publicado',
      autor_id: 1,
      isbn: '9780596517748',
      numero_paginas: 172
    })
  });
  
  return await response.json();
}

// 3. Buscar materiais
async function buscarMateriais() {
  const response = await fetch(
    `${BASE_URL}/materials?tipo=Livro&status=publicado`
  );
  return await response.json();
}

// Executar
(async () => {
  const token = await registrar();
  const material = await criarMaterial(token);
  const materiais = await buscarMateriais();
  console.log(materiais);
})();
```

---

## ✅ 10. Fluxo Completo de Uso

```bash
# 1. Registrar usuário
TOKEN=$(curl -X POST http://localhost:3000/autenticacao/registrar \
  -H "Content-Type: application/json" \
  -d '{"email":"teste@exemplo.com","password":"senha123"}' \
  -s | jq -r '.dados.token')

# 2. Criar autor
AUTOR_ID=$(curl -X POST http://localhost:3000/autores \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"nome":"João Silva","tipo":"Pessoa","data_nascimento":"1980-05-15"}' \
  -s | jq -r '.dados.id')

# 3. Criar livro
MATERIAL_ID=$(curl -X POST http://localhost:3000/materials \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{\"tipo\":\"Livro\",\"titulo\":\"Meu Livro\",\"descricao\":\"Descrição\",\"status\":\"publicado\",\"autor_id\":$AUTOR_ID,\"isbn\":\"9780321765723\",\"numero_paginas\":450}" \
  -s | jq -r '.dados.id')

# 4. Listar materiais
curl "http://localhost:3000/materials" -s | jq '.dados[] | {id, titulo, tipo}'

# 5. Buscar
curl "http://localhost:3000/buscar?q=Livro" -s | jq '.dados | length'

# 6. Estatísticas
curl "http://localhost:3000/estatisticas" -s | jq '.dados'
```

---

## 📚 Recursos Adicionais

- **Documentação Interativa**: http://localhost:3000/api-docs
- **GraphQL Playground**: Use tools como GraphiQL ou Insomnia
- **Postman Collection**: Importe o arquivo `swagger.json`

---

**Happy Coding! 🚀**
