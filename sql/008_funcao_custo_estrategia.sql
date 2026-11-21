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

-- upgrades usados em estratégias mas não cadastrados (deve ficar vazia)
create or replace view estrategia_upgrades_faltando as
select
  et.estrategia_id,
  et.id as estrategia_torre_id,
  t.nome as torre,
  c.caminho,
  n.nivel
from estrategia_torres et
join torres t on t.id = et.torre_id
cross join (values ('caminho_1'::caminho_upgrade), ('caminho_2'), ('caminho_3')) as c(caminho)
cross join generate_series(1, 5) as n(nivel)
where n.nivel <= case c.caminho
                   when 'caminho_1' then et.upgrade_caminho_1
                   when 'caminho_2' then et.upgrade_caminho_2
                   when 'caminho_3' then et.upgrade_caminho_3
                 end
  and not exists (
    select 1
    from upgrades u
    where u.torre_id = et.torre_id
      and u.caminho = c.caminho
      and u.nivel = n.nivel
  );

COMMENT ON VIEW estrategia_upgrades_faltando IS
  'Upgrades usados em estratégias que não existem em upgrades. Deve ficar vazia.';

-- grava estrategias.custo_total_estimado (na dificuldade_alvo, ou medio)
-- p_estrategia_id NULL = todas. Retorna quantas foram atualizadas.
create or replace function atualizar_custo_estrategias(p_estrategia_id int default null)
returns int
language plpgsql
as '
declare
  n int;
begin
  update estrategias e
  set custo_total_estimado = custo_estrategia(e.id)
  where p_estrategia_id is null or e.id = p_estrategia_id;

  get diagnostics n = row_count;
  return n;
end;
';

COMMENT ON FUNCTION atualizar_custo_estrategias(int) IS
  'Recalcula estrategias.custo_total_estimado. NULL atualiza todas.';

-- Exemplos
-- select custo_estrategia(1, 'impopivel');
-- select * from estrategia_custos order by custo_medio desc;
-- select * from estrategia_upgrades_faltando;
-- select atualizar_custo_estrategias();
-- Teste: 1 Dart Monkey com caminho 1 até o nível 3, no Médio = 860
-- (200 + 140 + 200 + 320)
-- from torres where nome = 'Dart Monkey';
-- select custo_estrategia(currval(pg_get_serial_sequence('estrategias', 'id')));
-- delete from estrategias where nome = 'teste custo';