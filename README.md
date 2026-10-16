# 🎈 Sistema de Análise Bloons TD6

Banco de dados para o jogo **Bloons TD 6** que **analisa partidas e recomenda as estratégias
mais eficientes**, em vez de apenas catalogar informações do jogo (torres, upgrades, bloons
e mapas). Ele registra **partidas reais** e cruza esses resultados com as estratégias usadas
para responder perguntas como:

- Qual estratégia tem a maior taxa de vitória em determinado mapa?
- Qual combinação de torres gera o melhor custo-benefício?
- Em qual round as estratégias costumam falhar?
- Qual estratégia recomendar para um mapa e dificuldade específicos?

## 🗂️ Modelo de dados
 
Os dados do jogo ficam separados dos dados analíticos:
 
**Dados de referência**
 
| Tabela | Descrição |
|---|---|
| `torres` | Torres do jogo, categoria e custo base |
| `upgrades` | Upgrades de cada torre, por caminho e nível, com custo |
| `bloons` | Tipos de bloons e suas propriedades |
| `mapas` | Mapas e suas características |

**Dados analíticos**
 
| Tabela | Descrição |
|---|---|
| `estrategias` | Estratégias cadastradas e as torres/upgrades que as compõem |
| `partidas` | Partidas jogadas, com mapa, dificuldade, estratégia usada e resultado |
 
## 🛣️ Roadmap
 
- [ ] Modelagem das tabelas de referência
- [ ] Modelagem de estratégias e partidas
- [ ] Consultas de análise (ranking de estratégias)
- [ ] Sistema de recomendação por mapa e dificuldade
## ⚠️ Aviso
 
Projeto não oficial, sem vínculo com a Ninja Kiwi. Bloons TD 6 é marca da Ninja Kiwi.
