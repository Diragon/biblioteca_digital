class CreateUsuarios < ActiveRecord::Migration[8.1]
  def change
    create_table :usuarios do |t|
      # Email do usuário - deve ser único e obrigatório
      t.string :email, null: false
      # Hash da senha usando bcrypt
      t.string :senha_digest, null: false

      t.timestamps
    end
    
    # Índice único para email para garantir unicidade
    add_index :usuarios, :email, unique: true
  end
end
