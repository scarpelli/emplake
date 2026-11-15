// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Emplake';

  @override
  String get soundOn => 'Sonido activado';

  @override
  String get soundOff => 'Sonido desactivado';

  @override
  String get soundOffShort => 'sonido apagado';

  @override
  String get navHome => 'Inicio';

  @override
  String get navHistory => 'Resueltos';

  @override
  String get navGame => 'Juego';

  @override
  String get navHelp => 'Ayuda';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get notFound => 'Página no encontrada.';

  @override
  String get back => 'Volver';

  @override
  String get cancel => 'Cancelar';

  @override
  String get ok => 'OK';

  @override
  String get retry => 'Reintentar';

  @override
  String get coverTagline =>
      'Usa los cuatro dígitos de la placa, en orden, para formar una igualdad verdadera.';

  @override
  String get coverTap => 'TOCA PARA EMPEZAR';

  @override
  String get loginSubtitle =>
      'Inicia sesión para guardar los números que resuelvas.';

  @override
  String get loginTeam => 'EQUIPO';

  @override
  String loginMember(int n) {
    return 'INTEGRANTE $n';
  }

  @override
  String get loginCredit => 'Juego concebido por el Prof. Walter A. Carnielli';

  @override
  String get language => 'Idioma';

  @override
  String get loginOr => 'O';

  @override
  String get loginGoogle => 'Entrar con Google';

  @override
  String get loginGoogleError =>
      'No se pudo entrar con Google. Inténtalo de nuevo.';

  @override
  String greeting(String name, int points) {
    return 'HOLA, $name · $points PTS';
  }

  @override
  String stepOf(int step, int total) {
    return 'PASO $step DE $total';
  }

  @override
  String get modeQuestion => '¿Cómo quieres jugar?';

  @override
  String get modeEducational => 'Educativo';

  @override
  String get modeEducationalDesc =>
      'Ejemplos resueltos paso a paso para aprender los operadores.';

  @override
  String get modeRandom => 'Aleatorio';

  @override
  String get modeRandomDesc =>
      'Los números se sortean entre los que aún no resolviste.';

  @override
  String get modeSpecific => 'Específico';

  @override
  String get modeSpecificDesc =>
      'Escribes el número de 4 dígitos que quieres resolver.';

  @override
  String get modeChallenges => 'Desafíos';

  @override
  String get modeChallengesDesc =>
      'Juega contra el reloj o con una regla extra en cada placa, e intenta superar tus récords.';

  @override
  String get modeAdventure => 'Aventura';

  @override
  String get modeAdventureDesc =>
      'Todas las placas del juego en una ruta, de Fácil a Difícil. Cada fase vale hasta 3 estrellas.';

  @override
  String get modeDaily => 'Placa del día';

  @override
  String get modeDailyDesc =>
      'Cada día sale un número nuevo, el mismo para todos, y puedes tomarte el tiempo que quieras.';

  @override
  String get dailyAlreadyPlayed =>
      'Ya jugaste la placa de hoy. ¡Vuelve mañana por una nueva!';

  @override
  String get dailyCopy => 'COPIAR RESULTADO';

  @override
  String dailyPlayedToday(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString personas ya jugaron hoy',
      one: '1 persona ya jugó hoy',
    );
    return '$_temp0';
  }

  @override
  String get dailyBeFirst => 'Nadie ha jugado todavía hoy';

  @override
  String dailyDoneIn(String time) {
    return 'Hecha en $time';
  }

  @override
  String dailyBetterThan(int percent) {
    return 'Mejor que el $percent% de los jugadores';
  }

  @override
  String get dailyFirstToday => 'Fuiste la primera persona en jugar hoy';

  @override
  String get dailyMissedTitle => 'Esta vez no salió';

  @override
  String get dailyComeBack => 'Mañana hay una placa nueva';

  @override
  String get dailyShare => 'COMPARTIR';

  @override
  String get dailyTimer => 'sin límite de tiempo en esta placa';

  @override
  String get dailyShareMissed => 'sin resolver';

  @override
  String get dailyYourSolution => 'TU SOLUCIÓN';

  @override
  String dailyStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días seguidos',
      one: '1 día seguido',
    );
    return '$_temp0';
  }

  @override
  String get blindShort => 'a ciegas';

  @override
  String hintsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pistas',
      one: '1 pista',
      zero: 'sin pistas',
    );
    return '$_temp0';
  }

  @override
  String streakShort(int count) {
    return '🔥 $count';
  }

  @override
  String get comingSoon => 'PRÓXIMAMENTE';

  @override
  String get continueLabel => 'CONTINUAR';

  @override
  String modeLabel(String mode) {
    return 'MODO: $mode';
  }

  @override
  String get chooseLevel => 'Elige el nivel';

  @override
  String get levelEasy => 'Fácil';

  @override
  String get levelIntermediate => 'Intermedio';

  @override
  String get levelAdvanced => 'Avanzado';

  @override
  String get levelHard => 'Difícil';

  @override
  String get levelEasyShort => 'Fácil';

  @override
  String get levelIntermediateShort => 'Interm.';

  @override
  String get levelAdvancedShort => 'Avanz.';

  @override
  String get levelHardShort => 'Difícil';

  @override
  String get levelEasyNote =>
      'Único nivel que acepta división no entera (5 ÷ 2).';

  @override
  String get levelIntermediateNote =>
      'Las divisiones deben dar un resultado entero.';

  @override
  String get levelAdvancedNote => 'Sin raíz cúbica ni potencia.';

  @override
  String get levelHardNote => 'Solo las cuatro operaciones y valor absoluto.';

  @override
  String operatorCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count operadores',
      one: '1 operador',
    );
    return '$_temp0';
  }

  @override
  String secondsPerNumber(int seconds) {
    return '${seconds}s por número';
  }

  @override
  String levelBasePoints(int points) {
    return '$points pts base';
  }

  @override
  String get fourDigitNumber => 'NÚMERO DE 4 DÍGITOS';

  @override
  String get typeFourDigits => 'Escribe los 4 dígitos.';

  @override
  String noSolutionOnLevel(String number, String level, String others) {
    return '$number no tiene solución en $level. Prueba en: $others.';
  }

  @override
  String noSolutionAnyLevel(String number) {
    return '$number no tiene solución en ningún nivel. Elige otro número.';
  }

  @override
  String get start => 'EMPEZAR';

  @override
  String levelProgress(int done, int total) {
    return '$done / $total resueltos';
  }

  @override
  String get practiceMode => 'Práctica (sin reloj)';

  @override
  String get practiceModeHint =>
      'Juega a tu ritmo. No suma puntos ni se guarda en tu historial.';

  @override
  String get practiceShort => 'práctica';

  @override
  String get practiceTimer => 'sin reloj';

  @override
  String pointsShort(int points) {
    return '$points pts';
  }

  @override
  String get treeGrowsHint =>
      'el árbol crece hacia arriba\na medida que unes los números';

  @override
  String get hintStart =>
      'Toca entre dos números y elige un operador, o arrastra el signo al hueco. El = entra igual, una sola vez. Arrastra un signo a otro hueco para moverlo, o fuera del árbol para quitarlo.';

  @override
  String get paletteBetween => 'ENTRE NÚMEROS';

  @override
  String get paletteOver => 'SOBRE UN TRAMO';

  @override
  String get paletteTapGap => 'toca un hueco o un signo';

  @override
  String get paletteTapNode => 'toca un número o rama';

  @override
  String get paletteGapSelected => 'hueco seleccionado';

  @override
  String paletteNodeSelected(String node) {
    return 'nodo seleccionado: $node';
  }

  @override
  String paletteCarryingOver(String sign) {
    return 'llevando $sign: toca un número o rama';
  }

  @override
  String get dropOverOnGap =>
      'Este signo va sobre un número o una rama, y no entre dos números.';

  @override
  String get dropBetweenOnNode =>
      'Este signo va entre dos números, en uno de los huecos punteados.';

  @override
  String paletteCarrying(String sign) {
    return 'llevando $sign: toca un hueco';
  }

  @override
  String gapLabel(int n) {
    return 'hueco $n';
  }

  @override
  String get removeOperator => 'Quitar signo';

  @override
  String hintTitle(int n) {
    return 'PISTA $n DE 3';
  }

  @override
  String hintEquals(int a, int b) {
    return 'El = va entre $a y $b.';
  }

  @override
  String hintLink(int a, int b, String op) {
    return 'Empieza uniendo $a y $b con $op.';
  }

  @override
  String hintTooltip(int n) {
    return 'Pista $n (cuesta 1/3 de los puntos)';
  }

  @override
  String get hintTooltipReveal => 'Revelar la solución (sin puntos)';

  @override
  String get hintRevealTitle => '¿REVELAR LA SOLUCIÓN?';

  @override
  String get hintRevealBody =>
      'Este número termina sin puntos y vuelve al sorteo para que lo intentes otro día.';

  @override
  String secondsLeftA11y(int seconds) {
    return 'quedan $seconds segundos';
  }

  @override
  String tutorialTapGap(int a, int b) {
    return 'Toca el hueco entre $a y $b (el cuadrito punteado).';
  }

  @override
  String get tutorialPickTimes =>
      'Ahora elige × para unirlos. También puedes arrastrar el signo al hueco.';

  @override
  String get tutorialLinkThree =>
      '¡El árbol creció! Une el resultado con el 3: toca el siguiente hueco.';

  @override
  String get tutorialEqualsGap =>
      '1 × 2 × 3 vale 6. Toca el último hueco para poner el =.';

  @override
  String get tutorialPickEquals => 'Elige =.';

  @override
  String get tutorialVerify => '¡6 = 6! Toca Verificar para comprobar.';

  @override
  String get tutorialOffScript =>
      '¡Está bien experimentar! Para seguir el tutorial, usa ↶ deshacer para volver al paso anterior.';

  @override
  String get tutorialSkip => 'SALTAR TUTORIAL';

  @override
  String get liveValuesShow => 'Mostrar valores en tiempo real';

  @override
  String get liveValuesHide => 'Ocultar valores en tiempo real';

  @override
  String get toggleParens => 'Paréntesis';

  @override
  String get undo => 'Deshacer';

  @override
  String get skip => 'SALTAR';

  @override
  String get skipTitle => '¿SALTAR ESTE NÚMERO?';

  @override
  String get skipBody =>
      '¿Quieres ver una solución? Si prefieres, no revelamos nada: el número vuelve al sorteo para que lo intentes otro día.';

  @override
  String get skipBodyAdventure =>
      '¿Quieres ver una solución? Si prefieres, no revelamos nada: la fase sigue abierta en el camino para que la intentes después.';

  @override
  String get skipBodyDaily =>
      '¿Quieres ver una solución? Al saltar termina el intento de hoy; mañana hay otra placa.';

  @override
  String get skipBodyRetry =>
      '¿Quieres ver una solución? Si prefieres, no revelamos nada y puedes intentarlo de nuevo cuando quieras.';

  @override
  String get close => 'Cerrar';

  @override
  String get skipYes => 'SÍ, MOSTRAR';

  @override
  String get skipNo => 'NO, SALTAR';

  @override
  String get seeSolution => 'Ver una solución';

  @override
  String get seeSolutionShort => 'SOLUCIÓN';

  @override
  String get verify => 'VERIFICAR';

  @override
  String linksLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'FALTAN $count UNIONES',
      one: 'FALTA 1 UNIÓN',
    );
    return '$_temp0';
  }

  @override
  String get fixError => 'CORRIGE EL ERROR';

  @override
  String get latex => 'LATEX';

  @override
  String get copy => 'Copiar';

  @override
  String get copied => '¡Copiado!';

  @override
  String get pause => 'Pausar';

  @override
  String get pausedTitle => 'EN PAUSA';

  @override
  String get pausedBody => 'El árbol queda oculto durante la pausa.';

  @override
  String get resume => 'Continuar';

  @override
  String get timeUp => 'se acabó el tiempo';

  @override
  String leftSide(String value) {
    return 'izquierda $value';
  }

  @override
  String rightSide(String value) {
    return 'derecha $value';
  }

  @override
  String get equalityTrue => 'igualdad verdadera';

  @override
  String get equalityFalse => 'igualdad falsa';

  @override
  String get loadingNumber => 'SORTEANDO UN NÚMERO…';

  @override
  String get allSolved => '¡Ya resolviste todos los números de este nivel!';

  @override
  String get allSolvedCatalog =>
      '¡Resolviste todos los números de este nivel por ahora! Prueba otro nivel o escribe un número en el modo Específico.';

  @override
  String get alreadySolved =>
      'Ya resolviste este número en este nivel. Puedes jugar de nuevo, pero sin puntos.';

  @override
  String get noGame => 'No hay ninguna partida en curso.';

  @override
  String get newGame => 'NUEVA PARTIDA';

  @override
  String get treeTitleDesktop =>
      'ÁRBOL DE LA EXPRESIÓN · haz clic en un nodo · Tab alterna';

  @override
  String get formula => 'FÓRMULA';

  @override
  String get infoNumber => 'NÚMERO';

  @override
  String get infoDigits => 'DÍGITOS';

  @override
  String get infoMode => 'MODO';

  @override
  String get infoLevel => 'NIVEL';

  @override
  String get wrongTitle => 'IGUALDAD FALSA';

  @override
  String wrongBody(String left, String right) {
    return 'El lado izquierdo vale $left y el derecho vale $right. Ajusta e inténtalo de nuevo.';
  }

  @override
  String get errDivisionByZero => 'DIVISIÓN POR CERO';

  @override
  String get errDivisionByZeroBody =>
      'No se puede dividir por cero. Cambia el nodo resaltado.';

  @override
  String errNonIntegerDivision(String a, String b, String result) {
    return 'DIVISIÓN NO ENTERA: $a ÷ $b = $result';
  }

  @override
  String errNonIntegerDivisionBody(String level) {
    return 'En el nivel $level, toda división debe dar un entero. Cambia el nodo resaltado o la estructura.';
  }

  @override
  String get errFactorialDomain => 'FACTORIAL NO VÁLIDO';

  @override
  String get errFactorialDomainBody =>
      'El factorial solo vale para enteros desde 0.';

  @override
  String get errFactorialTooLarge => 'FACTORIAL DEMASIADO GRANDE';

  @override
  String get errFactorialTooLargeBody => 'Usa el factorial solo hasta 20!.';

  @override
  String get errEvenRoot => 'RAÍZ DE UN NÚMERO NEGATIVO';

  @override
  String get errEvenRootBody =>
      'La raíz cuadrada de un número negativo no es real.';

  @override
  String get errZeroNegPower => 'CERO ELEVADO A NEGATIVO';

  @override
  String get errZeroNegPowerBody =>
      '0 elevado a un exponente negativo no está definido.';

  @override
  String get errComplexPower => 'POTENCIA NO REAL';

  @override
  String get errComplexPowerBody =>
      'Una base negativa con exponente no entero no da un número real.';

  @override
  String get errTooLarge => 'NÚMERO DEMASIADO GRANDE';

  @override
  String get errTooLargeBody =>
      'El resultado superó el límite. Prueba otra estructura.';

  @override
  String get errNotAllowed => 'OPERADOR FUERA DEL NIVEL';

  @override
  String get errNotAllowedBody =>
      'Este operador no está disponible en este nivel.';

  @override
  String get resultTrue => 'IGUALDAD VERDADERA';

  @override
  String resultTrueDetail(String value, int seconds) {
    return '$value = $value · resuelto en ${seconds}s';
  }

  @override
  String get resultLate => 'CORRECTO, PERO FUERA DE TIEMPO';

  @override
  String resultLateDetail(String value) {
    return '$value = $value · el tiempo se acabó antes de verificar';
  }

  @override
  String get revealedTitle => 'UNA SOLUCIÓN POSIBLE';

  @override
  String revealedDetail(String number) {
    return 'Sin puntos esta vez. $number sigue en el sorteo para que lo intentes de nuevo.';
  }

  @override
  String get revealedDetailAdventure =>
      'Sin estrellas esta vez. La fase sigue abierta en el camino para que la intentes de nuevo.';

  @override
  String get revealedDetailDaily =>
      'Sin puntos esta vez. Mañana hay otra placa.';

  @override
  String get revealedDetailRetry =>
      'Sin puntos esta vez. Puedes intentarlo de nuevo cuando quieras.';

  @override
  String get points => 'PUNTOS';

  @override
  String get total => 'TOTAL';

  @override
  String achievementUnlocked(String title) {
    return 'Logro: $title';
  }

  @override
  String get achievementBanner => 'LOGRO DESBLOQUEADO';

  @override
  String savedReplay(String number) {
    return '$number ya estaba en tus resueltos';
  }

  @override
  String get saving => 'Guardando…';

  @override
  String get saveError => 'No se pudo guardar. Revisa tu conexión.';

  @override
  String get menu => 'MENÚ';

  @override
  String get nextNumber => 'SIGUIENTE NÚMERO';

  @override
  String get historyEyebrow => 'TU HISTORIAL';

  @override
  String get historyTitle => 'Resueltos';

  @override
  String get historyLoading => 'TRAZANDO TU HISTORIAL…';

  @override
  String get solvedCount => 'RESUELTOS';

  @override
  String get skippedCount => 'SALTADOS';

  @override
  String get filterAll => 'Todos';

  @override
  String get historyEmpty => 'Aún no hay números resueltos aquí. ¿Empezamos?';

  @override
  String get historyError => 'No se pudo cargar tu historial.';

  @override
  String get today => 'HOY';

  @override
  String get yesterday => 'AYER';

  @override
  String get latexCopied => 'LaTeX copiado';

  @override
  String get lateTag => 'FUERA DE TIEMPO';

  @override
  String get skippedEmpty =>
      'Ningún número saltado. Cuando saltes uno, aparecerá aquí para que lo intentes de nuevo.';

  @override
  String skippedTimes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'saltado $count veces',
      one: 'saltado 1 vez',
    );
    return '$_temp0';
  }

  @override
  String get skippedRevealed => 'solución vista';

  @override
  String get tryAgain => 'INTENTAR';

  @override
  String achievementsTitle(int count, int total) {
    return 'LOGROS · $count/$total';
  }

  @override
  String get achievementUnlockedShort => 'desbloqueado';

  @override
  String get achievementLocked => 'bloqueado';

  @override
  String get achFirstSolve => 'Primera placa';

  @override
  String get achFirstSolveDesc => 'Resuelve tu primer número.';

  @override
  String get achTenInTime => 'Contra el reloj';

  @override
  String get achTenInTimeDesc => 'Resuelve 10 números a tiempo.';

  @override
  String get achBlind => 'A ciegas';

  @override
  String get achBlindDesc =>
      'Resuelve un número sin los valores en tiempo real.';

  @override
  String get achThreeStars => 'Hueso duro';

  @override
  String get achThreeStarsDesc => 'Resuelve un número ★3.';

  @override
  String get achAllLevels => 'Escalera completa';

  @override
  String get achAllLevelsDesc => 'Resuelve un número en cada nivel.';

  @override
  String get achStreak5 => 'En racha';

  @override
  String get achStreak5Desc => 'Acierta 5 seguidos, a tiempo y sin pistas.';

  @override
  String get achDaily7 => 'Semana completa';

  @override
  String get achDaily7Desc => 'Resuelve una placa al día, 7 días seguidos.';

  @override
  String get achHundred => 'Centena';

  @override
  String get achHundredDesc => 'Resuelve 100 números.';

  @override
  String get settingsEyebrow => 'PREFERENCIAS';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get theme => 'TEMA';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeHint =>
      'Sigue el tema del dispositivo hasta que elijas otro.';

  @override
  String get settingsGame => 'JUEGO';

  @override
  String get settingsLiveValues => 'Valores en tiempo real';

  @override
  String get settingsLiveValuesHint =>
      'Muestra cuánto vale cada rama y cada lado del = mientras armas.';

  @override
  String get settingsHaptics => 'Vibración';

  @override
  String get settingsReduceMotion => 'Reducir animaciones';

  @override
  String get settingsReduceMotionHint =>
      'Desactiva las animaciones del árbol, la celebración y las pistas.';

  @override
  String get settingsHints => 'Tutorial de la primera partida';

  @override
  String get settingsHintsHint =>
      'Actívalo para repetir el paso a paso (1 × 2 × 3 = 6) en tu próxima partida.';

  @override
  String get seedColor => 'COLOR SEMILLA';

  @override
  String get pickColor => 'Elegir color';

  @override
  String get fontFamily => 'TIPO DE LETRA';

  @override
  String get fontSize => 'TAMAÑO DE FUENTE';

  @override
  String get fontSample => 'Usa los cuatro dígitos en orden.';

  @override
  String get sound => 'SONIDO';

  @override
  String get soundEffects => 'Efectos de sonido';

  @override
  String get music => 'Música';

  @override
  String get languageSection => 'IDIOMA';

  @override
  String get account => 'CUENTA';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get settingsReset => 'RESTAURAR VALORES PREDETERMINADOS';

  @override
  String get settingsResetTitle => '¿Restaurar los ajustes predeterminados?';

  @override
  String get settingsResetBody =>
      'El tema, el color, el tamaño del texto, las opciones de juego, el sonido y el idioma vuelven a los predeterminados. Tu progreso, puntos y récords no cambian.';

  @override
  String get providerGoogle => 'Google';

  @override
  String get providerEmail => 'Correo';

  @override
  String get player => 'Jugador';

  @override
  String get settingsGroupPlayer => 'Jugador';

  @override
  String get settingsGroupAppearance => 'Apariencia';

  @override
  String get settingsGroupGame => 'Juego';

  @override
  String get statDayStreak => 'DÍAS SEGUIDOS';

  @override
  String get avatarCreate => 'Crear mi avatar';

  @override
  String get avatarYours => 'Tu avatar';

  @override
  String get openProfile => 'Abrir tu perfil';

  @override
  String get avatarTitle => 'Tu robot';

  @override
  String get avatarPreview => 'Vista previa de tu robot';

  @override
  String get avatarShuffle => 'SORTEAR';

  @override
  String get avatarSave => 'GUARDAR AVATAR';

  @override
  String get avatarSaved => 'GUARDADO';

  @override
  String get avatarSaveError =>
      'No pudimos guardar tu avatar ahora. Inténtalo de nuevo en un rato.';

  @override
  String get avatarGroupHead => 'CABEZA';

  @override
  String get avatarGroupTop => 'PARTE DE ARRIBA';

  @override
  String get avatarGroupEyes => 'OJOS';

  @override
  String get avatarGroupMouth => 'BOCA';

  @override
  String get avatarGroupSide => 'LATERALES';

  @override
  String get avatarGroupAcc => 'ACCESORIOS';

  @override
  String avatarHead(String v) {
    String _temp0 = intl.Intl.selectLogic(v, {
      'rounded': 'redondeada',
      'square': 'cuadrada',
      'capsule': 'cápsula',
      'round': 'redonda',
      'octagon': 'octágono',
      'other': '–',
    });
    return '$_temp0';
  }

  @override
  String avatarTop(String v) {
    String _temp0 = intl.Intl.selectLogic(v, {
      'none': 'nada',
      'antenna': 'antena',
      'twoAntennas': 'dos antenas',
      'spring': 'resorte',
      'heart': 'corazón',
      'propeller': 'hélice',
      'dome': 'cúpula',
      'crown': 'corona',
      'other': '–',
    });
    return '$_temp0';
  }

  @override
  String avatarEyes(String v) {
    String _temp0 = intl.Intl.selectLogic(v, {
      'round': 'redondos',
      'lashes': 'pestañas',
      'hearts': 'corazones',
      'wink': 'guiñando',
      'sleepy': 'dormilones',
      'glasses': 'gafas',
      'visor': 'visor',
      'cyclops': 'cíclope',
      'other': '–',
    });
    return '$_temp0';
  }

  @override
  String avatarMouth(String v) {
    String _temp0 = intl.Intl.selectLogic(v, {
      'smile': 'sonrisa',
      'teeth': 'dientitos',
      'open': 'abierta',
      'wave': 'ondulada',
      'grille': 'rejilla',
      'line': 'recta',
      'other': '–',
    });
    return '$_temp0';
  }

  @override
  String avatarSide(String v) {
    String _temp0 = intl.Intl.selectLogic(v, {
      'none': 'nada',
      'bolts': 'tornillos',
      'headphones': 'auriculares',
      'gears': 'engranajes',
      'rods': 'varillas',
      'other': '–',
    });
    return '$_temp0';
  }

  @override
  String avatarAcc(String v) {
    String _temp0 = intl.Intl.selectLogic(v, {
      'none': 'nada',
      'cheeks': 'mejillas',
      'bowTie': 'pajarita',
      'tie': 'corbata',
      'medal': 'medalla',
      'other': '–',
    });
    return '$_temp0';
  }

  @override
  String get helpTitle => 'CÓMO JUGAR';

  @override
  String get helpPageTitle => 'Cómo jugar';

  @override
  String get helpTabPlay => 'JUGAR';

  @override
  String get helpTabOperators => 'OPERADORES';

  @override
  String get helpTabScoring => 'PUNTOS';

  @override
  String get helpExample => 'EJEMPLO';

  @override
  String get helpExampleCaption =>
      '1236 → 1 × 2 × 3 = 6. Cada unión sube un piso en el árbol.';

  @override
  String get helpKeys => 'TECLADO';

  @override
  String get helpKeysList =>
      'Enter verificar · Esc saltar · Tab selección · Ctrl+Z deshacer · ⌫ quitar · H pista\n+ − * / ^ = ( ) operadores · ! factorial · r √ · c ∛ · a |x| · n −x · f ⌊x⌋ · F ⌈x⌉';

  @override
  String get helpOperatorsIntro =>
      'Los binarios (+ − × ÷ xʸ) unen dos bloques en un hueco. Los demás actúan sobre un tramo: toca un número o rama y elige.';

  @override
  String get opAdd => 'Suma';

  @override
  String get opSub => 'Resta';

  @override
  String get opMul => 'Multiplicación';

  @override
  String get opDiv => 'División';

  @override
  String get opPow => 'Potencia';

  @override
  String get opNeg => 'Opuesto (cambia el signo)';

  @override
  String get opSqrt => 'Raíz cuadrada';

  @override
  String get opCbrt => 'Raíz cúbica';

  @override
  String get opFact => 'Factorial';

  @override
  String get opAbs => 'Valor absoluto';

  @override
  String get opFloor => 'Piso (redondea hacia abajo)';

  @override
  String get opCeil => 'Techo (redondea hacia arriba)';

  @override
  String get lessonsTitle => 'Aprender los operadores';

  @override
  String lessonsEyebrow(int done, int total) {
    return '$done DE $total LECCIONES';
  }

  @override
  String get lessonsIntro =>
      'Cada lección muestra una placa resuelta paso a paso con un operador. Después es tu turno, sin reloj.';

  @override
  String get lessonDone => 'lección completada';

  @override
  String get lessonPrev => 'Paso anterior';

  @override
  String get lessonNext => 'Paso siguiente';

  @override
  String get lessonPlay => 'Reproducir';

  @override
  String get lessonNowYou => 'AHORA TÚ';

  @override
  String lessonStepStart(String number) {
    return 'La placa $number: cuatro dígitos, en orden.';
  }

  @override
  String lessonStepLink(int a, int b, String op, String name) {
    return 'Unimos $a y $b con $op ($name).';
  }

  @override
  String lessonStepUnary(String op, String name) {
    return 'Aplicamos $op ($name) sobre el tramo.';
  }

  @override
  String lessonStepEquals(int a, int b) {
    return 'Por último, el = entre $a y $b: ambos lados valen lo mismo.';
  }

  @override
  String get help1 =>
      'Usa los cuatro dígitos de la placa en el orden en que aparecen.';

  @override
  String get help2 =>
      'El = va entre dos números, una sola vez, y separa los dos lados.';

  @override
  String get help3 =>
      'Toca un hueco (o arrastra un signo hasta él) para unir dos bloques con + − × ÷ xʸ. Toca un nodo para cambiar el operador o aplicar √, !, |x| y otros sobre ese tramo; ( ) agrupa el tramo. Arrastra un signo o el = a otro hueco para moverlo; arrástralo fuera del árbol, o usa ⌫, para quitarlo.';

  @override
  String get help4 =>
      'Abre LATEX ▾ junto a la fórmula para verla en LaTeX y copiar el código. Verificar comprueba si ambos lados son iguales. Saltar pregunta si quieres ver una solución; si no, el número vuelve otro día.';

  @override
  String get helpEasyOps => 'todos, incluso ⌊x⌋ ⌈x⌉';

  @override
  String get helpFraction =>
      'La división con resultado no entero (como 5 ÷ 2) solo vale en Fácil.';

  @override
  String get helpScoringTitle => 'PUNTUACIÓN';

  @override
  String get helpScoringTime => 'TIEMPO';

  @override
  String get helpScoringBaseCol => 'BASE';

  @override
  String get helpScoringBase =>
      'Cada número resuelto vale los puntos base del nivel.';

  @override
  String get helpScoringBonus =>
      'Bono de tiempo: +1 punto por cada 5 segundos que quedan en el reloj al verificar.';

  @override
  String helpScoringExample(int base, int seconds, int total) {
    return 'Ejemplo: en Intermedio ($base base), verificar con ${seconds}s restantes da $total puntos.';
  }

  @override
  String get helpScoringLate =>
      'Si se acaba el tiempo, aún puedes terminar y el número cuenta como resuelto, pero vale 0 puntos.';

  @override
  String get helpScoringReplay =>
      'Repetir un número que ya resolviste en el mismo nivel no da puntos otra vez.';

  @override
  String get helpScoringHints =>
      'Pistas: la 1ª muestra dónde va el = (conservas 2/3 de los puntos), la 2ª una primera unión (1/3), la 3ª revela la solución (0 puntos; el número vuelve al sorteo).';

  @override
  String get helpScoringBlind =>
      'A ciegas: jugando todo el número con los valores en tiempo real apagados, los puntos valen ×1,25.';

  @override
  String get helpScoringCombo =>
      'Combo: cada acierto seguido, a tiempo y sin pistas, suma +10% (hasta +50%). Saltar reinicia el combo.';

  @override
  String get helpDayStreak =>
      'Días seguidos: resuelve al menos una placa al día, en cualquier modo, para que tu racha crezca. Ver la solución no cuenta.';

  @override
  String get helpScoringPractice =>
      'La práctica y las lecciones no dan puntos.';

  @override
  String helpScoringPause(int seconds) {
    return 'Tienes una pausa de ${seconds}s por número; durante la pausa el reloj se detiene y el árbol se oculta.';
  }

  @override
  String get helpGotIt => 'ENTENDIDO';

  @override
  String get homePage => 'Página de inicio';

  @override
  String get adventureCurrent => 'actual';

  @override
  String adventureCollapse(String level) {
    return 'Contraer $level';
  }

  @override
  String adventureExpand(String level) {
    return 'Mostrar $level';
  }

  @override
  String adventureStage(int number) {
    return 'Fase $number';
  }

  @override
  String adventureLockedColumn(int count) {
    return 'Se abre con $count fases completadas en el nivel anterior.';
  }

  @override
  String get adventureLockedStage =>
      'Esta fase se abre cuando completes las anteriores.';

  @override
  String get adventureStarsRule =>
      '★ cuando la resuelves, ★★ a tiempo y sin pistas, ★★★ con al menos la mitad del tiempo de sobra';

  @override
  String helpAdventureUntimed(int count) {
    return 'Las primeras $count fases de la Aventura no tienen reloj: el tiempo se mide, pero no se acaba.';
  }

  @override
  String adventureContinue(int number) {
    return 'CONTINUAR FASE $number';
  }

  @override
  String get adventureAllDone => '¡Completaste toda la ruta!';

  @override
  String adventureStarsEarned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count estrellas',
      one: '1 estrella',
      zero: 'Sin estrellas',
    );
    return '$_temp0';
  }

  @override
  String get adventureNext => 'SIGUIENTE FASE';

  @override
  String get adventureTrail => 'RUTA';

  @override
  String adventureStageA11y(int number, String plate, String state) {
    return 'Fase $number, placa $plate, $state';
  }

  @override
  String get adventureStateDone => 'completada';

  @override
  String get adventureStateOpen => 'abierta';

  @override
  String get adventureStateLocked => 'bloqueada';

  @override
  String get adventureOps => 'operadores';

  @override
  String get challengeClockTitle => 'Contra el reloj';

  @override
  String get challengeClockTag => '3 MIN';

  @override
  String get challengeClockDesc =>
      'Resuelve todas las placas que puedas en 3 minutos. Saltar cuesta 10 segundos. Subir de escalón da +10 s.';

  @override
  String get challengeRestrictedTitle => 'Con restricción';

  @override
  String get challengeRestrictedTag => 'REGLA EXTRA';

  @override
  String get challengeRestrictedDesc =>
      'Cada placa trae una regla: sin +, = fijo, operador obligatorio… Tienes 3 vidas.';

  @override
  String get challengeLadder =>
      'Los dos desafíos empiezan en Fácil y suben un escalón cada 3 aciertos, hasta llegar a Difícil. No hay pistas ni pausa.';

  @override
  String get challengeRecord => 'RÉCORD';

  @override
  String get challengePlays => 'PARTIDAS';

  @override
  String get challengePlay => 'JUGAR';

  @override
  String runPlates(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count placas',
      one: '1 placa',
      zero: '0 placas',
    );
    return '$_temp0';
  }

  @override
  String runStep(int step) {
    return 'escalón $step';
  }

  @override
  String runLives(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vidas',
      one: '1 vida',
      zero: 'sin vidas',
    );
    return '$_temp0';
  }

  @override
  String runSkip(int seconds) {
    return 'SALTAR −${seconds}s';
  }

  @override
  String get runSkipLife => 'SALTAR −♥';

  @override
  String get ruleTitle => 'REGLA DE LA PLACA';

  @override
  String ruleForbid(String op) {
    return 'En esta placa no se puede usar $op.';
  }

  @override
  String ruleRequire(String op) {
    return 'En esta placa, la igualdad tiene que usar $op.';
  }

  @override
  String ruleEqualsAt(int a, int b) {
    return 'En esta placa, el = tiene que ir entre el $a y el $b.';
  }

  @override
  String ruleShortForbid(String op) {
    return 'sin $op';
  }

  @override
  String ruleShortRequire(String op) {
    return 'usa $op';
  }

  @override
  String ruleShortEquals(int a, int b) {
    return '= entre $a y $b';
  }

  @override
  String get ruleBroken => 'Verdadera, pero rompe la regla';

  @override
  String get runRight => '¡BIEN!';

  @override
  String get runRightDetail => 'La siguiente placa aparece enseguida.';

  @override
  String runStepUp(int step, int seconds) {
    return 'Subiste al escalón $step y ganaste ${seconds}s en el reloj.';
  }

  @override
  String get runPlateLost => 'PLACA PERDIDA';

  @override
  String get runPlateLostDetail =>
      'Perdiste una vida. Esta es una solución que sigue la regla.';

  @override
  String get runOverClock => 'SE ACABÓ EL TIEMPO';

  @override
  String get runOverLives => 'SIN VIDAS';

  @override
  String runScoreSolved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count placas resueltas',
      one: '1 placa resuelta',
      zero: 'Ninguna placa resuelta',
    );
    return '$_temp0';
  }

  @override
  String get runNewRecord => '¡NUEVO RÉCORD!';

  @override
  String runBest(int count) {
    return 'Récord: $count';
  }

  @override
  String get runPlayAgain => 'JUGAR OTRA VEZ';

  @override
  String get runNextPlate => 'SIGUIENTE PLACA';

  @override
  String get runLastSolution => 'Una solución de la última placa:';

  @override
  String get coverHaveAccount => '¿Ya tienes cuenta?';

  @override
  String get coverSignIn => 'Entrar';

  @override
  String get loginGuest => 'Continuar como invitado';

  @override
  String get guestError =>
      'No se pudo entrar como invitado. Inténtalo de nuevo.';

  @override
  String get guest => 'Invitado';

  @override
  String get guestSubtitle => 'Progreso guardado solo en este dispositivo';

  @override
  String get guestCreateAccount => 'Crear cuenta';

  @override
  String get guestSignOutTitle => '¿Salir del modo invitado?';

  @override
  String get guestSignOutBody =>
      'Perderás el progreso de invitado. Crea una cuenta antes para conservarlo.';

  @override
  String get guestSignOutConfirm => 'Salir y perder el progreso';

  @override
  String get remindTitle => 'Guarda tu progreso';

  @override
  String get remindFirstGame =>
      '¿Te gusta? Crea una cuenta para guardar tus números resueltos y jugar en cualquier dispositivo.';

  @override
  String get remindFirstAchievement =>
      '¡Primer logro! Como invitado, solo queda en este dispositivo. Crea una cuenta para no perderlo.';

  @override
  String remindSolved(int n) {
    return '¡Ya resolviste $n placas! Crea una cuenta para no perder este progreso.';
  }

  @override
  String get remindLater => 'Ahora no';

  @override
  String get linkTitle => 'Crear cuenta';

  @override
  String get linkBody =>
      'Todo lo que hiciste como invitado pasa a la cuenta nueva.';

  @override
  String get linkGoogle => 'Continuar con Google';

  @override
  String get linkEmail => 'Correo';

  @override
  String get linkPassword => 'Contraseña';

  @override
  String get linkSubmit => 'Crear cuenta con correo';

  @override
  String get linkDone => '¡Cuenta creada! Tu progreso está guardado.';

  @override
  String get linkExistsTitle => 'Esta cuenta ya existe';

  @override
  String get linkExistsBody =>
      'Entrar en ella descarta el progreso de invitado de este dispositivo.';

  @override
  String get linkExistsConfirm => 'Entrar de todos modos';

  @override
  String get linkWeakPassword =>
      'La contraseña necesita al menos 6 caracteres.';

  @override
  String get linkInvalidEmail => 'Correo no válido.';

  @override
  String get linkWrongPassword => 'Contraseña incorrecta para esta cuenta.';

  @override
  String get linkError => 'No se pudo crear la cuenta. Inténtalo de nuevo.';
}
