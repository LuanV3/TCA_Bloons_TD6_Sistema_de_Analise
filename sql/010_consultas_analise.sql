-- Sistema de Análise Bloons TD 6
-- consultas de análise (views e função de ranking)
-- Rodar DEPOIS do 001 a 009. Pode rodar mais de uma vez (create or replace).
-- Regras usadas em todas as views:
-- recomendacoes.custo_beneficio ("rounds alcançados por 1.000 de custo").
-- Obs.: as views leem as partidas reais. Os dados de teste do 009 entram igual;
-- para ver só os reais, apague os de teste (veja a LIMPEZA no final do 009).
-- 1. DESEMPENHO POR CENÁRIO (mapa + dificuldade + modo + estratégia)
-- Responde: "qual estratégia tem a maior taxa de vitória em determinado mapa?"

create or replace view analise_estrategia_cenario as
select
  m.id   as mapa_id,
  m.nome as mapa,
  p.dificuldade,
  p.modo,
  e.id   as estrategia_id,
  e.nome as estrategia,
  count(*) filter (where p.resultado <> 'abandonada')::int as partidas_concluidas,
  count(*) filter (where p.resultado = 'vitoria')::int     as vitorias,
  count(*) filter (where p.resultado = 'derrota')::int     as derrotas,
  count(*) filter (where p.resultado = 'abandonada')::int  as abandonadas,
  round(
    100.0 * count(*) filter (where p.resultado = 'vitoria')
    / nullif(count(*) filter (where p.resultado <> 'abandonada'), 0), 2
  ) as taxa_vitoria,
  round(avg(p.round_final) filter (where p.resultado = 'derrota')::numeric, 2)   as round_medio_derrota,
  round(avg(p.round_final) filter (where p.resultado <> 'abandonada')::numeric, 2) as round_medio_final,
  custo_estrategia(e.id, p.dificuldade) as custo,
  round(
    avg(p.round_final) filter (where p.resultado <> 'abandonada')::numeric
    / nullif(custo_estrategia(e.id, p.dificuldade) / 1000.0, 0), 4
  ) as custo_beneficio
from partidas p
join mapas m       on m.id = p.mapa_id
join estrategias e on e.id = p.estrategia_id
group by m.id, m.nome, p.dificuldade, p.modo, e.id, e.nome;

COMMENT ON VIEW analise_estrategia_cenario IS
  'Vitórias, taxa de vitória, round médio e custo-benefício por mapa, dificuldade, modo e estratégia. Ignora abandonadas.';

-- 2. DESEMPENHO GERAL DE CADA ESTRATÉGIA (todos os mapas)
-- Responde: "qual estratégia é melhor no geral?"

create or replace view analise_estrategia_geral as
select
  e.id   as estrategia_id,
  e.nome as estrategia,
  e.dificuldade_alvo,
  e.modo_alvo,
  e.round_alvo,
  count(*) filter (where p.resultado <> 'abandonada')::int as partidas_concluidas,
  count(*) filter (where p.resultado = 'vitoria')::int     as vitorias,
  count(*) filter (where p.resultado = 'derrota')::int     as derrotas,
  count(*) filter (where p.resultado = 'abandonada')::int  as abandonadas,
  round(
    100.0 * count(*) filter (where p.resultado = 'vitoria')
    / nullif(count(*) filter (where p.resultado <> 'abandonada'), 0), 2
  ) as taxa_vitoria,
  round(avg(p.round_final) filter (where p.resultado = 'derrota')::numeric, 2) as round_medio_derrota,
  custo_estrategia(e.id) as custo_na_dificuldade_alvo
from estrategias e
join partidas p on p.estrategia_id = e.id
group by e.id, e.nome, e.dificuldade_alvo, e.modo_alvo, e.round_alvo;

COMMENT ON VIEW analise_estrategia_geral IS
  'Taxa de vitória de cada estratégia somando todos os mapas. Só estratégias com partidas.';

-- 3. ROUNDS DE FALHA
-- Responde: "em qual round as estratégias costumam falhar?"

create or replace view analise_rounds_falha as
select
  f.round_falha,
  count(*)::int                      as falhas,
  count(distinct f.partida_id)::int  as partidas_afetadas,
  coalesce(sum(f.vidas_perdidas), 0)::int as vidas_perdidas_total,
  round(100.0 * count(*) / sum(count(*)) over (), 2) as percentual_das_falhas
from partida_falhas f
group by f.round_falha
order by falhas desc, f.round_falha;

COMMENT ON VIEW analise_rounds_falha IS
  'Quantas falhas ocorrem em cada round, da mais frequente para a menos frequente.';

-- mesma ideia, agrupada em faixas de 10 rounds (1-10, 11-20, ...)
create or replace view analise_falhas_faixa_round as
select
  ((f.round_falha - 1) / 10) * 10 + 1  as round_inicio,
  ((f.round_falha - 1) / 10) * 10 + 10 as round_fim,
  count(*)::int                        as falhas,
  count(distinct f.partida_id)::int    as partidas_afetadas,
  round(100.0 * count(*) / sum(count(*)) over (), 2) as percentual_das_falhas
from partida_falhas f
group by ((f.round_falha - 1) / 10)
order by round_inicio;

COMMENT ON VIEW analise_falhas_faixa_round IS
  'Falhas agrupadas em faixas de 10 rounds.';

-- 4. BLOONS QUE MAIS CAUSAM FALHA

create or replace view analise_falhas_por_bloon as
select
  coalesce(b.nome, 'não informado') as bloon,
  b.tipo,
  b.resistencia,
  count(*)::int                     as falhas,
  count(distinct f.partida_id)::int as partidas_afetadas,
  round(avg(f.round_falha)::numeric, 2) as round_medio_falha,
  coalesce(sum(f.vidas_perdidas), 0)::int as vidas_perdidas_total
from partida_falhas f
left join bloons b on b.id = f.bloon_causador_id
group by b.nome, b.tipo, b.resistencia
order by falhas desc, bloon;