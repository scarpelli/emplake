<!-- Gerado por tool/gen_catalog_test.dart a partir de assets/catalog.json. Não edite à mão. -->
# Catálogo de placas

O jogo sorteia placas **só** deste catálogo (`assets/catalog.json`). Cada entrada tem o número de 4 dígitos, o nível em que a placa é oferecida, a dificuldade e uma solução verificada pelo próprio `Evaluator` do jogo.

| Nível | Placas | ★1 | ★2 | ★3 | Triviais (×0) | Com variante de restrição | Fases da Aventura |
|---|---|---|---|---|---|---|---|
| [Fácil](facil.md) | 40 | 20 | 14 | 6 | 7 | 38 | 001–040 |
| [Intermediário](intermediario.md) | 40 | 20 | 14 | 6 | 4 | 40 | 041–080 |
| [Avançado](avancado.md) | 35 | 18 | 12 | 5 | 9 | 33 | 081–115 |
| [Difícil](dificil.md) | 35 | 18 | 12 | 5 | 9 | 27 | 116–150 |
| **Total** | **150** | | | | **29** | **138** (374 variantes) | 1–150 |

As lições do modo Educacional estão em [licoes.md](licoes.md).

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
| `s` | **dificuldade** de 1 a 3 (★). Uma placa ★1 usa operadores simples e tem muitos valores em que os dois lados se encontram; uma ★2 tem poucos desses valores ou usa um unário; uma ★3 usa dois ou mais unários. Essas estrelas são diferentes das que o jogador ganha numa fase da Aventura. |
| `x` | solução em notação prefixa (`=(esquerda,direita)`). Os binários são `+ - * / ^`, e os unários são `n` (−x), `s` (√), `c` (∛), `!`, `a` (\|x\|), `f` (⌊x⌋) e `C` (⌈x⌉). |
| `t` | **trivial**: a placa tem 0 e a solução anula um lado com × 0 (ou 0 ÷ x, 0ʸ). Na Aventura, a placa vira aquecimento; no Contra o relógio, fica de fora; e no Com restrição, recebe a regra "sem ×". |
| `r` | variantes do desafio **Com restrição**: `{r: regra, x: solução}`. As regras são `-op` (sem o operador), `+op` (use o operador) e `=k` (o = fica no vão k, e o vão 0 é o que vem depois do 1º dígito). Cada variante tem uma solução verificada sob a regra, e a regra **invalida** a solução `x` original. |

A ordem das entradas de cada nível no JSON é a **ordem da trilha da Aventura**, e as placas novas entram no fim do nível.

## Como regenerar

```
flutter test tool/gen_catalog_test.dart
```

O comando lê as entradas atuais, recalcula `t` e `r`, verifica tudo com as regras do jogo e reescreve o `assets/catalog.json` e estes arquivos. O `test/catalog_test.dart` falha se os docs ficarem desatualizados.
