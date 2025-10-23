require 'rails_helper'

RSpec.describe Autor, type: :model do
  describe "validações" do
    it "é válido com dados válidos para pessoa" do
      autor = build(:autor, tipo: "Pessoa", nome: "João Silva", data_nascimento: Date.new(1990, 1, 1))
      expect(autor).to be_valid
    end

    it "é válido com dados válidos para instituição" do
      autor = build(:autor, tipo: "Instituicao", nome: "Universidade Federal", cidade: "São Paulo")
      expect(autor).to be_valid
    end

    it "não é válido sem nome" do
      autor = build(:autor, nome: nil)
      expect(autor).not_to be_valid
      expect(autor.errors[:nome]).to include("não pode estar em branco")
    end

    it "não é válido sem tipo" do
      autor = build(:autor, tipo: nil)
      expect(autor).not_to be_valid
      expect(autor.errors[:tipo]).to include("não pode estar em branco")
    end

    it "não é válido com tipo inválido" do
      autor = build(:autor, tipo: "TipoInvalido")
      expect(autor).not_to be_valid
      expect(autor.errors[:tipo]).to include("deve ser Pessoa ou Instituicao")
    end

    it "não é válido sem data de nascimento para pessoa" do
      autor = build(:autor, tipo: "Pessoa", data_nascimento: nil)
      expect(autor).not_to be_valid
      expect(autor.errors[:data_nascimento]).to include("é obrigatória para pessoas")
    end

    it "não é válido sem cidade para instituição" do
      autor = build(:autor, tipo: "Instituicao", cidade: nil)
      expect(autor).not_to be_valid
      expect(autor.errors[:cidade]).to include("é obrigatória para instituições")
    end
  end

  describe "métodos" do
    let(:autor_pessoa) { create(:autor, tipo: "Pessoa", nome: "João Silva", data_nascimento: Date.new(1990, 1, 1)) }
    let(:autor_instituicao) { create(:autor, tipo: "Instituicao", nome: "Universidade Federal", cidade: "São Paulo") }

    it "identifica corretamente se é pessoa" do
      expect(autor_pessoa.pessoa?).to be true
      expect(autor_instituicao.pessoa?).to be false
    end

    it "identifica corretamente se é instituição" do
      expect(autor_pessoa.instituicao?).to be false
      expect(autor_instituicao.instituicao?).to be true
    end

    it "retorna nome completo formatado" do
      expect(autor_pessoa.nome_completo).to eq("João Silva (Pessoa)")
      expect(autor_instituicao.nome_completo).to eq("Universidade Federal (Instituição)")
    end

    it "calcula idade corretamente para pessoa" do
      expect(autor_pessoa.idade).to be > 30
    end

    it "retorna nil para idade de instituição" do
      expect(autor_instituicao.idade).to be_nil
    end
  end
end
