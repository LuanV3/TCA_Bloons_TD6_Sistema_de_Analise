-- Sistema de Análise Bloons TD 6
-- função que calcula o custo em cada dificuldade
-- O banco guarda só o custo na dificuldade Médio (custo_base / custo).
-- Esta função aplica o multiplicador da dificuldade e arredonda para múltiplo de 5:
--   facil 0,85 | medio 1,00 | dificil 1,08 | impopivel 1,20
-- O arredondamento é "para o par" nos empates (ex.: 722,5 -> 720; 297,5 -> 300),
-- que foi o que reproduziu os valores da wiki.
-- Conferido contra 44 itens da wiki (torres e heróis): 42 batem nas 4 dificuldades.
-- Exceções conhecidas, ambas no Fácil: Boomerang Monkey (função: 270, wiki: 265)
-- e Ice Monkey (função: 425, wiki: 450).
-- Obs.: o corpo da função está entre aspas simples; por isso as aspas internas
-- aparecem duplicadas (''facil'' significa 'facil').
-- Exemplos:
-- select custo_na_dificuldade(540, 'facil');                 -- 460
-- select nome, custo_na_dificuldade(custo_base, 'impopivel') from torres;

create or replace function custo_na_dificuldade(custo int, d dificuldade)
returns int
language sql
immutable
as '
  select ((floor(x) + case
             when x - floor(x) > 0.5 then 1
             when x - floor(x) < 0.5 then 0
             else mod(floor(x), 2)
           end)::int) * 5
  from (
    select custo * (case d
                      when ''facil''     then 0.85
                      when ''medio''     then 1.00
                      when ''dificil''   then 1.08
                      when ''impopivel'' then 1.20
                    end) / 5 as x
  ) s
';