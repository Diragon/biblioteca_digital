// Tipos para a API da Biblioteca Digital

export interface Usuario {
  id: number;
  email: string;
  criado_em: string;
  total_materiais?: number;
}

export interface Autor {
  id: number;
  nome: string;
  tipo: 'Pessoa' | 'Instituicao';
  nome_completo: string;
  data_nascimento?: string;
  cidade?: string;
  idade?: number;
  total_materiais: number;
  criado_em: string;
  atualizado_em?: string;
  materiais?: Material[];
}

export interface Material {
  id: number;
  titulo: string;
  descricao?: string;
  tipo: 'Livro' | 'Artigo' | 'Video';
  status: 'rascunho' | 'publicado' | 'arquivado';
  autor: {
    id: number;
    nome: string;
    tipo: string;
    nome_completo?: string;
  };
  criado_por: string;
  criado_em: string;
  atualizado_em: string;
  informacoes_especificas: {
    isbn?: string;
    numero_paginas?: number;
    doi?: string;
    duracao_minutos?: number;
  };
  pode_editar?: boolean;
  pode_excluir?: boolean;
}

export interface Livro {
  id: number;
  isbn: string;
  isbn_formatado: string;
  numero_paginas: number;
  material: Material;
}

export interface Artigo {
  id: number;
  doi: string;
  doi_url: string;
  material: Material;
}

export interface Video {
  id: number;
  duracao_minutos: number;
  duracao_formatada: string;
  duracao_segundos: number;
  material: Material;
}

export interface Paginacao {
  pagina_atual: number;
  por_pagina: number;
  total_registros: number;
  total_paginas: number;
}

export interface RespostaAPI<T> {
  sucesso: boolean;
  mensagem?: string;
  dados?: T;
  paginacao?: Paginacao;
  erro?: string;
  codigo?: string;
  detalhes?: string;
  erros?: any;
}

export interface LoginRequest {
  email: string;
  password: string;
}

export interface LoginResponse {
  sucesso: boolean;
  mensagem: string;
  dados: {
    token: string;
    usuario: Usuario;
  };
}

export interface RegistroRequest {
  email: string;
  password: string;
}

export interface MaterialRequest {
  tipo: 'Livro' | 'Artigo' | 'Video';
  titulo: string;
  descricao?: string;
  status?: 'rascunho' | 'publicado' | 'arquivado';
  autor_id: number;
  // Campos específicos para Livro
  isbn?: string;
  numero_paginas?: number;
  // Campos específicos para Artigo
  doi?: string;
  // Campos específicos para Video
  duracao_minutos?: number;
}

export interface AutorRequest {
  nome: string;
  tipo: 'Pessoa' | 'Instituicao';
  data_nascimento?: string;
  cidade?: string;
}

export interface Estatisticas {
  total_materiais: number;
  por_tipo: {
    livros: number;
    artigos: number;
    videos: number;
  };
  por_status: {
    rascunho: number;
    publicado: number;
    arquivado: number;
  };
  total_autores: number;
  total_usuarios: number;
  materiais_recentes: Array<{
    id: number;
    titulo: string;
    tipo: string;
    autor: string;
    criado_em: string;
  }>;
}

export interface FiltrosMaterial {
  tipo?: string;
  status?: string;
  autor_id?: number;
  termo_busca?: string;
  page?: number;
  per_page?: number;
}

export interface FiltrosAutor {
  tipo?: string;
  termo_busca?: string;
  page?: number;
  per_page?: number;
}
