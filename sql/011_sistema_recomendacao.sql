-- Sistema de Análise Bloons TD 6
-- sistema de recomendação por mapa, dificuldade e modo
-- Rodar DEPOIS do 001 a 010. Pode rodar mais de uma vez.
-- A tabela recomendacoes é um ranking PRÉ-CALCULADO: ela só muda quando você
-- chama recalcular_recomendacoes(). Chame de novo depois de registrar partidas novas.
-- O ranking usa as mesmas regras da função ranking_estrategias (script 010):
-- taxa de vitória, depois nº de partidas, depois custo-benefício. Abandonadas não contam.
-- 1. RECALCULAR O RANKING
-- p_min_partidas: mínimo de partidas concluídas da estratégia no cenário
-- (mínimo efetivo 1, pois recomendacoes.total_partidas >= 1).
-- O padrão é 1 para funcionar com os dados de teste do 009;
-- com dados reais, use 3 ou mais para evitar "100%" com 1 partida.
-- p_top:quantas estratégias guardar por cenário (NULL = todas).
-- Retorna quantas linhas foram gravadas.
-- A função apaga e reconstrói tudo na mesma transação: se falhar, nada muda.

create or replace function recalcular_recomendacoes(
  p_min_partidas int default 1,
  p_top          int default 5
)
returns int
language plpgsql
as '
declare
  n int;
begin
  delete from recomendacoes where true;

  insert into recomendacoes
    (mapa_id, dificuldade, modo, estrategia_id, posicao_ranking,
     taxa_vitoria, total_partidas, round_medio_derrota, custo_beneficio)
  select
    r.mapa_id, r.dificuldade, r.modo, r.estrategia_id, r.pos::smallint,
    r.taxa_vitoria, r.partidas_concluidas, r.round_medio_derrota, r.custo_beneficio
  from (
    select
      v.*,
      row_number() over (
        partition by v.mapa_id, v.dificuldade, v.modo
        order by v.taxa_vitoria desc nulls last,
                 v.partidas_concluidas desc,
                 v.custo_beneficio desc nulls last,
                 v.estrategia
      ) as pos
    from analise_estrategia_cenario v
    where v.partidas_concluidas >= greatest(p_min_partidas, 1)
  ) r
  where p_top is null or r.pos <= p_top;

  get diagnostics n = row_count;
  return n;
end;
';