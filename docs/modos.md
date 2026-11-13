# Modos Aventura e Desafios

Este documento descreve o game design dos dois modos e como cada um usa o catálogo de placas
([catalogo/README.md](catalogo/README.md)). A referência de ritmo e progressão é o Duolingo:
a trilha de lições (Aventura), o *Ramp Up* (Contra o relógio) e os corações (Com restrição).

## Princípios

- **Um catálogo só.** Todos os modos sorteiam do mesmo `assets/catalog.json`, com soluções
  verificadas pelo `Evaluator` do jogo. Os modos novos não inventam placas. O que muda é a
  ordem, o filtro e as regras extras.
- **Os números das 150 placas não mudaram.** O histórico dos jogadores (resolvido = número + nível),
  a placa do dia e as lições continuam válidos. O catálogo passou para a versão 2 só com metadados
  novos: `t` (trivial) e `r` (variantes com restrição).
- **Níveis com as regras do jogo.** No Emplake, "fácil" quer dizer *mais ferramentas*: o Fácil tem
  todos os operadores e o Difícil só + − × ÷ com −x e |x|. Os cabeçalhos da Aventura mostram os
  operadores reais de cada nível (`Level.operatorLabels`). O mockup serviu só de layout.

## Placas triviais (com 0)

Muitas placas com 0 saem na hora anulando um lado com × 0 (ex.: 6004 → 6 × 0 = 0 × 4). O gerador marca
como **trivial** a placa que tem 0 e cuja solução tem um ×, ÷ ou ^ que vale 0 porque um operando é 0.
Hoje são 29 das 150. Elas não saíram do catálogo. Cada modo tem uma regra própria para elas:

| Modo | Placas triviais |
|---|---|
| Aleatório, Específico, placa do dia | Sem mudança. |
| Aventura | Entram como **aquecimento**: as 2 primeiras fases de cada coluna, depois uma a cada 2 fases normais. Ensinam o truque do ×0 de propósito. |
| Contra o relógio | **Excluídas**, porque seriam ponto de graça numa corrida contra o tempo. |
| Com restrição | Recebem primeiro a regra **"sem ×"**, que desliga o truque. Variantes que ainda saem com ×0, como 0 ÷ 1 = 0 + 0, são descartadas. Placas sem nenhuma variante decente (ex.: 0100) ficam fora do desafio. |

## Aventura: a coleção inteira como trilha

- **Sempre a coleção inteira.** São quatro colunas (Fácil → Difícil) com *todas* as placas do
  catálogo, hoje 40 + 40 + 35 + 35 = 150. Quando o catálogo crescer, a trilha cresce sozinha. Placas
  novas entram no fim do seu nível, para não deslocar o progresso de ninguém.
- **Ordem:** dentro de cada nível, a ordem das entradas no JSON é a ordem da trilha: dificuldade ★,
  depois a `difficulty` do solver, com as triviais intercaladas como aquecimento. As fases são
  numeradas ao longo da coleção: 001–040 Fácil, 041–080 Intermediário, 081–115 Avançado,
  116–150 Difícil.
- **Desbloqueio dentro da coluna:** a fase *atual* é a primeira não concluída. Ela e as 3 seguintes
  ficam abertas, para o jogador não travar numa placa difícil.
- **Desbloqueio entre colunas (checkpoint):** a coluna seguinte abre quando a anterior tem
  **12 fases concluídas**. Sem isso, seriam 115 placas até chegar ao Difícil. Depois de abertas, as
  colunas andam em paralelo.
- **Progresso compartilhado:** uma placa resolvida em qualquer modo que grava `solved` (Aleatório,
  Específico, placa do dia, Aventura) conta como concluída. As estrelas saem dos dados já guardados no
  doc `solved` (`inTime`, `hints`, `seconds`).
- **Estrelas da fase** (desempenho, diferentes da dificuldade ★ do catálogo):
  - ★ resolveu;
  - ★★ resolveu no tempo e sem dica;
  - ★★★ resolveu no tempo, sem dica e com pelo menos metade do tempo sobrando.

  Revelar a solução não dá estrela. Rejogar uma fase pode melhorar a nota, e fica guardada a maior.
- **Pontos:** a Aventura grava em `solved` como o Aleatório. Uma placa já resolvida dá 0 ponto, mas as
  estrelas contam.

## Desafios

Os dois desafios sobem a mesma **escada fixa**. A cada 3 acertos o jogador sobe um degrau:

| Degrau | Nível | Dificuldade |
|---|---|---|
| 1 | Fácil | ★1 |
| 2 | Fácil | ★2 |
| 3 | Intermediário | ★1 |
| 4 | Intermediário | ★2 |
| 5 | Avançado | ★1 |
| 6 | Avançado | ★2 |
| 7 | Difícil | ★1–2 |
| 8+ | Difícil | ★2–3 (repete até o fim) |

Regras comuns aos dois:

- Não há dicas nem pausa.
- Nenhuma placa se repete na mesma partida. Quando o degrau acaba, o sorteio vale o nível inteiro.
- Os desafios **não** somam em `totalPoints` nem gravam em `solved`, para não gastar placas do
  Aleatório. Têm recordes próprios.
- Uma partida interrompida (recarregar a página, voltar pelo MENU ou começar outra partida) termina
  com a pontuação que tinha e conta como jogada.

### D.01 Contra o relógio (referência: *Ramp Up* do Duolingo)

- Um relógio de **3:00** vale para a partida toda e passa de uma placa para a outra.
- **Subir de degrau dá +10 s.** **Pular custa 10 s**, sem diálogo, e não conta para o degrau.
- O tempo zerado encerra a partida e mostra uma solução da última placa.
- **Recorde** = maior número de placas resolvidas numa partida.

### D.02 Com restrição (referência: corações do Duolingo)

- Cada placa vem com uma regra das variantes `r` do catálogo. Há três tipos:
  - **sem op** (`-*`): o operador aparece riscado e desativado na paleta, e o avaliador o rejeita;
  - **use op** (`+/`): a igualdade precisa ter o operador;
  - **= fixo** (`=1`): o "=" tem que ficar num vão definido.
- Uma igualdade verdadeira que quebra a regra é recusada com o aviso "Verdadeira, mas fora da regra",
  e não custa vida.
- Cada placa tem o tempo do seu nível (45 a 75 s).
- **3 vidas:** estourar o tempo ou pular custa uma. A placa perdida mostra uma solução que segue a regra.
- **Recorde** = maior sequência de placas resolvidas.

### Descartado: Caça às soluções

O mockup tinha um terceiro desafio, "Caça às soluções" (uma placa, quantas igualdades diferentes
existem). Ele saiu por dois motivos:

- **Com unários, o total é infinito.** −(−x), |x| e outros geram novas igualdades sem fim, então não dá
  para mostrar "14 / 23".
- **Só com binários, quase não há o que caçar.** A mediana das 150 placas é de **1** solução.

## Onde está no código

| Parte | Arquivo |
|---|---|
| Regras extras (`Restriction`, `OpRules`) | `lib/features/game/domain/rules.dart` |
| Solver com restrição (obrigatório = flag na DP; = fixo = filtro do vão) | `lib/features/game/domain/solver.dart` |
| Trilha, desbloqueio e estrelas | `lib/features/game/domain/adventure.dart` |
| Escada, partida e sorteio dos desafios | `lib/features/game/domain/challenge.dart` |
| Estado da partida (relógio que passa de placa a placa, vidas, `ruleBroken`) | `lib/features/game/application/game_controller.dart` |
| Telas | `lib/features/adventure/adventure_page.dart`, `lib/features/challenges/challenges_page.dart` |
| Persistência (Firestore + cópia local) | `lib/features/adventure/adventure_store.dart`, `lib/features/challenges/challenge_store.dart`, `lib/data/firestore_repository.dart` |
| Gerador do catálogo e dos docs | `tool/gen_catalog_test.dart`, `tool/catalog_docs.dart` |

No Firestore, as estrelas da Aventura (`adventure.{nivel_numero}`) e os recordes
(`challenges.{clock|restricted}.{best,plays}`) ficam no próprio documento `users/{uid}`, que o dono já
pode escrever. Por isso as regras do Firestore não mudaram. Uma cópia local em SharedPreferences
faz a trilha e os recordes funcionarem offline e no build de preview.

## Para depois

- Conquistas novas: "coluna completa" na Aventura e "10 placas" no Contra o relógio.
- Ampliar o catálogo: placas novas entram no fim de cada nível e o gerador calcula `t` e `r` para elas.
