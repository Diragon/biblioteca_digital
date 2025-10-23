import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { Usuario, LoginRequest, RegistroRequest } from '../types/api';
import apiService from '../services/api';

interface AuthContextType {
  usuario: Usuario | null;
  token: string | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  login: (credenciais: LoginRequest) => Promise<void>;
  registrar: (dados: RegistroRequest) => Promise<void>;
  logout: () => void;
  atualizarPerfil: (dados: Partial<RegistroRequest>) => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

interface AuthProviderProps {
  children: ReactNode;
}

export const AuthProvider: React.FC<AuthProviderProps> = ({ children }) => {
  const [usuario, setUsuario] = useState<Usuario | null>(null);
  const [token, setToken] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  // Verifica se há token salvo no localStorage ao inicializar
  useEffect(() => {
    const tokenSalvo = localStorage.getItem('token');
    const usuarioSalvo = localStorage.getItem('usuario');

    if (tokenSalvo && usuarioSalvo) {
      setToken(tokenSalvo);
      setUsuario(JSON.parse(usuarioSalvo));
      
      // Valida o token com o servidor
      apiService.validarToken()
        .then((response) => {
          if (response.sucesso && response.dados?.valido) {
            setUsuario(response.dados.usuario);
          } else {
            // Token inválido, limpa o estado
            localStorage.removeItem('token');
            localStorage.removeItem('usuario');
            setToken(null);
            setUsuario(null);
          }
        })
        .catch(() => {
          // Erro na validação, limpa o estado
          localStorage.removeItem('token');
          localStorage.removeItem('usuario');
          setToken(null);
          setUsuario(null);
        })
        .finally(() => {
          setIsLoading(false);
        });
    } else {
      setIsLoading(false);
    }
  }, []);

  const login = async (credenciais: LoginRequest): Promise<void> => {
    try {
      const response = await apiService.login(credenciais);
      
      if (response.sucesso && response.dados) {
        const { token: novoToken, usuario: novoUsuario } = response.dados;
        
        // Salva no localStorage
        localStorage.setItem('token', novoToken);
        localStorage.setItem('usuario', JSON.stringify(novoUsuario));
        
        // Atualiza o estado
        setToken(novoToken);
        setUsuario(novoUsuario);
      } else {
        throw new Error(response.mensagem || 'Erro no login');
      }
    } catch (error) {
      throw error;
    }
  };

  const registrar = async (dados: RegistroRequest): Promise<void> => {
    try {
      const response = await apiService.registrar(dados);
      
      if (response.sucesso && response.dados) {
        const { token: novoToken, usuario: novoUsuario } = response.dados;
        
        // Salva no localStorage
        localStorage.setItem('token', novoToken);
        localStorage.setItem('usuario', JSON.stringify(novoUsuario));
        
        // Atualiza o estado
        setToken(novoToken);
        setUsuario(novoUsuario);
      } else {
        throw new Error(response.mensagem || 'Erro no registro');
      }
    } catch (error) {
      throw error;
    }
  };

  const logout = (): void => {
    // Remove do localStorage
    localStorage.removeItem('token');
    localStorage.removeItem('usuario');
    
    // Atualiza o estado
    setToken(null);
    setUsuario(null);
    
    // Chama o endpoint de logout (opcional)
    apiService.logout().catch(() => {
      // Ignora erros no logout
    });
  };

  const atualizarPerfil = async (dados: Partial<RegistroRequest>): Promise<void> => {
    try {
      const response = await apiService.atualizarPerfil(dados);
      
      if (response.sucesso && response.dados) {
        const usuarioAtualizado = response.dados;
        
        // Atualiza no localStorage
        localStorage.setItem('usuario', JSON.stringify(usuarioAtualizado));
        
        // Atualiza o estado
        setUsuario(usuarioAtualizado);
      } else {
        throw new Error(response.mensagem || 'Erro ao atualizar perfil');
      }
    } catch (error) {
      throw error;
    }
  };

  const value: AuthContextType = {
    usuario,
    token,
    isAuthenticated: !!token && !!usuario,
    isLoading,
    login,
    registrar,
    logout,
    atualizarPerfil,
  };

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = (): AuthContextType => {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth deve ser usado dentro de um AuthProvider');
  }
  return context;
};
