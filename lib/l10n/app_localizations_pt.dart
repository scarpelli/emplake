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
  String get coverTagline =>
      'Use os quatro dígitos da placa, na ordem, para montar uma igualdade verdadeira.';

  @override
  String get coverTap => 'TOQUE PARA COMEÇAR';

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
      'Jogue contra o relógio ou com uma regra extra em cada placa, e tente bater os seus recordes.';

  @override
  String get modeAdventure => 'Aventura';

  @override
  String get modeAdventureDesc =>
      'Todas as placas do jogo numa trilha, do Fácil ao Difícil. Cada fase vale até 3 estrelas.';

  @override
  String get modeDaily => 'Placa do dia';

  @override
  String get modeDailyDesc =>
      'Todo dia sai um número novo, o mesmo para todo mundo, e você pode levar o tempo que quiser.';

  @override
  String get dailyAlreadyPlayed =>
      'Você já jogou a placa de hoje. Volte amanhã para uma nova!';

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
      other: '$countString pessoas já jogaram hoje',
      one: '1 pessoa já jogou hoje',
    );
    return '$_temp0';
  }

  @override
  String get dailyBeFirst => 'Ninguém jogou ainda hoje';

  @override
  String dailyDoneIn(String time) {
    return 'Feita em $time';
  }

  @override
  String dailyBetterThan(int percent) {
    return 'Melhor que $percent% dos jogadores';
  }

  @override
  String get dailyFirstToday => 'Você foi a primeira pessoa a jogar hoje';

  @override
  String get dailyMissedTitle => 'Não foi dessa vez';

  @override
  String get dailyComeBack => 'Amanhã tem uma placa nova';

  @override
  String get dailyShare => 'COMPARTILHAR';

  @override
  String get dailyTimer => 'sem limite de tempo nesta placa';

  @override
  String get dailyShareMissed => 'não resolvido';

  @override
  String get dailyYourSolution => 'SUA SOLUÇÃO';

  @override
  String dailyStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dias seguidos',
      one: '1 dia seguido',
    );
    return '$_temp0';
  }

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
  String get paletteTapGap => 'toque num vão ou num sinal';

  @override
  String get paletteTapNode => 'toque num número ou ramo';

  @override
  String get paletteGapSelected => 'vão selecionado';

  @override
  String paletteNodeSelected(String node) {
    return 'nó selecionado: $node';
  }

  @override
  String paletteCarryingOver(String sign) {
    return 'levando $sign: toque num número ou ramo';
  }

  @override
  String get dropOverOnGap =>
      'Esse sinal vai em cima de um número ou de um ramo, e não entre dois números.';

  @override
  String get dropBetweenOnNode =>
      'Esse sinal vai entre dois números, num dos vãos tracejados.';

  @override
  String paletteCarrying(String sign) {
    return 'levando $sign: toque num vão';
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
  String get skipBodyAdventure =>
      'Quer ver uma solução? Se preferir, não revelamos nada: a fase continua aberta na trilha para você tentar depois.';

  @override
  String get skipBodyDaily =>
      'Quer ver uma solução? Pulando, a tentativa de hoje termina; amanhã tem outra placa.';

  @override
  String get skipBodyRetry =>
      'Quer ver uma solução? Se preferir, não revelamos nada e você pode tentar de novo quando quiser.';

  @override
  String get close => 'Fechar';

  @override
  String get skipYes => 'SIM, MOSTRAR';

  @override
  String get skipNo => 'NÃO, PULAR';

  @override
  String get seeSolution => 'Ver uma solução';

  @override
  String get seeSolutionShort => 'SOLUÇÃO';

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
  String get revealedDetailAdventure =>
      'Sem estrelas desta vez. A fase continua aberta na trilha para você tentar de novo.';

  @override
  String get revealedDetailDaily =>
      'Sem pontos desta vez. Amanhã tem outra placa.';

  @override
  String get revealedDetailRetry =>
      'Sem pontos desta vez. Você pode tentar de novo quando quiser.';

  @override
  String get points => 'PONTOS';

  @override
  String get total => 'TOTAL';

  @override
  String achievementUnlocked(String title) {
    return 'Conquista: $title';
  }

  @override
  String get achievementBanner => 'CONQUISTA DESBLOQUEADA';

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
  String get fontFamily => 'TIPO DA FONTE';

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
  String get settingsReset => 'RESTAURAR PADRÃO';

  @override
  String get settingsResetTitle => 'Restaurar as configurações padrão?';

  @override
  String get settingsResetBody =>
      'Tema, cor, tamanho do texto, opções de jogo, som e idioma voltam ao padrão. Seu progresso, pontos e recordes não mudam.';

  @override
  String get providerGoogle => 'Google';

  @override
  String get providerEmail => 'E-mail';

  @override
  String get player => 'Jogador';

  @override
  String get settingsGroupPlayer => 'Jogador';

  @override
  String get settingsGroupAppearance => 'Aparência';

  @override
  String get settingsGroupGame => 'Jogo';

  @override
  String get statBestStreak => 'MELHOR SEQUÊNCIA';

  @override
  String get avatarCreate => 'Criar o meu avatar';

  @override
  String get avatarYours => 'Seu avatar';

  @override
  String get avatarTitle => 'Seu robô';

  @override
  String get avatarPreview => 'Prévia do seu robô';

  @override
  String get avatarShuffle => 'SORTEAR';

  @override
  String get avatarSave => 'SALVAR AVATAR';

  @override
  String get avatarSaved => 'SALVO';

  @override
  String get avatarSaveError =>
      'Não deu para salvar o avatar agora. Tente de novo daqui a pouco.';

  @override
  String get avatarGroupHead => 'CABEÇA';

  @override
  String get avatarGroupTop => 'TOPO';

  @override
  String get avatarGroupEyes => 'OLHOS';

  @override
  String get avatarGroupMouth => 'BOCA';

  @override
  String get avatarGroupSide => 'LATERAIS';

  @override
  String get avatarGroupAcc => 'ACESSÓRIOS';

  @override
  String avatarHead(String v) {
    String _temp0 = intl.Intl.selectLogic(v, {
      'rounded': 'arredondada',
      'square': 'quadrada',
      'capsule': 'cápsula',
      'round': 'redonda',
      'octagon': 'octógono',
      'other': '–',
    });
    return '$_temp0';
  }

  @override
  String avatarTop(String v) {
    String _temp0 = intl.Intl.selectLogic(v, {
      'none': 'nada',
      'antenna': 'antena',
      'twoAntennas': 'duas antenas',
      'spring': 'mola',
      'heart': 'coração',
      'propeller': 'hélice',
      'dome': 'cúpula',
      'crown': 'coroa',
      'other': '–',
    });
    return '$_temp0';
  }

  @override
  String avatarEyes(String v) {
    String _temp0 = intl.Intl.selectLogic(v, {
      'round': 'redondos',
      'lashes': 'cílios',
      'hearts': 'corações',
      'wink': 'piscando',
      'sleepy': 'sonolentos',
      'glasses': 'óculos',
      'visor': 'visor',
      'cyclops': 'ciclope',
      'other': '–',
    });
    return '$_temp0';
  }

  @override
  String avatarMouth(String v) {
    String _temp0 = intl.Intl.selectLogic(v, {
      'smile': 'sorriso',
      'teeth': 'dentinhos',
      'open': 'aberta',
      'wave': 'onda',
      'grille': 'grade',
      'line': 'linha',
      'other': '–',
    });
    return '$_temp0';
  }

  @override
  String avatarSide(String v) {
    String _temp0 = intl.Intl.selectLogic(v, {
      'none': 'nada',
      'bolts': 'parafusos',
      'headphones': 'fones',
      'gears': 'engrenagens',
      'rods': 'hastes',
      'other': '–',
    });
    return '$_temp0';
  }

  @override
  String avatarAcc(String v) {
    String _temp0 = intl.Intl.selectLogic(v, {
      'none': 'nada',
      'cheeks': 'bochechas',
      'bowTie': 'gravata',
      'tie': 'gravata longa',
      'medal': 'medalha',
      'other': '–',
    });
    return '$_temp0';
  }

  @override
  String get helpTitle => 'COMO JOGAR';

  @override
  String get helpPageTitle => 'Como jogar';

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

  @override
  String get homePage => 'Página inicial';

  @override
  String get adventureCurrent => 'atual';

  @override
  String adventureCollapse(String level) {
    return 'Recolher $level';
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
    return 'Abre com $count fases concluídas no nível anterior.';
  }

  @override
  String get adventureLockedStage =>
      'Esta fase abre quando você concluir as anteriores.';

  @override
  String get adventureStarsRule =>
      '★ quando você resolve, ★★ no tempo e sem dicas, ★★★ com pelo menos metade do tempo sobrando';

  @override
  String adventureContinue(int number) {
    return 'CONTINUAR FASE $number';
  }

  @override
  String get adventureAllDone => 'Você completou a trilha inteira!';

  @override
  String adventureStarsEarned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count estrelas',
      one: '1 estrela',
      zero: 'Nenhuma estrela',
    );
    return '$_temp0';
  }

  @override
  String get adventureNext => 'PRÓXIMA FASE';

  @override
  String get adventureTrail => 'TRILHA';

  @override
  String adventureStageA11y(int number, String plate, String state) {
    return 'Fase $number, placa $plate, $state';
  }

  @override
  String get adventureStateDone => 'concluída';

  @override
  String get adventureStateOpen => 'aberta';

  @override
  String get adventureStateLocked => 'bloqueada';

  @override
  String get adventureOps => 'operadores';

  @override
  String get challengeClockTitle => 'Contra o relógio';

  @override
  String get challengeClockTag => '3 MIN';

  @override
  String get challengeClockDesc =>
      'Resolva o máximo de placas em 3 minutos. Pular custa 10 segundos. Subir de degrau dá +10 s.';

  @override
  String get challengeRestrictedTitle => 'Com restrição';

  @override
  String get challengeRestrictedTag => 'REGRA EXTRA';

  @override
  String get challengeRestrictedDesc =>
      'Cada placa vem com uma regra: sem +, = fixo, operador obrigatório… Você tem 3 vidas.';

  @override
  String get challengeLadder =>
      'Os dois desafios começam no Fácil e sobem um degrau a cada 3 acertos, até chegar ao Difícil. Neles não há dicas nem pausa.';

  @override
  String get challengeRecord => 'RECORDE';

  @override
  String get challengeStreak => 'SEQUÊNCIA';

  @override
  String get challengePlays => 'PARTIDAS';

  @override
  String get challengePlay => 'JOGAR';

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
    return 'degrau $step';
  }

  @override
  String runLives(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vidas',
      one: '1 vida',
      zero: 'sem vidas',
    );
    return '$_temp0';
  }

  @override
  String runSkip(int seconds) {
    return 'PULAR −${seconds}s';
  }

  @override
  String get runSkipLife => 'PULAR −♥';

  @override
  String get ruleTitle => 'REGRA DA PLACA';

  @override
  String ruleForbid(String op) {
    return 'Nesta placa, o $op não pode ser usado.';
  }

  @override
  String ruleRequire(String op) {
    return 'Nesta placa, a igualdade precisa usar o $op.';
  }

  @override
  String ruleEqualsAt(int a, int b) {
    return 'Nesta placa, o = tem que ficar entre o $a e o $b.';
  }

  @override
  String ruleShortForbid(String op) {
    return 'sem $op';
  }

  @override
  String ruleShortRequire(String op) {
    return 'use $op';
  }

  @override
  String ruleShortEquals(int a, int b) {
    return '= entre $a e $b';
  }

  @override
  String get ruleBroken => 'Verdadeira, mas fora da regra';

  @override
  String get runRight => 'CERTO!';

  @override
  String get runRightDetail => 'A próxima placa aparece em instantes.';

  @override
  String runStepUp(int step, int seconds) {
    return 'Você subiu para o degrau $step e ganhou ${seconds}s no relógio.';
  }

  @override
  String get runPlateLost => 'PLACA PERDIDA';

  @override
  String get runPlateLostDetail =>
      'Você perdeu uma vida. Esta é uma solução que segue a regra.';

  @override
  String get runOverClock => 'FIM DO TEMPO';

  @override
  String get runOverLives => 'SEM VIDAS';

  @override
  String runScoreClock(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count placas resolvidas',
      one: '1 placa resolvida',
      zero: 'Nenhuma placa resolvida',
    );
    return '$_temp0';
  }

  @override
  String runScoreStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sequência de $count placas',
      one: 'Sequência de 1 placa',
      zero: 'Nenhuma placa na sequência',
    );
    return '$_temp0';
  }

  @override
  String get runNewRecord => 'NOVO RECORDE!';

  @override
  String runBest(int count) {
    return 'Recorde: $count';
  }

  @override
  String get runPlayAgain => 'JOGAR DE NOVO';

  @override
  String get runNextPlate => 'PRÓXIMA PLACA';

  @override
  String get runLastSolution => 'Uma solução da última placa:';

  @override
  String get coverHaveAccount => 'Já tem conta?';

  @override
  String get coverSignIn => 'Entrar';

  @override
  String get loginGuest => 'Continuar como convidado';

  @override
  String get guestError =>
      'Não foi possível entrar como convidado. Tente de novo.';

  @override
  String get guest => 'Convidado';

  @override
  String get guestSubtitle => 'Progresso salvo só neste aparelho';

  @override
  String get guestCreateAccount => 'Criar conta';

  @override
  String get guestSignOutTitle => 'Sair do modo convidado?';

  @override
  String get guestSignOutBody =>
      'O progresso de convidado será perdido. Crie uma conta antes para guardá-lo.';

  @override
  String get guestSignOutConfirm => 'Sair e perder o progresso';

  @override
  String get remindTitle => 'Salve seu progresso';

  @override
  String get remindFirstGame =>
      'Gostou? Crie uma conta para guardar seus números resolvidos e jogar em qualquer aparelho.';

  @override
  String get remindFirstAchievement =>
      'Primeira conquista! Como convidado, ela fica só neste aparelho. Crie uma conta para não perdê-la.';

  @override
  String remindSolved(int n) {
    return 'Você já resolveu $n placas! Crie uma conta para não perder esse progresso.';
  }

  @override
  String get remindLater => 'Agora não';

  @override
  String get linkTitle => 'Criar conta';

  @override
  String get linkBody =>
      'Tudo o que você fez como convidado vai junto para a conta nova.';

  @override
  String get linkGoogle => 'Continuar com Google';

  @override
  String get linkEmail => 'E-mail';

  @override
  String get linkPassword => 'Senha';

  @override
  String get linkSubmit => 'Criar conta com e-mail';

  @override
  String get linkDone => 'Conta criada! Seu progresso está salvo.';

  @override
  String get linkExistsTitle => 'Essa conta já existe';

  @override
  String get linkExistsBody =>
      'Entrar nela descarta o progresso de convidado deste aparelho.';

  @override
  String get linkExistsConfirm => 'Entrar mesmo assim';

  @override
  String get linkWeakPassword => 'A senha precisa ter pelo menos 6 caracteres.';

  @override
  String get linkInvalidEmail => 'E-mail inválido.';

  @override
  String get linkWrongPassword => 'Senha incorreta para essa conta.';

  @override
  String get linkError => 'Não foi possível criar a conta. Tente de novo.';
}
