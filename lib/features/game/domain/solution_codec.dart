import 'board.dart';
import 'expr.dart';

abstract final class SolutionCodec {
  static const _binary = {BinOp.add: '+', BinOp.sub: '-', BinOp.mul: '*', BinOp.div: '/', BinOp.pow: '^'};
  static const _unary = {
    UnOp.neg: 'n',
    UnOp.sqrt: 's',
    UnOp.cbrt: 'c',
    UnOp.fact: '!',
    UnOp.abs: 'a',
    UnOp.floor: 'f',
    UnOp.ceil: 'C',
  };

  static String letterOf(Enum op) => switch (op) {
    BinOp() => _binary[op]!,
    UnOp() => _unary[op]!,
    _ => throw ArgumentError.value(op, 'op'),
  };

  static Enum opOf(String letter) {
    for (final e in _binary.entries) {
      if (e.value == letter) return e.key;
    }
    for (final e in _unary.entries) {
      if (e.value == letter) return e.key;
    }
    throw FormatException('unknown operator', letter);
  }

  static String encodeNode(Node n) => switch (n) {
    Leaf(:final digit) => '$digit',
    Binary(:final op, :final left, :final right) => '${_binary[op]}(${encodeNode(left)},${encodeNode(right)})',
    Unary(:final op, :final child) => '${_unary[op]}(${encodeNode(child)})',
  };

  static String encode(Node left, Node right) => '=(${encodeNode(left)},${encodeNode(right)})';

  static String encodeBoard(Board board) {
    if (!board.isComplete) throw StateError('board is not complete');
    return encode(board.blocks[0], board.blocks[1]);
  }

  static Board decode(String number, String text) {
    final p = _Parser(text);
    p.expect('=');
    p.expect('(');
    final left = p.node();
    p.expect(',');
    final right = p.node();
    p.expect(')');
    if (!p.done) throw FormatException('trailing text', text, p.i);
    final digits = number.split('').map(int.parse).toList();
    if (p.leafDigits.join() != digits.join()) {
      throw FormatException('digits ${p.leafDigits.join()} do not match $number', text);
    }
    return Board.fromSides(digits, left, right, nextId: p.nextId);
  }
}

class _Parser {
  _Parser(this.s);

  final String s;
  int i = 0;
  int nextId = 0;
  final leafDigits = <int>[];

  bool get done => i == s.length;

  void expect(String ch) {
    if (i >= s.length || s[i] != ch) throw FormatException('expected "$ch"', s, i);
    i++;
  }

  Node node() {
    if (i >= s.length) throw FormatException('unexpected end', s, i);
    final ch = s[i];
    final digit = int.tryParse(ch);
    if (digit != null) {
      i++;
      final index = leafDigits.length;
      leafDigits.add(digit);
      return Leaf(nextId++, digit, index);
    }
    i++;
    final bin = SolutionCodec._binary.entries.where((e) => e.value == ch).firstOrNull?.key;
    if (bin != null) {
      expect('(');
      final l = node();
      expect(',');
      final r = node();
      expect(')');
      return Binary(nextId++, bin, l, r);
    }
    final un = SolutionCodec._unary.entries.where((e) => e.value == ch).firstOrNull?.key;
    if (un != null) {
      expect('(');
      final c = node();
      expect(')');
      return Unary(nextId++, un, c);
    }
    throw FormatException('unknown symbol "$ch"', s, i - 1);
  }
}
