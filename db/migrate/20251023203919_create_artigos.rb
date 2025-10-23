class CreateArtigos < ActiveRecord::Migration[8.1]
  def change
    create_table :artigos do |t|
      # Referência ao material base
      t.references :material, null: false, foreign_key: true
      # DOI do artigo - deve ser único e seguir formato padrão
      t.string :doi, null: false

      t.timestamps
    end

    # Índice único para DOI para garantir unicidade
    add_index :artigos, :doi, unique: true
  end
end
