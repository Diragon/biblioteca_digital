class CreateVideos < ActiveRecord::Migration[8.1]
  def change
    create_table :videos do |t|
      # Referência ao material base
      t.references :material, null: false, foreign_key: true
      # Duração do vídeo em minutos - deve ser maior que zero
      t.integer :duracao_minutos, null: false

      t.timestamps
    end
  end
end
