class CreateAutors < ActiveRecord::Migration[8.1]
  def change
    create_table :autors do |t|
      # Tipo do autor: 'Pessoa' ou 'Instituicao'
      t.string :tipo, null: false
      # Nome do autor - obrigatório
      t.string :nome, null: false
      # Data de nascimento - obrigatória para pessoas, nula para instituições
      t.date :data_nascimento
      # Cidade - obrigatória para instituições, opcional para pessoas
      t.string :cidade

      t.timestamps
    end

    # Índice para tipo para otimizar consultas
    add_index :autors, :tipo
  end
end
