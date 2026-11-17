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

  -- Intermediário (26)
  ('Adora''s Temple', 'intermediario', true, 4, null, null, 'Saídas: 4; junções: 0'),
  ('Ancient Portal', 'intermediario', true, 1, null, null, 'Saídas: 2; junções: 1'),
  ('Balance', 'intermediario', true, 2, null, null, 'Saídas: 2; junções: 8'),
  ('Bazaar', 'intermediario', true, 2, null, null, 'Saídas: 2; junções: 0'),
  ('Bloonarius Prime', 'intermediario', true, 1, null, null, 'Saídas: 2; junções: 2'),
  ('Chutes', 'intermediario', true, 2, null, null, 'Saídas: 2; junções: 0'),
  ('Covered Garden', 'intermediario', true, 1, null, null, 'Saídas: 1; junções: 0'),
  ('Cracked', 'intermediario', true, 1, null, null, 'Saídas: 1; junções: 0'),
  ('Downstream', 'intermediario', true, 1, null, null, 'Saídas: 1; junções: 0'),
  ('Encrypted', 'intermediario', true, 1, null, null, 'Saídas: 2; junções: 1'),
  ('Firing Range', 'intermediario', true, 2, null, null, 'Saídas: 2; junções: 0'),
  ('Haunted', 'intermediario', true, 2, null, null, 'Saídas: 2; junções: 0'),
  ('KartsNDarts', 'intermediario', false, 1, null, null, 'Saídas: 1; junções: 0'),
  ('Lost Crevasse', 'intermediario', true, 3, null, null, 'Saídas: 3; junções: 2'),
  ('Luminous Cove', 'intermediario', true, 2, null, null, 'Saídas: 2; junções: 0'),
  ('Moon Landing', 'intermediario', false, 1, null, null, 'Saídas: 1; junções: 0'),
  ('Polyphemus', 'intermediario', true, 2, null, null, 'Saídas: 2; junções: 0'),
  ('Protect The Yacht', 'intermediario', true, 2, null, null, 'Saídas: 2; junções: 0'),
  ('Quarry', 'intermediario', true, 2, null, null, 'Saídas: 1; junções: 1'),
  ('Quiet Street', 'intermediario', true, 3, null, null, 'Saídas: 3; junções: 0'),
  ('Rake', 'intermediario', true, 2, null, null, 'Saídas: 2; junções: 0'),
  ('Spice Islands', 'intermediario', true, 1, null, null, 'Saídas: 1; junções: 0'),
  ('Spring Spring', 'intermediario', true, 2, null, null, 'Saídas: 2; junções: 0'),
  ('Streambed', 'intermediario', true, 1, null, null, 'Saídas: 1; junções: 0'),
  ('Sulfur Springs', 'intermediario', true, 1, null, null, 'Saídas: 1; junções: 0'),
  ('Water Park', 'intermediario', true, 2, null, null, 'Saídas: 2; junções: 0'),

  -- Avançado (24)
  ('Another Brick', 'avancado', true, 1, null, null, 'Saídas: 1; junções: 0'),
  ('Ascent', 'avancado', true, 2, null, null, 'Saídas: 2; junções: 0'),
  ('Cargo', 'avancado', true, 2, null, null, 'Saídas: 2; junções: 0'),
  ('Castle Revenge', 'avancado', true, 4, null, null, 'Saídas: 2; junções: 2'),
  ('Cornfield', 'avancado', false, 1, null, null, 'Saídas: 1; junções: 0'),
  ('Dark Path', 'avancado', false, 1, null, null, 'Saídas: 1; junções: 0'),
  ('Enchanted Glade', 'avancado', true, 2, null, null, 'Saídas: 1; junções: 0'),
  ('Erosion', 'avancado', true, 6, null, null, 'Saídas: 6; junções: 0'),
  ('Geared', 'avancado', false, 1, null, null, 'Saídas: 1; junções: 0'),
  ('High Finance', 'avancado', true, 2, null, null, 'Saídas: 2; junções: 0'),
  ('Last Resort', 'avancado', true, 1, null, null, 'Saídas: 1; junções: 0'),
  ('Mesa', 'avancado', false, 2, null, null, 'Saídas: 2; junções: 0'),
  ('Midnight Mansion', 'avancado', false, 2, null, null, 'Saídas: 2; junções: 0'),
  ('Mushroom Grotto', 'avancado', false, 2, null, null, 'Saídas: 2; junções: 0'),
  ('Off The Coast', 'avancado', true, 1, null, null, 'Saídas: 1; junções: 0'),
  ('Party Parade', 'avancado', false, 2, null, null, 'Saídas: 2; junções: 0'),
  ('Pat''s Pond', 'avancado', true, 2, null, null, 'Saídas: 2; junções: 0'),
  ('Peninsula', 'avancado', true, 1, null, null, 'Saídas: 1; junções: 0'),
  ('Ship Capture', 'avancado', true, 4, null, null, 'Saídas: 2; junções: 2'),
  ('Spillway', 'avancado', true, 4, null, null, 'Saídas: 4; junções: 0'),
  ('Sunken Columns', 'avancado', true, 2, null, null, 'Saídas: 2; junções: 0'),
  ('Sunset Gulch', 'avancado', false, 2, null, null, 'Saídas: 2; junções: 0'),
  ('Underground', 'avancado', false, 2, null, null, 'Saídas: 2; junções: 0'),
  ('X Factor', 'avancado', false, 4, null, null, 'Saídas: 4; junções: 4'),

  -- Especialista (14)
  ('#Ouch', 'especialista', true, 4, null, null, 'Saídas: 4; junções: 0'),
  ('Blons', 'especialista', true, 1, null, null, 'Saídas: 1; junções: 0'),
  ('Bloody Puddles', 'especialista', true, 6, null, null, 'Saídas: 6; junções: 0'),
  ('Dark Castle', 'especialista', true, 4, null, null, 'Saídas: 1; junções: 2'),
  ('Dark Dungeons', 'especialista', true, 4, null, null, 'Saídas: 4; junções: 0'),
  ('Flooded Valley', 'especialista', true, 2, null, null, 'Saídas: 2; junções: 0'),
  ('Glacial Trail', 'especialista', true, 1, null, null, 'Saídas: 1; junções: 0'),
  ('Infernal', 'especialista', true, 2, null, null, 'Saídas: 2; junções: 0'),
  ('Muddy Puddles', 'especialista', true, 4, null, null, 'Saídas: 4; junções: 0'),
  ('Quad', 'especialista', true, 4, null, null, 'Saídas: 4; junções: 0'),
  ('Ravine', 'especialista', true, 2, null, null, 'Saídas: 4; junções: 2'),
  ('Sanctuary', 'especialista', true, 2, null, null, 'Saídas: 4; junções: 2'),
  ('Tricky Tracks', 'especialista', false, 6, null, null, 'Saídas: 6'),
  ('Workshop', 'especialista', false, 2, null, null, 'Saídas: 1; junções: 1')
on conflict (nome) do update set
  dificuldade = excluded.dificuldade,
  tem_agua = excluded.tem_agua,
  numero_caminhos = excluded.numero_caminhos,
  area_util_colocacao = excluded.area_util_colocacao,
  linha_de_visao_bloqueada = excluded.linha_de_visao_bloqueada,
  observacoes = excluded.observacoes;