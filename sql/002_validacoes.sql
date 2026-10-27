-- Sistema de Análise Bloons TD 6
-- regras de validação (CHECK/UNIQUE)
-- Rodar DEPOIS do 001_criar_tabelas.sql

-- VALIDAÇÕES: DADOS DE REFERÊNCIA

alter table torres
add constraint torres_custo_base_ck check (custo_base >= 0),
add constraint torres_alcance_ck check (
    alcance_base is null
    or alcance_base >= 0
);

alter table upgrades
add constraint upgrades_nivel_ck check (nivel between 1 and 5),
add constraint upgrades_custo_ck check (custo >= 0);

alter table herois
add constraint herois_custo_base_ck check (custo_base >= 0);

alter table bloons
add constraint bloons_vida_ck check (vida >= 0),
add constraint bloons_filhos_ck check (
    filhos_gerados is null
    or filhos_gerados >= 0
);

alter table mapas
add constraint mapas_caminhos_ck check (numero_caminhos >= 1);

-- VALIDAÇÕES: ESTRATÉGIAS

alter table estrategias
add constraint estrategias_round_alvo_ck check (
    round_alvo is null
    or round_alvo >= 1
),
add constraint estrategias_custo_ck check (
    custo_total_estimado is null
    or custo_total_estimado >= 0
),
-- CHIMPS só existe na dificuldade Impopível
add constraint estrategias_chimps_ck check (
    modo_alvo is distinct from 'impopivel_chimps'
    or dificuldade_alvo = 'impopivel'
);

alter table estrategia_torres
add constraint estrategia_torres_quantidade_ck check (quantidade >= 1),
add constraint estrategia_torres_round_ck check (
    round_colocacao is null
    or round_colocacao >= 1
),
-- cada caminho vai de 0 a 5
add constraint estrategia_torres_niveis_ck check (
    upgrade_caminho_1 between 0 and 5
    and upgrade_caminho_2 between 0 and 5
    and upgrade_caminho_3 between 0 and 5
),
-- regra do jogo: no máximo 1 caminho acima de 2 e no máximo 2 caminhos usados
add constraint estrategia_torres_regra_jogo_ck check (
    (upgrade_caminho_1 > 2)::int + (upgrade_caminho_2 > 2)::int + (upgrade_caminho_3 > 2)::int <= 1
    and (upgrade_caminho_1 > 0)::int + (upgrade_caminho_2 > 0)::int + (upgrade_caminho_3 > 0)::int <= 2
);

-- sem duas torres com a mesma ordem de colocação na mesma estratégia
create unique index estrategia_torres_ordem_uq on estrategia_torres (estrategia_id, ordem);

-- VALIDAÇÕES: PARTIDAS

alter table partidas
add constraint partidas_round_inicial_ck check (round_inicial >= 1),
add constraint partidas_round_final_ck check (round_final >= round_inicial),
add constraint partidas_vidas_ck check (
    vidas_restantes is null
    or vidas_restantes >= 0
),
add constraint partidas_dinheiro_ck check (
    dinheiro_final is null
    or dinheiro_final >= 0
),
add constraint partidas_duracao_ck check (
    duracao_segundos is null
    or duracao_segundos >= 0
),
add constraint partidas_chimps_ck check (
    modo <> 'impopivel_chimps'
    or dificuldade = 'impopivel'
);

alter table partida_falhas
add constraint partida_falhas_round_ck check (round_falha >= 1),
add constraint partida_falhas_vidas_ck check (
    vidas_perdidas is null
    or vidas_perdidas >= 0
);

-- VALIDAÇÕES: RECOMENDAÇÕES

alter table recomendacoes
add constraint recomendacoes_posicao_ck check (posicao_ranking >= 1),
add constraint recomendacoes_taxa_ck check (
    taxa_vitoria between 0 and 100
),
add constraint recomendacoes_total_ck check (total_partidas >= 1),
add constraint recomendacoes_chimps_ck check (
    modo <> 'impopivel_chimps'
    or dificuldade = 'impopivel'
);

-- a mesma estratégia não aparece duas vezes no ranking do mesmo cenário
create unique index recomendacoes_cenario_estrategia_uq on recomendacoes (
    mapa_id,
    dificuldade,
    modo,
    estrategia_id
);