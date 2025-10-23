require 'rails_helper'

RSpec.describe Material, type: :model do
  let(:usuario) { create(:usuario) }
  let(:autor) { create(:autor) }

  describe "validações" do
    it "é válido com dados válidos" do
      material = build(:material, usuario: usuario, autor: autor)
      expect(material).to be_valid
    end

    it "não é válido sem título" do
      material = build(:material, titulo: nil, usuario: usuario, autor: autor)
      expect(material).not_to be_valid
      expect(material.errors[:titulo]).to include("não pode estar em branco")
    end

    it "não é válido sem tipo" do
      material = build(:material, tipo: nil, usuario: usuario, autor: autor)
      expect(material).not_to be_valid
      expect(material.errors[:tipo]).to include("não pode estar em branco")
    end

    it "não é válido com tipo inválido" do
      material = build(:material, tipo: "TipoInvalido", usuario: usuario, autor: autor)
      expect(material).not_to be_valid
      expect(material.errors[:tipo]).to include("deve ser Livro, Artigo ou Video")
    end

    it "não é válido sem status" do
      material = build(:material, status: nil, usuario: usuario, autor: autor)
      expect(material).not_to be_valid
      expect(material.errors[:status]).to include("não pode estar em branco")
    end

    it "não é válido com status inválido" do
      material = build(:material, status: "status_invalido", usuario: usuario, autor: autor)
      expect(material).not_to be_valid
      expect(material.errors[:status]).to include("deve ser rascunho, publicado ou arquivado")
    end

    it "não é válido sem usuário" do
      material = build(:material, usuario: nil, autor: autor)
      expect(material).not_to be_valid
      expect(material.errors[:usuario]).to include("é obrigatório")
    end

    it "não é válido sem autor" do
      material = build(:material, usuario: usuario, autor: nil)
      expect(material).not_to be_valid
      expect(material.errors[:autor]).to include("é obrigatório")
    end
  end

  describe "métodos" do
    let(:material) { create(:material, usuario: usuario, autor: autor) }

    it "verifica se pode ser editado pelo criador" do
      expect(material.pode_ser_editado_por?(usuario)).to be true
    end

    it "não permite edição por outro usuário" do
      outro_usuario = create(:usuario)
      expect(material.pode_ser_editado_por?(outro_usuario)).to be false
    end

    it "verifica se pode ser excluído pelo criador" do
      expect(material.pode_ser_excluido_por?(usuario)).to be true
    end

    it "não permite exclusão por outro usuário" do
      outro_usuario = create(:usuario)
      expect(material.pode_ser_excluido_por?(outro_usuario)).to be false
    end

    it "verifica se está publicado" do
      material.update!(status: "publicado")
      expect(material.publicado?).to be true
    end

    it "verifica se é rascunho" do
      expect(material.rascunho?).to be true
    end

    it "verifica se está arquivado" do
      material.update!(status: "arquivado")
      expect(material.arquivado?).to be true
    end
  end

  describe "scopes" do
    let!(:material_publicado) { create(:material, status: "publicado", usuario: usuario, autor: autor) }
    let!(:material_rascunho) { create(:material, status: "rascunho", usuario: usuario, autor: autor) }
    let!(:material_livro) { create(:material, tipo: "Livro", usuario: usuario, autor: autor) }

    it "filtra por status" do
      expect(Material.por_status("publicado")).to include(material_publicado)
      expect(Material.por_status("publicado")).not_to include(material_rascunho)
    end

    it "filtra materiais publicados" do
      expect(Material.publicados).to include(material_publicado)
      expect(Material.publicados).not_to include(material_rascunho)
    end

    it "filtra por tipo" do
      expect(Material.por_tipo("Livro")).to include(material_livro)
    end

    it "busca por texto" do
      material = create(:material, titulo: "Título Específico", usuario: usuario, autor: autor)
      expect(Material.buscar_por_texto("Específico")).to include(material)
    end
  end
end
