import 'expr.dart';

class Board {
  const Board._(this.digits, this.blocks, this.eqGap, this.nextId);

  factory Board.start(String number) {
    assert(number.length == 4 && int.tryParse(number) != null);
    final digits = number.split('').map(int.parse).toList(growable: false);
    return Board._(digits, [for (var i = 0; i < digits.length; i++) Leaf(i, digits[i], i)], null, digits.length);
  }

  factory Board.fromSides(List<int> digits, Node left, Node right, {required int nextId}) =>
      Board._(List.unmodifiable(digits), List.unmodifiable([left, right]), 0, nextId);

  static const totalLinks = 3;

  final List<int> digits;
  final List<Node> blocks;
  final int? eqGap;
  final int nextId;

  String get number => digits.join();

  int get gapCount => blocks.length - 1;

  int get linksMade => (digits.length - blocks.length) + (eqGap == null ? 0 : 1);

  int get linksLeft => totalLinks - linksMade;

  bool get isComplete => blocks.length == 2 && eqGap == 0;

  Node? get left => isComplete ? blocks[0] : null;
  Node? get right => isComplete ? blocks[1] : null;

  bool canLink(int gap) => gap >= 0 && gap < gapCount && gap != eqGap;

  bool canPlaceEquals(int gap) => eqGap == null && gap >= 0 && gap < gapCount;

  Board link(int gap, BinOp op) {
    if (!canLink(gap)) throw StateError('gap $gap cannot be linked');
    final merged = Binary(nextId, op, blocks[gap], blocks[gap + 1]);
    final newBlocks = [...blocks]..replaceRange(gap, gap + 2, [merged]);
    final newEq = eqGap != null && eqGap! > gap ? eqGap! - 1 : eqGap;
    return Board._(digits, List.unmodifiable(newBlocks), newEq, nextId + 1);
  }

  Board placeEquals(int gap) {
    if (!canPlaceEquals(gap)) throw StateError('cannot place = at gap $gap');
    return Board._(digits, blocks, gap, nextId);
  }

  int digitGapOf(int blockGap) => blocks[blockGap].lastIndex;

  int? blockGapAt(int gap) {
    for (var i = 0; i < gapCount; i++) {
      if (digitGapOf(i) == gap) return i;
    }
    return null;
  }

  int? get eqDigitGap => eqGap == null ? null : digitGapOf(eqGap!);

  Binary? binaryAt(int gap) {
    for (final b in blocks) {
      for (final n in b.descendants) {
        if (n is Binary && n.digitGap == gap) return n;
      }
    }
    return null;
  }

  Board removeEquals() => eqGap == null ? this : Board._(digits, blocks, null, nextId);

  Board unlink(int nodeId) {
    final node = find(nodeId);
    if (node is! Binary) throw StateError('node $nodeId is not binary');
    final i = blockOf(nodeId);
    final (a, b) = blocks[i].splitAt(node.digitGap);
    final newBlocks = [...blocks]..replaceRange(i, i + 1, [a, b]);
    final newEq = eqGap != null && eqGap! >= i ? eqGap! + 1 : eqGap;
    return Board._(digits, List.unmodifiable(newBlocks), newEq, nextId);
  }

  Board clearGap(int gap) {
    if (eqDigitGap == gap) return removeEquals();
    final b = binaryAt(gap);
    return b == null ? this : unlink(b.id);
  }

  Board dropBinary(BinOp op, int gap) {
    final existing = binaryAt(gap);
    if (existing != null) return existing.op == op ? this : changeBinary(existing.id, op);
    final cleared = clearGap(gap);
    return cleared.link(cleared.blockGapAt(gap)!, op);
  }

  Board dropEquals(int gap) {
    if (eqDigitGap == gap) return this;
    final cleared = removeEquals().clearGap(gap);
    return cleared.placeEquals(cleared.blockGapAt(gap)!);
  }

  Board moveBinary(int nodeId, int gap) {
    final node = find(nodeId);
    if (node is! Binary) throw StateError('node $nodeId is not binary');
    final from = node.digitGap;
    if (from == gap) return this;
    final other = binaryAt(gap);
    if (other != null) {
      return changeBinary(nodeId, other.op).changeBinary(other.id, node.op);
    }
    final hadEquals = eqDigitGap == gap;
    var next = unlink(nodeId);
    if (hadEquals) {
      next = next.removeEquals();
      next = next.placeEquals(next.blockGapAt(from)!);
    }
    return next.link(next.blockGapAt(gap)!, node.op);
  }

  Board moveEquals(int gap) {
    final from = eqDigitGap;
    if (from == null || from == gap) return this;
    final other = binaryAt(gap);
    var next = removeEquals();
    if (other != null) next = next.unlink(other.id);
    next = next.placeEquals(next.blockGapAt(gap)!);
    if (other != null) next = next.link(next.blockGapAt(from)!, other.op);
    return next;
  }

  Node? find(int nodeId) {
    for (final b in blocks) {
      final n = b.find(nodeId);
      if (n != null) return n;
    }
    return null;
  }

  int blockOf(int nodeId) => blocks.indexWhere((b) => b.find(nodeId) != null);

  Board _replace(int nodeId, Node Function(Node) fn, {int idDelta = 0}) {
    final i = blockOf(nodeId);
    if (i < 0) throw StateError('node $nodeId not found');
    final newBlocks = [...blocks];
    newBlocks[i] = blocks[i].replace(nodeId, fn);
    return Board._(digits, List.unmodifiable(newBlocks), eqGap, nextId + idDelta);
  }

  Board applyUnary(int nodeId, UnOp op) => _replace(nodeId, (n) => Unary(nextId, op, n), idDelta: 1);

  Board unwrap(int nodeId) {
    final node = find(nodeId);
    if (node is! Unary) throw StateError('node $nodeId is not unary');
    return _replace(nodeId, (n) => (n as Unary).child);
  }

  Board changeBinary(int nodeId, BinOp op) => _replace(nodeId, (n) => (n as Binary).withOp(op));

  Board toggleParens(int nodeId) => _replace(nodeId, (n) => n.withParens(!n.parens));

  Map<String, dynamic> toJson() => {
    'digits': digits,
    'blocks': [for (final b in blocks) b.toJson()],
    if (eqGap != null) 'eq': eqGap,
    'next': nextId,
  };

  factory Board.fromJson(Map<String, dynamic> json) => Board._(
    (json['digits'] as List).cast<int>(),
    List.unmodifiable([for (final b in json['blocks'] as List) Node.fromJson((b as Map).cast<String, dynamic>())]),
    json['eq'] as int?,
    json['next'] as int,
  );
}
