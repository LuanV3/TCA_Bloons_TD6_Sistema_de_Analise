-- Sistema de Análise Bloons TD 6
-- dados de referência (torres e heróis)
-- Rodar DEPOIS do 001 e do 002. Pode rodar mais de uma vez: valores já cadastrados são atualizados (on conflict do update).
-- Fonte dos valores: tabelas da Bloons Wiki conferidas pelo usuário (custos na dificuldade Médio).
-- Os custos e alcances mudam com as atualizações do jogo.
-- alcance_base: faixa base da torre, sem upgrades, na unidade da wiki.
-- NULL = sem alcance finito (Sniper, Monkey Ace, Mortar, Dartling Gunner: "infinito" na wiki)
-- ou ainda não cadastrado (Desperado, Mermonkey, Skywarden).
-- tamanho_footprint: tamanho que a torre ocupa no mapa, na unidade da wiki.
-- Formato: 'circular R' (raio R) ou 'retangular L' / 'retangular LxA' (largura x altura).
-- NULL = ainda não cadastrado (Desperado, Skywarden).

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
 
  -- Suporte
  ('Banana Farm',      'suporte',  1250, false, 40, 'retangular 30'),
  ('Spike Factory',    'suporte',  1000, false, 34, 'circular 8'),
  ('Monkey Village',   'suporte',  1200, false, 40, 'circular 11'),
  ('Engineer Monkey',  'suporte',   350, false, 40, 'circular 7'),    -- a sentinela tem faixa 45
  ('Beast Handler',    'suporte',   250, false, 20, 'circular 7')     -- 20 do próprio manipulador; 60 com a fera
on conflict (nome) do update set
  categoria    = excluded.categoria,
  custo_base   = excluded.custo_base,
  aquatica     = excluded.aquatica,
  alcance_base = excluded.alcance_base,
  tamanho_footprint = excluded.tamanho_footprint;
 
-- HERÓIS (18)

insert into herois (nome, custo_base) values
  ('Quincy',            540),
  ('Gwendolin',         725),
  ('Striker Jones',     700),
  ('Obyn Greenfoot',    650),
  ('Captain Churchill', 2000),
  ('Benjamin',          1200),
  ('Ezili',             600),
  ('Pat Fusty',         800),
  ('Adora',             1000),
  ('Admiral Brickell',  900),
  ('Etienne',           850),
  ('Sauda',             600),
  ('Psi',               1000),
  ('Geraldo',           750),
  ('Corvus',            925),
  ('Rosalia',           875),
  ('Silas',             850),
  ('Dan D''Monke',      650)
on conflict (nome) do update set
  custo_base = excluded.custo_base;
