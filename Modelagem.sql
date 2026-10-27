// Sistema de Análise Bloons TD 6


Project bloons_analise {
  database_type: 'PostgreSQL'
  Note: 'Banco que registra partidas reais e cruza resultados com estratégias para recomendar as mais eficientes.'
}


// ENUMS

Enum categoria_torre {
  primaria
  militar
  magia
  suporte
}

Enum caminho_upgrade {
  caminho_1 [note: 'Superior / Top']
  caminho_2 [note: 'Meio / Middle']
  caminho_3 [note: 'Inferior / Bottom']
}

Enum dificuldade {
  facil
  medio
  dificil
  impopivel
}

Enum modo_jogo {
  padrao
  alternate_bloons_rounds
  reverso
  apopalypse
  deflation
  half_cash
  impopivel_chimps
  sandbox
}

Enum resultado_partida {
  vitoria
  derrota
  abandonada
}

Enum dificuldade_mapa {
  iniciante
  intermediario
  avancado
  especialista
}

Enum tipo_bloon {
  normal
  moab_class
  especial
}

// DADOS DE REFERÊNCIA


Table torres {
  id int [pk, increment]
  nome varchar(60) [not null, unique]
  categoria categoria_torre [not null]
  custo_base int [not null, note: 'Custo na dificuldade Medio']
  tamanho_footprint varchar(20) [note: 'pequeno, medio, grande — afeta posicionamento']
  alcance_base decimal(6,2)
  aquatica boolean [not null, default: false, note: 'Só pode ser colocada na água']
  ativo boolean [not null, default: true]

  Note: 'Torres do jogo, categoria e custo base.'
}

Table upgrades {
  id int [pk, increment]
  torre_id int [not null, ref: > torres.id]
  caminho caminho_upgrade [not null]
  nivel smallint [not null, note: '1 a 5']
  nome varchar(80) [not null]
  custo int [not null, note: 'Custo na dificuldade Medio']
  descricao text

  indexes {
    (torre_id, caminho, nivel) [unique]
  }

  Note: 'Upgrades de cada torre, por caminho e nível, com custo.'
}

Table herois {
  id int [pk, increment]
  nome varchar(60) [not null, unique]
  custo_base int [not null]

  Note: 'Heróis, pois influenciam fortemente as estratégias.'
}

Table bloons {
  id int [pk, increment]
  nome varchar(60) [not null, unique]
  tipo tipo_bloon [not null]
  vida int [not null]
  velocidade decimal(6,2)
  camuflado_possivel boolean [not null, default: true]
  regenera_possivel boolean [not null, default: true]
  resistencia varchar(120) [note: 'Ex: imune a explosivos, imune a gelo']
  filhos_gerados int [default: 0]

  Note: 'Tipos de bloons e suas propriedades.'
}

Table mapas {
  id int [pk, increment]
  nome varchar(60) [not null, unique]
  dificuldade dificuldade_mapa [not null]
  tem_agua boolean [not null, default: false]
  numero_caminhos smallint [not null, default: 1]
  area_util_colocacao varchar(20) [note: 'baixa, media, alta']
  linha_de_visao_bloqueada boolean [not null, default: false]
  observacoes text

  Note: 'Mapas e suas características.'
}


// DADOS ANALÍTICOS — ESTRATÉGIAS


Table estrategias {
  id int [pk, increment]
  nome varchar(100) [not null, unique]
  descricao text
  autor varchar(80)
  heroi_id int [ref: > herois.id, note: 'Herói recomendado (opcional)']
  dificuldade_alvo dificuldade
  modo_alvo modo_jogo [default: 'padrao']
  round_alvo smallint [note: 'Round final que a estratégia se propõe a atingir (ex: 40, 100)']
  custo_total_estimado int [note: 'Calculado a partir dos itens']
  criada_em timestamp [not null, default: `now()`]

  Note: 'Estratégias cadastradas.'
}

Table estrategia_torres {
  id int [pk, increment]
  estrategia_id int [not null, ref: > estrategias.id]
  torre_id int [not null, ref: > torres.id]
  quantidade smallint [not null, default: 1]
  upgrade_caminho_1 smallint [not null, default: 0, note: 'Nível 0 a 5']
  upgrade_caminho_2 smallint [not null, default: 0, note: 'Nível 0 a 5']
  upgrade_caminho_3 smallint [not null, default: 0, note: 'Nível 0 a 5']
  round_colocacao smallint [note: 'Round em que entra na estratégia']
  ordem smallint [note: 'Ordem de colocação']
  observacao varchar(200)

  indexes {
    estrategia_id
    torre_id
  }

  Note: 'Torres e níveis de upgrade que compõem cada estratégia. Respeita a regra do jogo: máx. 5 no caminho principal e 2 no secundário (validar via CHECK/trigger).'
}


// DADOS ANALÍTICOS — PARTIDAS


Table partidas {
  id bigint [pk, increment]
  mapa_id int [not null, ref: > mapas.id]
  estrategia_id int [not null, ref: > estrategias.id]
  dificuldade dificuldade [not null]
  modo modo_jogo [not null, default: 'padrao']
  resultado resultado_partida [not null]
  round_final smallint [not null, note: 'Round em que a partida terminou']
  round_inicial smallint [not null, default: 1]
  vidas_restantes int
  dinheiro_final int
  duracao_segundos int
  jogador varchar(80)
  jogada_em timestamp [not null, default: `now()`]
  observacoes text

  indexes {
    (mapa_id, dificuldade)
    estrategia_id
    resultado
    round_final
  }

  Note: 'Partidas jogadas, com mapa, dificuldade, estratégia usada e resultado.'
}

Table partida_falhas {
  id bigint [pk, increment]
  partida_id bigint [not null, ref: > partidas.id]
  round_falha smallint [not null]
  bloon_causador_id int [ref: > bloons.id, note: 'Bloon que furou a defesa']
  vidas_perdidas int
  motivo varchar(200) [note: 'Ex: camuflado sem detecção, MOAB sem dano suficiente']

  indexes {
    round_falha
    bloon_causador_id
  }

  Note: 'Detalha onde e por que a estratégia falhou. Base para a pergunta: em qual round as estratégias costumam falhar?'
}

// RECOMENDAÇÃO (materializada)


Table recomendacoes {
  id int [pk, increment]
  mapa_id int [not null, ref: > mapas.id]
  dificuldade dificuldade [not null]
  modo modo_jogo [not null, default: 'padrao']
  estrategia_id int [not null, ref: > estrategias.id]
  posicao_ranking smallint [not null]
  taxa_vitoria decimal(5,2) [not null]
  total_partidas int [not null]
  round_medio_derrota decimal(6,2)
  custo_beneficio decimal(10,4) [note: 'Ex: rounds alcançados por 1.000 de custo']
  calculado_em timestamp [not null, default: `now()`]

  indexes {
    (mapa_id, dificuldade, modo, posicao_ranking)
  }

  Note: 'Ranking pré-calculado por mapa/dificuldade/modo. Reconstruído periodicamente a partir de partidas.'
}