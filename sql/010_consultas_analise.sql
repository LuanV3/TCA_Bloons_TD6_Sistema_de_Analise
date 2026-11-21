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

COMMENT ON VIEW analise_falhas_por_bloon IS
  'Bloons que mais furam a defesa, com o round médio em que isso acontece.';

-- 5. ONDE CADA ESTRATÉGIA FALHA, COMPARADO COM O ROUND ALVO

create or replace view analise_falhas_por_estrategia as
select
  e.id   as estrategia_id,
  e.nome as estrategia,
  e.round_alvo,
  count(*)::int as falhas,
  round(avg(f.round_falha)::numeric, 2) as round_medio_falha,
  mode() within group (order by f.round_falha) as round_mais_comum,
  round(e.round_alvo - avg(f.round_falha)::numeric, 2) as rounds_ate_o_alvo
from partida_falhas f
join partidas p    on p.id = f.partida_id
join estrategias e on e.id = p.estrategia_id
group by e.id, e.nome, e.round_alvo;

COMMENT ON VIEW analise_falhas_por_estrategia IS
  'Round médio e mais comum de falha de cada estratégia e quantos rounds faltaram para o alvo.';

-- 6. DESEMPENHO DE CADA TORRE
-- Responde: "quais torres aparecem nas estratégias que mais vencem?"
-- Cada torre conta uma vez por partida da estratégia (mesmo que apareça em mais de uma linha).

create or replace view analise_torres as
select
  t.id   as torre_id,
  t.nome as torre,
  t.categoria,
  count(distinct x.estrategia_id)::int as estrategias,
  count(p.id) filter (where p.resultado <> 'abandonada')::int as partidas_concluidas,
  count(p.id) filter (where p.resultado = 'vitoria')::int     as vitorias,
  round(
    100.0 * count(p.id) filter (where p.resultado = 'vitoria')
    / nullif(count(p.id) filter (where p.resultado <> 'abandonada'), 0), 2
  ) as taxa_vitoria
from torres t
join (select distinct estrategia_id, torre_id from estrategia_torres) x on x.torre_id = t.id
join partidas p on p.estrategia_id = x.estrategia_id
group by t.id, t.nome, t.categoria;

COMMENT ON VIEW analise_torres IS
  'Taxa de vitória das partidas em que a torre fazia parte da estratégia. Não isola o efeito da torre: as outras torres da estratégia também contam.';

-- 7. COMBINAÇÕES DE DUAS TORRES
-- Responde: "qual combinação de torres gera o melhor resultado?"

create or replace view analise_pares_torres as
select
  t1.nome as torre_a,
  t2.nome as torre_b,
  count(distinct x1.estrategia_id)::int as estrategias,
  count(p.id) filter (where p.resultado <> 'abandonada')::int as partidas_concluidas,
  count(p.id) filter (where p.resultado = 'vitoria')::int     as vitorias,
  round(
    100.0 * count(p.id) filter (where p.resultado = 'vitoria')
    / nullif(count(p.id) filter (where p.resultado <> 'abandonada'), 0), 2
  ) as taxa_vitoria
from (select distinct estrategia_id, torre_id from estrategia_torres) x1
join (select distinct estrategia_id, torre_id from estrategia_torres) x2
  on x2.estrategia_id = x1.estrategia_id and x2.torre_id > x1.torre_id
join torres t1 on t1.id = x1.torre_id
join torres t2 on t2.id = x2.torre_id
join partidas p on p.estrategia_id = x1.estrategia_id
group by t1.nome, t2.nome;

COMMENT ON VIEW analise_pares_torres IS
  'Taxa de vitória por par de torres que aparecem juntas na mesma estratégia.';

-- 8. RANKING DE ESTRATÉGIAS PARA UM CENÁRIO
-- Ordena por taxa de vitória, depois por nº de partidas, depois por custo-benefício.
-- p_min_partidas evita que 1 vitória em 1 partida vire "100%" no topo.
-- Exemplo: select * from ranking_estrategias('Monkey Meadow', 'medio');

create or replace function ranking_estrategias(
  p_mapa          text,
  p_dificuldade   dificuldade,
  p_modo          modo_jogo default 'padrao',
  p_min_partidas  int       default 1
)
returns table (
  posicao             int,
  estrategia_id       int,
  estrategia          text,
  partidas_concluidas int,
  vitorias            int,
  taxa_vitoria        numeric,
  round_medio_derrota numeric,
  custo               int,
  custo_beneficio     numeric
)
language sql
stable
as '
  select
    row_number() over (
      order by v.taxa_vitoria desc nulls last,
               v.partidas_concluidas desc,
               v.custo_beneficio desc nulls last,
               v.estrategia
    )::int,
    v.estrategia_id,
    v.estrategia::text,
    v.partidas_concluidas,
    v.vitorias,
    v.taxa_vitoria,
    v.round_medio_derrota,
    v.custo,
    v.custo_beneficio
  from analise_estrategia_cenario v
  where lower(v.mapa) = lower(p_mapa)
    and v.dificuldade = p_dificuldade
    and v.modo = p_modo
    and v.partidas_concluidas >= p_min_partidas
  order by 1
';

COMMENT ON FUNCTION ranking_estrategias(text, dificuldade, modo_jogo, int) IS
  'Ranking de estratégias para um mapa, dificuldade e modo, com mínimo de partidas.';

-- EXEMPLOS (rodar um por vez)
-- select * from analise_estrategia_cenario order by mapa, dificuldade, taxa_vitoria desc;
-- select * from analise_estrategia_geral order by taxa_vitoria desc;
-- select * from analise_rounds_falha;
-- select * from analise_falhas_faixa_round;
-- select * from analise_falhas_por_bloon;
-- select * from analise_falhas_por_estrategia;
-- select * from analise_torres order by taxa_vitoria desc;
-- select * from analise_pares_torres order by taxa_vitoria desc, partidas_concluidas desc;
-- select * from ranking_estrategias('Monkey Meadow', 'medio');
-- select * from ranking_estrategias('Logs', 'impopivel', 'impopivel_chimps');