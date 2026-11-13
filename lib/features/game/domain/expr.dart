library;

enum BinOp {
  add('+'),
  sub('−'),
  mul('×'),
  div('÷'),
  pow('^');

  const BinOp(this.symbol);

  final String symbol;

  String get label => this == BinOp.pow ? 'xʸ' : symbol;
}

enum UnOp {
  neg('−x', '−'),
  sqrt('√', '√'),
  cbrt('∛', '∛'),
  fact('!', '!'),
  abs('|x|', '|'),
  floor('⌊x⌋', '⌊'),
  ceil('⌈x⌉', '⌈');

  const UnOp(this.label, this.symbol);

  final String label;

  final String symbol;

  bool get isBracketing => this == UnOp.abs || this == UnOp.floor || this == UnOp.ceil;
}

sealed class Node {
  const Node(this.id, {this.parens = false});

  final int id;

  final bool parens;

  Node withParens(bool value);

  Map<String, dynamic> toJson();

  static Node fromJson(Map<String, dynamic> json) {
    final id = json['id'] as int;
    final parens = json['p'] as bool? ?? false;
    switch (json['t']) {
      case 'l':
        return Leaf(id, json['d'] as int, json['i'] as int, parens: parens);
      case 'b':
        return Binary(
          id,
          BinOp.values.byName(json['op'] as String),
          Node.fromJson((json['l'] as Map).cast<String, dynamic>()),
          Node.fromJson((json['r'] as Map).cast<String, dynamic>()),
          parens: parens,
        );
      case 'u':
        return Unary(
          id,
          UnOp.values.byName(json['op'] as String),
          Node.fromJson((json['c'] as Map).cast<String, dynamic>()),
          parens: parens,
        );
    }
    throw FormatException('Unknown node type ${json['t']}');
  }

  Iterable<Node> get descendants sync* {
    yield this;
    switch (this) {
      case Leaf():
        break;
      case Binary(:final left, :final right):
        yield* left.descendants;
        yield* right.descendants;
      case Unary(:final child):
        yield* child.descendants;
    }
  }

  int get firstIndex => switch (this) {
    Leaf(:final index) => index,
    Binary(:final left) => left.firstIndex,
    Unary(:final child) => child.firstIndex,
  };

  int get lastIndex => switch (this) {
    Leaf(:final index) => index,
    Binary(:final right) => right.lastIndex,
    Unary(:final child) => child.lastIndex,
  };

  (Node, Node) splitAt(int gap) {
    assert(firstIndex <= gap && gap < lastIndex, 'gap $gap outside $firstIndex..$lastIndex');
    switch (this) {
      case Leaf():
        throw StateError('a leaf has no gap to split');
      case Unary(:final child):
        return child.splitAt(gap);
      case Binary(:final op, :final left, :final right):
        final at = left.lastIndex;
        if (gap == at) return (left, right);
        if (gap < at) {
          final (a, b) = left.splitAt(gap);
          return (a, Binary(id, op, b, right, parens: parens));
        }
        final (a, b) = right.splitAt(gap);
        return (Binary(id, op, left, a, parens: parens), b);
    }
  }

  Node? find(int nodeId) {
    for (final n in descendants) {
      if (n.id == nodeId) return n;
    }
    return null;
  }

  Node replace(int nodeId, Node Function(Node) replace) {
    if (id == nodeId) return replace(this);
    return switch (this) {
      Leaf() => this,
      Binary(:final op, :final left, :final right) => _sameOrNew(
        left.replace(nodeId, replace),
        right.replace(nodeId, replace),
        (l, r) => Binary(id, op, l, r, parens: parens),
        left,
        right,
      ),
      Unary(:final op, :final child) => () {
        final c = child.replace(nodeId, replace);
        return identical(c, child) ? this : Unary(id, op, c, parens: parens);
      }(),
    };
  }

  Node _sameOrNew(Node l, Node r, Node Function(Node, Node) build, Node oldL, Node oldR) =>
      identical(l, oldL) && identical(r, oldR) ? this : build(l, r);
}

class Leaf extends Node {
  const Leaf(super.id, this.digit, this.index, {super.parens});

  final int digit;

  final int index;

  @override
  Leaf withParens(bool value) => Leaf(id, digit, index, parens: value);

  @override
  Map<String, dynamic> toJson() => {'t': 'l', 'id': id, 'd': digit, 'i': index, if (parens) 'p': true};
}

class Binary extends Node {
  const Binary(super.id, this.op, this.left, this.right, {super.parens});

  final BinOp op;
  final Node left;
  final Node right;

  @override
  Binary withParens(bool value) => Binary(id, op, left, right, parens: value);

  Binary withOp(BinOp value) => Binary(id, value, left, right, parens: parens);

  int get digitGap => left.lastIndex;

  @override
  Map<String, dynamic> toJson() => {
    't': 'b',
    'id': id,
    'op': op.name,
    'l': left.toJson(),
    'r': right.toJson(),
    if (parens) 'p': true,
  };
}

class Unary extends Node {
  const Unary(super.id, this.op, this.child, {super.parens});

  final UnOp op;
  final Node child;

  @override
  Unary withParens(bool value) => Unary(id, op, child, parens: value);

  @override
  Map<String, dynamic> toJson() => {'t': 'u', 'id': id, 'op': op.name, 'c': child.toJson(), if (parens) 'p': true};
}
