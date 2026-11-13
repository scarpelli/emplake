import 'package:emplake/features/game/domain/board.dart';
import 'package:emplake/features/game/domain/catalog.dart';
import 'package:emplake/features/game/domain/evaluator.dart';
import 'package:emplake/features/game/domain/expr.dart';
import 'package:emplake/features/game/domain/format.dart';
import 'package:emplake/features/game/domain/level.dart';
import 'package:emplake/features/game/domain/rules.dart';
import 'package:emplake/features/game/domain/solution_codec.dart';

const levelSlug = {
  Level.easy: 'facil',
  Level.intermediate: 'intermediario',
  Level.advanced: 'avancado',
  Level.hard: 'dificil',
};

const levelName = {
  Level.easy: 'Fácil',
  Level.intermediate: 'Intermediário',
  Level.advanced: 'Avançado',
  Level.hard: 'Difícil',
};

const _generatedNote =
    '<!-- Gerado por tool/gen_catalog_test.dart a partir de assets/catalog.json. Não edite à mão. -->';

String opLabel(Enum op) => switch (op) {
  BinOp() => op.label,
  UnOp() => op.label,
  _ => op.name,
};

String restrictionLabel(Restriction r) => switch (r.kind) {
  RestrictionKind.forbid => 'sem ${opLabel(r.op!)}',
  RestrictionKind.require => 'use ${opLabel(r.op!)}',
  RestrictionKind.equalsAt => '= depois do ${r.gap! + 1}º dígito',
};

String cell(String s) => s.replaceAll('|', r'\|');

String starsText(int s) => '${'★' * s}${'☆' * (3 - s)}';

List<Enum> opsUsed(Board board) {
  final found = <Enum>{
    for (final b in board.blocks)
      for (final n in b.descendants)
        if (n is Binary) n.op else if (n is Unary) n.op,
  };
  return [
    for (final op in BinOp.values)
      if (found.contains(op)) op,
    for (final op in UnOp.values)
      if (found.contains(op)) op,
  ];
}

int nodeCount(Board board) => board.blocks.fold(0, (a, b) => a + b.descendants.length);

String _sides(Board board, OpRules rules) {
  final r = Evaluator(rules).evaluateBoard(board);
  final v = r.values[board.blocks[0].id];
  return v == null ? '' : ' → cada lado vale **${v.display()}**';
}

Map<String, int> stageNumbers(Catalog catalog) {
  final out = <String, int>{};
  var i = 0;
  for (final e in catalog.all) {
    out[e.id] = ++i;
  }
  return out;
}

Map<String, String> renderCatalogDocs(Catalog catalog) {
  final stages = stageNumbers(catalog);
  final width = catalog.length.toString().length;
  String stage(CatalogEntry e) => stages[e.id]!.toString().padLeft(width, '0');

  final files = <String, String>{};

  final idx = StringBuffer()
    ..writeln(_generatedNote)
    ..writeln('# Catálogo de placas')
    ..writeln()
    ..writeln(
      'O jogo sorteia placas **só** deste catálogo (`assets/catalog.json`). Cada placa '
      'é um número de 4 dígitos, o nível em que ela é oferecida, a dificuldade e uma '
      'solução verificada pelo próprio `Evaluator` do jogo.',
    )
    ..writeln()
    ..writeln('| Nível | Placas | ★1 | ★2 | ★3 | Triviais (×0) | Com variante de restrição | Fases da Aventura |')
    ..writeln('|---|---|---|---|---|---|---|---|');
  for (final level in Level.values) {
    final list = catalog.entriesFor(level);
    int stars(int s) => list.where((e) => e.stars == s).length;
    final first = stage(list.first), last = stage(list.last);
    idx.writeln(
      '| [${levelName[level]}](${levelSlug[level]}.md) | ${list.length} | ${stars(1)} | ${stars(2)} | ${stars(3)} '
      '| ${list.where((e) => e.trivial).length} | ${list.where((e) => e.variants.isNotEmpty).length} | $first–$last |',
    );
  }
  final variants = catalog.all.fold(0, (a, e) => a + e.variants.length);
  idx
    ..writeln(
      '| **Total** | **${catalog.length}** | | | | **${catalog.all.where((e) => e.trivial).length}** '
      '| **${catalog.all.where((e) => e.variants.isNotEmpty).length}** ($variants variantes) | 1–${catalog.length} |',
    )
    ..writeln()
    ..writeln('Lições do modo Educacional: [licoes.md](licoes.md).')
    ..writeln()
    ..writeln('## Regras dos níveis')
    ..writeln()
    ..writeln('| Nível | Binários | Unários | Divisão não inteira | Tempo | Pontos base |')
    ..writeln('|---|---|---|---|---|---|');
  for (final level in Level.values) {
    idx.writeln(
      '| ${levelName[level]} | ${level.binary.map(opLabel).join(' ')} | ${cell(level.unary.map(opLabel).join(' '))} '
      '| ${level.allowsFractionalDivision ? 'aceita' : 'erro'} | ${level.seconds} s | ${level.basePoints} |',
    );
  }
  idx
    ..writeln()
    ..writeln(
      'No Emplake, "fácil" quer dizer **mais ferramentas**: o Fácil tem todos os operadores e o Difícil só os básicos.',
    )
    ..writeln()
    ..writeln('## Campos (formato v2)')
    ..writeln()
    ..writeln('| Campo | Significado |')
    ..writeln('|---|---|')
    ..writeln('| `n` | número da placa (4 dígitos, usados nessa ordem, sem concatenar) |')
    ..writeln('| `l` | nível: `easy`, `intermediate`, `advanced`, `hard` |')
    ..writeln(
      '| `s` | **dificuldade** 1–3 (★). ★1 operadores simples e muitos valores onde os lados se encontram; '
      '★2 poucos valores ou um unário; ★3 dois ou mais unários. Não confundir com as estrelas que o jogador ganha numa fase da Aventura. |',
    )
    ..writeln(
      '| `x` | solução em notação prefixa (`=(esquerda,direita)`). Binários `+ - * / ^`; '
      'unários `n` (−x), `s` (√), `c` (∛), `!`, `a` (\\|x\\|), `f` (⌊x⌋), `C` (⌈x⌉). |',
    )
    ..writeln(
      '| `t` | **trivial**: a placa tem 0 e a solução anula um lado com × 0 (ou 0 ÷ x, 0ʸ). '
      'Na Aventura vira aquecimento; fica fora do Contra o relógio; no Com restrição recebe "sem ×". |',
    )
    ..writeln(
      '| `r` | variantes do desafio **Com restrição**: `{r: regra, x: solução}`. Regras: `-op` (sem op), '
      '`+op` (use op), `=k` (= no vão k, 0 = depois do 1º dígito). Cada variante tem solução verificada '
      'sob a regra e **invalida** a solução `x` original. |',
    )
    ..writeln()
    ..writeln(
      'A ordem das entradas de cada nível no JSON é a **ordem da trilha da Aventura**. Placas novas entram no fim do nível.',
    )
    ..writeln()
    ..writeln('## Como regenerar')
    ..writeln()
    ..writeln('```')
    ..writeln('flutter test tool/gen_catalog_test.dart')
    ..writeln('```')
    ..writeln()
    ..writeln(
      'Lê as entradas atuais, recalcula `t` e `r`, verifica tudo com as regras do jogo e reescreve '
      '`assets/catalog.json` e estes arquivos. `test/catalog_test.dart` falha se os docs ficarem desatualizados.',
    );
  files['docs/catalogo/README.md'] = idx.toString();

  for (final level in Level.values) {
    final list = catalog.entriesFor(level);
    final b = StringBuffer()
      ..writeln(_generatedNote)
      ..writeln('# ${levelName[level]} — ${list.length} placas')
      ..writeln()
      ..writeln(
        'Operadores: ${level.binary.map(opLabel).join(' ')} · ${level.unary.map(opLabel).join(' ')} · '
        'divisão não inteira ${level.allowsFractionalDivision ? 'aceita' : 'dá erro'} · ${level.seconds} s · '
        '${level.basePoints} pontos base.',
      )
      ..writeln()
      ..writeln('[← catálogo](README.md)')
      ..writeln()
      ..writeln('| Fase | Placa | Dificuldade | Solução | Trivial | Restrições |')
      ..writeln('|---|---|---|---|---|---|');
    for (final e in list) {
      b.writeln(
        '| [${stage(e)}](#fase-${stage(e)}--${e.number}) | ${e.number} | ${starsText(e.stars)} | `${cell(linearText(e.board()))}` '
        '| ${e.trivial ? 'sim' : ''} | ${cell(e.variants.map((v) => restrictionLabel(v.rule)).join(' · '))} |',
      );
    }
    b.writeln();
    for (final e in list) {
      final board = e.board();
      b
        ..writeln('## Fase ${stage(e)} — ${e.number}')
        ..writeln()
        ..writeln('- **Dificuldade:** ${starsText(e.stars)} (${e.stars})')
        ..writeln('- **Solução:** `${linearText(board)}`${_sides(board, level)}')
        ..writeln('- **LaTeX:** `${latexOf(board)}`')
        ..writeln('- **Código:** `${e.solution}`')
        ..writeln(
          '- **Operadores:** ${opsUsed(board).map(opLabel).join(' ')} · ${nodeCount(board)} nós '
          '(6 = só dois binários além do =) · "=" depois do ${board.eqDigitGap! + 1}º dígito',
        )
        ..writeln(
          '- **Trivial (×0):** ${e.trivial ? 'sim' : 'não'} · **Placa do dia:** ${e.stars == 2 ? 'pode sair' : 'não'}',
        );
      if (e.variants.isEmpty) {
        b.writeln('- **Com restrição:** nenhuma variante verificada');
      } else {
        b.writeln('- **Com restrição:**');
        for (final v in e.variants) {
          final vb = SolutionCodec.decode(e.number, v.solution);
          b.writeln(
            '  - *${restrictionLabel(v.rule)}* (`${v.rule.encode()}`): `${linearText(vb)}`'
            '${_sides(vb, v.rule.rulesFor(level))} — código `${v.solution}`',
          );
        }
      }
      b.writeln();
    }
    files['docs/catalogo/${levelSlug[level]}.md'] = b.toString();
  }

  final l = StringBuffer()
    ..writeln(_generatedNote)
    ..writeln('# Lições do modo Educacional')
    ..writeln()
    ..writeln(
      'Uma lição por operador: um exemplo mostrado passo a passo e uma placa para o jogador tentar. '
      'Os números das lições não se repetem no catálogo de sorteio.',
    )
    ..writeln()
    ..writeln('[← catálogo](README.md)')
    ..writeln()
    ..writeln('| Operador | Exemplo | Solução do exemplo | Prática | Solução da prática |')
    ..writeln('|---|---|---|---|---|');
  for (final lesson in catalog.lessons) {
    final ex = lesson.example, pr = lesson.practice;
    l.writeln(
      '| ${cell(opLabel(lesson.op))} | ${ex.number} (${levelName[ex.level]}) | `${cell(linearText(ex.board()))}` '
      '| ${pr.number} (${levelName[pr.level]}) | `${cell(linearText(pr.board()))}` |',
    );
  }
  files['docs/catalogo/licoes.md'] = l.toString();
  return files;
}
