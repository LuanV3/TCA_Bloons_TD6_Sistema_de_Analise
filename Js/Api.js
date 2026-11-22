// Comunicação com a API REST do Supabase usando só fetch (sem biblioteca).
// Cobre os scripts 001 a 012: tabelas, views de análise e funções (rpc).
import { SUPABASE_URL, SUPABASE_KEY } from './config.js';

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

// ---------- LISTAS PARA MENUS ----------

// Só os nomes de uma tabela: 'mapas', 'estrategias', 'bloons', 'torres' ou 'herois'
export async function listarOpcoes(tabela) {
  return await buscar(tabela + '?select=nome&order=nome');
}

// ---------- PARTIDAS ----------

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