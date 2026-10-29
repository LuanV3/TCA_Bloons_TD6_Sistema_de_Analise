-- Sistema de Análise Bloons TD 6
-- dados de referência (torres e heróis)
-- Rodar DEPOIS do 001 e do 002. Pode rodar mais de uma vez: valores já cadastrados são atualizados (on conflict do update).
-- Fonte dos valores: tabelas da Bloons Wiki conferidas pelo usuário (custos na dificuldade Médio).
-- Os custos e alcances mudam com as atualizações do jogo.
-- alcance_base: faixa base da torre, sem upgrades, na unidade da wiki.
--   NULL = sem alcance finito (Sniper, Monkey Ace, Mortar, Dartling Gunner: "infinito" na wiki)
--          ou ainda não cadastrado (Desperado, Mermonkey, Skywarden).
-- tamanho_footprint: tamanho que a torre ocupa no mapa, na unidade da wiki.
--   Formato: 'circular R' (raio R) ou 'retangular L' / 'retangular LxA' (largura x altura).
--   NULL = ainda não cadastrado (Desperado, Skywarden).

-- TORRES (26)

insert into torres (nome, categoria, custo_base, aquatica, alcance_base, tamanho_footprint) values
  -- Primárias
  ('Dart Monkey',      'primaria',  200, false, 32, 'circular 6'),
  ('Boomerang Monkey', 'primaria',  315, false, 43, 'circular 7'),
  ('Bomb Shooter',     'primaria',  375, false, 40, 'circular 7'),
  ('Tack Shooter',     'primaria',  260, false, 23, 'circular 6'),
  ('Ice Monkey',       'primaria',  500, false, 20, 'circular 6'),
  ('Glue Gunner',      'primaria',  225, false, 46, 'circular 6'),
  ('Desperado',        'primaria',  300, false, null, null),

  -- Militares
  ('Sniper Monkey',    'militar',   350, false, null, 'circular 6'),  -- alcance infinito
  ('Monkey Sub',       'militar',   325, true,  42, 'circular 7'),
  ('Monkey Buccaneer', 'militar',   400, true,  60, 'circular 8'),
  ('Monkey Ace',       'militar',   800, false, null, 'retangular 28x18'),  -- alcance infinito
  ('Heli Pilot',       'militar',  1600, false, 42, 'retangular 27'),
  ('Mortar Monkey',    'militar',   750, false, null, 'circular 11'),  -- alcance infinito
  ('Dartling Gunner',  'militar',   850, false, null, 'circular 7'),  -- alcance infinito

  -- Mágicas
  ('Wizard Monkey',    'magia',     325, false, 40, 'circular 7'),
  ('Super Monkey',     'magia',    2500, false, 50, 'circular 11'),
  ('Ninja Monkey',     'magia',     400, false, 40, 'circular 6'),
  ('Alchemist',        'magia',     550, false, 45, 'circular 6'),
  ('Druid',            'magia',     400, false, 35, 'circular 7'),
  ('Mermonkey',        'magia',     600, false, null, 'circular 8'),  -- anfíbia: pode ficar na terra ou na água
  ('Skywarden',        'magia',     205, false, null, null),

