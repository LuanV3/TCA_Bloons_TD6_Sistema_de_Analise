# 🎈 Sistema de Análise Bloons TD6

Banco de dados para o jogo **Bloons TD 6** que **analisa partidas e recomenda as estratégias
mais eficientes**, em vez de apenas catalogar informações do jogo. Ele registra **partidas reais**
e cruza esses resultados com as estratégias usadas para responder perguntas como:

- Qual estratégia tem a maior taxa de vitória em determinado mapa?
- Qual combinação de torres gera o melhor custo-benefício?
- Em qual round as estratégias costumam falhar?
- Qual estratégia recomendar para um mapa e dificuldade específicos?

## 🗂️ Modelo de dados

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

## 🛣️ Roadmap

- [x] Modelagem das tabelas de referência
- [x] Modelagem de estratégias e partidas
- [x] Criação das tabelas no Supabase
- [x] Regras de validação (`CHECK`, `UNIQUE`)
- [ ] Cadastro das torres e dos heróis
- [ ] Função de custo por dificuldade
- [ ] Cadastro dos mapas e dos bloons
- [ ] Cadastro dos upgrades
- [ ] Cadastro de estratégias e partidas de teste
- [ ] Consultas de análise (ranking de estratégias, rounds de falha)
- [ ] Sistema de recomendação por mapa e dificuldade
- [ ] Interface para registrar partidas

## ⚠️ Aviso

Projeto não oficial, sem vínculo com a Ninja Kiwi. Bloons TD 6 é marca da Ninja Kiwi.