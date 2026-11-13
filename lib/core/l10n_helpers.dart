import 'package:flutter/widgets.dart';

import '../features/game/application/game_controller.dart';
import '../features/game/domain/evaluator.dart';
import '../features/game/domain/expr.dart';
import '../features/game/domain/level.dart';
import '../l10n/app_localizations.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  String get decimalSeparator => Localizations.localeOf(this).languageCode == 'en' ? '.' : ',';
}

extension LevelL10n on Level {
  String label(AppLocalizations l) => switch (this) {
    Level.easy => l.levelEasy,
    Level.intermediate => l.levelIntermediate,
    Level.advanced => l.levelAdvanced,
    Level.hard => l.levelHard,
  };

  String shortLabel(AppLocalizations l) => switch (this) {
    Level.easy => l.levelEasyShort,
    Level.intermediate => l.levelIntermediateShort,
    Level.advanced => l.levelAdvancedShort,
    Level.hard => l.levelHardShort,
  };

  String note(AppLocalizations l) => switch (this) {
    Level.easy => l.levelEasyNote,
    Level.intermediate => l.levelIntermediateNote,
    Level.advanced => l.levelAdvancedNote,
    Level.hard => l.levelHardNote,
  };
}

extension ModeL10n on GameMode {
  String label(AppLocalizations l) => switch (this) {
    GameMode.educational => l.modeEducational,
    GameMode.random => l.modeRandom,
    GameMode.specific => l.modeSpecific,
    GameMode.challenges => l.modeChallenges,
    GameMode.adventure => l.modeAdventure,
    GameMode.daily => l.modeDaily,
  };

  String description(AppLocalizations l) => switch (this) {
    GameMode.educational => l.modeEducationalDesc,
    GameMode.random => l.modeRandomDesc,
    GameMode.specific => l.modeSpecificDesc,
    GameMode.challenges => l.modeChallengesDesc,
    GameMode.adventure => l.modeAdventureDesc,
    GameMode.daily => l.modeDailyDesc,
  };

  bool get isAvailable => switch (this) {
    _ => true,
  };
}

(String, String) evalErrorText(EvalError e, Level level, AppLocalizations l, String sep) => switch (e.kind) {
  EvalErrorKind.divisionByZero => (l.errDivisionByZero, l.errDivisionByZeroBody),
  EvalErrorKind.nonIntegerDivision => (
    l.errNonIntegerDivision(
      e.left?.display(decimalSeparator: sep) ?? '?',
      e.right?.display(decimalSeparator: sep) ?? '?',
      e.result?.display(decimalSeparator: sep) ?? '?',
    ),
    l.errNonIntegerDivisionBody(level.label(l)),
  ),
  EvalErrorKind.factorialDomain => (l.errFactorialDomain, l.errFactorialDomainBody),
  EvalErrorKind.factorialTooLarge => (l.errFactorialTooLarge, l.errFactorialTooLargeBody),
  EvalErrorKind.evenRootOfNegative => (l.errEvenRoot, l.errEvenRootBody),
  EvalErrorKind.zeroToNegativePower => (l.errZeroNegPower, l.errZeroNegPowerBody),
  EvalErrorKind.complexPower => (l.errComplexPower, l.errComplexPowerBody),
  EvalErrorKind.tooLarge => (l.errTooLarge, l.errTooLargeBody),
  EvalErrorKind.operatorNotAllowed => (l.errNotAllowed, l.errNotAllowedBody),
};

extension BinOpL10n on BinOp {
  String name(AppLocalizations l) => switch (this) {
    BinOp.add => l.opAdd,
    BinOp.sub => l.opSub,
    BinOp.mul => l.opMul,
    BinOp.div => l.opDiv,
    BinOp.pow => l.opPow,
  };

  String example(String sep) => switch (this) {
    BinOp.add => '2 + 3 = 5',
    BinOp.sub => '7 − 4 = 3',
    BinOp.mul => '3 × 4 = 12',
    BinOp.div => '8 ÷ 2 = 4',
    BinOp.pow => '2³ = 8',
  };
}

extension UnOpL10n on UnOp {
  String name(AppLocalizations l) => switch (this) {
    UnOp.neg => l.opNeg,
    UnOp.sqrt => l.opSqrt,
    UnOp.cbrt => l.opCbrt,
    UnOp.fact => l.opFact,
    UnOp.abs => l.opAbs,
    UnOp.floor => l.opFloor,
    UnOp.ceil => l.opCeil,
  };

  String example(String sep) => switch (this) {
    UnOp.neg => '−(3) = −3',
    UnOp.sqrt => '√9 = 3',
    UnOp.cbrt => '∛8 = 2',
    UnOp.fact => '3! = 3 × 2 × 1 = 6',
    UnOp.abs => '|−2| = 2',
    UnOp.floor => '⌊2${sep}5⌋ = 2',
    UnOp.ceil => '⌈2${sep}5⌉ = 3',
  };
}
