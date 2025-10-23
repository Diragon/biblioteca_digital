import React, { useState, useEffect } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { Material, Estatisticas } from '../types/api';
import apiService from '../services/api';
import { 
  BookOpen, 
  FileText, 
  Video, 
  Users, 
  Search, 
  Plus, 
  LogOut,
  User,
  BarChart3,
  Filter,
  Grid,
  List
} from 'lucide-react';

const Dashboard: React.FC = () => {
  const { usuario, logout } = useAuth();
  const [materiais, setMateriais] = useState<Material[]>([]);
  const [estatisticas, setEstatisticas] = useState<Estatisticas | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string>('');
  const [filtros, setFiltros] = useState({
    tipo: '',
    status: '',
    termo_busca: '',
    page: 1,
    per_page: 10
  });
  const [viewMode, setViewMode] = useState<'grid' | 'list'>('grid');
  const [showModal, setShowModal] = useState(false);
  const [novoMaterial, setNovoMaterial] = useState({
    tipo: 'Livro',
    titulo: '',
    descricao: '',
    status: 'rascunho',
    autor_id: '',
    // Campos específicos
    isbn: '',
    numero_paginas: '',
    doi: '',
    duracao_minutos: ''
  });

  useEffect(() => {
    carregarDados();
  }, [filtros]);

  const carregarDados = async () => {
    try {
      setIsLoading(true);
      setError('');

      // Carrega materiais e estatísticas em paralelo
      const [materiaisResponse, estatisticasResponse] = await Promise.all([
        apiService.listarMateriais(filtros),
        apiService.obterEstatisticas()
      ]);

      if (materiaisResponse.sucesso && materiaisResponse.dados) {
        setMateriais(materiaisResponse.dados);
      }

      if (estatisticasResponse.sucesso && estatisticasResponse.dados) {
        setEstatisticas(estatisticasResponse.dados);
      }
    } catch (err: any) {
      setError(err.response?.data?.erro || err.message || 'Erro ao carregar dados');
    } finally {
      setIsLoading(false);
    }
  };

  const handleFiltroChange = (campo: string, valor: string) => {
    setFiltros(prev => ({
      ...prev,
      [campo]: valor,
      page: 1 // Reset para primeira página ao filtrar
    }));
  };

  const handleBusca = (termo: string) => {
    setFiltros(prev => ({
      ...prev,
      termo_busca: termo,
      page: 1
    }));
  };

  const getTipoIcon = (tipo: string) => {
    switch (tipo) {
      case 'Livro':
        return <BookOpen className="h-5 w-5 text-blue-600" />;
      case 'Artigo':
        return <FileText className="h-5 w-5 text-green-600" />;
      case 'Video':
        return <Video className="h-5 w-5 text-purple-600" />;
      default:
        return <BookOpen className="h-5 w-5 text-gray-600" />;
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'publicado':
        return 'bg-green-100 text-green-800';
      case 'rascunho':
        return 'bg-yellow-100 text-yellow-800';
      case 'arquivado':
        return 'bg-gray-100 text-gray-800';
      default:
        return 'bg-gray-100 text-gray-800';
    }
  };

  const formatarData = (data: string) => {
    return new Date(data).toLocaleDateString('pt-BR');
  };

  const handleAdicionarMaterial = () => {
    setShowModal(true);
  };

  const handleFecharModal = () => {
    setShowModal(false);
    setNovoMaterial({
      tipo: 'Livro',
      titulo: '',
      descricao: '',
      status: 'rascunho',
      autor_id: '',
      isbn: '',
      numero_paginas: '',
      doi: '',
      duracao_minutos: ''
    });
  };

  const handleSalvarMaterial = async () => {
    try {
      setIsLoading(true);
      
      // Validações obrigatórias gerais
      if (!novoMaterial.titulo || novoMaterial.titulo.trim() === '') {
        alert('Título é obrigatório');
        return;
      }
      
      if (!novoMaterial.autor_id || novoMaterial.autor_id === '') {
        alert('ID do Autor é obrigatório');
        return;
      }
      
      // Validar ID do autor (deve ser um número entre 1 e 7)
      const autorId = parseInt(novoMaterial.autor_id);
      if (isNaN(autorId) || autorId < 1 || autorId > 7) {
        alert('ID do Autor deve ser um número entre 1 e 7');
        return;
      }
      
      // Validações específicas por tipo
      if (novoMaterial.tipo === 'Livro') {
        // Validar ISBN
        if (!novoMaterial.isbn || novoMaterial.isbn.length !== 13) {
          alert('ISBN deve ter exatamente 13 dígitos');
          return;
        }
        if (!/^\d{13}$/.test(novoMaterial.isbn)) {
          alert('ISBN deve conter apenas números');
          return;
        }
        
        // Lista de ISBNs já existentes (para validação no frontend)
        const isbnsExistentes = [
          '9780321765723', '9780596516178', '9781491921706', '1234567890123',
          '9876543210987', '1111111111111', '9999999999999', '5555555555555',
          '7777777777777', '8888888888888', '1234567890124', '1234567890125'
        ];
        
        if (isbnsExistentes.includes(novoMaterial.isbn)) {
          alert('Este ISBN já está cadastrado. Use um ISBN diferente.');
          return;
        }
        
        // Validar número de páginas
        const numeroPaginas = parseInt(novoMaterial.numero_paginas);
        if (isNaN(numeroPaginas) || numeroPaginas <= 0) {
          alert('Número de páginas deve ser maior que zero');
          return;
        }
      } else if (novoMaterial.tipo === 'Artigo') {
        // Validar DOI
        if (!novoMaterial.doi || novoMaterial.doi.trim() === '') {
          alert('DOI é obrigatório para artigos');
          return;
        }
      } else if (novoMaterial.tipo === 'Video') {
        // Validar duração
        const duracao = parseInt(novoMaterial.duracao_minutos);
        if (isNaN(duracao) || duracao <= 0) {
          alert('Duração deve ser maior que zero');
          return;
        }
      }
      
      const dadosMaterial: any = {
        tipo: novoMaterial.tipo as 'Livro' | 'Artigo' | 'Video',
        titulo: novoMaterial.titulo,
        descricao: novoMaterial.descricao,
        status: novoMaterial.status as 'rascunho' | 'publicado' | 'arquivado',
        autor_id: parseInt(novoMaterial.autor_id)
      };

      // Adiciona campos específicos baseado no tipo
      if (novoMaterial.tipo === 'Livro') {
        dadosMaterial.isbn = novoMaterial.isbn;
        dadosMaterial.numero_paginas = parseInt(novoMaterial.numero_paginas) || 0;
      } else if (novoMaterial.tipo === 'Artigo') {
        dadosMaterial.doi = novoMaterial.doi;
      } else if (novoMaterial.tipo === 'Video') {
        dadosMaterial.duracao_minutos = parseInt(novoMaterial.duracao_minutos) || 0;
      }

      const response = await apiService.criarMaterial(dadosMaterial);
      
      if (response.sucesso) {
        handleFecharModal();
        carregarDados(); // Recarrega a lista
        alert('Material criado com sucesso!');
      } else {
        alert('Erro ao criar material: ' + (response.erro || 'Erro desconhecido'));
      }
    } catch (err: any) {
      // Mostrar erros específicos do backend
      let mensagemErro = 'Erro desconhecido';
      
      if (err.response?.data?.detalhes) {
        // Se for um array de detalhes
        mensagemErro = err.response.data.detalhes.join(', ');
      } else if (err.response?.data?.erro) {
        // Se for uma mensagem de erro simples
        mensagemErro = err.response.data.erro;
      } else if (err.message) {
        // Se for uma mensagem de erro padrão
        mensagemErro = err.message;
      }
      
      // Tratar mensagens específicas
      if (mensagemErro.includes('Isbn já está em uso')) {
        mensagemErro = 'Este ISBN já está cadastrado. Use um ISBN diferente.';
      } else if (mensagemErro.includes('Validation failed')) {
        mensagemErro = mensagemErro.replace('Validation failed: ', '');
      }
      
      alert('Erro ao criar material: ' + mensagemErro);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center py-6">
            <div className="flex items-center">
              <BookOpen className="h-8 w-8 text-primary-600 mr-3" />
              <h1 className="text-2xl font-bold text-gray-900">Biblioteca Digital</h1>
            </div>
            
            <div className="flex items-center space-x-4">
              <div className="flex items-center text-sm text-gray-700">
                <User className="h-4 w-4 mr-1" />
                {usuario?.email}
              </div>
              <button
                onClick={logout}
                className="flex items-center text-sm text-gray-700 hover:text-gray-900"
              >
                <LogOut className="h-4 w-4 mr-1" />
                Sair
              </button>
            </div>
          </div>
        </div>
      </header>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Estatísticas */}
        {estatisticas && (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
            <div className="bg-white overflow-hidden shadow rounded-lg">
              <div className="p-5">
                <div className="flex items-center">
                  <div className="flex-shrink-0">
                    <BookOpen className="h-6 w-6 text-blue-600" />
                  </div>
                  <div className="ml-5 w-0 flex-1">
                    <dl>
                      <dt className="text-sm font-medium text-gray-500 truncate">
                        Total de Materiais
                      </dt>
                      <dd className="text-lg font-medium text-gray-900">
                        {estatisticas.total_materiais}
                      </dd>
                    </dl>
                  </div>
                </div>
              </div>
            </div>

            <div className="bg-white overflow-hidden shadow rounded-lg">
              <div className="p-5">
                <div className="flex items-center">
                  <div className="flex-shrink-0">
                    <Users className="h-6 w-6 text-green-600" />
                  </div>
                  <div className="ml-5 w-0 flex-1">
                    <dl>
                      <dt className="text-sm font-medium text-gray-500 truncate">
                        Total de Autores
                      </dt>
                      <dd className="text-lg font-medium text-gray-900">
                        {estatisticas.total_autores}
                      </dd>
                    </dl>
                  </div>
                </div>
              </div>
            </div>

            <div className="bg-white overflow-hidden shadow rounded-lg">
              <div className="p-5">
                <div className="flex items-center">
                  <div className="flex-shrink-0">
                    <BarChart3 className="h-6 w-6 text-purple-600" />
                  </div>
                  <div className="ml-5 w-0 flex-1">
                    <dl>
                      <dt className="text-sm font-medium text-gray-500 truncate">
                        Publicados
                      </dt>
                      <dd className="text-lg font-medium text-gray-900">
                        {estatisticas.por_status.publicado}
                      </dd>
                    </dl>
                  </div>
                </div>
              </div>
            </div>

            <div className="bg-white overflow-hidden shadow rounded-lg">
              <div className="p-5">
                <div className="flex items-center">
                  <div className="flex-shrink-0">
                    <User className="h-6 w-6 text-orange-600" />
                  </div>
                  <div className="ml-5 w-0 flex-1">
                    <dl>
                      <dt className="text-sm font-medium text-gray-500 truncate">
                        Usuários
                      </dt>
                      <dd className="text-lg font-medium text-gray-900">
                        {estatisticas.total_usuarios}
                      </dd>
                    </dl>
                  </div>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Filtros e Busca */}
        <div className="bg-white shadow rounded-lg p-6 mb-8">
          <div className="flex flex-col lg:flex-row lg:items-center lg:justify-between space-y-4 lg:space-y-0">
            <div className="flex flex-col sm:flex-row space-y-2 sm:space-y-0 sm:space-x-4">
              {/* Busca */}
              <div className="relative">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
                <input
                  type="text"
                  placeholder="Buscar materiais..."
                  value={filtros.termo_busca}
                  onChange={(e) => handleBusca(e.target.value)}
                  className="pl-10 pr-4 py-2 border border-gray-300 rounded-md focus:ring-primary-500 focus:border-primary-500"
                />
              </div>

              {/* Filtro por tipo */}
              <select
                value={filtros.tipo}
                onChange={(e) => handleFiltroChange('tipo', e.target.value)}
                className="px-3 py-2 border border-gray-300 rounded-md focus:ring-primary-500 focus:border-primary-500"
              >
                <option value="">Todos os tipos</option>
                <option value="Livro">Livros</option>
                <option value="Artigo">Artigos</option>
                <option value="Video">Vídeos</option>
              </select>

              {/* Filtro por status */}
              <select
                value={filtros.status}
                onChange={(e) => handleFiltroChange('status', e.target.value)}
                className="px-3 py-2 border border-gray-300 rounded-md focus:ring-primary-500 focus:border-primary-500"
              >
                <option value="">Todos os status</option>
                <option value="publicado">Publicados</option>
                <option value="rascunho">Rascunhos</option>
                <option value="arquivado">Arquivados</option>
              </select>
            </div>

            <div className="flex items-center space-x-4">
              {/* Botão de visualização */}
              <div className="flex border border-gray-300 rounded-md">
                <button
                  onClick={() => setViewMode('grid')}
                  className={`p-2 ${viewMode === 'grid' ? 'bg-primary-100 text-primary-600' : 'text-gray-500'}`}
                >
                  <Grid className="h-4 w-4" />
                </button>
                <button
                  onClick={() => setViewMode('list')}
                  className={`p-2 ${viewMode === 'list' ? 'bg-primary-100 text-primary-600' : 'text-gray-500'}`}
                >
                  <List className="h-4 w-4" />
                </button>
              </div>

              {/* Botão adicionar */}
              <button 
                onClick={handleAdicionarMaterial}
                className="flex items-center px-4 py-2 bg-primary-600 text-white rounded-md hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-primary-500"
              >
                <Plus className="h-4 w-4 mr-2" />
                Adicionar Material
              </button>
            </div>
          </div>
        </div>

        {/* Lista de Materiais */}
        {isLoading ? (
          <div className="flex justify-center items-center py-12">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600"></div>
          </div>
        ) : error ? (
          <div className="bg-red-50 border border-red-200 text-red-600 px-4 py-3 rounded-md">
            {error}
          </div>
        ) : (
          <div className={viewMode === 'grid' ? 'grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6' : 'space-y-4'}>
            {materiais.map((material) => (
              <div
                key={material.id}
                className={`bg-white shadow rounded-lg ${viewMode === 'list' ? 'p-6' : 'p-6'}`}
              >
                <div className="flex items-start justify-between">
                  <div className="flex items-center">
                    {getTipoIcon(material.tipo)}
                    <div className="ml-3">
                      <h3 className="text-lg font-medium text-gray-900">
                        {material.titulo}
                      </h3>
                      <p className="text-sm text-gray-500">
                        por {material.autor.nome}
                      </p>
                    </div>
                  </div>
                  <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getStatusColor(material.status)}`}>
                    {material.status}
                  </span>
                </div>

                {material.descricao && (
                  <p className="mt-3 text-sm text-gray-600 line-clamp-2">
                    {material.descricao}
                  </p>
                )}

                <div className="mt-4 flex items-center justify-between text-sm text-gray-500">
                  <span>Criado em {formatarData(material.criado_em)}</span>
                  <span>por {material.criado_por}</span>
                </div>

                {material.informacoes_especificas && (
                  <div className="mt-3 pt-3 border-t border-gray-200">
                    <div className="text-sm text-gray-600">
                      {material.tipo === 'Livro' && material.informacoes_especificas.isbn && (
                        <div>ISBN: {material.informacoes_especificas.isbn}</div>
                      )}
                      {material.tipo === 'Livro' && material.informacoes_especificas.numero_paginas && (
                        <div>{material.informacoes_especificas.numero_paginas} páginas</div>
                      )}
                      {material.tipo === 'Artigo' && material.informacoes_especificas.doi && (
                        <div>DOI: {material.informacoes_especificas.doi}</div>
                      )}
                      {material.tipo === 'Video' && material.informacoes_especificas.duracao_minutos && (
                        <div>{material.informacoes_especificas.duracao_minutos} minutos</div>
                      )}
                    </div>
                  </div>
                )}
              </div>
            ))}
          </div>
        )}

        {materiais.length === 0 && !isLoading && (
          <div className="text-center py-12">
            <BookOpen className="mx-auto h-12 w-12 text-gray-400" />
            <h3 className="mt-2 text-sm font-medium text-gray-900">Nenhum material encontrado</h3>
            <p className="mt-1 text-sm text-gray-500">
              Tente ajustar os filtros ou adicionar novos materiais.
            </p>
          </div>
        )}
      </div>

      {/* Modal para Adicionar Material */}
      {showModal && (
        <div className="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
          <div className="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white">
            <div className="mt-3">
              <h3 className="text-lg font-medium text-gray-900 mb-4">
                Adicionar Novo Material
              </h3>
              
              <div className="space-y-4">
                {/* Tipo */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Tipo
                  </label>
                  <select
                    value={novoMaterial.tipo}
                    onChange={(e) => setNovoMaterial({...novoMaterial, tipo: e.target.value})}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-primary-500 focus:border-primary-500"
                  >
                    <option value="Livro">Livro</option>
                    <option value="Artigo">Artigo</option>
                    <option value="Video">Vídeo</option>
                  </select>
                </div>

                {/* Título */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Título <span className="text-red-500">*</span>
                  </label>
                  <input
                    type="text"
                    value={novoMaterial.titulo}
                    onChange={(e) => setNovoMaterial({...novoMaterial, titulo: e.target.value})}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-primary-500 focus:border-primary-500"
                    placeholder="Digite o título do material"
                    required
                  />
                  {!novoMaterial.titulo && (
                    <p className="text-xs text-red-500 mt-1">
                      Título é obrigatório
                    </p>
                  )}
                </div>

                {/* Descrição */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Descrição
                  </label>
                  <textarea
                    value={novoMaterial.descricao}
                    onChange={(e) => setNovoMaterial({...novoMaterial, descricao: e.target.value})}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-primary-500 focus:border-primary-500"
                    rows={3}
                    placeholder="Digite uma descrição do material"
                  />
                </div>

                {/* Status */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Status
                  </label>
                  <select
                    value={novoMaterial.status}
                    onChange={(e) => setNovoMaterial({...novoMaterial, status: e.target.value})}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-primary-500 focus:border-primary-500"
                  >
                    <option value="rascunho">Rascunho</option>
                    <option value="publicado">Publicado</option>
                    <option value="arquivado">Arquivado</option>
                  </select>
                </div>

                {/* Autor ID */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    ID do Autor <span className="text-red-500">*</span>
                  </label>
                  <input
                    type="number"
                    value={novoMaterial.autor_id}
                    onChange={(e) => setNovoMaterial({...novoMaterial, autor_id: e.target.value})}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-primary-500 focus:border-primary-500"
                    placeholder="Digite o ID do autor (1-7)"
                    min="1"
                    max="7"
                    required
                  />
                  {(!novoMaterial.autor_id || parseInt(novoMaterial.autor_id) < 1 || parseInt(novoMaterial.autor_id) > 7) && (
                    <p className="text-xs text-red-500 mt-1">
                      ID do Autor deve ser um número entre 1 e 7
                    </p>
                  )}
                </div>

                {/* Campos específicos baseado no tipo */}
                {novoMaterial.tipo === 'Livro' && (
                  <>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">
                        ISBN <span className="text-red-500">*</span>
                      </label>
                      <input
                        type="text"
                        value={novoMaterial.isbn}
                        onChange={(e) => setNovoMaterial({...novoMaterial, isbn: e.target.value})}
                        className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-primary-500 focus:border-primary-500"
                        placeholder="Digite o ISBN (13 dígitos)"
                        maxLength={13}
                      />
                      <p className="text-xs text-gray-500 mt-1">
                        ISBN deve ter exatamente 13 dígitos numéricos
                      </p>
                      <p className="text-xs text-blue-600 mt-1">
                        💡 Dica: Use um ISBN único (ex: 1234567890126, 1234567890127, etc.)
                      </p>
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">
                        Número de Páginas <span className="text-red-500">*</span>
                      </label>
                      <input
                        type="number"
                        value={novoMaterial.numero_paginas}
                        onChange={(e) => setNovoMaterial({...novoMaterial, numero_paginas: e.target.value})}
                        className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-primary-500 focus:border-primary-500"
                        placeholder="Digite o número de páginas"
                        min="1"
                        required
                      />
                      {(!novoMaterial.numero_paginas || parseInt(novoMaterial.numero_paginas) <= 0) && (
                        <p className="text-xs text-red-500 mt-1">
                          Número de páginas deve ser maior que zero
                        </p>
                      )}
                    </div>
                  </>
                )}

                {novoMaterial.tipo === 'Artigo' && (
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      DOI <span className="text-red-500">*</span>
                    </label>
                    <input
                      type="text"
                      value={novoMaterial.doi}
                      onChange={(e) => setNovoMaterial({...novoMaterial, doi: e.target.value})}
                      className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-primary-500 focus:border-primary-500"
                      placeholder="Digite o DOI"
                      required
                    />
                    {!novoMaterial.doi && (
                      <p className="text-xs text-red-500 mt-1">
                        DOI é obrigatório para artigos
                      </p>
                    )}
                  </div>
                )}

                {novoMaterial.tipo === 'Video' && (
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Duração (minutos) <span className="text-red-500">*</span>
                    </label>
                    <input
                      type="number"
                      value={novoMaterial.duracao_minutos}
                      onChange={(e) => setNovoMaterial({...novoMaterial, duracao_minutos: e.target.value})}
                      className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-primary-500 focus:border-primary-500"
                      placeholder="Digite a duração em minutos"
                      min="1"
                      required
                    />
                    {(!novoMaterial.duracao_minutos || parseInt(novoMaterial.duracao_minutos) <= 0) && (
                      <p className="text-xs text-red-500 mt-1">
                        Duração deve ser maior que zero
                      </p>
                    )}
                  </div>
                )}
              </div>

              {/* Botões */}
              <div className="flex justify-end space-x-3 mt-6">
                <button
                  onClick={handleFecharModal}
                  className="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 rounded-md hover:bg-gray-200 focus:outline-none focus:ring-2 focus:ring-gray-500"
                >
                  Cancelar
                </button>
                <button
                  onClick={handleSalvarMaterial}
                  disabled={
                    !novoMaterial.titulo || 
                    !novoMaterial.autor_id || 
                    parseInt(novoMaterial.autor_id) < 1 || 
                    parseInt(novoMaterial.autor_id) > 7 ||
                    (novoMaterial.tipo === 'Livro' && (!novoMaterial.isbn || novoMaterial.isbn.length !== 13 || !novoMaterial.numero_paginas || parseInt(novoMaterial.numero_paginas) <= 0)) ||
                    (novoMaterial.tipo === 'Artigo' && !novoMaterial.doi) ||
                    (novoMaterial.tipo === 'Video' && (!novoMaterial.duracao_minutos || parseInt(novoMaterial.duracao_minutos) <= 0))
                  }
                  className="px-4 py-2 text-sm font-medium text-white bg-primary-600 rounded-md hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-primary-500 disabled:bg-gray-300 disabled:cursor-not-allowed"
                >
                  Salvar Material
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default Dashboard;
