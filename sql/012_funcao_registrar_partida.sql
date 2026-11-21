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