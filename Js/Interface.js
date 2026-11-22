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