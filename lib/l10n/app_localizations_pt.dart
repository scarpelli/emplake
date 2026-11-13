// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Emplake';

  @override
  String get soundOn => 'Som ligado';

  @override
  String get soundOff => 'Som desligado';

  @override
  String get soundOffShort => 'som desligado';

  @override
  String get navHome => 'Início';

  @override
  String get navHistory => 'Resolvidos';

  @override
  String get navGame => 'Jogo';

  @override
  String get navHelp => 'Ajuda';

  @override
  String get navSettings => 'Configurações';

  @override
  String get notFound => 'Página não encontrada.';

  @override
  String get back => 'Voltar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get ok => 'OK';

  @override
  String get retry => 'Tentar de novo';

  @override
  String get coverSheet => 'FL. 00 · CAPA';

  @override
  String get plateCountry => 'BRASIL';

  @override
  String get coverTagline =>
      'Use os quatro dígitos da placa, na ordem, para montar uma igualdade verdadeira.';

  @override
  String get coverTap => 'TOQUE PARA COMEÇAR';

  @override
  String get coverProject => 'PROJETO';

  @override
  String get coverScale => 'ESCALA';

  @override
  String get coverYear => 'ANO';

  @override
  String get loginSubtitle => 'Entre para salvar seus números resolvidos.';

  @override
  String get loginTeam => 'EQUIPE';

  @override
  String loginMember(int n) {
    return 'INTEGRANTE $n';
  }

  @override
  String get loginCredit => 'Jogo concebido por Prof. Walter A. Carnielli';

  @override
  String get language => 'Idioma';

  @override
  String get loginOr => 'OU';

  @override
  String get loginGoogle => 'Entrar com Google';

  @override
  String get loginGoogleError =>
      'Não foi possível entrar com o Google. Tente de novo.';

  @override
  String greeting(String name, int points) {
    return 'OLÁ, $name · $points PTS';
  }

  @override
  String stepOf(int step, int total) {
    return 'PASSO $step DE $total';
  }

  @override
  String get modeQuestion => 'Como você quer jogar?';

  @override
  String get modeEducational => 'Educacional';

  @override
  String get modeEducationalDesc =>
      'Exemplos resolvidos passo a passo para aprender os operadores.';

  @override
  String get modeRandom => 'Aleatório';

  @override
  String get modeRandomDesc =>
      'Os números são sorteados entre os que você ainda não resolveu.';

  @override
  String get modeSpecific => 'Específico';

  @override
  String get modeSpecificDesc =>
      'Você digita o número de 4 dígitos que quer resolver.';

  @override
  String get modeChallenges => 'Desafios';

  @override
  String get modeChallengesDesc =>
      'Conjunto de desafios com diferentes dificuldades.';

  @override
  String get modeAdventure => 'Aventura';

  @override
  String get modeAdventureDesc =>
      'Uma placa por cidade, numa viagem pelo Brasil.';

  @override
  String get modeDaily => 'Placa do dia';

  @override
  String get modeDailyDesc =>
      'O mesmo número para todo mundo hoje. Uma tentativa; compartilhe o resultado.';

  @override
  String get dailyAlreadyPlayed =>
      'Você já jogou a placa de hoje. Volte amanhã para uma nova!';

  @override
  String get dailyCopy => 'COPIAR RESULTADO';

  @override
  String get blindShort => 'às cegas';

  @override
  String hintsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dicas',
      one: '1 dica',
      zero: 'sem dicas',
    );
    return '$_temp0';
  }

  @override
  String streakShort(int count) {
    return '🔥 $count';
  }

  @override
  String get comingSoon => 'EM BREVE';

  @override
  String get continueLabel => 'CONTINUAR';

  @override
  String modeLabel(String mode) {
    return 'MODO: $mode';
  }

  @override
  String get chooseLevel => 'Escolha o nível';

  @override
  String get levelEasy => 'Fácil';

  @override
  String get levelIntermediate => 'Intermediário';

  @override
  String get levelAdvanced => 'Avançado';

  @override
  String get levelHard => 'Difícil';

  @override
  String get levelEasyShort => 'Fácil';

  @override
  String get levelIntermediateShort => 'Interm.';

  @override
  String get levelAdvancedShort => 'Avanç.';

  @override
  String get levelHardShort => 'Difícil';

  @override
  String get levelEasyNote =>
      'Único nível que aceita divisão não inteira (5 ÷ 2).';

  @override
  String get levelIntermediateNote =>
      'Divisões precisam dar resultado inteiro.';

  @override
  String get levelAdvancedNote => 'Sem raiz cúbica e sem potência.';

  @override
  String get levelHardNote => 'Só as quatro operações e módulo.';

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
  String get typeFourDigits => 'Digite os 4 dígitos.';

  @override
  String noSolutionOnLevel(String number, String level, String others) {
    return '$number não tem solução no $level. Tente no: $others.';
  }

  @override
  String noSolutionAnyLevel(String number) {
    return '$number não tem solução em nenhum nível. Escolha outro número.';
  }

  @override
  String get start => 'COMEÇAR';

  @override
  String levelProgress(int done, int total) {
    return '$done / $total resolvidos';
  }

  @override
  String get practiceMode => 'Treino (sem relógio)';

  @override
  String get practiceModeHint =>
      'Jogue no seu ritmo. Não vale pontos e não entra no histórico.';

  @override
  String get practiceShort => 'treino';

  @override
  String get practiceTimer => 'sem relógio';

  @override
  String get practiceNoPoints => 'Treino: sem pontos, no seu ritmo.';

  @override
  String pointsShort(int points) {
    return '$points pts';
  }

  @override
  String get treeGrowsHint =>
      'a árvore cresce para cima\nconforme você liga os números';

  @override
  String get hintStart =>
      'Toque entre dois números e escolha um operador, ou arraste o sinal até o vão. O = entra do mesmo jeito, uma única vez. Arraste um sinal para outro vão para movê-lo, ou para fora da árvore para tirá-lo.';

  @override
  String get paletteBetween => 'ENTRE NÚMEROS';

  @override
  String get paletteOver => 'SOBRE UM TRECHO';

  @override
  String get paletteTapGap => 'toque num vão entre números';

  @override
  String get paletteTapNode => 'toque num número ou ramo';

  @override
  String get paletteGapSelected => 'vão selecionado';

  @override
  String paletteNodeSelected(String node) {
    return 'nó selecionado: $node';
  }

  @override
  String gapLabel(int n) {
    return 'vão $n';
  }

  @override
  String get removeOperator => 'Remover sinal';

  @override
  String hintTitle(int n) {
    return 'DICA $n DE 3';
  }

  @override
  String hintEquals(int a, int b) {
    return 'O = fica entre o $a e o $b.';
  }

  @override
  String hintLink(int a, int b, String op) {
    return 'Comece ligando o $a e o $b com $op.';
  }

  @override
  String hintTooltip(int n) {
    return 'Dica $n (custa 1/3 dos pontos)';
  }

  @override
  String get hintTooltipReveal => 'Revelar a solução (sem pontos)';

  @override
  String get hintRevealTitle => 'REVELAR A SOLUÇÃO?';

  @override
  String get hintRevealBody =>
      'Este número termina sem pontos e volta ao sorteio para você tentar outro dia.';

  @override
  String secondsLeftA11y(int seconds) {
    return '$seconds segundos restantes';
  }

  @override
  String tutorialTapGap(int a, int b) {
    return 'Toque no vão entre o $a e o $b (o quadradinho tracejado).';
  }

  @override
  String get tutorialPickTimes =>
      'Agora escolha × para ligar os dois. Dá também para arrastar o sinal até o vão.';

  @override
  String get tutorialLinkThree =>
      'A árvore cresceu! Ligue o resultado com o 3: toque no próximo vão.';

  @override
  String get tutorialEqualsGap =>
      '1 × 2 × 3 vale 6. Toque no último vão para pôr o =.';

  @override
  String get tutorialPickEquals => 'Escolha o =.';

  @override
  String get tutorialVerify => '6 = 6! Toque em Verificar para conferir.';

  @override
  String get tutorialOffScript =>
      'Tudo bem experimentar! Para seguir o tutorial, use ↶ desfazer até voltar ao passo anterior.';

  @override
  String get tutorialSkip => 'PULAR TUTORIAL';

  @override
  String get liveValuesShow => 'Mostrar valores em tempo real';

  @override
  String get liveValuesHide => 'Esconder valores em tempo real';

  @override
  String get toggleParens => 'Parênteses';

  @override
  String get undo => 'Desfazer';

  @override
  String get skip => 'PULAR';

  @override
  String get skipTitle => 'PULAR ESTE NÚMERO?';

  @override
  String get skipBody =>
      'Quer ver uma solução? Se preferir, não revelamos nada: o número volta ao sorteio para você tentar outro dia.';

  @override
  String get skipYes => 'SIM, MOSTRAR';

  @override
  String get skipNo => 'NÃO, PULAR';

  @override
  String get seeSolution => 'Ver uma solução';

  @override
  String get verify => 'VERIFICAR';

  @override
  String linksLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'FALTAM $count LIGAÇÕES',
      one: 'FALTA 1 LIGAÇÃO',
    );
    return '$_temp0';
  }

  @override
  String get fixError => 'CORRIJA O ERRO';

  @override
  String get latex => 'LATEX';

  @override
  String get copy => 'Copiar';

  @override
  String get copied => 'Copiado!';

  @override
  String get pause => 'Pausar';

  @override
  String get pausedTitle => 'PAUSADO';

  @override
  String get pausedBody => 'A árvore fica escondida durante a pausa.';

  @override
  String get resume => 'Continuar';

  @override
  String get timeUp => 'tempo esgotado';

  @override
  String leftSide(String value) {
    return 'esquerda $value';
  }

  @override
  String rightSide(String value) {
    return 'direita $value';
  }

  @override
  String get equalityTrue => 'igualdade verdadeira';

  @override
  String get equalityFalse => 'igualdade falsa';

  @override
  String get loadingNumber => 'SORTEANDO UM NÚMERO…';

  @override
  String get allSolved => 'Você já resolveu todos os números deste nível!';

  @override
  String get allSolvedCatalog =>
      'Você resolveu todos os números deste nível por enquanto! Tente outro nível ou digite um número no modo Específico.';

  @override
  String get alreadySolved =>
      'Você já resolveu este número neste nível. Pode jogar de novo, mas sem pontos.';

  @override
  String get noGame => 'Nenhuma partida em andamento.';

  @override
  String get newGame => 'NOVA PARTIDA';

  @override
  String get treeTitleDesktop =>
      'ÁRVORE DA EXPRESSÃO · clique num nó · Tab alterna';

  @override
  String get formula => 'FÓRMULA';

  @override
  String get infoNumber => 'NÚMERO';

  @override
  String get infoDigits => 'DÍGITOS';

  @override
  String get infoMode => 'MODO';

  @override
  String get infoLevel => 'NÍVEL';

  @override
  String get wrongTitle => 'IGUALDADE FALSA';

  @override
  String wrongBody(String left, String right) {
    return 'O lado esquerdo vale $left e o direito vale $right. Ajuste e tente de novo.';
  }

  @override
  String get errDivisionByZero => 'DIVISÃO POR ZERO';

  @override
  String get errDivisionByZeroBody =>
      'Não dá para dividir por zero. Troque o nó destacado.';

  @override
  String errNonIntegerDivision(String a, String b, String result) {
    return 'DIVISÃO NÃO INTEIRA: $a ÷ $b = $result';
  }

  @override
  String errNonIntegerDivisionBody(String level) {
    return 'No nível $level, toda divisão precisa ter resultado inteiro. Troque o nó destacado ou mude a estrutura.';
  }

  @override
  String get errFactorialDomain => 'FATORIAL INVÁLIDO';

  @override
  String get errFactorialDomainBody =>
      'O fatorial só vale para números inteiros de 0 em diante.';

  @override
  String get errFactorialTooLarge => 'FATORIAL GRANDE DEMAIS';

  @override
  String get errFactorialTooLargeBody => 'Use o fatorial só até 20!.';

  @override
  String get errEvenRoot => 'RAIZ DE NÚMERO NEGATIVO';

  @override
  String get errEvenRootBody =>
      'A raiz quadrada de um número negativo não é um número real.';

  @override
  String get errZeroNegPower => 'ZERO ELEVADO A NEGATIVO';

  @override
  String get errZeroNegPowerBody =>
      '0 elevado a um expoente negativo não está definido.';

  @override
  String get errComplexPower => 'POTÊNCIA NÃO REAL';

  @override
  String get errComplexPowerBody =>
      'Base negativa com expoente não inteiro não dá um número real.';

  @override
  String get errTooLarge => 'NÚMERO GRANDE DEMAIS';

  @override
  String get errTooLargeBody =>
      'O resultado passou do limite. Tente outra estrutura.';

  @override
  String get errNotAllowed => 'OPERADOR FORA DO NÍVEL';

  @override
  String get errNotAllowedBody =>
      'Esse operador não está liberado neste nível.';

  @override
  String get resultTrue => 'IGUALDADE VERDADEIRA';

  @override
  String resultTrueDetail(String value, int seconds) {
    return '$value = $value · resolvido em ${seconds}s';
  }

  @override
  String get resultLate => 'CERTO, MAS FORA DO TEMPO';

  @override
  String resultLateDetail(String value) {
    return '$value = $value · o tempo acabou antes de verificar';
  }

  @override
  String get revealedTitle => 'UMA SOLUÇÃO POSSÍVEL';

  @override
  String revealedDetail(String number) {
    return 'Sem pontos desta vez. $number continua no sorteio para você tentar de novo.';
  }

  @override
  String get points => 'PONTOS';

  @override
  String get total => 'TOTAL';

  @override
  String pointsBreakdown(int base, int bonus) {
    return '$base base + $bonus pelo tempo';
  }

  @override
  String get pointsLateZero => 'Fora do tempo não vale pontos.';

  @override
  String get pointsReplayZero => 'Número já resolvido neste nível: sem pontos.';

  @override
  String get howScoringWorks => 'Como funciona?';

  @override
  String scoreHints(int count, int percent) {
    return 'dicas ×$percent%';
  }

  @override
  String get scoreBlind => 'às cegas ×1,25';

  @override
  String scoreStreak(int count, int percent) {
    return 'sequência $count: +$percent%';
  }

  @override
  String achievementUnlocked(String title) {
    return 'Conquista: $title';
  }

  @override
  String savedSolved(String number) {
    return '$number salvo nos seus resolvidos';
  }

  @override
  String savedCounts(String number) {
    return '$number conta como resolvido';
  }

  @override
  String savedReplay(String number) {
    return '$number já estava nos seus resolvidos';
  }

  @override
  String get saving => 'Salvando…';

  @override
  String get saveError => 'Não foi possível salvar. Verifique sua conexão.';

  @override
  String get menu => 'MENU';

  @override
  String get nextNumber => 'PRÓXIMO NÚMERO';

  @override
  String get historyEyebrow => 'SEU HISTÓRICO';

  @override
  String get historyTitle => 'Resolvidos';

  @override
  String get historyLoading => 'TRAÇANDO SEU HISTÓRICO…';

  @override
  String get solvedCount => 'RESOLVIDOS';

  @override
  String get skippedCount => 'PULADOS';

  @override
  String get filterAll => 'Todos';

  @override
  String get historyEmpty =>
      'Nenhum número resolvido aqui ainda. Que tal começar?';

  @override
  String get historyError => 'Não foi possível carregar seu histórico.';

  @override
  String get today => 'HOJE';

  @override
  String get yesterday => 'ONTEM';

  @override
  String get latexCopied => 'LaTeX copiado';

  @override
  String get lateTag => 'FORA DO TEMPO';

  @override
  String get skippedEmpty =>
      'Nenhum número pulado. Quando pular um, ele aparece aqui para você tentar de novo.';

  @override
  String skippedTimes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'pulado $count vezes',
      one: 'pulado 1 vez',
    );
    return '$_temp0';
  }

  @override
  String get skippedRevealed => 'solução vista';

  @override
  String get tryAgain => 'TENTAR';

  @override
  String achievementsTitle(int count, int total) {
    return 'CONQUISTAS · $count/$total';
  }

  @override
  String get achievementUnlockedShort => 'desbloqueada';

  @override
  String get achievementLocked => 'bloqueada';

  @override
  String get achFirstSolve => 'Primeira placa';

  @override
  String get achFirstSolveDesc => 'Resolva o seu primeiro número.';

  @override
  String get achTenInTime => 'Contra o relógio';

  @override
  String get achTenInTimeDesc => 'Resolva 10 números dentro do tempo.';

  @override
  String get achBlind => 'Às cegas';

  @override
  String get achBlindDesc => 'Resolva um número sem os valores em tempo real.';

  @override
  String get achThreeStars => 'Osso duro';

  @override
  String get achThreeStarsDesc => 'Resolva um número ★3.';

  @override
  String get achAllLevels => 'Escada completa';

  @override
  String get achAllLevelsDesc => 'Resolva um número em cada nível.';

  @override
  String get achStreak5 => 'Embalado';

  @override
  String get achStreak5Desc => 'Acerte 5 seguidos, no tempo e sem dicas.';

  @override
  String get achDaily7 => 'Semana cheia';

  @override
  String get achDaily7Desc => 'Resolva a placa do dia 7 dias seguidos.';

  @override
  String get achHundred => 'Centena';

  @override
  String get achHundredDesc => 'Resolva 100 números.';

  @override
  String get settingsEyebrow => 'PREFERÊNCIAS';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get theme => 'TEMA';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get themeHint => 'Segue o tema do aparelho até você escolher outro.';

  @override
  String get settingsGame => 'JOGO';

  @override
  String get settingsLiveValues => 'Valores em tempo real';

  @override
  String get settingsLiveValuesHint =>
      'Mostra quanto vale cada ramo e cada lado do = enquanto você monta.';

  @override
  String get settingsHaptics => 'Vibração';

  @override
  String get settingsReduceMotion => 'Reduzir animações';

  @override
  String get settingsReduceMotionHint =>
      'Desliga as animações da árvore, da comemoração e das dicas.';

  @override
  String get settingsHints => 'Tutorial da primeira partida';

  @override
  String get settingsHintsHint =>
      'Ligue para refazer o passo a passo (1 × 2 × 3 = 6) na próxima partida.';

  @override
  String get seedColor => 'COR SEMENTE';

  @override
  String get pickColor => 'Escolher cor';

  @override
  String get fontSize => 'TAMANHO DA FONTE';

  @override
  String get fontSample => 'Use os quatro dígitos na ordem.';

  @override
  String get sound => 'SOM';

  @override
  String get soundEffects => 'Efeitos sonoros';

  @override
  String get music => 'Música';

  @override
  String get languageSection => 'IDIOMA';

  @override
  String get account => 'CONTA';

  @override
  String get signOut => 'Sair';

  @override
  String get providerGoogle => 'Google';

  @override
  String get providerEmail => 'E-mail';

  @override
  String get player => 'Jogador';

  @override
  String get helpTitle => 'COMO JOGAR';

  @override
  String get helpTabPlay => 'JOGAR';

  @override
  String get helpTabOperators => 'OPERADORES';

  @override
  String get helpTabScoring => 'PONTOS';

  @override
  String get helpExample => 'EXEMPLO';

  @override
  String get helpExampleCaption =>
      '1236 → 1 × 2 × 3 = 6. Cada ligação sobe um andar na árvore.';

  @override
  String get helpKeys => 'TECLADO';

  @override
  String get helpKeysList =>
      'Enter verificar · Esc pular · Tab seleção · Ctrl+Z desfazer · ⌫ remover · H dica\n+ − * / ^ = ( ) operadores · ! fatorial · r √ · c ∛ · a |x| · n −x · f ⌊x⌋ · F ⌈x⌉';

  @override
  String get helpOperatorsIntro =>
      'Os binários (+ − × ÷ xʸ) ligam dois blocos num vão. Os outros agem sobre um trecho: toque num número ou ramo e escolha.';

  @override
  String get opAdd => 'Soma';

  @override
  String get opSub => 'Subtração';

  @override
  String get opMul => 'Multiplicação';

  @override
  String get opDiv => 'Divisão';

  @override
  String get opPow => 'Potência';

  @override
  String get opNeg => 'Oposto (troca o sinal)';

  @override
  String get opSqrt => 'Raiz quadrada';

  @override
  String get opCbrt => 'Raiz cúbica';

  @override
  String get opFact => 'Fatorial';

  @override
  String get opAbs => 'Módulo (valor absoluto)';

  @override
  String get opFloor => 'Piso (arredonda para baixo)';

  @override
  String get opCeil => 'Teto (arredonda para cima)';

  @override
  String get lessonsTitle => 'Aprender os operadores';

  @override
  String lessonsEyebrow(int done, int total) {
    return '$done DE $total LIÇÕES';
  }

  @override
  String get lessonsIntro =>
      'Cada lição mostra uma placa resolvida passo a passo usando um operador. Depois é a sua vez, sem relógio.';

  @override
  String get lessonDone => 'lição concluída';

  @override
  String get lessonPrev => 'Passo anterior';

  @override
  String get lessonNext => 'Próximo passo';

  @override
  String get lessonPlay => 'Reproduzir';

  @override
  String get lessonNowYou => 'AGORA VOCÊ';

  @override
  String get lessonNowYouHint =>
      'Você joga outra placa que também usa este operador, sem relógio e sem pontos.';

  @override
  String lessonStepStart(String number) {
    return 'A placa $number: quatro dígitos, na ordem.';
  }

  @override
  String lessonStepLink(int a, int b, String op, String name) {
    return 'Ligamos o $a e o $b com $op ($name).';
  }

  @override
  String lessonStepUnary(String op, String name) {
    return 'Aplicamos $op ($name) sobre o trecho.';
  }

  @override
  String lessonStepEquals(int a, int b) {
    return 'Por fim, o = entre o $a e o $b: os dois lados valem o mesmo.';
  }

  @override
  String get help1 =>
      'Use os quatro dígitos da placa na ordem em que aparecem.';

  @override
  String get help2 =>
      'O = entra entre dois números, uma única vez, e separa os dois lados.';

  @override
  String get help3 =>
      'Toque num vão (ou arraste um sinal até ele) para ligar dois blocos com + − × ÷ xʸ. Toque num nó para trocar o operador ou aplicar √, !, |x| e outros sobre aquele trecho; ( ) agrupa o trecho. Arraste um sinal ou o = para outro vão para movê-lo; arraste para fora da árvore, ou use ⌫, para tirá-lo.';

  @override
  String get help4 =>
      'Abra o LATEX ▾ ao lado da fórmula para vê-la em LaTeX e copiar o código. Verificar confere se os dois lados são iguais. Pular pergunta se você quer ver uma solução; se não quiser, o número volta outro dia.';

  @override
  String get helpEasyOps => 'todos, inclusive ⌊x⌋ ⌈x⌉';

  @override
  String get helpFraction =>
      'Divisão com resultado não inteiro (como 5 ÷ 2) só vale no Fácil.';

  @override
  String get helpScoringTitle => 'PONTUAÇÃO';

  @override
  String get helpScoringTime => 'TEMPO';

  @override
  String get helpScoringBaseCol => 'BASE';

  @override
  String get helpScoringBase =>
      'Cada número certo vale os pontos base do nível.';

  @override
  String get helpScoringBonus =>
      'Bônus de tempo: +1 ponto a cada 5 segundos que sobram no relógio quando você verifica.';

  @override
  String helpScoringExample(int base, int seconds, int total) {
    return 'Exemplo: no Intermediário ($base base), verificar com ${seconds}s restantes dá $total pontos.';
  }

  @override
  String get helpScoringLate =>
      'Se o tempo acabar, ainda dá para terminar e o número conta como resolvido, mas vale 0 pontos.';

  @override
  String get helpScoringReplay =>
      'Repetir um número que você já resolveu no mesmo nível não dá pontos de novo.';

  @override
  String get helpScoringHints =>
      'Dicas: a 1ª mostra onde vai o = (fica com 2/3 dos pontos), a 2ª uma primeira ligação (1/3), a 3ª revela a solução (0 pontos; o número volta ao sorteio).';

  @override
  String get helpScoringBlind =>
      'Às cegas: jogando o número inteiro com os valores em tempo real desligados, os pontos valem ×1,25.';

  @override
  String get helpScoringStreak =>
      'Sequência: cada acerto seguido, no tempo e sem dicas, soma +10% (até +50%). Pular zera a sequência.';

  @override
  String get helpScoringPractice => 'Treino e lições não valem pontos.';

  @override
  String helpScoringPause(int seconds) {
    return 'Você tem uma pausa de ${seconds}s por número; durante a pausa o relógio para e a árvore fica escondida.';
  }

  @override
  String get helpGotIt => 'ENTENDI';
}
