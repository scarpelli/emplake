# Modos Aventura e Desafios

Este documento descreve o game design dos dois modos e como cada um usa o catálogo de placas
([catalogo/README.md](catalogo/README.md)). A referência de ritmo e progressão é o Duolingo:
a trilha de lições (Aventura), o *Ramp Up* (Contra o relógio) e os corações (Com restrição).

## Princípios

- Todos os modos sorteiam do mesmo `assets/catalog.json`, com soluções verificadas pelo
  `Evaluator` do jogo. Os modos novos não criam placas, só mudam a ordem, o filtro e as regras extras.
- Os números das 150 placas não mudaram, então o histórico dos jogadores (uma placa resolvida é
  identificada pelo número e pelo nível), a placa do dia e as lições continuam válidos. O catálogo
  passou para a versão 2 ganhando só dois metadados: `t` (trivial) e `r` (variantes com restrição).
- No Emplake, "fácil" quer dizer *mais ferramentas*: o Fácil tem todos os operadores, e o Difícil
  só tem + − × ÷, −x e |x|. Os cabeçalhos da Aventura mostram os operadores reais de cada nível
  (`Level.operatorLabels`), e do mockup aproveitamos só o layout.

## Placas triviais (com 0)

Muitas placas com 0 saem na hora anulando um lado com × 0 (ex.: 6004 → 6 × 0 = 0 × 4). O gerador marca
como **trivial** a placa que tem 0 e cuja solução tem um ×, ÷ ou ^ que vale 0 porque um operando é 0.
Hoje são 29 das 150. Elas continuam no catálogo, mas cada modo as trata de um jeito:

| Modo | Placas triviais |
|---|---|
| Aleatório, Específico, placa do dia | Entram no sorteio como as outras. |
| Aventura | Entram como **aquecimento**: as 2 primeiras fases de cada coluna, depois uma a cada 2 fases normais, para ensinar o truque do ×0. |
| Contra o relógio | Ficam **de fora**, porque seriam pontos de graça numa corrida contra o tempo. |
| Com restrição | Recebem primeiro a regra **"sem ×"**, que desliga o truque. Variantes que ainda saem com ×0, como 0 ÷ 1 = 0 + 0, são descartadas. Placas sem nenhuma variante decente (ex.: 0100) ficam fora do desafio. |

## Aventura: a coleção inteira como trilha

- **Coleção inteira:** são quatro colunas (do Fácil ao Difícil) com *todas* as placas do catálogo,
  hoje 40 + 40 + 35 + 35 = 150. Quando o catálogo crescer, a trilha cresce junto, e as placas novas
  entram no fim do seu nível para não deslocar o progresso de ninguém.
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

  Quem revela a solução não ganha estrelas. Rejogar uma fase pode melhorar a nota, e fica guardada a maior.
- **Pontos:** a Aventura grava em `solved` como o Aleatório. Uma placa já resolvida dá 0 pontos, mas as
  estrelas contam.
- **Fases sem relógio:** as fases 001–010 usam um cronômetro em vez da contagem regressiva, como a
  placa do dia. O tempo é medido e conta para as estrelas e o bônus, mas nunca acaba, então quem está
  começando aprende os operadores sem a pressão do relógio (`AdventureProgress.untimedStages`).

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
- Nenhuma placa se repete na mesma partida. Quando acabam as placas do degrau, o sorteio passa a
  valer para o nível inteiro.
- Os desafios **não** somam em `totalPoints` nem gravam em `solved`, para não gastar as placas do
  Aleatório, e têm recordes próprios.
- Uma partida interrompida (recarregar a página, voltar pelo MENU ou começar outra partida) termina
  com a pontuação que tinha e conta como jogada.

### D.01 Contra o relógio (referência: *Ramp Up* do Duolingo)

- Um relógio de **3:00** vale para a partida toda e passa de uma placa para a outra.
- Subir de degrau dá **+10 s**. Pular custa **10 s**, não abre diálogo e não conta para o degrau.
- O tempo zerado encerra a partida e mostra uma solução da última placa.
- O **recorde** é o maior número de placas resolvidas numa partida.

### D.02 Com restrição (referência: corações do Duolingo)

- Cada placa vem com uma regra das variantes `r` do catálogo. Há três tipos:
  - **sem op** (`-*`): o operador aparece riscado e desativado na paleta, e o avaliador o rejeita;
  - **use op** (`+/`): a igualdade precisa ter o operador;
  - **= fixo** (`=1`): o "=" tem que ficar num vão definido.
- Uma igualdade verdadeira que quebra a regra é recusada com o aviso "Verdadeira, mas fora da regra",
  e não custa vida.
- Cada placa tem o tempo do seu nível (45 a 75 s).
- O jogador tem **3 vidas**, e estourar o tempo ou pular custa uma delas. A placa perdida mostra uma solução que segue a regra.
- O **recorde** é o maior número de placas resolvidas antes de perder as 3 vidas.

### Descartado: Caça às soluções

O mockup tinha um terceiro desafio, "Caça às soluções" (uma placa, quantas igualdades diferentes
existem). Ele saiu por dois motivos:

- Com os unários, o total é infinito: −(−x), |x| e outros geram igualdades novas sem fim, então não
  dá para mostrar algo como "14 / 23".
- Só com os binários, quase não há o que caçar, porque a mediana das 150 placas é de **1** solução.

## Placa do dia e sequência de dias

- **Sem repetição:** a placa do dia sai das placas ★2 do catálogo (52 hoje), numa ordem embaralhada
  com semente fixa. Nenhuma placa se repete até o ciclo inteiro passar, e a ordem muda a cada ciclo
  sem repetir a placa na virada (`Daily.entryFor`).
- **Fuso local:** o dia vira à meia-noite do jogador, não à meia-noite UTC (21h no Brasil). Todo mundo
  joga a mesma placa na mesma data, e as estatísticas do dia (`dailyStats`) somam os jogadores pela data.
- **Uma sequência só:** a sequência conta os dias seguidos em que o jogador resolveu pelo menos uma
  placa, em qualquer modo (desafios e lições incluídos). Ver a solução não conta, e errar a placa do
  dia não zera a sequência. Ela aparece no topo da tela inicial, ao lado do cumprimento, com o ícone
  de fogo na cor de destaque do tema. Também aparece nas estatísticas do jogador e no texto
  compartilhado da placa do dia (`FirestoreRepository.recordPlayedDay`, `Daily.streakOn`).
- O antigo bônus de acertos seguidos, que soma até +50% nos pontos, passou a se chamar **combo**,
  para não ser confundido com a sequência de dias.

## Onde está no código

| Parte | Arquivo |
|---|---|
| Regras extras (`Restriction`, `OpRules`) | `lib/features/game/domain/rules.dart` |
| Solver com restrição (o operador obrigatório vira uma flag na DP, e o "=" fixo filtra o vão) | `lib/features/game/domain/solver.dart` |
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

- Criar conquistas novas, como "coluna completa" na Aventura e "10 placas" no Contra o relógio.
- Ampliar o catálogo. As placas novas entram no fim de cada nível, e o gerador calcula `t` e `r` para elas.
