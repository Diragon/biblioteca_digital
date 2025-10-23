class CreateLivros < ActiveRecord::Migration[8.1]
  def change
    create_table :livros do |t|
      # Referência ao material base
      t.references :material, null: false, foreign_key: true
      # ISBN do livro - deve ser único e ter exatamente 13 caracteres
      t.string :isbn, null: false, limit: 13
      # Número de páginas - deve ser maior que zero
      t.integer :numero_paginas, null: false

      t.timestamps
    end
    
    # Índice único para ISBN para garantir unicidade
    add_index :livros, :isbn, unique: true
  end
end
