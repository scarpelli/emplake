import 'package:flutter/widgets.dart';

import '../features/game/application/game_controller.dart';
import '../features/game/domain/evaluator.dart';
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
      };

  String description(AppLocalizations l) => switch (this) {
        GameMode.educational => l.modeEducationalDesc,
        GameMode.random => l.modeRandomDesc,
        GameMode.specific => l.modeSpecificDesc,
        GameMode.challenges => l.modeChallengesDesc,
        GameMode.adventure => l.modeAdventureDesc,
      };

  bool get isAvailable => this == GameMode.random || this == GameMode.specific;
}

(String, String) evalErrorText(EvalError e, Level level, AppLocalizations l, String sep) =>
    switch (e.kind) {
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
