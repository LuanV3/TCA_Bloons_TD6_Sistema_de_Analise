-- Sistema de Análise Bloons TD 6
-- regras de validação (CHECK/UNIQUE) e segurança (RLS)

 

-- VALIDAÇÕES: DADOS DE REFERÊNCIA

 
alter table torres
  add constraint torres_custo_base_ck check (custo_base >= 0),
  add constraint torres_alcance_ck    check (alcance_base is null or alcance_base >= 0);
 
alter table upgrades
  add constraint upgrades_nivel_ck check (nivel between 1 and 5),
  add constraint upgrades_custo_ck check (custo >= 0);
 
alter table herois
  add constraint herois_custo_base_ck check (custo_base >= 0);
 
alter table bloons
  add constraint bloons_vida_ck check (vida >= 0),
  add constraint bloons_filhos_ck check (filhos_gerados is null or filhos_gerados >= 0);
 
alter table mapas
  add constraint mapas_caminhos_ck check (numero_caminhos >= 1);
 
-- =========================================================
-- VALIDAÇÕES: ESTRATÉGIAS
-- =========================================================
 
alter table estrategias
  add constraint estrategias_round_alvo_ck check (round_alvo is null or round_alvo >= 1),
  add constraint estrategias_custo_ck      check (custo_total_estimado is null or custo_total_estimado >= 0),
  -- CHIMPS só existe na dificuldade Impopível
  add constraint estrategias_chimps_ck     check (modo_alvo is distinct from 'impopivel_chimps'
                                                  or dificuldade_alvo = 'impopivel');
 