require 'rails_helper'

RSpec.describe Livro, type: :model do
  let(:material) { create(:material, tipo: "Livro") }

  describe "validações" do
    it "é válido com dados válidos" do
      livro = build(:livro, material: material)
      expect(livro).to be_valid
    end

    it "não é válido sem ISBN" do
      livro = build(:livro, isbn: nil, material: material)
      expect(livro).not_to be_valid
      expect(livro.errors[:isbn]).to include("não pode estar em branco")
    end

    it "não é válido com ISBN duplicado" do
      create(:livro, isbn: "9781234567890", material: material)
      livro_duplicado = build(:livro, isbn: "9781234567890", material: material)
      expect(livro_duplicado).not_to be_valid
      expect(livro_duplicado.errors[:isbn]).to include("já está em uso")
    end

    it "não é válido com ISBN inválido" do
      livro = build(:livro, isbn: "123", material: material)
      expect(livro).not_to be_valid
      expect(livro.errors[:isbn]).to include("deve ter exatamente 13 caracteres")
    end

    it "não é válido com ISBN não numérico" do
      livro = build(:livro, isbn: "abc1234567890", material: material)
      expect(livro).not_to be_valid
      expect(livro.errors[:isbn]).to include("deve conter apenas números")
    end

    it "não é válido sem número de páginas" do
      livro = build(:livro, numero_paginas: nil, material: material)
      expect(livro).not_to be_valid
      expect(livro.errors[:numero_paginas]).to include("não pode estar em branco")
    end

    it "não é válido com número de páginas zero" do
      livro = build(:livro, numero_paginas: 0, material: material)
      expect(livro).not_to be_valid
      expect(livro.errors[:numero_paginas]).to include("deve ser maior que zero")
    end

    it "não é válido com número de páginas negativo" do
      livro = build(:livro, numero_paginas: -1, material: material)
      expect(livro).not_to be_valid
      expect(livro.errors[:numero_paginas]).to include("deve ser maior que zero")
    end
  end

  describe "métodos" do
    let(:livro) { create(:livro, material: material) }

    it "formata ISBN corretamente" do
      expect(livro.isbn_formatado).to eq("978-00-00000-00-5")
    end

    it "retorna informações completas" do
      informacoes = livro.informacoes_completas
      expect(informacoes[:isbn]).to eq(livro.isbn)
      expect(informacoes[:numero_paginas]).to eq(livro.numero_paginas)
      expect(informacoes[:material][:titulo]).to eq(material.titulo)
    end
  end

  describe "métodos de classe" do
    it "busca livro por ISBN" do
      livro = create(:livro, isbn: "9781234567890", material: material)
      livro_encontrado = Livro.buscar_por_isbn("9781234567890")
      expect(livro_encontrado).to eq(livro)
    end

    it "valida ISBN corretamente" do
      expect(Livro.isbn_valido?("9781234567890")).to be true
      expect(Livro.isbn_valido?("123")).to be false
      expect(Livro.isbn_valido?("abc1234567890")).to be false
    end
  end
end
