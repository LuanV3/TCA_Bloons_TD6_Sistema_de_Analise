import { SUPABASE_URL, SUPABASE_KEY } from './Config.js';

const API_URL = SUPABASE_URL + '/rest/v1/';

// Trata a resposta: se deu erro, lança uma mensagem; se deu certo, devolve o json
async function tratarResposta(response) {
  if (response.ok === false) {
    let mensagem = 'Erro ' + response.status + ' na API';
    try {
      const erro = await response.json();
      if (erro.message) {
        mensagem = erro.message;
      }
    } catch (e) {
      // resposta sem json: fica com a mensagem padrão
    }
    throw new Error(mensagem);
  }
  if (response.status === 204) {
    return null;
  }
  return await response.json();
}

// GET genérico: caminho = tabela ou view com a query (ex: 'mapas?select=nome')
async function buscar(caminho) {
  const response = await fetch(API_URL + caminho, {
    method: 'GET',
    headers: { apikey: SUPABASE_KEY }
  });
  return await tratarResposta(response);
}

// POST em uma função do banco (rpc). corpo = objeto com os parâmetros
async function chamarFuncao(nome, corpo) {
  const response = await fetch(API_URL + 'rpc/' + nome, {
    method: 'POST',
    headers: {
      apikey: SUPABASE_KEY,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(corpo)
  });
  return await tratarResposta(response);
}

// LISTAS PARA MENUS

// Só os nomes de uma tabela: 'mapas', 'estrategias', 'bloons', 'torres' ou 'herois'
export async function listarOpcoes(tabela) {
  return await buscar(tabela + '?select=nome&order=nome');
}

// PARTIDAS

// Partidas com o nome do mapa e da estratégia (filtros opcionais, '' = sem filtro)
export async function listarPartidas(resultado, dificuldade) {
  let caminho = 'partidas?select=*,mapas(nome),estrategias(nome)&order=id.desc&limit=100';
  if (resultado !== '') {
    caminho = caminho + '&resultado=eq.' + encodeURIComponent(resultado);
  }
  if (dificuldade !== '') {
    caminho = caminho + '&dificuldade=eq.' + encodeURIComponent(dificuldade);
  }
  return await buscar(caminho);
}

// Registra uma partida (e a falha, se for derrota). Devolve o id da partida.
// corpo usa os nomes da função do script 012, ex:
// { p_mapa: 'Logs', p_estrategia: 'Teste - Aquático', p_dificuldade: 'medio',
//   p_resultado: 'derrota', p_round_final: 55, p_falha_bloon: 'BFB' }
export async function registrarPartida(corpo) {
  return await chamarFuncao('registrar_partida', corpo);
}

// ANÁLISE (views do script 010)

// Desempenho de cada estratégia por mapa, dificuldade e modo
export async function listarDesempenhoCenario(mapa, dificuldade) {
  let caminho = 'analise_estrategia_cenario?select=*&order=mapa.asc,taxa_vitoria.desc';
  if (mapa !== '') {
    caminho = caminho + '&mapa=eq.' + encodeURIComponent(mapa);
  }
  if (dificuldade !== '') {
    caminho = caminho + '&dificuldade=eq.' + encodeURIComponent(dificuldade);
  }
  return await buscar(caminho);
}

// Desempenho geral de cada estratégia
export async function listarDesempenhoGeral() {
  return await buscar('analise_estrategia_geral?select=*&order=taxa_vitoria.desc');
}

// Rounds em que mais acontecem falhas
export async function listarRoundsFalha() {
  return await buscar('analise_rounds_falha?select=*');
}

// Bloons que mais causam falha
export async function listarFalhasPorBloon() {
  return await buscar('analise_falhas_por_bloon?select=*');
}

// Ranking de um cenário na hora (função do script 010)
export async function obterRanking(mapa, dificuldade, modo, minPartidas) {
  return await chamarFuncao('ranking_estrategias', {
    p_mapa: mapa,
    p_dificuldade: dificuldade,
    p_modo: modo,
    p_min_partidas: minPartidas
  });
}

// RECOMENDAÇÃO (script 011)

// Recomendações já calculadas (filtros opcionais, '' = sem filtro)
export async function listarRecomendacoes(mapa, dificuldade, modo) {
  let caminho = 'recomendacoes_detalhe?select=*&order=mapa.asc,posicao_ranking.asc';
  if (mapa !== '') {
    caminho = caminho + '&mapa=eq.' + encodeURIComponent(mapa);
  }
  if (dificuldade !== '') {
    caminho = caminho + '&dificuldade=eq.' + encodeURIComponent(dificuldade);
  }
  if (modo !== '') {
    caminho = caminho + '&modo=eq.' + encodeURIComponent(modo);
  }
  return await buscar(caminho);
}

// As melhores estratégias de um mapa e dificuldade (já ranqueadas)
export async function recomendarEstrategia(mapa, dificuldade, modo, limite) {
  return await chamarFuncao('recomendar_estrategia', {
    p_mapa: mapa,
    p_dificuldade: dificuldade,
    p_modo: modo,
    p_limite: limite
  });
}

// Reconstrói o ranking a partir das partidas. Devolve quantas linhas gravou.
export async function recalcularRecomendacoes(minPartidas, top) {
  return await chamarFuncao('recalcular_recomendacoes', {
    p_min_partidas: minPartidas,
    p_top: top
  });
}