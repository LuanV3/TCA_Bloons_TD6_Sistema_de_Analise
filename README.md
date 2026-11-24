# Sistema de Análise Bloons TD6

Banco de dados para o jogo **Bloons TD 6** que **analisa partidas e recomenda as estratégias
mais eficientes**, em vez de apenas catalogar informações do jogo. Ele registra **partidas reais**
e cruza esses resultados com as estratégias usadas para responder perguntas como:

- Qual estratégia tem a maior taxa de vitória em determinado mapa?
- Qual combinação de torres gera o melhor custo-benefício?
- Em qual round as estratégias costumam falhar?
- Qual estratégia recomendar para um mapa e dificuldade específicos?

## Modelo de dados

Os dados do jogo ficam separados dos dados analíticos.

**Dados de referência** (o que existe no jogo)

| Tabela | Descrição |
|---|---|
| `torres` | Torres do jogo, categoria, custo base e alcance |
| `upgrades` | Upgrades de cada torre, por caminho e nível, com custo |
| `herois` | Heróis e seus custos, pois influenciam as estratégias |
| `bloons` | Tipos de bloons e suas propriedades |
| `mapas` | Mapas e suas características |

**Dados analíticos** (o que se joga e se mede)

| Tabela | Descrição |
|---|---|
| `estrategias` | Estratégias cadastradas, com herói, dificuldade e round alvo |
| `estrategia_torres` | Torres e níveis de upgrade que compõem cada estratégia |
| `partidas` | Partidas jogadas, com mapa, dificuldade, estratégia usada e resultado |
| `partida_falhas` | Onde e por que a estratégia falhou em cada partida |
| `recomendacoes` | Ranking pré-calculado de estratégias por mapa, dificuldade e modo |


| Script | O que faz |
|---|---|
| `001_criar_tabelas.sql` | Tipos (enums) e tabelas |
| `002_validacoes.sql` | Regras `CHECK` e `UNIQUE` |
| `003_dados_torres_e_herois.sql` | Cadastro das torres e dos heróis |
| `004_funcao_custo_dificuldade.sql` | Função `custo_na_dificuldade` (Fácil, Médio, Difícil, Impopível) |
| `005_dados_bloons.sql` | Cadastro dos bloons |
| `006_dados_mapas.sql` | Cadastro dos mapas |
| `007_dados_upgrades.sql` | Cadastro dos upgrades |
| `008_funcao_custo_estrategia.sql` | Função `custo_estrategia`, views de custo e de upgrades faltando |
| `009_dados_teste_estrategias_partidas.sql` | **Dados fictícios** de exemplo: 5 estratégias (nomes começam com `Teste - `) e 35 partidas (jogador `teste`), para testar e demonstrar o sistema |
| `010_consultas_analise.sql` | Views de análise e a função `ranking_estrategias` |
| `011_sistema_recomendacao.sql` | `recalcular_recomendacoes`, view `recomendacoes_detalhe` e `recomendar_estrategia` |
| `012_funcao_registrar_partida.sql` | Função `registrar_partida` (registra partida e falha pelos nomes) |

Os dados do script 009 são **inventados** e servem só como exemplo. Eles não vêm de partidas reais.

### Consultas de análise (script 010)

| Objeto | Responde |
|---|---|
| `analise_estrategia_cenario` | Taxa de vitória, round médio e custo-benefício por mapa, dificuldade, modo e estratégia |
| `analise_estrategia_geral` | Desempenho de cada estratégia somando todos os mapas |
| `analise_rounds_falha` / `analise_falhas_faixa_round` | Em quais rounds as falhas acontecem |
| `analise_falhas_por_bloon` | Quais bloons mais furam a defesa |
| `analise_falhas_por_estrategia` | Round médio de falha comparado ao round alvo |
| `analise_torres` / `analise_pares_torres` | Taxa de vitória por torre e por par de torres |
| `ranking_estrategias(mapa, dificuldade, modo, min_partidas)` | Ranking na hora para um cenário |

Partidas abandonadas não entram na taxa de vitória nem nas médias.

### Recomendação (script 011)

A tabela `recomendacoes` é um ranking **pré-calculado**. Ela só muda quando se chama
`select recalcular_recomendacoes(min_partidas, top);`. Com dados reais, use um mínimo de
3 partidas por estratégia, para uma vitória em 1 partida não aparecer como 100%.

### Registrar uma partida (script 012)

```sql
select registrar_partida('Monkey Meadow', 'Teste - Aéreo Ace e Heli', 'medio', 'derrota', 52,
                         p_falha_bloon => 'BFB',
                         p_falha_vidas => 70,
                         p_falha_motivo => 'BFB sem dano suficiente');
```

## API e interface

A pasta `api/` usa só JavaScript nativo e `fetch`, sem biblioteca.

| Arquivo | Descrição |
|---|---|
| `config.js` | URL do projeto e chave publishable do Supabase (preencher) |
| `api.js` | Funções que chamam a API REST: partidas, análise, ranking e recomendação |
| `index.html`, `app.js`, `estilo.css` | Interface: registrar partida, listar partidas, recomendações e falhas |

## Roadmap

- [x] Modelagem das tabelas de referência
- [x] Modelagem de estratégias e partidas
- [x] Criação das tabelas no Supabase
- [x] Regras de validação (`CHECK`, `UNIQUE`)
- [x] Cadastro das torres e dos heróis
- [x] Função de custo por dificuldade
- [x] Cadastro dos mapas e dos bloons
- [x] Cadastro dos upgrades
- [x] Função de custo de uma estratégia
- [x] Cadastro de estratégias e partidas de teste
- [x] Consultas de análise (ranking de estratégias, rounds de falha)
- [x] Sistema de recomendação por mapa e dificuldade
- [x] API e interface para registrar partidas


## Aviso

Projeto não oficial, sem vínculo com a Ninja Kiwi. Bloons TD 6 é marca da Ninja Kiwi.
