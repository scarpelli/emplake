<!-- Gerado por tool/gen_catalog_test.dart a partir de assets/catalog.json. Não edite à mão. -->
# Catálogo de placas

O jogo sorteia placas **só** deste catálogo (`assets/catalog.json`). Cada placa é um número de 4 dígitos, o nível em que ela é oferecida, a dificuldade e uma solução verificada pelo próprio `Evaluator` do jogo.

| Nível | Placas | ★1 | ★2 | ★3 | Triviais (×0) | Com variante de restrição | Fases da Aventura |
|---|---|---|---|---|---|---|---|
| [Fácil](facil.md) | 40 | 20 | 14 | 6 | 7 | 38 | 001–040 |
| [Intermediário](intermediario.md) | 40 | 20 | 14 | 6 | 4 | 40 | 041–080 |
| [Avançado](avancado.md) | 35 | 18 | 12 | 5 | 9 | 33 | 081–115 |
| [Difícil](dificil.md) | 35 | 18 | 12 | 5 | 9 | 27 | 116–150 |
| **Total** | **150** | | | | **29** | **138** (374 variantes) | 1–150 |

Lições do modo Educacional: [licoes.md](licoes.md).

## Regras dos níveis

| Nível | Binários | Unários | Divisão não inteira | Tempo | Pontos base |
|---|---|---|---|---|---|
| Fácil | + − × ÷ xʸ | −x √ ∛ ! \|x\| ⌊x⌋ ⌈x⌉ | aceita | 45 s | 5 |
| Intermediário | + − × ÷ xʸ | −x √ ∛ ! \|x\| | erro | 45 s | 10 |
| Avançado | + − × ÷ | −x √ ! \|x\| | erro | 60 s | 15 |
| Difícil | + − × ÷ | −x \|x\| | erro | 75 s | 20 |

No Emplake, "fácil" quer dizer **mais ferramentas**: o Fácil tem todos os operadores e o Difícil só os básicos.

## Campos (formato v2)

| Campo | Significado |
|---|---|
| `n` | número da placa (4 dígitos, usados nessa ordem, sem concatenar) |
| `l` | nível: `easy`, `intermediate`, `advanced`, `hard` |
| `s` | **dificuldade** 1–3 (★). ★1 operadores simples e muitos valores onde os lados se encontram; ★2 poucos valores ou um unário; ★3 dois ou mais unários. Não confundir com as estrelas que o jogador ganha numa fase da Aventura. |
| `x` | solução em notação prefixa (`=(esquerda,direita)`). Binários `+ - * / ^`; unários `n` (−x), `s` (√), `c` (∛), `!`, `a` (\|x\|), `f` (⌊x⌋), `C` (⌈x⌉). |
| `t` | **trivial**: a placa tem 0 e a solução anula um lado com × 0 (ou 0 ÷ x, 0ʸ). Na Aventura vira aquecimento; fica fora do Contra o relógio; no Com restrição recebe "sem ×". |
| `r` | variantes do desafio **Com restrição**: `{r: regra, x: solução}`. Regras: `-op` (sem op), `+op` (use op), `=k` (= no vão k, 0 = depois do 1º dígito). Cada variante tem solução verificada sob a regra e **invalida** a solução `x` original. |

A ordem das entradas de cada nível no JSON é a **ordem da trilha da Aventura**. Placas novas entram no fim do nível.

## Como regenerar

```
flutter test tool/gen_catalog_test.dart
```

Lê as entradas atuais, recalcula `t` e `r`, verifica tudo com as regras do jogo e reescreve `assets/catalog.json` e estes arquivos. `test/catalog_test.dart` falha se os docs ficarem desatualizados.
