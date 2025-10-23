require 'rails_helper'

RSpec.describe Artigo, type: :model do
  let(:material) { create(:material, tipo: "Artigo") }

  describe "validações" do
    it "é válido com dados válidos" do
      artigo = build(:artigo, material: material)
      expect(artigo).to be_valid
    end

    it "não é válido sem DOI" do
      artigo = build(:artigo, doi: nil, material: material)
      expect(artigo).not_to be_valid
      expect(artigo.errors[:doi]).to include("não pode estar em branco")
    end

    it "não é válido com DOI duplicado" do
      create(:artigo, doi: "10.1000/xyz123", material: material)
      artigo_duplicado = build(:artigo, doi: "10.1000/xyz123", material: material)
      expect(artigo_duplicado).not_to be_valid
      expect(artigo_duplicado.errors[:doi]).to include("já está em uso")
    end

    it "não é válido com DOI inválido" do
      artigo = build(:artigo, doi: "doi_invalido", material: material)
      expect(artigo).not_to be_valid
      expect(artigo.errors[:doi]).to include("deve seguir o formato padrão DOI (ex: 10.1000/xyz123)")
    end

    it "aceita DOI válido" do
      artigo = build(:artigo, doi: "10.1000/xyz123", material: material)
      expect(artigo).to be_valid
    end
  end

  describe "métodos" do
    let(:artigo) { create(:artigo, material: material) }

    it "retorna DOI URL corretamente" do
      expect(artigo.doi_url).to eq("https://doi.org/#{artigo.doi}")
    end

    it "retorna informações completas" do
      informacoes = artigo.informacoes_completas
      expect(informacoes[:doi]).to eq(artigo.doi)
      expect(informacoes[:doi_url]).to eq(artigo.doi_url)
      expect(informacoes[:material][:titulo]).to eq(material.titulo)
    end
  end

  describe "métodos de classe" do
    it "busca artigo por DOI" do
      artigo = create(:artigo, doi: "10.1000/xyz123", material: material)
      artigo_encontrado = Artigo.buscar_por_doi("10.1000/xyz123")
      expect(artigo_encontrado).to eq(artigo)
    end

    it "valida DOI corretamente" do
      expect(Artigo.doi_valido?("10.1000/xyz123")).to be true
      expect(Artigo.doi_valido?("doi_invalido")).to be false
      expect(Artigo.doi_valido?("10.1000")).to be false
    end
  end
end
