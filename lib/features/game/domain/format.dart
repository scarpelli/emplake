import 'board.dart';
import 'expr.dart';

class FormulaToken {
  const FormulaToken(this.text, [this.nodeId]);
  final String text;
  final int? nodeId;

  @override
  String toString() => text;
}

const _atom = 10;

int _linearPrec(Node n) {
  if (n.parens) return _atom;
  return switch (n) {
    Leaf() => _atom,
    Unary(:final op) => switch (op) {
      UnOp.abs || UnOp.floor || UnOp.ceil => _atom,
      UnOp.fact => 9,
      UnOp.sqrt || UnOp.cbrt => 8,
      UnOp.neg => 6,
    },
    Binary(:final op) => switch (op) {
      BinOp.pow => 7,
      BinOp.mul || BinOp.div => 5,
      BinOp.add || BinOp.sub => 4,
    },
  };
}

int _latexPrec(Node n) {
  if (n.parens) return _atom;
  return switch (n) {
    Unary(op: UnOp.sqrt || UnOp.cbrt) => _atom,
    Binary(op: BinOp.div) => 9,
    _ => _linearPrec(n),
  };
}

bool _isNeg(Node n) => !n.parens && n is Unary && n.op == UnOp.neg;

bool _isFact(Node n) => !n.parens && n is Unary && n.op == UnOp.fact;

bool _binaryChildNeedsParens(BinOp op, Node child, bool isRight, int Function(Node) prec) {
  final p = prec(child);
  if (isRight && _isNeg(child)) return true;
  switch (op) {
    case BinOp.add:
      return false;
    case BinOp.sub:
      return isRight && p <= 4;
    case BinOp.mul:
      return p < 5;
    case BinOp.div:
      return isRight ? p <= 5 : p < 5;
    case BinOp.pow:
      return isRight ? p < 7 : p < _atom;
  }
}

List<FormulaToken> linearTokens(Board board) {
  final out = <FormulaToken>[];
  for (var i = 0; i < board.blocks.length; i++) {
    if (i > 0) {
      out.add(i - 1 == board.eqGap ? const FormulaToken(' = ') : const FormulaToken('   '));
    }
    _linear(board.blocks[i], out);
  }
  return out;
}

String linearText(Board board) => linearTokens(board).join();

String linearNode(Node node) {
  final out = <FormulaToken>[];
  _linear(node, out);
  return out.join();
}

void _linear(Node n, List<FormulaToken> out) {
  if (n.parens) out.add(FormulaToken('(', n.id));
  switch (n) {
    case Leaf(:final digit):
      out.add(FormulaToken('$digit', n.id));
    case Binary(:final op, :final left, :final right):
      _wrapIf(_binaryChildNeedsParens(op, left, false, _linearPrec), left, out);
      out.add(FormulaToken(op == BinOp.pow ? '^' : ' ${op.symbol} ', n.id));
      _wrapIf(_binaryChildNeedsParens(op, right, true, _linearPrec), right, out);
    case Unary(:final op, :final child):
      switch (op) {
        case UnOp.neg:
          out.add(FormulaToken('−', n.id));
          _wrapIf(_linearPrec(child) <= 7 && !_isNeg(child), child, out);
        case UnOp.sqrt || UnOp.cbrt:
          out.add(FormulaToken(op.symbol, n.id));
          _wrapIf(_linearPrec(child) < _atom, child, out);
        case UnOp.fact:
          _wrapIf(_linearPrec(child) < _atom && !_isFact(child), child, out);
          out.add(FormulaToken('!', n.id));
        case UnOp.abs:
          out.add(FormulaToken('|', n.id));
          _linear(child, out);
          out.add(FormulaToken('|', n.id));
        case UnOp.floor:
          out.add(FormulaToken('⌊', n.id));
          _linear(child, out);
          out.add(FormulaToken('⌋', n.id));
        case UnOp.ceil:
          out.add(FormulaToken('⌈', n.id));
          _linear(child, out);
          out.add(FormulaToken('⌉', n.id));
      }
  }
  if (n.parens) out.add(FormulaToken(')', n.id));
}

void _wrapIf(bool wrap, Node child, List<FormulaToken> out) {
  if (wrap) out.add(const FormulaToken('('));
  _linear(child, out);
  if (wrap) out.add(const FormulaToken(')'));
}

String latexOf(Board board) {
  final b = StringBuffer();
  for (var i = 0; i < board.blocks.length; i++) {
    if (i > 0) b.write(i - 1 == board.eqGap ? ' = ' : ' \\quad ');
    b.write(latexNode(board.blocks[i]));
  }
  return b.toString();
}

String latexNode(Node n) {
  final inner = switch (n) {
    Leaf(:final digit) => '$digit',
    Binary(:final op, :final left, :final right) => _latexBinary(op, left, right),
    Unary(:final op, :final child) => switch (op) {
      UnOp.neg => '-${_lwrap(_latexPrec(child) <= 7 && !_isNeg(child), child)}',
      UnOp.sqrt => '\\sqrt{${latexNode(child)}}',
      UnOp.cbrt => '\\sqrt[3]{${latexNode(child)}}',
      UnOp.fact => '${_lwrap(_latexPrec(child) < _atom && !_isFact(child), child)}!',
      UnOp.abs => '\\left|${latexNode(child)}\\right|',
      UnOp.floor => '\\left\\lfloor ${latexNode(child)} \\right\\rfloor',
      UnOp.ceil => '\\left\\lceil ${latexNode(child)} \\right\\rceil',
    },
  };
  return n.parens ? '\\left($inner\\right)' : inner;
}

String _latexBinary(BinOp op, Node left, Node right) {
  if (op == BinOp.div) return '\\frac{${latexNode(left.withParens(false))}}{${latexNode(right.withParens(false))}}';
  if (op == BinOp.pow) {
    return '{${_lwrap(_latexPrec(left) < _atom, left)}}^{${latexNode(right.withParens(false))}}';
  }
  final l = _lwrap(_binaryChildNeedsParens(op, left, false, _latexPrec), left);
  final r = _lwrap(_binaryChildNeedsParens(op, right, true, _latexPrec), right);
  final sym = switch (op) {
    BinOp.add => '+',
    BinOp.sub => '-',
    _ => ' \\times ',
  };
  return '$l$sym$r';
}

String _lwrap(bool wrap, Node child) {
  final s = latexNode(child);
  return wrap ? '\\left($s\\right)' : s;
}
