// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Emplake';

  @override
  String get soundOn => 'Sound on';

  @override
  String get soundOff => 'Sound off';

  @override
  String get soundOffShort => 'sound off';

  @override
  String get navHome => 'Home';

  @override
  String get navHistory => 'Solved';

  @override
  String get navGame => 'Game';

  @override
  String get navHelp => 'Help';

  @override
  String get navSettings => 'Settings';

  @override
  String get notFound => 'Page not found.';

  @override
  String get back => 'Back';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get retry => 'Try again';

  @override
  String get coverSheet => 'SH. 00 · COVER';

  @override
  String get plateCountry => 'BRAZIL';

  @override
  String get coverTagline =>
      'Use the four digits of the plate, in order, to build a true equation.';

  @override
  String get coverTap => 'TAP TO START';

  @override
  String get coverProject => 'PROJECT';

  @override
  String get coverScale => 'SCALE';

  @override
  String get coverYear => 'YEAR';

  @override
  String get loginSubtitle => 'Sign in to save the numbers you solve.';

  @override
  String get loginTeam => 'TEAM';

  @override
  String loginMember(int n) {
    return 'MEMBER $n';
  }

  @override
  String get loginCredit => 'Game conceived by Prof. Walter A. Carnielli';

  @override
  String get language => 'Language';

  @override
  String greeting(String name, int points) {
    return 'HI, $name · $points PTS';
  }

  @override
  String stepOf(int step, int total) {
    return 'STEP $step OF $total';
  }

  @override
  String get modeQuestion => 'How do you want to play?';

  @override
  String get modeEducational => 'Educational';

  @override
  String get modeEducationalDesc =>
      'Step-by-step solved examples to learn the operators.';

  @override
  String get modeRandom => 'Random';

  @override
  String get modeRandomDesc =>
      'Numbers are drawn from the ones you have not solved yet.';

  @override
  String get modeSpecific => 'Specific';

  @override
  String get modeSpecificDesc =>
      'You type the 4-digit number you want to solve.';

  @override
  String get modeChallenges => 'Challenges';

  @override
  String get modeChallengesDesc =>
      'A set of challenges with different difficulties.';

  @override
  String get modeAdventure => 'Adventure';

  @override
  String get modeAdventureDesc =>
      'One plate per city, on a trip across Brazil.';

  @override
  String get comingSoon => 'COMING SOON';

  @override
  String get continueLabel => 'CONTINUE';

  @override
  String modeLabel(String mode) {
    return 'MODE: $mode';
  }

  @override
  String get chooseLevel => 'Choose the level';

  @override
  String get levelEasy => 'Easy';

  @override
  String get levelIntermediate => 'Intermediate';

  @override
  String get levelAdvanced => 'Advanced';

  @override
  String get levelHard => 'Hard';

  @override
  String get levelEasyShort => 'Easy';

  @override
  String get levelIntermediateShort => 'Interm.';

  @override
  String get levelAdvancedShort => 'Adv.';

  @override
  String get levelHardShort => 'Hard';

  @override
  String get levelEasyNote =>
      'The only level that accepts non-integer division (5 ÷ 2).';

  @override
  String get levelIntermediateNote => 'Divisions must give an integer result.';

  @override
  String get levelAdvancedNote => 'No cube root and no power.';

  @override
  String get levelHardNote => 'Only the four operations and absolute value.';

  @override
  String operatorCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count operators',
      one: '1 operator',
    );
    return '$_temp0';
  }

  @override
  String secondsPerNumber(int seconds) {
    return '${seconds}s per number';
  }

  @override
  String get fourDigitNumber => '4-DIGIT NUMBER';

  @override
  String get typeFourDigits => 'Type the 4 digits.';

  @override
  String get start => 'START';

  @override
  String pointsShort(int points) {
    return '$points pts';
  }

  @override
  String get treeGrowsHint => 'the tree grows upward\nas you link the numbers';

  @override
  String get hintStart =>
      'Tap between two numbers and pick an operator to link them. The = goes in the same way, only once.';

  @override
  String get paletteBetween => 'BETWEEN NUMBERS';

  @override
  String get paletteOver => 'ON A SEGMENT';

  @override
  String get paletteTapGap => 'tap a gap between numbers';

  @override
  String get paletteTapNode => 'tap a number or branch';

  @override
  String get paletteGapSelected => 'gap selected';

  @override
  String paletteNodeSelected(String node) {
    return 'selected node: $node';
  }

  @override
  String gapLabel(int n) {
    return 'gap $n';
  }

  @override
  String get removeOperator => 'Remove operator';

  @override
  String get toggleParens => 'Parentheses';

  @override
  String get undo => 'Undo';

  @override
  String get skip => 'SKIP';

  @override
  String get verify => 'CHECK';

  @override
  String linksLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count LINKS LEFT',
      one: '1 LINK LEFT',
    );
    return '$_temp0';
  }

  @override
  String get fixError => 'FIX THE ERROR';

  @override
  String get latex => 'LATEX';

  @override
  String get copy => 'Copy';

  @override
  String get copied => 'Copied!';

  @override
  String get pause => 'Pause';

  @override
  String get pausedTitle => 'PAUSED';

  @override
  String get pausedBody => 'The tree is hidden while paused.';

  @override
  String get resume => 'Resume';

  @override
  String get timeUp => 'time is up';

  @override
  String leftSide(String value) {
    return 'left $value';
  }

  @override
  String rightSide(String value) {
    return 'right $value';
  }

  @override
  String get equalityTrue => 'true equation';

  @override
  String get equalityFalse => 'false equation';

  @override
  String get loadingNumber => 'DRAWING A NUMBER…';

  @override
  String get allSolved => 'You have solved every number on this level!';

  @override
  String get alreadySolved =>
      'You already solved this number on this level. You can play again, but without points.';

  @override
  String get noGame => 'No game in progress.';

  @override
  String get newGame => 'NEW GAME';

  @override
  String get treeTitleDesktop => 'EXPRESSION TREE · click a node · Tab cycles';

  @override
  String get formula => 'FORMULA';

  @override
  String get infoNumber => 'NUMBER';

  @override
  String get infoDigits => 'DIGITS';

  @override
  String get infoMode => 'MODE';

  @override
  String get infoLevel => 'LEVEL';

  @override
  String get wrongTitle => 'FALSE EQUATION';

  @override
  String wrongBody(String left, String right) {
    return 'The left side is $left and the right side is $right. Adjust and try again.';
  }

  @override
  String get errDivisionByZero => 'DIVISION BY ZERO';

  @override
  String get errDivisionByZeroBody =>
      'You cannot divide by zero. Change the highlighted node.';

  @override
  String errNonIntegerDivision(String a, String b, String result) {
    return 'NON-INTEGER DIVISION: $a ÷ $b = $result';
  }

  @override
  String errNonIntegerDivisionBody(String level) {
    return 'On the $level level every division must give an integer. Change the highlighted node or the structure.';
  }

  @override
  String get errFactorialDomain => 'INVALID FACTORIAL';

  @override
  String get errFactorialDomainBody =>
      'Factorial only works for whole numbers from 0 up.';

  @override
  String get errFactorialTooLarge => 'FACTORIAL TOO LARGE';

  @override
  String get errFactorialTooLargeBody => 'Use factorial only up to 20!.';

  @override
  String get errEvenRoot => 'ROOT OF A NEGATIVE NUMBER';

  @override
  String get errEvenRootBody =>
      'The square root of a negative number is not a real number.';

  @override
  String get errZeroNegPower => 'ZERO TO A NEGATIVE POWER';

  @override
  String get errZeroNegPowerBody =>
      '0 raised to a negative exponent is undefined.';

  @override
  String get errComplexPower => 'NON-REAL POWER';

  @override
  String get errComplexPowerBody =>
      'A negative base with a non-integer exponent is not a real number.';

  @override
  String get errTooLarge => 'NUMBER TOO LARGE';

  @override
  String get errTooLargeBody =>
      'The result went past the limit. Try another structure.';

  @override
  String get errNotAllowed => 'OPERATOR NOT IN THIS LEVEL';

  @override
  String get errNotAllowedBody =>
      'This operator is not available on this level.';

  @override
  String get resultTrue => 'TRUE EQUATION';

  @override
  String resultTrueDetail(String value, int seconds) {
    return '$value = $value · solved in ${seconds}s';
  }

  @override
  String get resultLate => 'RIGHT, BUT OUT OF TIME';

  @override
  String resultLateDetail(String value) {
    return '$value = $value · time ran out before checking';
  }

  @override
  String get points => 'POINTS';

  @override
  String get total => 'TOTAL';

  @override
  String savedSolved(String number) {
    return '$number saved to your solved numbers';
  }

  @override
  String savedCounts(String number) {
    return '$number counts as solved';
  }

  @override
  String savedReplay(String number) {
    return '$number was already in your solved numbers';
  }

  @override
  String get saving => 'Saving…';

  @override
  String get saveError => 'Could not save. Check your connection.';

  @override
  String get menu => 'MENU';

  @override
  String get nextNumber => 'NEXT NUMBER';

  @override
  String get historyEyebrow => 'YOUR HISTORY';

  @override
  String get historyTitle => 'Solved';

  @override
  String get historyLoading => 'DRAWING YOUR HISTORY…';

  @override
  String get solvedCount => 'SOLVED';

  @override
  String get skippedCount => 'SKIPPED';

  @override
  String get filterAll => 'All';

  @override
  String get historyEmpty => 'No solved numbers here yet. Shall we start?';

  @override
  String get historyError => 'Could not load your history.';

  @override
  String get today => 'TODAY';

  @override
  String get yesterday => 'YESTERDAY';

  @override
  String get latexCopied => 'LaTeX copied';

  @override
  String get lateTag => 'OUT OF TIME';

  @override
  String get settingsEyebrow => 'PREFERENCES';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get theme => 'THEME';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeHint => 'Follows your device theme until you pick another.';

  @override
  String get presets => 'READY-MADE THEMES';

  @override
  String get presetBlueprint => 'Blueprint';

  @override
  String get presetGraphite => 'Graphite';

  @override
  String get presetSepia => 'Sepia';

  @override
  String get presetForest => 'Forest';

  @override
  String get seedColor => 'SEED COLOR';

  @override
  String get pickColor => 'Pick a color';

  @override
  String get fontSize => 'FONT SIZE';

  @override
  String get fontSample => 'Use the four digits in order.';

  @override
  String get fontFamily => 'FONT';

  @override
  String get sound => 'SOUND';

  @override
  String get soundEffects => 'Sound effects';

  @override
  String get music => 'Music';

  @override
  String get languageSection => 'LANGUAGE';

  @override
  String get account => 'ACCOUNT';

  @override
  String get signOut => 'Sign out';

  @override
  String get providerGoogle => 'Google';

  @override
  String get providerEmail => 'Email';

  @override
  String get player => 'Player';

  @override
  String get helpTitle => 'HOW TO PLAY';

  @override
  String get help1 =>
      'Use the four digits of the plate in the order they appear.';

  @override
  String get help2 =>
      'The = goes between two numbers, only once, and splits the two sides.';

  @override
  String get help3 =>
      'Tap a gap to link two blocks with + − × ÷ xʸ. Tap a node to change its operator or apply √, !, |x| and others to that segment; ( ) groups the segment.';

  @override
  String get help4 =>
      'Right below your formula you see the same formula in LaTeX. Check tests whether both sides are equal; Skip swaps to another unsolved number.';

  @override
  String get helpEasyOps => 'all, including ⌊x⌋ ⌈x⌉';

  @override
  String get helpFraction =>
      'Division with a non-integer result (like 5 ÷ 2) is only allowed on Easy.';

  @override
  String get helpGotIt => 'GOT IT';
}
