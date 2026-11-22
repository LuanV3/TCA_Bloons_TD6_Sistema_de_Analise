import {
  listarOpcoes, listarPartidas, registrarPartida,
  listarRecomendacoes, recalcularRecomendacoes,
  listarRoundsFalha, listarFalhasPorBloon
} from './Api.js';

const DIFICULDADES = ['facil', 'medio', 'dificil', 'impopivel'];
const MODOS = ['padrao', 'alternate_bloons_rounds', 'reverso', 'apopalypse', 'deflation', 'half_cash', 'impopivel_chimps', 'sandbox'];
const RESULTADOS = ['vitoria', 'derrota', 'abandonada'];

function pegar(id) {
  return document.getElementById(id);
}

// Evita que texto vire HTML
function esc(texto) {
  if (texto === null || texto === undefined) {
    return '';
  }
  texto = String(texto);
  texto = texto.replaceAll('&', '&amp;');
  texto = texto.replaceAll('<', '&lt;');
  texto = texto.replaceAll('>', '&gt;');
  texto = texto.replaceAll('"', '&quot;');
  return texto;
}

function traco(valor) {
  if (valor === null || valor === undefined || valor === '') {
    return '-';
  }
  return esc(valor);
}

function mostrarMensagem(texto, erro) {
  const el = pegar('mensagem');
  el.textContent = texto;
  if (erro === true) {
    el.className = 'mensagem erro';
  } else {
    el.className = 'mensagem';
  }
  el.hidden = texto === '';
}

// Preenche um <select> com uma lista de textos (vazio = primeira opção sem valor)
function opcoes(select, valores, textoVazio) {
  select.innerHTML = '';
  if (textoVazio !== undefined) {
    select.add(new Option(textoVazio, ''));
  }
  valores.forEach(function (v) {
    select.add(new Option(v, v));
  });
}

// Mesma coisa, mas a lista vem da API como [{ nome: '...' }]
function opcoesDaApi(select, lista, textoVazio) {
  const nomes = [];
  lista.forEach(function (item) {
    nomes.push(item.nome);
  });
  opcoes(select, nomes, textoVazio);
}

function linhaVazia(colunas, texto) {
  return '<tr><td colspan="' + colunas + '" class="vazio">' + texto + '</td></tr>';
}

// ABAS

const botoes = document.querySelectorAll('nav button');
const abas = document.querySelectorAll('main section');

function abrirAba(nome) {
  abas.forEach(function (aba) {
    aba.hidden = aba.id !== 'aba-' + nome;
  });
  botoes.forEach(function (botao) {
    if (botao.dataset.aba === nome) {
      botao.setAttribute('aria-current', 'page');
    } else {
      botao.removeAttribute('aria-current');
    }
  });
  mostrarMensagem('', false);
  if (nome === 'partidas') {
    carregarPartidas();
  }
  if (nome === 'recomendacoes') {
    carregarRecomendacoes();
  }
  if (nome === 'falhas') {
    carregarFalhas();
  }
}

botoes.forEach(function (botao) {
  botao.addEventListener('click', function () {
    abrirAba(botao.dataset.aba);
  });
});

// REGISTRAR PARTIDA

const formPartida = pegar('form-partida');
const blocoFalha = pegar('bloco-falha');

opcoes(formPartida.elements.dificuldade, DIFICULDADES);
opcoes(formPartida.elements.modo, MODOS);
opcoes(formPartida.elements.resultado, RESULTADOS);
formPartida.elements.dificuldade.value = 'medio';

formPartida.elements.resultado.addEventListener('change', function () {
  blocoFalha.hidden = formPartida.elements.resultado.value !== 'derrota';
});

// Só coloca no objeto os campos preenchidos
function adicionarNumero(objeto, chave, valor) {
  if (valor !== '') {
    objeto[chave] = Number(valor);
  }
}

function adicionarTexto(objeto, chave, valor) {
  valor = valor.trim();
  if (valor !== '') {
    objeto[chave] = valor;
  }
}

function lerFormPartida() {
  const e = formPartida.elements;
  const corpo = {};
  corpo.p_mapa = e.mapa.value;
  corpo.p_estrategia = e.estrategia.value;
  corpo.p_dificuldade = e.dificuldade.value;
  corpo.p_resultado = e.resultado.value;
  corpo.p_modo = e.modo.value;
  adicionarNumero(corpo, 'p_round_final', e.round_final.value);
  adicionarNumero(corpo, 'p_round_inicial', e.round_inicial.value);
  adicionarNumero(corpo, 'p_vidas', e.vidas.value);
  adicionarNumero(corpo, 'p_dinheiro', e.dinheiro.value);
  adicionarNumero(corpo, 'p_duracao', e.duracao.value);
  adicionarTexto(corpo, 'p_jogador', e.jogador.value);
  adicionarTexto(corpo, 'p_observacoes', e.observacoes.value);
  if (e.resultado.value === 'derrota') {
    adicionarNumero(corpo, 'p_falha_round', e.falha_round.value);
    adicionarTexto(corpo, 'p_falha_bloon', e.falha_bloon.value);
    adicionarNumero(corpo, 'p_falha_vidas', e.falha_vidas.value);
    adicionarTexto(corpo, 'p_falha_motivo', e.falha_motivo.value);
  }
  return corpo;
}

formPartida.addEventListener('submit', async function (ev) {
  ev.preventDefault();
  try {
    const id = await registrarPartida(lerFormPartida());
    mostrarMensagem('Partida registrada com o ID ' + id + '.', false);
    const e = formPartida.elements;
    e.round_final.value = '';
    e.vidas.value = '';
    e.dinheiro.value = '';
    e.duracao.value = '';
    e.observacoes.value = '';
    e.falha_round.value = '';
    e.falha_vidas.value = '';
    e.falha_motivo.value = '';
  } catch (erro) {
    mostrarMensagem(erro.message, true);
  }
});

// PARTIDAS

const filtrosPartidas = pegar('filtros-partidas');
const corpoPartidas = pegar('corpo-partidas');

opcoes(filtrosPartidas.elements.resultado, RESULTADOS, 'Todos os resultados');
opcoes(filtrosPartidas.elements.dificuldade, DIFICULDADES, 'Todas as dificuldades');

async function carregarPartidas() {
  corpoPartidas.innerHTML = linhaVazia(9, 'Carregando...');
  try {
    const lista = await listarPartidas(
      filtrosPartidas.elements.resultado.value,
      filtrosPartidas.elements.dificuldade.value
    );
    if (lista.length === 0) {
      corpoPartidas.innerHTML = linhaVazia(9, 'Nenhuma partida encontrada.');
      return;
    }
    let linhas = '';
    lista.forEach(function (p) {
      linhas += '<tr>' +
        '<td>' + p.id + '</td>' +
        '<td>' + esc(p.mapas.nome) + '</td>' +
        '<td>' + esc(p.estrategias.nome) + '</td>' +
        '<td>' + esc(p.dificuldade) + '</td>' +
        '<td>' + esc(p.modo) + '</td>' +
        '<td>' + esc(p.resultado) + '</td>' +
        '<td>' + p.round_inicial + ' a ' + p.round_final + '</td>' +
        '<td>' + traco(p.vidas_restantes) + '</td>' +
        '<td>' + new Date(p.jogada_em).toLocaleString('pt-BR') + '</td>' +
        '</tr>';
    });

    corpoPartidas.innerHTML = linhas;
  } catch (erro) {
    corpoPartidas.innerHTML = '';
    mostrarMensagem(erro.message, true);
  }
}

filtrosPartidas.addEventListener('submit', function (ev) {
  ev.preventDefault();
  carregarPartidas();
});

// RECOMENDAÇÕES

const filtrosRec = pegar('filtros-recomendacoes');
const corpoRec = pegar('corpo-recomendacoes');
const formRecalcular = pegar('form-recalcular');

opcoes(filtrosRec.elements.dificuldade, DIFICULDADES, 'Todas as dificuldades');
opcoes(filtrosRec.elements.modo, MODOS, 'Todos os modos');

async function carregarRecomendacoes() {
  corpoRec.innerHTML = linhaVazia(9, 'Carregando...');
  try {
    const lista = await listarRecomendacoes(
      filtrosRec.elements.mapa.value,
      filtrosRec.elements.dificuldade.value,
      filtrosRec.elements.modo.value
    );
    if (lista.length === 0) {
      corpoRec.innerHTML = linhaVazia(9, 'Nenhuma recomendação. Registre partidas e clique em "Recalcular ranking".');
      return;
    }
    let linhas = '';
    lista.forEach(function (r) {
      linhas += '<tr>' +
        '<td>' + r.posicao_ranking + '</td>' +
        '<td>' + esc(r.mapa) + ' (' + esc(r.dificuldade) + ', ' + esc(r.modo) + ')</td>' +
        '<td>' + esc(r.estrategia) + '</td>' +
        '<td>' + traco(r.heroi) + '</td>' +
        '<td>' + r.taxa_vitoria + '%</td>' +
        '<td>' + r.total_partidas + '</td>' +
        '<td>' + traco(r.round_medio_derrota) + '</td>' +
        '<td>' + traco(r.custo) + '</td>' +
        '<td>' + traco(r.custo_beneficio) + '</td>' +
        '</tr>';
    });
    corpoRec.innerHTML = linhas;
  } catch (erro) {
    corpoRec.innerHTML = '';
    mostrarMensagem(erro.message, true);
  }
}

filtrosRec.addEventListener('submit', function (ev) {
  ev.preventDefault();
  mostrarMensagem('', false);
  carregarRecomendacoes();
});

formRecalcular.addEventListener('submit', async function (ev) {
  ev.preventDefault();
  try {
    const n = await recalcularRecomendacoes(
      Number(formRecalcular.elements.minimo.value),
      Number(formRecalcular.elements.top.value)
    );
    mostrarMensagem('Ranking recalculado: ' + n + ' linhas gravadas.', false);
    carregarRecomendacoes();
  } catch (erro) {
    mostrarMensagem(erro.message, true);
  }
});