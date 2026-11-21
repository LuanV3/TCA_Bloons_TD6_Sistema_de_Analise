-- Sistema de Análise Bloons TD 6
-- dados de TESTE: estratégias, composição de torres, partidas e falhas
-- Rodar DEPOIS do 001 a 008. Pode rodar mais de uma vez.
-- ATENÇÃO: os dados são FICTÍCIOS, só servem para testar views e recomendações.
-- Marcação para limpeza:
--   estratégias com nome começando por 'Teste - '
--   partidas com jogador = 'teste' (observacoes = 'teste-01', 'teste-02', ...)
-- Para apagar tudo no fim dos testes: veja o bloco LIMPEZA no final do arquivo.
-- Rounds de referência: Fácil 1-40 | Médio 1-60 | Difícil 3-80 | Impopível/CHIMPS 6-100.

-- 0. Limpa as partidas de teste anteriores (partida_falhas some junto, ON DELETE CASCADE)
delete from partidas where jogador = 'teste';

-- 1. ESTRATÉGIAS

insert into estrategias
  (nome, descricao, autor, heroi_id, dificuldade_alvo, modo_alvo, round_alvo)
values
  ('Teste - Dardos e Bombas',
   'Estratégia básica de torres primárias e Sniper, para o Fácil.',
   'teste', (select id from herois where nome = 'Quincy'), 'facil', 'padrao', 40),
  ('Teste - Ninja e Alchemist',
   'Combinação de Ninja com Alchemist e Village, para o Difícil.',
   'teste', (select id from herois where nome = 'Obyn Greenfoot'), 'dificil', 'padrao', 80),
  ('Teste - Super Monkey CHIMPS',
   'Super Monkey com economia de Farms, para o CHIMPS.',
   'teste', (select id from herois where nome = 'Benjamin'), 'impopivel', 'impopivel_chimps', 100),
  ('Teste - Aéreo Ace e Heli',
   'Foco em Monkey Ace e Heli Pilot, para o Médio.',
   'teste', (select id from herois where nome = 'Psi'), 'medio', 'padrao', 60),
  ('Teste - Aquático',
   'Buccaneer e Sub, só para mapas com água.',
   'teste', (select id from herois where nome = 'Admiral Brickell'), 'medio', 'padrao', 60)
on conflict (nome) do nothing;

-- 2. TORRES DE CADA ESTRATÉGIA
-- (estratégia, ordem, torre, quantidade, caminho 1, caminho 2, caminho 3, round de colocação)
-- Todas respeitam a regra: no máx. 1 caminho acima de 2 e no máx. 2 caminhos usados.

insert into estrategia_torres
  (estrategia_id, ordem, torre_id, quantidade,
   upgrade_caminho_1, upgrade_caminho_2, upgrade_caminho_3, round_colocacao)
select e.id, v.ordem, t.id, v.qtd, v.c1, v.c2, v.c3, v.rnd
from (values
  ('Teste - Dardos e Bombas',     1, 'Dart Monkey',       2, 0, 2, 3,  1),
  ('Teste - Dardos e Bombas',     2, 'Bomb Shooter',      1, 3, 2, 0,  5),
  ('Teste - Dardos e Bombas',     3, 'Sniper Monkey',     1, 2, 0, 3,  8),
  ('Teste - Dardos e Bombas',     4, 'Banana Farm',       2, 0, 3, 2, 10),

  ('Teste - Ninja e Alchemist',   1, 'Ninja Monkey',      1, 4, 2, 0,  3),
  ('Teste - Ninja e Alchemist',   2, 'Alchemist',         1, 4, 0, 2,  8),
  ('Teste - Ninja e Alchemist',   3, 'Monkey Village',    1, 2, 0, 3, 12),
  ('Teste - Ninja e Alchemist',   4, 'Wizard Monkey',     1, 0, 2, 4, 15),
  ('Teste - Ninja e Alchemist',   5, 'Spike Factory',     1, 0, 3, 2, 20),

  ('Teste - Super Monkey CHIMPS', 1, 'Ninja Monkey',      1, 0, 1, 5,  6),
  ('Teste - Super Monkey CHIMPS', 2, 'Banana Farm',       3, 0, 3, 2, 10),
  ('Teste - Super Monkey CHIMPS', 3, 'Monkey Village',    1, 0, 2, 3, 20),
  ('Teste - Super Monkey CHIMPS', 4, 'Super Monkey',      2, 2, 0, 5, 40),
  ('Teste - Super Monkey CHIMPS', 5, 'Engineer Monkey',   1, 0, 4, 2, 50),

  ('Teste - Aéreo Ace e Heli',    1, 'Monkey Ace',        1, 0, 3, 2,  4),
  ('Teste - Aéreo Ace e Heli',    2, 'Heli Pilot',        1, 2, 0, 4, 15),
  ('Teste - Aéreo Ace e Heli',    3, 'Mortar Monkey',     1, 0, 2, 3, 20),
  ('Teste - Aéreo Ace e Heli',    4, 'Banana Farm',       2, 3, 2, 0, 10),

  ('Teste - Aquático',            1, 'Monkey Buccaneer',  1, 3, 0, 2,  4),
  ('Teste - Aquático',            2, 'Monkey Sub',        2, 2, 4, 0,  8),
  ('Teste - Aquático',            3, 'Banana Farm',       2, 0, 2, 3, 12)
) as v(estrategia, ordem, torre, qtd, c1, c2, c3, rnd)
join estrategias e on e.nome = v.estrategia
join torres t on t.nome = v.torre
on conflict (estrategia_id, ordem) do nothing;