-- Sistema de Análise Bloons TD 6
-- dados de referência (bloons)
-- Rodar DEPOIS do 001 e do 002. Pode rodar mais de uma vez (on conflict do update).
-- vida:vida da camada do próprio bloon, sem contar os filhos.
-- velocidade:relativa ao Red Bloon (Red = 1,00), conforme a tabela de velocidades da wiki.
-- filhos_gerados:quantidade de bloons que saem quando ele estoura (um nível abaixo).
-- camuflado_possivel/regenera_possivel: se o bloon pode aparecer com a propriedade.
-- Bloons da classe MOAB não são camuflados nem regeneram; o DDT é sempre camuflado.
-- resistencia:NULL = sem imunidades.
-- Valores conferidos nos cards da Bloons Wiki pelo usuário: vida, velocidade, filhos e imunidades.
-- Chefes (Bloonarius, Lych etc.) não foram cadastrados.

-- BLOONS (17)

insert into bloons
  (nome, tipo, vida, velocidade, camuflado_possivel, regenera_possivel, resistencia, filhos_gerados)
values
  -- Normais
  ('Red', 'normal', 1, 1.00, true, true, null, 0),
  ('Blue', 'normal', 1, 1.40, true, true, null, 1),
  ('Green', 'normal', 1, 1.80, true, true, null, 1),
  ('Yellow', 'normal', 1, 3.20, true, true, null, 1),
  ('Pink', 'normal', 1, 3.50, true, true, null, 1),
  ('Black', 'normal', 1, 1.80, true, true, 'imune a explosões', 2),
  ('White', 'normal', 1, 2.00, true, true, 'imune a gelo', 2),
  ('Purple', 'normal', 1, 3.00, true, true, 'imune a energia, fogo e plasma', 2),
  ('Lead', 'normal', 1, 1.00, true, true, 'imune a perfurantes', 2),
  ('Zebra', 'normal', 1, 1.80, true, true, 'imune a explosões e gelo', 2),
  ('Rainbow', 'normal', 1, 2.20, true, true, null, 2),
  ('Ceramic', 'normal', 10, 2.50, true, true, null, 2),

  -- Classe MOAB
  ('MOAB', 'moab_class', 200, 1.00, false, false, null, 4),
  ('BFB', 'moab_class', 700, 0.25, false, false, null, 4),
  ('ZOMG', 'moab_class', 4000, 0.18, false, false, null, 4),
  ('DDT', 'moab_class', 400, 2.64, true, false, 'imune a explosões e perfurantes', 4),
  ('BAD', 'moab_class', 20000, 0.18, false, false, null, 5)   -- 2 ZOMG + 3 DDT
on conflict (nome) do update set
  tipo               = excluded.tipo,
  vida               = excluded.vida,
  velocidade         = excluded.velocidade,
  camuflado_possivel = excluded.camuflado_possivel,
  regenera_possivel  = excluded.regenera_possivel,
  resistencia        = excluded.resistencia,
  filhos_gerados     = excluded.filhos_gerados;