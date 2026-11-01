-- Sistema de Análise Bloons TD 6
-- dados de referência (mapas)
-- Rodar DEPOIS do 001 e do 002. Pode rodar mais de uma vez (on conflict do update).
-- Fonte: tabela "List of maps in BTD6" da Bloons Wiki, conferida pelo usuário (90 mapas).
-- dificuldade: Beginner = iniciante, Intermediate = intermediario, Advanced = avancado, Expert = especialista.
-- tem_agua: coluna "Water?" da wiki.
-- numero_caminhos: coluna "Entrances" (entradas) da wiki.
-- observacoes: saídas e junções da wiki, que não têm coluna própria.
-- area_util_colocacao: ficou NULL (a tabela da wiki não traz esse dado).
-- linha_de_visao_bloqueada: NULL = não informado. Só Middle of the Road está como true
-- (a página da wiki cita bloqueios de linha de visão nesse mapa).
-- A coluna era "not null default false", o que faria "não informado" parecer "sem bloqueio".
-- Aqui ela passa a aceitar NULL.
alter table mapas alter column linha_de_visao_bloqueada drop not null;
alter table mapas alter column linha_de_visao_bloqueada drop default;

insert into mapas
  (nome, dificuldade, tem_agua, numero_caminhos, area_util_colocacao, linha_de_visao_bloqueada, observacoes)
values
  -- Iniciante (26)
  ('Alpine Run', 'iniciante', false, 1, null, null, 'Saídas: 1; junções: 0'),
  ('Candy Falls', 'iniciante', true, 1, null, null, 'Saídas: 1; junções: 0'),
  ('Carved', 'iniciante', true, 1, null, null, 'Saídas: 1; junções: 0'),
  ('Cubism', 'iniciante', true, 1, null, null, 'Saídas: 1; junções: 0'),
  ('End Of The Road', 'iniciante', true, 1, null, null, 'Saídas: 1; junções: 0'),
  ('Four Circles', 'iniciante', true, 1, null, null, 'Saídas: 1; junções: 0'),
  ('Frozen Over', 'iniciante', true, 1, null, null, 'Saídas: 1; junções: 0'),
  ('Hedge', 'iniciante', false, 1, null, null, 'Saídas: 1; junções: 0'),
  ('In The Loop', 'iniciante', true, 1, null, null, 'Saídas: 1; junções: 0'),
  ('Logs', 'iniciante', true, 1, null, null, 'Saídas: 1; junções: 0'),
  ('Lotus Island', 'iniciante', true, 1, null, null, 'Saídas: 1; junções: 0'),
  ('Middle of the Road', 'iniciante', true, 1, null, true, 'Saídas: 1; junções: 0'),
  ('Monkey Meadow', 'iniciante', false, 1, null, null, 'Saídas: 1; junções: 0'),
  ('One Two Tree', 'iniciante', true, 1, null, null, 'Saídas: 1; junções: 0'),
  ('Park Path', 'iniciante', true, 1, null, null, 'Saídas: 1; junções: 0'),
  ('Resort', 'iniciante', true, 1, null, null, 'Saídas: 1; junções: 0'),
  ('Scrapyard', 'iniciante', false, 1, null, null, 'Saídas: 1; junções: 0'),
  ('Skates', 'iniciante', true, 1, null, null, 'Saídas: 1; junções: 0'),
  ('Skull Tweak', 'iniciante', true, 1, null, null, 'Saídas: 1; junções: 0'),
  ('Spa Pits', 'iniciante', true, 1, null, null, 'Saídas: 1; junções: 0'),
  ('The Cabin', 'iniciante', true, 1, null, null, 'Saídas: 1; junções: 0'),
  ('Three Mines ''Round', 'iniciante', true, 1, null, null, 'Saídas: 1; junções: 1'),
  ('Tinkerton', 'iniciante', true, 1, null, null, 'Saídas: 1; junções: 0'),
  ('Town Center', 'iniciante', true, 1, null, null, 'Saídas: 1; junções: 0'),
  ('Tree Stump', 'iniciante', false, 1, null, null, 'Saídas: 1; junções: 0'),
  ('Winter Park', 'iniciante', true, 1, null, null, 'Saídas: 1; junções: 0'),