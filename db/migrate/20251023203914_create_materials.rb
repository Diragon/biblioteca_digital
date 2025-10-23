class CreateMaterials < ActiveRecord::Migration[8.1]
  def change
    create_table :materials do |t|
      # Tipo do material: 'Livro', 'Artigo' ou 'Video'
      t.string :tipo, null: false
      # Título do material - obrigatório
      t.string :titulo, null: false
      # Descrição opcional do material
      t.text :descricao
      # Status do material: 'rascunho', 'publicado' ou 'arquivado'
      t.string :status, null: false, default: 'rascunho'
      # Referência ao usuário que criou o material
      t.references :usuario, null: false, foreign_key: true
      # Referência ao autor do material
      t.references :autor, null: false, foreign_key: true

      t.timestamps
    end
    
    # Índices para otimizar consultas
    add_index :materials, :tipo
    add_index :materials, :status
    add_index :materials, :titulo
  end
end
