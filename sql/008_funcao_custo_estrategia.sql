-- Sistema de Análise Bloons TD 6
-- custo de uma estratégia em cada dificuldade
-- Rodar DEPOIS do 001, 002, 003, 004 e 007. Pode rodar mais de uma vez.
-- Custo = quantidade x (torre + upgrades comprados) + herói.
-- Upgrades comprados = níveis 1 até N de cada caminho.
-- A conversão de dificuldade é feita item a item (torre, cada upgrade, herói).
-- Não considera Monkey Knowledge nem descontos de Village/Farm.
-- Upgrade não cadastrado entra como custo 0 (ver estrategia_upgrades_faltando).
-- Obs.: o corpo das funções está entre aspas simples; por isso as aspas internas
-- custo de uma estratégia
-- d NULL = usa dificuldade_alvo da estratégia; se também NULL, usa 'medio'.
-- Retorna NULL se a estratégia não existir.
create or replace function custo_estrategia(p_estrategia_id int, d dificuldade default null)
returns int
language sql
stable
as '
  with est as (
    select
      e.id,
      e.heroi_id,
      coalesce(d, e.dificuldade_alvo, ''medio''::dificuldade) as dif
    from estrategias e
    where e.id = p_estrategia_id
  ),
  custo_torres as (
    select
      et.quantidade * (
        custo_na_dificuldade(t.custo_base, est.dif)
        + coalesce((
            select sum(custo_na_dificuldade(u.custo, est.dif))
            from upgrades u
            where u.torre_id = et.torre_id
              and (
                (u.caminho = ''caminho_1'' and u.nivel <= et.upgrade_caminho_1)
                or (u.caminho = ''caminho_2'' and u.nivel <= et.upgrade_caminho_2)
                or (u.caminho = ''caminho_3'' and u.nivel <= et.upgrade_caminho_3)
              )
          ), 0)
      ) as custo
    from est
    join estrategia_torres et on et.estrategia_id = est.id
    join torres t on t.id = et.torre_id
  )
  select (
    coalesce((select sum(custo) from custo_torres), 0)
    + coalesce((
        select custo_na_dificuldade(h.custo_base, est.dif)
        from herois h
        where h.id = est.heroi_id
      ), 0)
  )::int
  from est
';

COMMENT ON FUNCTION custo_estrategia(int, dificuldade) IS
  'Custo total de uma estratégia (torres + upgrades + herói) na dificuldade informada.';

-- custo nas 4 dificuldades
create or replace view estrategia_custos as
select
  e.id as estrategia_id,
  e.nome,
  custo_estrategia(e.id, 'facil')     as custo_facil,
  custo_estrategia(e.id, 'medio')     as custo_medio,
  custo_estrategia(e.id, 'dificil')   as custo_dificil,
  custo_estrategia(e.id, 'impopivel') as custo_impopivel
from estrategias e;

COMMENT ON VIEW estrategia_custos IS
  'Custo de cada estratégia nas quatro dificuldades.';