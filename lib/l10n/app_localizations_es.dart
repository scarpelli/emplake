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
  String get coverSheet => 'HJ. 00 · PORTADA';

  @override
  String get plateCountry => 'BRASIL';

  @override
  String get coverTagline =>
      'Usa los cuatro dígitos de la placa, en orden, para formar una igualdad verdadera.';

  @override
  String get coverTap => 'TOCA PARA EMPEZAR';

  @override
  String get coverProject => 'PROYECTO';

  @override
  String get coverScale => 'ESCALA';

  @override
  String get coverYear => 'AÑO';

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
      'Un conjunto de desafíos con distintas dificultades.';

  @override
  String get modeAdventure => 'Aventura';

  @override
  String get modeAdventureDesc =>
      'Una placa por ciudad, en un viaje por Brasil.';

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
  String get fourDigitNumber => 'NÚMERO DE 4 DÍGITOS';

  @override
  String get typeFourDigits => 'Escribe los 4 dígitos.';

  @override
  String get start => 'EMPEZAR';

  @override
  String pointsShort(int points) {
    return '$points pts';
  }

  @override
  String get treeGrowsHint =>
      'el árbol crece hacia arriba\na medida que unes los números';

  @override
  String get hintStart =>
      'Toca entre dos números y elige un operador para unirlos. El = entra igual, una sola vez.';

  @override
  String get paletteBetween => 'ENTRE NÚMEROS';

  @override
  String get paletteOver => 'SOBRE UN TRAMO';

  @override
  String get paletteTapGap => 'toca un hueco entre números';

  @override
  String get paletteTapNode => 'toca un número o rama';

  @override
  String get paletteGapSelected => 'hueco seleccionado';

  @override
  String paletteNodeSelected(String node) {
    return 'nodo seleccionado: $node';
  }

  @override
  String gapLabel(int n) {
    return 'hueco $n';
  }

  @override
  String get removeOperator => 'Quitar operador';

  @override
  String get toggleParens => 'Paréntesis';

  @override
  String get undo => 'Deshacer';

  @override
  String get skip => 'SALTAR';

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
  String get points => 'PUNTOS';

  @override
  String get total => 'TOTAL';

  @override
  String savedSolved(String number) {
    return '$number guardado en tus resueltos';
  }

  @override
  String savedCounts(String number) {
    return '$number cuenta como resuelto';
  }

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
  String get presets => 'TEMAS LISTOS';

  @override
  String get presetBlueprint => 'Plano';

  @override
  String get presetGraphite => 'Grafito';

  @override
  String get presetSepia => 'Sepia';

  @override
  String get presetForest => 'Bosque';

  @override
  String get seedColor => 'COLOR SEMILLA';

  @override
  String get pickColor => 'Elegir color';

  @override
  String get fontSize => 'TAMAÑO DE FUENTE';

  @override
  String get fontSample => 'Usa los cuatro dígitos en orden.';

  @override
  String get fontFamily => 'TIPO DE FUENTE';

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
  String get providerGoogle => 'Google';

  @override
  String get providerEmail => 'Correo';

  @override
  String get player => 'Jugador';

  @override
  String get helpTitle => 'CÓMO JUGAR';

  @override
  String get help1 =>
      'Usa los cuatro dígitos de la placa en el orden en que aparecen.';

  @override
  String get help2 =>
      'El = va entre dos números, una sola vez, y separa los dos lados.';

  @override
  String get help3 =>
      'Toca un hueco para unir dos bloques con + − × ÷ xʸ. Toca un nodo para cambiar el operador o aplicar √, !, |x| y otros sobre ese tramo; ( ) agrupa el tramo.';

  @override
  String get help4 =>
      'Justo debajo de tu fórmula aparece la misma fórmula en LaTeX. Verificar comprueba si ambos lados son iguales; Saltar cambia a otro número sin resolver.';

  @override
  String get helpEasyOps => 'todos, incluso ⌊x⌋ ⌈x⌉';

  @override
  String get helpFraction =>
      'La división con resultado no entero (como 5 ÷ 2) solo vale en Fácil.';

  @override
  String get helpGotIt => 'ENTENDIDO';
}
