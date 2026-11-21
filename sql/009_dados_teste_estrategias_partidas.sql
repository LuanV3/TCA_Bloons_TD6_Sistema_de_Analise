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

-- 3. PARTIDAS (35)
-- (tag, mapa, estratégia, dificuldade, modo, resultado, round inicial, round final, vidas, duração em s)

insert into partidas
  (mapa_id, estrategia_id, dificuldade, modo, resultado,
   round_inicial, round_final, vidas_restantes, duracao_segundos, jogador, observacoes)
select m.id, e.id, v.dif::dificuldade, v.modo::modo_jogo, v.res::resultado_partida,
       v.r_ini, v.r_fim, v.vidas, v.dur, 'teste', v.tag
from (values
  -- Dardos e Bombas (Fácil, 1-40)
  ('teste-01', 'Monkey Meadow', 'Teste - Dardos e Bombas', 'facil', 'padrao', 'vitoria', 1, 40, 180, 1500),
  ('teste-02', 'Hedge',         'Teste - Dardos e Bombas', 'facil', 'padrao', 'vitoria', 1, 40, 150, 1650),
  ('teste-03', 'Tree Stump',    'Teste - Dardos e Bombas', 'facil', 'padrao', 'derrota', 1, 34,   0, 1300),
  ('teste-04', 'Cubism',        'Teste - Dardos e Bombas', 'facil', 'padrao', 'derrota', 1, 28,   0, 1000),
  ('teste-05', 'Logs',          'Teste - Dardos e Bombas', 'facil', 'padrao', 'vitoria', 1, 40, 120, 1580),
  ('teste-06', 'Monkey Meadow', 'Teste - Dardos e Bombas', 'facil', 'padrao', 'derrota', 1, 38,   0, 1450),
  ('teste-07', 'Dark Castle',   'Teste - Dardos e Bombas', 'facil', 'padrao', 'derrota', 1, 22,   0,  900),

  -- Ninja e Alchemist (Difícil, 3-80)
  ('teste-08', 'Monkey Meadow', 'Teste - Ninja e Alchemist', 'dificil', 'padrao', 'vitoria', 3, 80,  70, 3100),
  ('teste-09', 'Hedge',         'Teste - Ninja e Alchemist', 'dificil', 'padrao', 'derrota', 3, 66,   0, 2600),
  ('teste-10', 'Tree Stump',    'Teste - Ninja e Alchemist', 'dificil', 'padrao', 'vitoria', 3, 80,  40, 3250),
  ('teste-11', 'Cubism',        'Teste - Ninja e Alchemist', 'dificil', 'padrao', 'derrota', 3, 72,   0, 2900),
  ('teste-12', 'Dark Castle',   'Teste - Ninja e Alchemist', 'dificil', 'padrao', 'derrota', 3, 58,   0, 2300),
  ('teste-13', 'Infernal',      'Teste - Ninja e Alchemist', 'dificil', 'padrao', 'derrota', 3, 79,   0, 3300),
  ('teste-14', 'Logs',          'Teste - Ninja e Alchemist', 'dificil', 'padrao', 'vitoria', 3, 80,  95, 3200),
  ('teste-15', 'Quad',          'Teste - Ninja e Alchemist', 'dificil', 'padrao', 'derrota', 3, 45,   0, 1800),

  -- Super Monkey CHIMPS (Impopível, 6-100, 1 vida)
  ('teste-16', 'Monkey Meadow', 'Teste - Super Monkey CHIMPS', 'impopivel', 'impopivel_chimps', 'vitoria', 6, 100, 1, 4200),
  ('teste-17', 'Cubism',        'Teste - Super Monkey CHIMPS', 'impopivel', 'impopivel_chimps', 'derrota', 6,  72, 0, 3000),
  ('teste-18', 'Dark Castle',   'Teste - Super Monkey CHIMPS', 'impopivel', 'impopivel_chimps', 'derrota', 6,  86, 0, 3600),
  ('teste-19', 'Hedge',         'Teste - Super Monkey CHIMPS', 'impopivel', 'impopivel_chimps', 'derrota', 6,  63, 0, 2600),
  ('teste-20', 'Logs',          'Teste - Super Monkey CHIMPS', 'impopivel', 'impopivel_chimps', 'vitoria', 6, 100, 1, 4300),
  ('teste-21', 'Infernal',      'Teste - Super Monkey CHIMPS', 'impopivel', 'impopivel_chimps', 'derrota', 6,  91, 0, 3900),
  ('teste-22', 'Quad',          'Teste - Super Monkey CHIMPS', 'impopivel', 'impopivel_chimps', 'derrota', 6,  78, 0, 3400),

  -- Aéreo Ace e Heli (Médio, 1-60)
  ('teste-23', 'Monkey Meadow', 'Teste - Aéreo Ace e Heli', 'medio', 'padrao', 'vitoria', 1, 60, 110, 2100),
  ('teste-24', 'Hedge',         'Teste - Aéreo Ace e Heli', 'medio', 'padrao', 'vitoria', 1, 60,  85, 2200),
  ('teste-25', 'Tree Stump',    'Teste - Aéreo Ace e Heli', 'medio', 'padrao', 'derrota', 1, 52,   0, 1900),
  ('teste-26', 'Cubism',        'Teste - Aéreo Ace e Heli', 'medio', 'padrao', 'vitoria', 1, 60, 130, 2050),
  ('teste-27', 'Logs',          'Teste - Aéreo Ace e Heli', 'medio', 'padrao', 'derrota', 1, 47,   0, 1700),
  ('teste-28', 'Dark Castle',   'Teste - Aéreo Ace e Heli', 'medio', 'padrao', 'derrota', 1, 39,   0, 1450),
  ('teste-29', 'Monkey Meadow', 'Teste - Aéreo Ace e Heli', 'medio', 'padrao', 'derrota', 1, 58,   0, 2150),

  -- Aquático (Médio, 1-60, só mapas com água)
  ('teste-30', 'Cubism',        'Teste - Aquático', 'medio', 'padrao', 'vitoria',    1, 60, 100, 2200),
  ('teste-31', 'Logs',          'Teste - Aquático', 'medio', 'padrao', 'vitoria',    1, 60,  75, 2250),
  ('teste-32', 'Candy Falls',   'Teste - Aquático', 'medio', 'padrao', 'vitoria',    1, 60, 140, 2150),
  ('teste-33', 'Cubism',        'Teste - Aquático', 'medio', 'padrao', 'derrota',    1, 44,   0, 1600),
  ('teste-34', 'Logs',          'Teste - Aquático', 'medio', 'padrao', 'derrota',    1, 55,   0, 1950),
  ('teste-35', 'Candy Falls',   'Teste - Aquático', 'medio', 'padrao', 'abandonada', 1, 20, 150,  400)
) as v(tag, mapa, estrategia, dif, modo, res, r_ini, r_fim, vidas, dur)
join mapas m on m.nome = v.mapa
join estrategias e on e.nome = v.estrategia;

-- 4. FALHAS (uma por derrota)
-- (tag da partida, round da falha, bloon causador, vidas perdidas, motivo)

insert into partida_falhas
  (partida_id, round_falha, bloon_causador_id, vidas_perdidas, motivo)
select p.id, v.rnd, b.id, v.vidas, v.motivo
from (values
  ('teste-03', 34, 'Ceramic', 60, 'Cerâmicos sem dano suficiente'),
  ('teste-04', 28, 'Lead',    55, 'Sem dano contra Lead (perfurantes ineficazes)'),
  ('teste-06', 38, 'Ceramic', 70, 'Cerâmicos em grupo furaram a defesa'),
  ('teste-07', 22, 'Zebra',   65, 'Defesa insuficiente no início do mapa'),
  ('teste-09', 66, 'BFB',     80, 'BFB sem dano suficiente'),
  ('teste-11', 72, 'DDT',     90, 'DDT camuflado sem detecção'),
  ('teste-12', 58, 'Ceramic', 60, 'Cerâmicos com regeneração'),
  ('teste-13', 79, 'ZOMG',    95, 'ZOMG chegou ao fim da pista'),
  ('teste-15', 45, 'Ceramic', 85, 'Economia fraca, poucas torres'),
  ('teste-17', 72, 'DDT',      1, 'DDT camuflado sem detecção'),
  ('teste-18', 86, 'ZOMG',     1, 'ZOMG sem dano suficiente'),
  ('teste-19', 63, 'DDT',      1, 'DDT camuflado sem detecção'),
  ('teste-21', 91, 'ZOMG',     1, 'ZOMG sem dano suficiente'),
  ('teste-22', 78, 'BFB',      1, 'BFB passou pela defesa'),
  ('teste-25', 52, 'BFB',     70, 'BFB sem dano suficiente'),
  ('teste-27', 47, 'Lead',    60, 'Sem dano contra Lead'),
  ('teste-28', 39, 'Zebra',   75, 'Sem dano contra Zebra (explosões e gelo)'),
  ('teste-29', 58, 'BFB',     50, 'BFB sem dano suficiente'),
  ('teste-33', 44, 'Ceramic', 90, 'Defesa aquática sem alcance na pista de terra'),
  ('teste-34', 55, 'BFB',     65, 'BFB sem dano suficiente')
) as v(tag, rnd, bloon, vidas, motivo)
join partidas p on p.observacoes = v.tag and p.jogador = 'teste'
join bloons b on b.nome = v.bloon;

-- 5. CUSTO DAS ESTRATÉGIAS
select atualizar_custo_estrategias();

-- CONFERÊNCIAS (rodar e olhar o resultado)
-- deve voltar vazia (upgrades usados que não estão cadastrados)
-- select * from estrategia_upgrades_faltando;
-- custo das estratégias de teste nas 4 dificuldades
-- select * from estrategia_custos where nome like 'Teste - %' order by custo_medio desc;
-- resumo rápido: partidas e vitórias por estratégia
-- select e.nome, count(*) as partidas,
--        count(*) filter (where p.resultado = 'vitoria') as vitorias
-- from partidas p join estrategias e on e.id = p.estrategia_id
-- where p.jogador = 'teste'
-- group by e.nome order by e.nome;
-- LIMPEZA (rodar só quando terminar os testes)
-- delete from partidas where jogador = 'teste';
-- delete from estrategias where nome like 'Teste - %';