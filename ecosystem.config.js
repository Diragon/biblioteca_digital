// Configuração PM2 para Biblioteca Digital
module.exports = {
  apps: [
    {
      name: 'biblioteca-digital-backend',
      script: 'bin/rails',
      args: 'server -e production -p 3000',
      cwd: '/caminho/para/biblioteca_digital',
      instances: 1,
      exec_mode: 'fork',
      env: {
        RAILS_ENV: 'production',
        DATABASE_URL: 'postgresql://usuario:senha@localhost/biblioteca_digital_production',
        JWT_SECRET: 'seu_jwt_secret_producao',
        SECRET_KEY_BASE: 'seu_secret_key_base_producao'
      },
      env_development: {
        RAILS_ENV: 'development',
        DATABASE_URL: 'postgresql://usuario:senha@localhost/biblioteca_digital_development',
        JWT_SECRET: 'jwt_secret_development',
        SECRET_KEY_BASE: 'secret_key_base_development'
      },
      log_file: 'log/combined.log',
      out_file: 'log/out.log',
      error_file: 'log/error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
      merge_logs: true,
      max_memory_restart: '1G',
      node_args: '--max-old-space-size=1024'
    },
    {
      name: 'biblioteca-digital-frontend',
      script: 'npm',
      args: 'start',
      cwd: '/caminho/para/biblioteca_digital/frontend',
      instances: 1,
      exec_mode: 'fork',
      env: {
        NODE_ENV: 'production',
        PORT: 3001,
        REACT_APP_API_URL: 'http://localhost:3000'
      },
      env_development: {
        NODE_ENV: 'development',
        PORT: 3001,
        REACT_APP_API_URL: 'http://localhost:3000'
      },
      log_file: 'log/frontend-combined.log',
      out_file: 'log/frontend-out.log',
      error_file: 'log/frontend-error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
      merge_logs: true,
      max_memory_restart: '512M'
    }
  ],

  deploy: {
    production: {
      user: 'deploy',
      host: 'seu-servidor.com',
      ref: 'origin/main',
      repo: 'git@github.com:seu-usuario/biblioteca-digital.git',
      path: '/var/www/biblioteca-digital',
      'pre-deploy-local': '',
      'post-deploy': 'bundle install && rails db:migrate && pm2 reload ecosystem.config.js --env production',
      'pre-setup': ''
    }
  }
};
