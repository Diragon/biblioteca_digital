require 'rails_helper'

RSpec.describe Video, type: :model do
  let(:material) { create(:material, tipo: "Video") }

  describe "validações" do
    it "é válido com dados válidos" do
      video = build(:video, material: material)
      expect(video).to be_valid
    end

    it "não é válido sem duração" do
      video = build(:video, duracao_minutos: nil, material: material)
      expect(video).not_to be_valid
      expect(video.errors[:duracao_minutos]).to include("não pode estar em branco")
    end

    it "não é válido com duração zero" do
      video = build(:video, duracao_minutos: 0, material: material)
      expect(video).not_to be_valid
      expect(video.errors[:duracao_minutos]).to include("deve ser um número inteiro maior que zero")
    end

    it "não é válido com duração negativa" do
      video = build(:video, duracao_minutos: -1, material: material)
      expect(video).not_to be_valid
      expect(video.errors[:duracao_minutos]).to include("deve ser um número inteiro maior que zero")
    end

    it "não é válido com duração não inteira" do
      video = build(:video, duracao_minutos: 1.5, material: material)
      expect(video).not_to be_valid
      expect(video.errors[:duracao_minutos]).to include("deve ser um número inteiro maior que zero")
    end

    it "não é válido com duração muito longa" do
      video = build(:video, duracao_minutos: 1500, material: material)
      expect(video).not_to be_valid
      expect(video.errors[:duracao_minutos]).to include("não pode ser maior que 24 horas")
    end
  end

  describe "métodos" do
    let(:video) { create(:video, material: material) }

    it "formata duração corretamente" do
      video.update!(duracao_minutos: 90)
      expect(video.duracao_formatada).to eq("1h 30min")
    end

    it "formata duração apenas em minutos" do
      video.update!(duracao_minutos: 30)
      expect(video.duracao_formatada).to eq("30min")
    end

    it "converte duração para segundos" do
      video.update!(duracao_minutos: 2)
      expect(video.duracao_segundos).to eq(120)
    end

    it "retorna informações completas" do
      informacoes = video.informacoes_completas
      expect(informacoes[:duracao_minutos]).to eq(video.duracao_minutos)
      expect(informacoes[:duracao_formatada]).to eq(video.duracao_formatada)
      expect(informacoes[:duracao_segundos]).to eq(video.duracao_segundos)
      expect(informacoes[:material][:titulo]).to eq(material.titulo)
    end
  end

  describe "métodos de classe" do
    it "filtra por duração" do
      video_curto = create(:video, duracao_minutos: 5, material: material)
      video_longo = create(:video, duracao_minutos: 120, material: material)
      
      videos_curtos = Video.por_duracao(max_minutos: 10)
      expect(videos_curtos).to include(video_curto)
      expect(videos_curtos).not_to include(video_longo)
    end

    it "filtra por categoria de duração" do
      video_curto = create(:video, duracao_minutos: 5, material: material)
      video_medio = create(:video, duracao_minutos: 30, material: material)
      video_longo = create(:video, duracao_minutos: 120, material: material)
      
      expect(Video.por_categoria_duracao("curto")).to include(video_curto)
      expect(Video.por_categoria_duracao("medio")).to include(video_medio)
      expect(Video.por_categoria_duracao("longo")).to include(video_longo)
    end

    it "retorna estatísticas de duração" do
      create(:video, duracao_minutos: 10, material: material)
      create(:video, duracao_minutos: 20, material: material)
      
      estatisticas = Video.estatisticas_duracao
      expect(estatisticas[:total_videos]).to eq(2)
      expect(estatisticas[:duracao_media]).to eq(15.0)
      expect(estatisticas[:duracao_minima]).to eq(10)
      expect(estatisticas[:duracao_maxima]).to eq(20)
      expect(estatisticas[:duracao_total]).to eq(30)
    end
  end
end
