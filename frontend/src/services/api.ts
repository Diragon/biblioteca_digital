import axios, { AxiosInstance, AxiosResponse } from 'axios';
import {
  LoginRequest,
  LoginResponse,
  RegistroRequest,
  RespostaAPI,
  Material,
  Autor,
  Livro,
  Artigo,
  Video,
  MaterialRequest,
  AutorRequest,
  Estatisticas,
  FiltrosMaterial,
  FiltrosAutor,
  Usuario
} from '../types/api';
import config from '../config/environment';

class ApiService {
  private api: AxiosInstance;
  private baseURL: string;

  constructor() {
    this.baseURL = config.apiUrl;
    
    this.api = axios.create({
      baseURL: this.baseURL,
      headers: {
        'Content-Type': 'application/json',
      },
    });

    // Interceptor para adicionar token de autenticação
    this.api.interceptors.request.use(
      (config) => {
        const token = localStorage.getItem('token');
        if (token) {
          config.headers.Authorization = `Bearer ${token}`;
        }
        return config;
      },
      (error) => {
        return Promise.reject(error);
      }
    );

    // Interceptor para tratar respostas
    this.api.interceptors.response.use(
      (response: AxiosResponse) => {
        return response;
      },
      (error) => {
        if (error.response?.status === 401) {
          // Token expirado ou inválido
          localStorage.removeItem('token');
          localStorage.removeItem('usuario');
          window.location.href = '/login';
        }
        return Promise.reject(error);
      }
    );
  }

  // ===== AUTENTICAÇÃO =====

  async login(credenciais: LoginRequest): Promise<LoginResponse> {
    const response = await this.api.post<LoginResponse>('/autenticacao/login', credenciais);
    return response.data;
  }

  async registrar(dados: RegistroRequest): Promise<LoginResponse> {
    const response = await this.api.post<LoginResponse>('/autenticacao/registrar', dados);
    return response.data;
  }

  async logout(): Promise<void> {
    await this.api.post('/autenticacao/logout');
  }

  async obterPerfil(): Promise<RespostaAPI<Usuario>> {
    const response = await this.api.get<RespostaAPI<Usuario>>('/autenticacao/perfil');
    return response.data;
  }

  async atualizarPerfil(dados: Partial<RegistroRequest>): Promise<RespostaAPI<Usuario>> {
    const response = await this.api.put<RespostaAPI<Usuario>>('/autenticacao/perfil', dados);
    return response.data;
  }

  async validarToken(): Promise<RespostaAPI<{ valido: boolean; usuario: Usuario }>> {
    const response = await this.api.get<RespostaAPI<{ valido: boolean; usuario: Usuario }>>('/autenticacao/validar_token');
    return response.data;
  }

  // ===== MATERIAIS =====

  async listarMateriais(filtros: FiltrosMaterial = {}): Promise<RespostaAPI<Material[]>> {
    const params = new URLSearchParams();
    Object.entries(filtros).forEach(([key, value]) => {
      if (value !== undefined && value !== null && value !== '') {
        params.append(key, value.toString());
      }
    });

    const response = await this.api.get<RespostaAPI<Material[]>>(`/materials?${params.toString()}`);
    return response.data;
  }

  async obterMaterial(id: number): Promise<RespostaAPI<Material>> {
    const response = await this.api.get<RespostaAPI<Material>>(`/materials/${id}`);
    return response.data;
  }

  async criarMaterial(dados: MaterialRequest): Promise<RespostaAPI<Material>> {
    const response = await this.api.post<RespostaAPI<Material>>('/materials', dados);
    return response.data;
  }

  async atualizarMaterial(id: number, dados: Partial<MaterialRequest>): Promise<RespostaAPI<Material>> {
    const response = await this.api.put<RespostaAPI<Material>>(`/materials/${id}`, dados);
    return response.data;
  }

  async excluirMaterial(id: number): Promise<RespostaAPI<void>> {
    const response = await this.api.delete<RespostaAPI<void>>(`/materials/${id}`);
    return response.data;
  }

  async buscarMateriais(termo: string, filtros: Omit<FiltrosMaterial, 'termo_busca'> = {}): Promise<RespostaAPI<Material[]>> {
    const params = new URLSearchParams({ q: termo });
    Object.entries(filtros).forEach(([key, value]) => {
      if (value !== undefined && value !== null && value !== '') {
        params.append(key, value.toString());
      }
    });

    const response = await this.api.get<RespostaAPI<Material[]>>(`/buscar?${params.toString()}`);
    return response.data;
  }

  async obterEstatisticas(): Promise<RespostaAPI<Estatisticas>> {
    const response = await this.api.get<RespostaAPI<Estatisticas>>('/estatisticas');
    return response.data;
  }

  // ===== AUTORES =====

  async listarAutores(filtros: FiltrosAutor = {}): Promise<RespostaAPI<Autor[]>> {
    const params = new URLSearchParams();
    Object.entries(filtros).forEach(([key, value]) => {
      if (value !== undefined && value !== null && value !== '') {
        params.append(key, value.toString());
      }
    });

    const response = await this.api.get<RespostaAPI<Autor[]>>(`/autores?${params.toString()}`);
    return response.data;
  }

  async obterAutor(id: number): Promise<RespostaAPI<Autor>> {
    const response = await this.api.get<RespostaAPI<Autor>>(`/autores/${id}`);
    return response.data;
  }

  async criarAutor(dados: AutorRequest): Promise<RespostaAPI<Autor>> {
    const response = await this.api.post<RespostaAPI<Autor>>('/autores', dados);
    return response.data;
  }

  async atualizarAutor(id: number, dados: Partial<AutorRequest>): Promise<RespostaAPI<Autor>> {
    const response = await this.api.put<RespostaAPI<Autor>>(`/autores/${id}`, dados);
    return response.data;
  }

  async excluirAutor(id: number): Promise<RespostaAPI<void>> {
    const response = await this.api.delete<RespostaAPI<void>>(`/autores/${id}`);
    return response.data;
  }

  // ===== LIVROS =====

  async listarLivros(filtros: Omit<FiltrosMaterial, 'tipo'> = {}): Promise<RespostaAPI<Livro[]>> {
    const params = new URLSearchParams();
    Object.entries(filtros).forEach(([key, value]) => {
      if (value !== undefined && value !== null && value !== '') {
        params.append(key, value.toString());
      }
    });

    const response = await this.api.get<RespostaAPI<Livro[]>>(`/livros?${params.toString()}`);
    return response.data;
  }

  async obterLivro(id: number): Promise<RespostaAPI<Livro>> {
    const response = await this.api.get<RespostaAPI<Livro>>(`/livros/${id}`);
    return response.data;
  }

  async criarLivro(dados: MaterialRequest): Promise<RespostaAPI<Livro>> {
    const response = await this.api.post<RespostaAPI<Livro>>('/livros', dados);
    return response.data;
  }

  async atualizarLivro(id: number, dados: Partial<MaterialRequest>): Promise<RespostaAPI<Livro>> {
    const response = await this.api.put<RespostaAPI<Livro>>(`/livros/${id}`, dados);
    return response.data;
  }

  async excluirLivro(id: number): Promise<RespostaAPI<void>> {
    const response = await this.api.delete<RespostaAPI<void>>(`/livros/${id}`);
    return response.data;
  }

  async buscarLivroPorIsbn(isbn: string): Promise<RespostaAPI<any>> {
    const response = await this.api.get<RespostaAPI<any>>(`/livros/buscar_isbn/${isbn}`);
    return response.data;
  }

  // ===== ARTIGOS =====

  async listarArtigos(filtros: Omit<FiltrosMaterial, 'tipo'> = {}): Promise<RespostaAPI<Artigo[]>> {
    const params = new URLSearchParams();
    Object.entries(filtros).forEach(([key, value]) => {
      if (value !== undefined && value !== null && value !== '') {
        params.append(key, value.toString());
      }
    });

    const response = await this.api.get<RespostaAPI<Artigo[]>>(`/artigos?${params.toString()}`);
    return response.data;
  }

  async obterArtigo(id: number): Promise<RespostaAPI<Artigo>> {
    const response = await this.api.get<RespostaAPI<Artigo>>(`/artigos/${id}`);
    return response.data;
  }

  async criarArtigo(dados: MaterialRequest): Promise<RespostaAPI<Artigo>> {
    const response = await this.api.post<RespostaAPI<Artigo>>('/artigos', dados);
    return response.data;
  }

  async atualizarArtigo(id: number, dados: Partial<MaterialRequest>): Promise<RespostaAPI<Artigo>> {
    const response = await this.api.put<RespostaAPI<Artigo>>(`/artigos/${id}`, dados);
    return response.data;
  }

  async excluirArtigo(id: number): Promise<RespostaAPI<void>> {
    const response = await this.api.delete<RespostaAPI<void>>(`/artigos/${id}`);
    return response.data;
  }

  // ===== VÍDEOS =====

  async listarVideos(filtros: Omit<FiltrosMaterial, 'tipo'> = {}): Promise<RespostaAPI<Video[]>> {
    const params = new URLSearchParams();
    Object.entries(filtros).forEach(([key, value]) => {
      if (value !== undefined && value !== null && value !== '') {
        params.append(key, value.toString());
      }
    });

    const response = await this.api.get<RespostaAPI<Video[]>>(`/videos?${params.toString()}`);
    return response.data;
  }

  async obterVideo(id: number): Promise<RespostaAPI<Video>> {
    const response = await this.api.get<RespostaAPI<Video>>(`/videos/${id}`);
    return response.data;
  }

  async criarVideo(dados: MaterialRequest): Promise<RespostaAPI<Video>> {
    const response = await this.api.post<RespostaAPI<Video>>('/videos', dados);
    return response.data;
  }

  async atualizarVideo(id: number, dados: Partial<MaterialRequest>): Promise<RespostaAPI<Video>> {
    const response = await this.api.put<RespostaAPI<Video>>(`/videos/${id}`, dados);
    return response.data;
  }

  async excluirVideo(id: number): Promise<RespostaAPI<void>> {
    const response = await this.api.delete<RespostaAPI<void>>(`/videos/${id}`);
    return response.data;
  }
}

// Instância singleton do serviço
export const apiService = new ApiService();
export default apiService;
