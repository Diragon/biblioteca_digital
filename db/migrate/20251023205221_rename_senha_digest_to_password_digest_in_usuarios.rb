class RenameSenhaDigestToPasswordDigestInUsuarios < ActiveRecord::Migration[8.1]
  def change
    # Renomeia a coluna senha_digest para password_digest para compatibilidade com has_secure_password
    rename_column :usuarios, :senha_digest, :password_digest
  end
end
