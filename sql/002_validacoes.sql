-- Sistema de Análise Bloons TD 6
-- regras de validação (CHECK/UNIQUE)
-- Rodar DEPOIS do 001_criar_tabelas.sql

-- VALIDAÇÕES: DADOS DE REFERÊNCIA

ALTER TABLE torres
  ADD CONSTRAINT torres_custo_base_ck CHECK (custo_base >= 0),
  ADD CONSTRAINT torres_alcance_ck CHECK (
    alcance_base IS NULL OR alcance_base >= 0
  );

ALTER TABLE upgrades
  ADD CONSTRAINT upgrades_nivel_ck CHECK (nivel BETWEEN 1 AND 5),
  ADD CONSTRAINT upgrades_custo_ck CHECK (custo >= 0);

ALTER TABLE herois
  ADD CONSTRAINT herois_custo_base_ck CHECK (custo_base >= 0);

ALTER TABLE bloons
  ADD CONSTRAINT bloons_vida_ck CHECK (vida >= 0),
  ADD CONSTRAINT bloons_filhos_ck CHECK (
    filhos_gerados IS NULL OR filhos_gerados >= 0
  );

ALTER TABLE mapas
  ADD CONSTRAINT mapas_caminhos_ck CHECK (numero_caminhos >= 1);

-- VALIDAÇÕES: ESTRATÉGIAS

ALTER TABLE estrategias
  ADD CONSTRAINT estrategias_round_alvo_ck CHECK (
    round_alvo IS NULL OR round_alvo >= 1
  ),
  ADD CONSTRAINT estrategias_custo_ck CHECK (
    custo_total_estimado IS NULL OR custo_total_estimado >= 0
  ),
  -- CHIMPS só existe na dificuldade Impopível
  ADD CONSTRAINT estrategias_chimps_ck CHECK (
    modo_alvo IS DISTINCT FROM 'impopivel_chimps'
    OR dificuldade_alvo = 'impopivel'
  );

ALTER TABLE estrategia_torres
  ADD CONSTRAINT estrategia_torres_quantidade_ck CHECK (quantidade >= 1),
  ADD CONSTRAINT estrategia_torres_round_ck CHECK (
    round_colocacao IS NULL OR round_colocacao >= 1
  ),
  -- cada caminho vai de 0 a 5
  ADD CONSTRAINT estrategia_torres_niveis_ck CHECK (
    upgrade_caminho_1 BETWEEN 0 AND 5
    AND upgrade_caminho_2 BETWEEN 0 AND 5
    AND upgrade_caminho_3 BETWEEN 0 AND 5
  ),
  -- regra do jogo: no máximo 1 caminho acima de 2 e no máximo 2 caminhos usados
  ADD CONSTRAINT estrategia_torres_regra_jogo_ck CHECK (
    (upgrade_caminho_1 > 2)::int + (upgrade_caminho_2 > 2)::int + (upgrade_caminho_3 > 2)::int <= 1
    AND (upgrade_caminho_1 > 0)::int + (upgrade_caminho_2 > 0)::int + (upgrade_caminho_3 > 0)::int <= 2
  );

-- sem duas torres com a mesma ordem de colocação na mesma estratégia
CREATE UNIQUE INDEX estrategia_torres_ordem_uq
ON estrategia_torres (estrategia_id, ordem);

-- VALIDAÇÕES: PARTIDAS

ALTER TABLE partidas
  ADD CONSTRAINT partidas_round_inicial_ck CHECK (round_inicial >= 1),
  ADD CONSTRAINT partidas_round_final_ck CHECK (round_final >= round_inicial),
  ADD CONSTRAINT partidas_vidas_ck CHECK (
    vidas_restantes IS NULL OR vidas_restantes >= 0
  ),
  ADD CONSTRAINT partidas_dinheiro_ck CHECK (
    dinheiro_final IS NULL OR dinheiro_final >= 0
  ),
  ADD CONSTRAINT partidas_duracao_ck CHECK (
    duracao_segundos IS NULL OR duracao_segundos >= 0
  ),
  ADD CONSTRAINT partidas_chimps_ck CHECK (
    modo <> 'impopivel_chimps'
    OR dificuldade = 'impopivel'
  );

ALTER TABLE partida_falhas
  ADD CONSTRAINT partida_falhas_round_ck CHECK (round_falha >= 1),
  ADD CONSTRAINT partida_falhas_vidas_ck CHECK (
    vidas_perdidas IS NULL OR vidas_perdidas >= 0
  );

-- VALIDAÇÕES: RECOMENDAÇÕES

ALTER TABLE recomendacoes
  ADD CONSTRAINT recomendacoes_posicao_ck CHECK (posicao_ranking >= 1),
  ADD CONSTRAINT recomendacoes_taxa_ck CHECK (
    taxa_vitoria BETWEEN 0 AND 100
  ),
  ADD CONSTRAINT recomendacoes_total_ck CHECK (total_partidas >= 1),
  ADD CONSTRAINT recomendacoes_chimps_ck CHECK (
    modo <> 'impopivel_chimps'
    OR dificuldade = 'impopivel'
  );

-- a mesma estratégia não aparece duas vezes no ranking do mesmo cenário
CREATE UNIQUE INDEX recomendacoes_cenario_estrategia_uq
ON recomendacoes (
  mapa_id,
  dificuldade,
  modo,
  estrategia_id
);