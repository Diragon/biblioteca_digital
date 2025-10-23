# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2025_10_23_205221) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "artigos", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "doi", null: false
    t.bigint "material_id", null: false
    t.datetime "updated_at", null: false
    t.index ["doi"], name: "index_artigos_on_doi", unique: true
    t.index ["material_id"], name: "index_artigos_on_material_id"
  end

  create_table "autors", force: :cascade do |t|
    t.string "cidade"
    t.datetime "created_at", null: false
    t.date "data_nascimento"
    t.string "nome", null: false
    t.string "tipo", null: false
    t.datetime "updated_at", null: false
    t.index ["tipo"], name: "index_autors_on_tipo"
  end

  create_table "livros", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "isbn", limit: 13, null: false
    t.bigint "material_id", null: false
    t.integer "numero_paginas", null: false
    t.datetime "updated_at", null: false
    t.index ["isbn"], name: "index_livros_on_isbn", unique: true
    t.index ["material_id"], name: "index_livros_on_material_id"
  end

  create_table "materials", force: :cascade do |t|
    t.bigint "autor_id", null: false
    t.datetime "created_at", null: false
    t.text "descricao"
    t.string "status", default: "rascunho", null: false
    t.string "tipo", null: false
    t.string "titulo", null: false
    t.datetime "updated_at", null: false
    t.bigint "usuario_id", null: false
    t.index ["autor_id"], name: "index_materials_on_autor_id"
    t.index ["status"], name: "index_materials_on_status"
    t.index ["tipo"], name: "index_materials_on_tipo"
    t.index ["titulo"], name: "index_materials_on_titulo"
    t.index ["usuario_id"], name: "index_materials_on_usuario_id"
  end

  create_table "usuarios", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_usuarios_on_email", unique: true
  end

  create_table "videos", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "duracao_minutos", null: false
    t.bigint "material_id", null: false
    t.datetime "updated_at", null: false
    t.index ["material_id"], name: "index_videos_on_material_id"
  end

  add_foreign_key "artigos", "materials"
  add_foreign_key "livros", "materials"
  add_foreign_key "materials", "autors"
  add_foreign_key "materials", "usuarios"
  add_foreign_key "videos", "materials"
end
