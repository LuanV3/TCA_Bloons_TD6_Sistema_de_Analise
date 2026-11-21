-- Sistema de Análise Bloons TD 6
-- função para registrar uma partida (e a falha, se for derrota) pelos NOMES
-- Rodar DEPOIS do 001 a 011. Pode rodar mais de uma vez.
-- Parâmetros obrigatórios: mapa, estratégia, dificuldade, resultado, round final.
-- Todo o resto é opcional e deve ser passado por nome (p_xxx => valor).
-- Se o mapa, a estratégia ou o bloon não existir, a função para com erro e não grava nada.
-- Partida e falha são gravadas na mesma transação: ou entram as duas, ou nenhuma.
-- Retorna o id da partida criada.
-- Round inicial: se não informado, usa o padrão da dificuldade
-- facil 1 | medio 1 | dificil 3 | impopivel 6.
-- Dados da falha (p_falha_*): só valem para resultado 'derrota'.
-- Se informar bloon, vidas perdidas ou motivo sem p_falha_round, o round da falha
-- é o próprio round final da partida.
-- As regras do 002 continuam valendo (ex.: CHIMPS só na dificuldade impopivel,
-- round final >= round inicial). Se uma regra for violada, o Postgres mostra o erro.

create or replace function registrar_partida(
  p_mapa           text,
  p_estrategia     text,
  p_dificuldade    dificuldade,
  p_resultado      resultado_partida,
  p_round_final    int,
  p_modo           modo_jogo default 'padrao',
  p_round_inicial  int       default null,
  p_vidas          int       default null,
  p_dinheiro       int       default null,
  p_duracao        int       default null,
  p_jogador        text      default null,
  p_observacoes    text      default null,
  p_falha_round    int       default null,
  p_falha_bloon    text      default null,
  p_falha_vidas    int       default null,
  p_falha_motivo   text      default null
)
returns bigint
language plpgsql
as '
declare
  v_mapa_id      int;
  v_estrategia_id int;
  v_bloon_id     int;
  v_round_ini    int;
  v_partida_id   bigint;
  v_tem_falha    boolean;
begin
  select id into v_mapa_id from mapas where lower(nome) = lower(p_mapa);
  if v_mapa_id is null then
    raise exception ''Mapa não encontrado: %'', p_mapa;
  end if;

  select id into v_estrategia_id from estrategias where lower(nome) = lower(p_estrategia);
  if v_estrategia_id is null then
    raise exception ''Estratégia não encontrada: %'', p_estrategia;
  end if;

  v_tem_falha := p_falha_round is not null
              or p_falha_bloon is not null
              or p_falha_vidas is not null
              or p_falha_motivo is not null;

  if v_tem_falha and p_resultado <> ''derrota'' then
    raise exception ''Dados de falha só podem ser informados para resultado derrota (resultado informado: %)'', p_resultado;
  end if;

  if p_falha_bloon is not null then
    select id into v_bloon_id from bloons where lower(nome) = lower(p_falha_bloon);
    if v_bloon_id is null then
      raise exception ''Bloon não encontrado: %'', p_falha_bloon;
    end if;
  end if;

  v_round_ini := coalesce(
    p_round_inicial,
    case p_dificuldade
      when ''facil''     then 1
      when ''medio''     then 1
      when ''dificil''   then 3
      when ''impopivel'' then 6
    end
  );

  insert into partidas
    (mapa_id, estrategia_id, dificuldade, modo, resultado,
     round_inicial, round_final, vidas_restantes, dinheiro_final,
     duracao_segundos, jogador, observacoes)
  values
    (v_mapa_id, v_estrategia_id, p_dificuldade, p_modo, p_resultado,
     v_round_ini, p_round_final, p_vidas, p_dinheiro,
     p_duracao, p_jogador, p_observacoes)
  returning id into v_partida_id;

  if v_tem_falha then
    insert into partida_falhas
      (partida_id, round_falha, bloon_causador_id, vidas_perdidas, motivo)
    values
      (v_partida_id, coalesce(p_falha_round, p_round_final), v_bloon_id,
       p_falha_vidas, p_falha_motivo);
  end if;

  return v_partida_id;
end;
';

COMMENT ON FUNCTION registrar_partida(text, text, dificuldade, resultado_partida, int, modo_jogo, int, int, int, int, text, text, int, text, int, text) IS
  'Registra uma partida (e a falha, se derrota) usando nomes de mapa, estratégia e bloon. Retorna o id da partida.';

-- EXEMPLOS (rodar um por vez)
-- Vitória simples:
-- select registrar_partida('Monkey Meadow', 'Teste - Aéreo Ace e Heli', 'medio', 'vitoria', 60,
-- p_vidas => 120, p_duracao => 2100, p_jogador => 'eu');
-- Derrota com a falha registrada:
-- select registrar_partida('Monkey Meadow', 'Teste - Aéreo Ace e Heli', 'medio', 'derrota', 52,
-- p_falha_bloon => 'BFB',
-- p_falha_vidas => 70,
-- p_falha_motivo => 'BFB sem dano suficiente',
-- p_jogador => 'eu');
-- CHIMPS (impopivel, começa no round 6):
-- select registrar_partida('Logs', 'Teste - Super Monkey CHIMPS', 'impopivel', 'vitoria', 100,
-- p_modo => 'impopivel_chimps', p_vidas => 1, p_jogador => 'eu');
-- Depois de registrar partidas novas, atualize o ranking:
-- select recalcular_recomendacoes();