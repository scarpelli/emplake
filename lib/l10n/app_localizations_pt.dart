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
  String get fourDigitNumber => 'NÚMERO DE 4 DÍGITOS';

  @override
  String get typeFourDigits => 'Digite os 4 dígitos.';

  @override
  String get start => 'COMEÇAR';

  @override
  String pointsShort(int points) {
    return '$points pts';
  }

  @override
  String get treeGrowsHint =>
      'a árvore cresce para cima\nconforme você liga os números';

  @override
  String get hintStart =>
      'Toque entre dois números e escolha um operador para ligá-los. O = entra do mesmo jeito, uma única vez.';

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
  String get removeOperator => 'Remover operador';

  @override
  String get toggleParens => 'Parênteses';

  @override
  String get undo => 'Desfazer';

  @override
  String get skip => 'PULAR';

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
  String get points => 'PONTOS';

  @override
  String get total => 'TOTAL';

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
  String get presets => 'TEMAS PRONTOS';

  @override
  String get presetBlueprint => 'Planta';

  @override
  String get presetGraphite => 'Grafite';

  @override
  String get presetSepia => 'Sépia';

  @override
  String get presetForest => 'Floresta';

  @override
  String get seedColor => 'COR SEMENTE';

  @override
  String get pickColor => 'Escolher cor';

  @override
  String get fontSize => 'TAMANHO DA FONTE';

  @override
  String get fontSample => 'Use os quatro dígitos na ordem.';

  @override
  String get fontFamily => 'TIPO DE FONTE';

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
  String get help1 =>
      'Use os quatro dígitos da placa na ordem em que aparecem.';

  @override
  String get help2 =>
      'O = entra entre dois números, uma única vez, e separa os dois lados.';

  @override
  String get help3 =>
      'Toque num vão para ligar dois blocos com + − × ÷ xʸ. Toque num nó para trocar o operador ou aplicar √, !, |x| e outros sobre aquele trecho; ( ) agrupa o trecho.';

  @override
  String get help4 =>
      'Logo abaixo da sua fórmula aparece a mesma fórmula em LaTeX. Verificar confere se os dois lados são iguais; Pular troca por outro número ainda não resolvido.';

  @override
  String get helpEasyOps => 'todos, inclusive ⌊x⌋ ⌈x⌉';

  @override
  String get helpFraction =>
      'Divisão com resultado não inteiro (como 5 ÷ 2) só vale no Fácil.';

  @override
  String get helpGotIt => 'ENTENDI';
}
