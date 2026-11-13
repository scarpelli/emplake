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
  String get plateCountry => 'BRAZIL';

  @override
  String get coverTagline =>
      'Use the four digits of the plate, in order, to build a true equation.';

  @override
  String get coverTap => 'TAP TO START';

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
  String get loginOr => 'OR';

  @override
  String get loginGoogle => 'Sign in with Google';

  @override
  String get loginGoogleError =>
      'Could not sign in with Google. Please try again.';

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
      'Play against the clock or with an extra rule on each plate, and try to beat your records.';

  @override
  String get modeAdventure => 'Adventure';

  @override
  String get modeAdventureDesc =>
      'Every plate in the game on one trail, from Easy to Hard. Each stage is worth up to 3 stars.';

  @override
  String get modeDaily => 'Plate of the day';

  @override
  String get modeDailyDesc =>
      'The same number for everyone today. One attempt; share your result.';

  @override
  String get dailyAlreadyPlayed =>
      'You already played today\'s plate. Come back tomorrow for a new one!';

  @override
  String get dailyCopy => 'COPY RESULT';

  @override
  String get blindShort => 'blind';

  @override
  String hintsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hints',
      one: '1 hint',
      zero: 'no hints',
    );
    return '$_temp0';
  }

  @override
  String streakShort(int count) {
    return '🔥 $count';
  }

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
  String levelBasePoints(int points) {
    return '$points base pts';
  }

  @override
  String get fourDigitNumber => '4-DIGIT NUMBER';

  @override
  String get typeFourDigits => 'Type the 4 digits.';

  @override
  String noSolutionOnLevel(String number, String level, String others) {
    return '$number has no solution on $level. Try: $others.';
  }

  @override
  String noSolutionAnyLevel(String number) {
    return '$number has no solution on any level. Pick another number.';
  }

  @override
  String get start => 'START';

  @override
  String levelProgress(int done, int total) {
    return '$done / $total solved';
  }

  @override
  String get practiceMode => 'Practice (no clock)';

  @override
  String get practiceModeHint =>
      'Play at your own pace. No points and it is not saved to your history.';

  @override
  String get practiceShort => 'practice';

  @override
  String get practiceTimer => 'no clock';

  @override
  String get practiceNoPoints => 'Practice: no points, at your own pace.';

  @override
  String pointsShort(int points) {
    return '$points pts';
  }

  @override
  String get treeGrowsHint => 'the tree grows upward\nas you link the numbers';

  @override
  String get hintStart =>
      'Tap between two numbers and pick an operator, or drag the sign onto the gap. The = goes in the same way, only once. Drag a sign to another gap to move it, or off the tree to remove it.';

  @override
  String get paletteBetween => 'BETWEEN NUMBERS';

  @override
  String get paletteOver => 'ON A SEGMENT';

  @override
  String get paletteTapGap => 'tap a gap or a sign';

  @override
  String get paletteTapNode => 'tap a number or branch';

  @override
  String get paletteGapSelected => 'gap selected';

  @override
  String paletteNodeSelected(String node) {
    return 'selected node: $node';
  }

  @override
  String paletteCarrying(String sign) {
    return 'carrying $sign: tap a gap';
  }

  @override
  String gapLabel(int n) {
    return 'gap $n';
  }

  @override
  String get removeOperator => 'Remove sign';

  @override
  String hintTitle(int n) {
    return 'HINT $n OF 3';
  }

  @override
  String hintEquals(int a, int b) {
    return 'The = goes between $a and $b.';
  }

  @override
  String hintLink(int a, int b, String op) {
    return 'Start by linking $a and $b with $op.';
  }

  @override
  String hintTooltip(int n) {
    return 'Hint $n (costs 1/3 of the points)';
  }

  @override
  String get hintTooltipReveal => 'Reveal the solution (no points)';

  @override
  String get hintRevealTitle => 'REVEAL THE SOLUTION?';

  @override
  String get hintRevealBody =>
      'This number ends with no points and goes back to the draw so you can try another day.';

  @override
  String secondsLeftA11y(int seconds) {
    return '$seconds seconds left';
  }

  @override
  String tutorialTapGap(int a, int b) {
    return 'Tap the gap between $a and $b (the dashed square).';
  }

  @override
  String get tutorialPickTimes =>
      'Now pick × to link them. You can also drag the sign onto the gap.';

  @override
  String get tutorialLinkThree =>
      'The tree grew! Link the result with 3: tap the next gap.';

  @override
  String get tutorialEqualsGap =>
      '1 × 2 × 3 is 6. Tap the last gap to place the =.';

  @override
  String get tutorialPickEquals => 'Pick =.';

  @override
  String get tutorialVerify => '6 = 6! Tap Check to confirm.';

  @override
  String get tutorialOffScript =>
      'Experimenting is fine! To follow the tutorial, use ↶ undo to go back a step.';

  @override
  String get tutorialSkip => 'SKIP TUTORIAL';

  @override
  String get liveValuesShow => 'Show live values';

  @override
  String get liveValuesHide => 'Hide live values';

  @override
  String get toggleParens => 'Parentheses';

  @override
  String get undo => 'Undo';

  @override
  String get skip => 'SKIP';

  @override
  String get skipTitle => 'SKIP THIS NUMBER?';

  @override
  String get skipBody =>
      'Do you want to see a solution? If you prefer, we reveal nothing: the number goes back to the draw so you can try another day.';

  @override
  String get skipYes => 'YES, SHOW ME';

  @override
  String get skipNo => 'NO, JUST SKIP';

  @override
  String get seeSolution => 'See a solution';

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
  String get allSolvedCatalog =>
      'You solved every number on this level for now! Try another level or type a number in Specific mode.';

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
  String get revealedTitle => 'ONE POSSIBLE SOLUTION';

  @override
  String revealedDetail(String number) {
    return 'No points this time. $number stays in the draw so you can try again.';
  }

  @override
  String get points => 'POINTS';

  @override
  String get total => 'TOTAL';

  @override
  String pointsBreakdown(int base, int bonus) {
    return '$base base + $bonus for time';
  }

  @override
  String get pointsLateZero => 'No points when out of time.';

  @override
  String get pointsReplayZero =>
      'You had already solved this number on this level, so it gives no points again.';

  @override
  String get howScoringWorks => 'How does it work?';

  @override
  String scoreHints(int count, int percent) {
    return 'hints ×$percent%';
  }

  @override
  String get scoreBlind => 'blind ×1.25';

  @override
  String scoreStreak(int count, int percent) {
    return 'streak $count: +$percent%';
  }

  @override
  String achievementUnlocked(String title) {
    return 'Achievement: $title';
  }

  @override
  String get achievementBanner => 'ACHIEVEMENT UNLOCKED';

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
  String get skippedEmpty =>
      'No skipped numbers. When you skip one, it shows up here so you can try again.';

  @override
  String skippedTimes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'skipped $count times',
      one: 'skipped once',
    );
    return '$_temp0';
  }

  @override
  String get skippedRevealed => 'solution seen';

  @override
  String get tryAgain => 'TRY';

  @override
  String achievementsTitle(int count, int total) {
    return 'ACHIEVEMENTS · $count/$total';
  }

  @override
  String get achievementUnlockedShort => 'unlocked';

  @override
  String get achievementLocked => 'locked';

  @override
  String get achFirstSolve => 'First plate';

  @override
  String get achFirstSolveDesc => 'Solve your first number.';

  @override
  String get achTenInTime => 'Beat the clock';

  @override
  String get achTenInTimeDesc => 'Solve 10 numbers in time.';

  @override
  String get achBlind => 'Blindfolded';

  @override
  String get achBlindDesc => 'Solve a number without live values.';

  @override
  String get achThreeStars => 'Tough nut';

  @override
  String get achThreeStarsDesc => 'Solve a ★3 number.';

  @override
  String get achAllLevels => 'Full ladder';

  @override
  String get achAllLevelsDesc => 'Solve a number on every level.';

  @override
  String get achStreak5 => 'On a roll';

  @override
  String get achStreak5Desc => 'Get 5 in a row, in time and without hints.';

  @override
  String get achDaily7 => 'Full week';

  @override
  String get achDaily7Desc => 'Solve the plate of the day 7 days in a row.';

  @override
  String get achHundred => 'Century';

  @override
  String get achHundredDesc => 'Solve 100 numbers.';

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
  String get settingsGame => 'GAME';

  @override
  String get settingsLiveValues => 'Live values';

  @override
  String get settingsLiveValuesHint =>
      'Shows the value of each branch and of each side of = while you build.';

  @override
  String get settingsHaptics => 'Vibration';

  @override
  String get settingsReduceMotion => 'Reduce motion';

  @override
  String get settingsReduceMotionHint =>
      'Turns off the tree, celebration and hint animations.';

  @override
  String get settingsHints => 'First-game tutorial';

  @override
  String get settingsHintsHint =>
      'Turn on to redo the walkthrough (1 × 2 × 3 = 6) in your next game.';

  @override
  String get seedColor => 'SEED COLOR';

  @override
  String get pickColor => 'Pick a color';

  @override
  String get fontSize => 'FONT SIZE';

  @override
  String get fontSample => 'Use the four digits in order.';

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
  String get settingsReset => 'RESTORE DEFAULTS';

  @override
  String get settingsResetTitle => 'Restore the default settings?';

  @override
  String get settingsResetBody =>
      'Theme, color, text size, game options, sound and language go back to the defaults. Your progress, points and records stay.';

  @override
  String get providerGoogle => 'Google';

  @override
  String get providerEmail => 'Email';

  @override
  String get player => 'Player';

  @override
  String get helpTitle => 'HOW TO PLAY';

  @override
  String get helpTabPlay => 'PLAY';

  @override
  String get helpTabOperators => 'OPERATORS';

  @override
  String get helpTabScoring => 'POINTS';

  @override
  String get helpExample => 'EXAMPLE';

  @override
  String get helpExampleCaption =>
      '1236 → 1 × 2 × 3 = 6. Each link adds a floor to the tree.';

  @override
  String get helpKeys => 'KEYBOARD';

  @override
  String get helpKeysList =>
      'Enter check · Esc skip · Tab selection · Ctrl+Z undo · ⌫ remove · H hint\n+ − * / ^ = ( ) operators · ! factorial · r √ · c ∛ · a |x| · n −x · f ⌊x⌋ · F ⌈x⌉';

  @override
  String get helpOperatorsIntro =>
      'Binary operators (+ − × ÷ xʸ) link two blocks at a gap. The others act on a segment: tap a number or branch and pick one.';

  @override
  String get opAdd => 'Addition';

  @override
  String get opSub => 'Subtraction';

  @override
  String get opMul => 'Multiplication';

  @override
  String get opDiv => 'Division';

  @override
  String get opPow => 'Power';

  @override
  String get opNeg => 'Negation (flips the sign)';

  @override
  String get opSqrt => 'Square root';

  @override
  String get opCbrt => 'Cube root';

  @override
  String get opFact => 'Factorial';

  @override
  String get opAbs => 'Absolute value';

  @override
  String get opFloor => 'Floor (rounds down)';

  @override
  String get opCeil => 'Ceiling (rounds up)';

  @override
  String get lessonsTitle => 'Learn the operators';

  @override
  String lessonsEyebrow(int done, int total) {
    return '$done OF $total LESSONS';
  }

  @override
  String get lessonsIntro =>
      'Each lesson shows a plate solved step by step with one operator. Then it is your turn, without the clock.';

  @override
  String get lessonDone => 'lesson done';

  @override
  String get lessonPrev => 'Previous step';

  @override
  String get lessonNext => 'Next step';

  @override
  String get lessonPlay => 'Play';

  @override
  String get lessonNowYou => 'NOW YOU';

  @override
  String get lessonNowYouHint =>
      'You play another plate that also uses this operator, with no clock and no points.';

  @override
  String lessonStepStart(String number) {
    return 'Plate $number: four digits, in order.';
  }

  @override
  String lessonStepLink(int a, int b, String op, String name) {
    return 'We link $a and $b with $op ($name).';
  }

  @override
  String lessonStepUnary(String op, String name) {
    return 'We apply $op ($name) to the segment.';
  }

  @override
  String lessonStepEquals(int a, int b) {
    return 'Finally, the = between $a and $b: both sides are worth the same.';
  }

  @override
  String get help1 =>
      'Use the four digits of the plate in the order they appear.';

  @override
  String get help2 =>
      'The = goes between two numbers, only once, and splits the two sides.';

  @override
  String get help3 =>
      'Tap a gap (or drag a sign onto it) to link two blocks with + − × ÷ xʸ. Tap a node to change its operator or apply √, !, |x| and others to that segment; ( ) groups the segment. Drag a sign or the = to another gap to move it; drag it off the tree, or use ⌫, to remove it.';

  @override
  String get help4 =>
      'Open LATEX ▾ next to the formula to see it typeset in LaTeX and copy the code. Check tests whether both sides are equal. Skip asks whether you want to see a solution; if not, the number comes back another day.';

  @override
  String get helpEasyOps => 'all, including ⌊x⌋ ⌈x⌉';

  @override
  String get helpFraction =>
      'Division with a non-integer result (like 5 ÷ 2) is only allowed on Easy.';

  @override
  String get helpScoringTitle => 'SCORING';

  @override
  String get helpScoringTime => 'TIME';

  @override
  String get helpScoringBaseCol => 'BASE';

  @override
  String get helpScoringBase =>
      'Each solved number is worth the level\'s base points.';

  @override
  String get helpScoringBonus =>
      'Time bonus: +1 point for every 5 seconds left on the clock when you check.';

  @override
  String helpScoringExample(int base, int seconds, int total) {
    return 'Example: on Intermediate ($base base), checking with ${seconds}s left gives $total points.';
  }

  @override
  String get helpScoringLate =>
      'If time runs out you can still finish and the number counts as solved, but it is worth 0 points.';

  @override
  String get helpScoringReplay =>
      'Replaying a number you already solved on the same level gives no points again.';

  @override
  String get helpScoringHints =>
      'Hints: the 1st shows where the = goes (you keep 2/3 of the points), the 2nd a first link (1/3), the 3rd reveals the solution (0 points; the number goes back to the draw).';

  @override
  String get helpScoringBlind =>
      'Blind: playing the whole number with live values off multiplies the points by 1.25.';

  @override
  String get helpScoringStreak =>
      'Streak: each answer in a row, in time and without hints, adds +10% (up to +50%). Skipping resets it.';

  @override
  String get helpScoringPractice => 'Practice and lessons give no points.';

  @override
  String helpScoringPause(int seconds) {
    return 'You get one ${seconds}s pause per number; while paused the clock stops and the tree is hidden.';
  }

  @override
  String get helpGotIt => 'GOT IT';

  @override
  String get homePage => 'Home page';

  @override
  String get adventureCurrent => 'current';

  @override
  String adventureStage(int number) {
    return 'Stage $number';
  }

  @override
  String adventureLockedColumn(int count) {
    return 'Opens after $count stages done on the previous level.';
  }

  @override
  String get adventureLockedStage =>
      'This stage opens once you finish the ones before it.';

  @override
  String get adventureStarsRule =>
      '★ when you solve it, ★★ in time and with no hints, ★★★ with at least half the time left';

  @override
  String adventureContinue(int number) {
    return 'CONTINUE STAGE $number';
  }

  @override
  String get adventureAllDone => 'You finished the whole trail!';

  @override
  String adventureStarsEarned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stars',
      one: '1 star',
      zero: 'No stars',
    );
    return '$_temp0';
  }

  @override
  String get adventureNext => 'NEXT STAGE';

  @override
  String get adventureTrail => 'TRAIL';

  @override
  String adventureStageA11y(int number, String plate, String state) {
    return 'Stage $number, plate $plate, $state';
  }

  @override
  String get adventureStateDone => 'done';

  @override
  String get adventureStateOpen => 'open';

  @override
  String get adventureStateLocked => 'locked';

  @override
  String get adventureOps => 'operators';

  @override
  String get challengeClockTitle => 'Against the clock';

  @override
  String get challengeClockTag => '3 MIN';

  @override
  String get challengeClockDesc =>
      'Solve as many plates as you can in 3 minutes. Skipping costs 10 seconds. Climbing a step gives +10 s.';

  @override
  String get challengeRestrictedTitle => 'With a restriction';

  @override
  String get challengeRestrictedTag => 'EXTRA RULE';

  @override
  String get challengeRestrictedDesc =>
      'Every plate comes with a rule: no +, fixed =, a required operator… You have 3 lives.';

  @override
  String get challengeLadder =>
      'Both challenges start on Easy and climb a step every 3 right answers, all the way to Hard. There are no hints and no pause.';

  @override
  String get challengeRecord => 'RECORD';

  @override
  String get challengeStreak => 'STREAK';

  @override
  String get challengePlays => 'RUNS';

  @override
  String get challengePlay => 'PLAY';

  @override
  String runPlates(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plates',
      one: '1 plate',
      zero: '0 plates',
    );
    return '$_temp0';
  }

  @override
  String runStep(int step) {
    return 'step $step';
  }

  @override
  String runLives(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lives',
      one: '1 life',
      zero: 'no lives',
    );
    return '$_temp0';
  }

  @override
  String runSkip(int seconds) {
    return 'SKIP −${seconds}s';
  }

  @override
  String get runSkipLife => 'SKIP −♥';

  @override
  String get ruleTitle => 'PLATE RULE';

  @override
  String ruleForbid(String op) {
    return 'On this plate, you may not use $op.';
  }

  @override
  String ruleRequire(String op) {
    return 'On this plate, the equation has to use $op.';
  }

  @override
  String ruleEqualsAt(int a, int b) {
    return 'On this plate, the = has to sit between $a and $b.';
  }

  @override
  String ruleShortForbid(String op) {
    return 'no $op';
  }

  @override
  String ruleShortRequire(String op) {
    return 'use $op';
  }

  @override
  String ruleShortEquals(int a, int b) {
    return '= between $a and $b';
  }

  @override
  String get ruleBroken => 'True, but it breaks the rule';

  @override
  String get runRight => 'RIGHT!';

  @override
  String get runRightDetail => 'The next plate shows up in a moment.';

  @override
  String runStepUp(int step, int seconds) {
    return 'You climbed to step $step and got ${seconds}s on the clock.';
  }

  @override
  String get runPlateLost => 'PLATE LOST';

  @override
  String get runPlateLostDetail =>
      'You lost a life. Here is a solution that follows the rule.';

  @override
  String get runOverClock => 'TIME IS UP';

  @override
  String get runOverLives => 'OUT OF LIVES';

  @override
  String runScoreClock(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plates solved',
      one: '1 plate solved',
      zero: 'No plates solved',
    );
    return '$_temp0';
  }

  @override
  String runScoreStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'A streak of $count plates',
      one: 'A streak of 1 plate',
      zero: 'No plates in a row',
    );
    return '$_temp0';
  }

  @override
  String get runNewRecord => 'NEW RECORD!';

  @override
  String runBest(int count) {
    return 'Record: $count';
  }

  @override
  String get runPlayAgain => 'PLAY AGAIN';

  @override
  String get runNextPlate => 'NEXT PLATE';

  @override
  String get runLastSolution => 'A solution to the last plate:';
}
