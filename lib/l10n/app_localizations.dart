import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In pt, this message translates to:
  /// **'Emplake'**
  String get appTitle;

  /// No description provided for @soundOn.
  ///
  /// In pt, this message translates to:
  /// **'Som ligado'**
  String get soundOn;

  /// No description provided for @soundOff.
  ///
  /// In pt, this message translates to:
  /// **'Som desligado'**
  String get soundOff;

  /// No description provided for @soundOffShort.
  ///
  /// In pt, this message translates to:
  /// **'som desligado'**
  String get soundOffShort;

  /// No description provided for @navHome.
  ///
  /// In pt, this message translates to:
  /// **'Início'**
  String get navHome;

  /// No description provided for @navHistory.
  ///
  /// In pt, this message translates to:
  /// **'Resolvidos'**
  String get navHistory;

  /// No description provided for @navGame.
  ///
  /// In pt, this message translates to:
  /// **'Jogo'**
  String get navGame;

  /// No description provided for @navHelp.
  ///
  /// In pt, this message translates to:
  /// **'Ajuda'**
  String get navHelp;

  /// No description provided for @navSettings.
  ///
  /// In pt, this message translates to:
  /// **'Configurações'**
  String get navSettings;

  /// No description provided for @notFound.
  ///
  /// In pt, this message translates to:
  /// **'Página não encontrada.'**
  String get notFound;

  /// No description provided for @back.
  ///
  /// In pt, this message translates to:
  /// **'Voltar'**
  String get back;

  /// No description provided for @cancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In pt, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @retry.
  ///
  /// In pt, this message translates to:
  /// **'Tentar de novo'**
  String get retry;

  /// No description provided for @plateCountry.
  ///
  /// In pt, this message translates to:
  /// **'BRASIL'**
  String get plateCountry;

  /// No description provided for @coverTagline.
  ///
  /// In pt, this message translates to:
  /// **'Use os quatro dígitos da placa, na ordem, para montar uma igualdade verdadeira.'**
  String get coverTagline;

  /// No description provided for @coverTap.
  ///
  /// In pt, this message translates to:
  /// **'TOQUE PARA COMEÇAR'**
  String get coverTap;

  /// No description provided for @loginSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Entre para salvar seus números resolvidos.'**
  String get loginSubtitle;

  /// No description provided for @loginTeam.
  ///
  /// In pt, this message translates to:
  /// **'EQUIPE'**
  String get loginTeam;

  /// No description provided for @loginMember.
  ///
  /// In pt, this message translates to:
  /// **'INTEGRANTE {n}'**
  String loginMember(int n);

  /// No description provided for @loginCredit.
  ///
  /// In pt, this message translates to:
  /// **'Jogo concebido por Prof. Walter A. Carnielli'**
  String get loginCredit;

  /// No description provided for @language.
  ///
  /// In pt, this message translates to:
  /// **'Idioma'**
  String get language;

  /// No description provided for @loginOr.
  ///
  /// In pt, this message translates to:
  /// **'OU'**
  String get loginOr;

  /// No description provided for @loginGoogle.
  ///
  /// In pt, this message translates to:
  /// **'Entrar com Google'**
  String get loginGoogle;

  /// No description provided for @loginGoogleError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível entrar com o Google. Tente de novo.'**
  String get loginGoogleError;

  /// No description provided for @greeting.
  ///
  /// In pt, this message translates to:
  /// **'OLÁ, {name} · {points} PTS'**
  String greeting(String name, int points);

  /// No description provided for @stepOf.
  ///
  /// In pt, this message translates to:
  /// **'PASSO {step} DE {total}'**
  String stepOf(int step, int total);

  /// No description provided for @modeQuestion.
  ///
  /// In pt, this message translates to:
  /// **'Como você quer jogar?'**
  String get modeQuestion;

  /// No description provided for @modeEducational.
  ///
  /// In pt, this message translates to:
  /// **'Educacional'**
  String get modeEducational;

  /// No description provided for @modeEducationalDesc.
  ///
  /// In pt, this message translates to:
  /// **'Exemplos resolvidos passo a passo para aprender os operadores.'**
  String get modeEducationalDesc;

  /// No description provided for @modeRandom.
  ///
  /// In pt, this message translates to:
  /// **'Aleatório'**
  String get modeRandom;

  /// No description provided for @modeRandomDesc.
  ///
  /// In pt, this message translates to:
  /// **'Os números são sorteados entre os que você ainda não resolveu.'**
  String get modeRandomDesc;

  /// No description provided for @modeSpecific.
  ///
  /// In pt, this message translates to:
  /// **'Específico'**
  String get modeSpecific;

  /// No description provided for @modeSpecificDesc.
  ///
  /// In pt, this message translates to:
  /// **'Você digita o número de 4 dígitos que quer resolver.'**
  String get modeSpecificDesc;

  /// No description provided for @modeChallenges.
  ///
  /// In pt, this message translates to:
  /// **'Desafios'**
  String get modeChallenges;

  /// No description provided for @modeChallengesDesc.
  ///
  /// In pt, this message translates to:
  /// **'Jogue contra o relógio ou com uma regra extra em cada placa, e tente bater os seus recordes.'**
  String get modeChallengesDesc;

  /// No description provided for @modeAdventure.
  ///
  /// In pt, this message translates to:
  /// **'Aventura'**
  String get modeAdventure;

  /// No description provided for @modeAdventureDesc.
  ///
  /// In pt, this message translates to:
  /// **'Todas as placas do jogo numa trilha, do Fácil ao Difícil. Cada fase vale até 3 estrelas.'**
  String get modeAdventureDesc;

  /// No description provided for @modeDaily.
  ///
  /// In pt, this message translates to:
  /// **'Placa do dia'**
  String get modeDaily;

  /// No description provided for @modeDailyDesc.
  ///
  /// In pt, this message translates to:
  /// **'O mesmo número para todo mundo hoje. Uma tentativa; compartilhe o resultado.'**
  String get modeDailyDesc;

  /// No description provided for @dailyAlreadyPlayed.
  ///
  /// In pt, this message translates to:
  /// **'Você já jogou a placa de hoje. Volte amanhã para uma nova!'**
  String get dailyAlreadyPlayed;

  /// No description provided for @dailyCopy.
  ///
  /// In pt, this message translates to:
  /// **'COPIAR RESULTADO'**
  String get dailyCopy;

  /// No description provided for @blindShort.
  ///
  /// In pt, this message translates to:
  /// **'às cegas'**
  String get blindShort;

  /// No description provided for @hintsCount.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =0{sem dicas} =1{1 dica} other{{count} dicas}}'**
  String hintsCount(int count);

  /// No description provided for @streakShort.
  ///
  /// In pt, this message translates to:
  /// **'🔥 {count}'**
  String streakShort(int count);

  /// No description provided for @comingSoon.
  ///
  /// In pt, this message translates to:
  /// **'EM BREVE'**
  String get comingSoon;

  /// No description provided for @continueLabel.
  ///
  /// In pt, this message translates to:
  /// **'CONTINUAR'**
  String get continueLabel;

  /// No description provided for @modeLabel.
  ///
  /// In pt, this message translates to:
  /// **'MODO: {mode}'**
  String modeLabel(String mode);

  /// No description provided for @chooseLevel.
  ///
  /// In pt, this message translates to:
  /// **'Escolha o nível'**
  String get chooseLevel;

  /// No description provided for @levelEasy.
  ///
  /// In pt, this message translates to:
  /// **'Fácil'**
  String get levelEasy;

  /// No description provided for @levelIntermediate.
  ///
  /// In pt, this message translates to:
  /// **'Intermediário'**
  String get levelIntermediate;

  /// No description provided for @levelAdvanced.
  ///
  /// In pt, this message translates to:
  /// **'Avançado'**
  String get levelAdvanced;

  /// No description provided for @levelHard.
  ///
  /// In pt, this message translates to:
  /// **'Difícil'**
  String get levelHard;

  /// No description provided for @levelEasyShort.
  ///
  /// In pt, this message translates to:
  /// **'Fácil'**
  String get levelEasyShort;

  /// No description provided for @levelIntermediateShort.
  ///
  /// In pt, this message translates to:
  /// **'Interm.'**
  String get levelIntermediateShort;

  /// No description provided for @levelAdvancedShort.
  ///
  /// In pt, this message translates to:
  /// **'Avanç.'**
  String get levelAdvancedShort;

  /// No description provided for @levelHardShort.
  ///
  /// In pt, this message translates to:
  /// **'Difícil'**
  String get levelHardShort;

  /// No description provided for @levelEasyNote.
  ///
  /// In pt, this message translates to:
  /// **'Único nível que aceita divisão não inteira (5 ÷ 2).'**
  String get levelEasyNote;

  /// No description provided for @levelIntermediateNote.
  ///
  /// In pt, this message translates to:
  /// **'Divisões precisam dar resultado inteiro.'**
  String get levelIntermediateNote;

  /// No description provided for @levelAdvancedNote.
  ///
  /// In pt, this message translates to:
  /// **'Sem raiz cúbica e sem potência.'**
  String get levelAdvancedNote;

  /// No description provided for @levelHardNote.
  ///
  /// In pt, this message translates to:
  /// **'Só as quatro operações e módulo.'**
  String get levelHardNote;

  /// No description provided for @operatorCount.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 operador} other{{count} operadores}}'**
  String operatorCount(int count);

  /// No description provided for @secondsPerNumber.
  ///
  /// In pt, this message translates to:
  /// **'{seconds}s por número'**
  String secondsPerNumber(int seconds);

  /// No description provided for @levelBasePoints.
  ///
  /// In pt, this message translates to:
  /// **'{points} pts base'**
  String levelBasePoints(int points);

  /// No description provided for @fourDigitNumber.
  ///
  /// In pt, this message translates to:
  /// **'NÚMERO DE 4 DÍGITOS'**
  String get fourDigitNumber;

  /// No description provided for @typeFourDigits.
  ///
  /// In pt, this message translates to:
  /// **'Digite os 4 dígitos.'**
  String get typeFourDigits;

  /// No description provided for @noSolutionOnLevel.
  ///
  /// In pt, this message translates to:
  /// **'{number} não tem solução no {level}. Tente no: {others}.'**
  String noSolutionOnLevel(String number, String level, String others);

  /// No description provided for @noSolutionAnyLevel.
  ///
  /// In pt, this message translates to:
  /// **'{number} não tem solução em nenhum nível. Escolha outro número.'**
  String noSolutionAnyLevel(String number);

  /// No description provided for @start.
  ///
  /// In pt, this message translates to:
  /// **'COMEÇAR'**
  String get start;

  /// No description provided for @levelProgress.
  ///
  /// In pt, this message translates to:
  /// **'{done} / {total} resolvidos'**
  String levelProgress(int done, int total);

  /// No description provided for @practiceMode.
  ///
  /// In pt, this message translates to:
  /// **'Treino (sem relógio)'**
  String get practiceMode;

  /// No description provided for @practiceModeHint.
  ///
  /// In pt, this message translates to:
  /// **'Jogue no seu ritmo. Não vale pontos e não entra no histórico.'**
  String get practiceModeHint;

  /// No description provided for @practiceShort.
  ///
  /// In pt, this message translates to:
  /// **'treino'**
  String get practiceShort;

  /// No description provided for @practiceTimer.
  ///
  /// In pt, this message translates to:
  /// **'sem relógio'**
  String get practiceTimer;

  /// No description provided for @pointsShort.
  ///
  /// In pt, this message translates to:
  /// **'{points} pts'**
  String pointsShort(int points);

  /// No description provided for @treeGrowsHint.
  ///
  /// In pt, this message translates to:
  /// **'a árvore cresce para cima\nconforme você liga os números'**
  String get treeGrowsHint;

  /// No description provided for @hintStart.
  ///
  /// In pt, this message translates to:
  /// **'Toque entre dois números e escolha um operador, ou arraste o sinal até o vão. O = entra do mesmo jeito, uma única vez. Arraste um sinal para outro vão para movê-lo, ou para fora da árvore para tirá-lo.'**
  String get hintStart;

  /// No description provided for @paletteBetween.
  ///
  /// In pt, this message translates to:
  /// **'ENTRE NÚMEROS'**
  String get paletteBetween;

  /// No description provided for @paletteOver.
  ///
  /// In pt, this message translates to:
  /// **'SOBRE UM TRECHO'**
  String get paletteOver;

  /// No description provided for @paletteTapGap.
  ///
  /// In pt, this message translates to:
  /// **'toque num vão ou num sinal'**
  String get paletteTapGap;

  /// No description provided for @paletteTapNode.
  ///
  /// In pt, this message translates to:
  /// **'toque num número ou ramo'**
  String get paletteTapNode;

  /// No description provided for @paletteGapSelected.
  ///
  /// In pt, this message translates to:
  /// **'vão selecionado'**
  String get paletteGapSelected;

  /// No description provided for @paletteNodeSelected.
  ///
  /// In pt, this message translates to:
  /// **'nó selecionado: {node}'**
  String paletteNodeSelected(String node);

  /// No description provided for @paletteCarrying.
  ///
  /// In pt, this message translates to:
  /// **'levando {sign}: toque num vão'**
  String paletteCarrying(String sign);

  /// No description provided for @gapLabel.
  ///
  /// In pt, this message translates to:
  /// **'vão {n}'**
  String gapLabel(int n);

  /// No description provided for @removeOperator.
  ///
  /// In pt, this message translates to:
  /// **'Remover sinal'**
  String get removeOperator;

  /// No description provided for @hintTitle.
  ///
  /// In pt, this message translates to:
  /// **'DICA {n} DE 3'**
  String hintTitle(int n);

  /// No description provided for @hintEquals.
  ///
  /// In pt, this message translates to:
  /// **'O = fica entre o {a} e o {b}.'**
  String hintEquals(int a, int b);

  /// No description provided for @hintLink.
  ///
  /// In pt, this message translates to:
  /// **'Comece ligando o {a} e o {b} com {op}.'**
  String hintLink(int a, int b, String op);

  /// No description provided for @hintTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Dica {n} (custa 1/3 dos pontos)'**
  String hintTooltip(int n);

  /// No description provided for @hintTooltipReveal.
  ///
  /// In pt, this message translates to:
  /// **'Revelar a solução (sem pontos)'**
  String get hintTooltipReveal;

  /// No description provided for @hintRevealTitle.
  ///
  /// In pt, this message translates to:
  /// **'REVELAR A SOLUÇÃO?'**
  String get hintRevealTitle;

  /// No description provided for @hintRevealBody.
  ///
  /// In pt, this message translates to:
  /// **'Este número termina sem pontos e volta ao sorteio para você tentar outro dia.'**
  String get hintRevealBody;

  /// No description provided for @secondsLeftA11y.
  ///
  /// In pt, this message translates to:
  /// **'{seconds} segundos restantes'**
  String secondsLeftA11y(int seconds);

  /// No description provided for @tutorialTapGap.
  ///
  /// In pt, this message translates to:
  /// **'Toque no vão entre o {a} e o {b} (o quadradinho tracejado).'**
  String tutorialTapGap(int a, int b);

  /// No description provided for @tutorialPickTimes.
  ///
  /// In pt, this message translates to:
  /// **'Agora escolha × para ligar os dois. Dá também para arrastar o sinal até o vão.'**
  String get tutorialPickTimes;

  /// No description provided for @tutorialLinkThree.
  ///
  /// In pt, this message translates to:
  /// **'A árvore cresceu! Ligue o resultado com o 3: toque no próximo vão.'**
  String get tutorialLinkThree;

  /// No description provided for @tutorialEqualsGap.
  ///
  /// In pt, this message translates to:
  /// **'1 × 2 × 3 vale 6. Toque no último vão para pôr o =.'**
  String get tutorialEqualsGap;

  /// No description provided for @tutorialPickEquals.
  ///
  /// In pt, this message translates to:
  /// **'Escolha o =.'**
  String get tutorialPickEquals;

  /// No description provided for @tutorialVerify.
  ///
  /// In pt, this message translates to:
  /// **'6 = 6! Toque em Verificar para conferir.'**
  String get tutorialVerify;

  /// No description provided for @tutorialOffScript.
  ///
  /// In pt, this message translates to:
  /// **'Tudo bem experimentar! Para seguir o tutorial, use ↶ desfazer até voltar ao passo anterior.'**
  String get tutorialOffScript;

  /// No description provided for @tutorialSkip.
  ///
  /// In pt, this message translates to:
  /// **'PULAR TUTORIAL'**
  String get tutorialSkip;

  /// No description provided for @liveValuesShow.
  ///
  /// In pt, this message translates to:
  /// **'Mostrar valores em tempo real'**
  String get liveValuesShow;

  /// No description provided for @liveValuesHide.
  ///
  /// In pt, this message translates to:
  /// **'Esconder valores em tempo real'**
  String get liveValuesHide;

  /// No description provided for @toggleParens.
  ///
  /// In pt, this message translates to:
  /// **'Parênteses'**
  String get toggleParens;

  /// No description provided for @undo.
  ///
  /// In pt, this message translates to:
  /// **'Desfazer'**
  String get undo;

  /// No description provided for @skip.
  ///
  /// In pt, this message translates to:
  /// **'PULAR'**
  String get skip;

  /// No description provided for @skipTitle.
  ///
  /// In pt, this message translates to:
  /// **'PULAR ESTE NÚMERO?'**
  String get skipTitle;

  /// No description provided for @skipBody.
  ///
  /// In pt, this message translates to:
  /// **'Quer ver uma solução? Se preferir, não revelamos nada: o número volta ao sorteio para você tentar outro dia.'**
  String get skipBody;

  /// No description provided for @skipBodyAdventure.
  ///
  /// In pt, this message translates to:
  /// **'Quer ver uma solução? Se preferir, não revelamos nada: a fase continua aberta na trilha para você tentar depois.'**
  String get skipBodyAdventure;

  /// No description provided for @skipBodyDaily.
  ///
  /// In pt, this message translates to:
  /// **'Quer ver uma solução? Pulando, a tentativa de hoje termina; amanhã tem outra placa.'**
  String get skipBodyDaily;

  /// No description provided for @skipBodyRetry.
  ///
  /// In pt, this message translates to:
  /// **'Quer ver uma solução? Se preferir, não revelamos nada e você pode tentar de novo quando quiser.'**
  String get skipBodyRetry;

  /// No description provided for @close.
  ///
  /// In pt, this message translates to:
  /// **'Fechar'**
  String get close;

  /// No description provided for @skipYes.
  ///
  /// In pt, this message translates to:
  /// **'SIM, MOSTRAR'**
  String get skipYes;

  /// No description provided for @skipNo.
  ///
  /// In pt, this message translates to:
  /// **'NÃO, PULAR'**
  String get skipNo;

  /// No description provided for @seeSolution.
  ///
  /// In pt, this message translates to:
  /// **'Ver uma solução'**
  String get seeSolution;

  /// Ação curta no lugar de Pular quando o tempo acaba: ver uma solução.
  ///
  /// In pt, this message translates to:
  /// **'SOLUÇÃO'**
  String get seeSolutionShort;

  /// No description provided for @verify.
  ///
  /// In pt, this message translates to:
  /// **'VERIFICAR'**
  String get verify;

  /// No description provided for @linksLeft.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{FALTA 1 LIGAÇÃO} other{FALTAM {count} LIGAÇÕES}}'**
  String linksLeft(int count);

  /// No description provided for @fixError.
  ///
  /// In pt, this message translates to:
  /// **'CORRIJA O ERRO'**
  String get fixError;

  /// No description provided for @latex.
  ///
  /// In pt, this message translates to:
  /// **'LATEX'**
  String get latex;

  /// No description provided for @copy.
  ///
  /// In pt, this message translates to:
  /// **'Copiar'**
  String get copy;

  /// No description provided for @copied.
  ///
  /// In pt, this message translates to:
  /// **'Copiado!'**
  String get copied;

  /// No description provided for @pause.
  ///
  /// In pt, this message translates to:
  /// **'Pausar'**
  String get pause;

  /// No description provided for @pausedTitle.
  ///
  /// In pt, this message translates to:
  /// **'PAUSADO'**
  String get pausedTitle;

  /// No description provided for @pausedBody.
  ///
  /// In pt, this message translates to:
  /// **'A árvore fica escondida durante a pausa.'**
  String get pausedBody;

  /// No description provided for @resume.
  ///
  /// In pt, this message translates to:
  /// **'Continuar'**
  String get resume;

  /// No description provided for @timeUp.
  ///
  /// In pt, this message translates to:
  /// **'tempo esgotado'**
  String get timeUp;

  /// No description provided for @leftSide.
  ///
  /// In pt, this message translates to:
  /// **'esquerda {value}'**
  String leftSide(String value);

  /// No description provided for @rightSide.
  ///
  /// In pt, this message translates to:
  /// **'direita {value}'**
  String rightSide(String value);

  /// No description provided for @equalityTrue.
  ///
  /// In pt, this message translates to:
  /// **'igualdade verdadeira'**
  String get equalityTrue;

  /// No description provided for @equalityFalse.
  ///
  /// In pt, this message translates to:
  /// **'igualdade falsa'**
  String get equalityFalse;

  /// No description provided for @loadingNumber.
  ///
  /// In pt, this message translates to:
  /// **'SORTEANDO UM NÚMERO…'**
  String get loadingNumber;

  /// No description provided for @allSolved.
  ///
  /// In pt, this message translates to:
  /// **'Você já resolveu todos os números deste nível!'**
  String get allSolved;

  /// No description provided for @allSolvedCatalog.
  ///
  /// In pt, this message translates to:
  /// **'Você resolveu todos os números deste nível por enquanto! Tente outro nível ou digite um número no modo Específico.'**
  String get allSolvedCatalog;

  /// No description provided for @alreadySolved.
  ///
  /// In pt, this message translates to:
  /// **'Você já resolveu este número neste nível. Pode jogar de novo, mas sem pontos.'**
  String get alreadySolved;

  /// No description provided for @noGame.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma partida em andamento.'**
  String get noGame;

  /// No description provided for @newGame.
  ///
  /// In pt, this message translates to:
  /// **'NOVA PARTIDA'**
  String get newGame;

  /// No description provided for @treeTitleDesktop.
  ///
  /// In pt, this message translates to:
  /// **'ÁRVORE DA EXPRESSÃO · clique num nó · Tab alterna'**
  String get treeTitleDesktop;

  /// No description provided for @formula.
  ///
  /// In pt, this message translates to:
  /// **'FÓRMULA'**
  String get formula;

  /// No description provided for @infoNumber.
  ///
  /// In pt, this message translates to:
  /// **'NÚMERO'**
  String get infoNumber;

  /// No description provided for @infoDigits.
  ///
  /// In pt, this message translates to:
  /// **'DÍGITOS'**
  String get infoDigits;

  /// No description provided for @infoMode.
  ///
  /// In pt, this message translates to:
  /// **'MODO'**
  String get infoMode;

  /// No description provided for @infoLevel.
  ///
  /// In pt, this message translates to:
  /// **'NÍVEL'**
  String get infoLevel;

  /// No description provided for @wrongTitle.
  ///
  /// In pt, this message translates to:
  /// **'IGUALDADE FALSA'**
  String get wrongTitle;

  /// No description provided for @wrongBody.
  ///
  /// In pt, this message translates to:
  /// **'O lado esquerdo vale {left} e o direito vale {right}. Ajuste e tente de novo.'**
  String wrongBody(String left, String right);

  /// No description provided for @errDivisionByZero.
  ///
  /// In pt, this message translates to:
  /// **'DIVISÃO POR ZERO'**
  String get errDivisionByZero;

  /// No description provided for @errDivisionByZeroBody.
  ///
  /// In pt, this message translates to:
  /// **'Não dá para dividir por zero. Troque o nó destacado.'**
  String get errDivisionByZeroBody;

  /// No description provided for @errNonIntegerDivision.
  ///
  /// In pt, this message translates to:
  /// **'DIVISÃO NÃO INTEIRA: {a} ÷ {b} = {result}'**
  String errNonIntegerDivision(String a, String b, String result);

  /// No description provided for @errNonIntegerDivisionBody.
  ///
  /// In pt, this message translates to:
  /// **'No nível {level}, toda divisão precisa ter resultado inteiro. Troque o nó destacado ou mude a estrutura.'**
  String errNonIntegerDivisionBody(String level);

  /// No description provided for @errFactorialDomain.
  ///
  /// In pt, this message translates to:
  /// **'FATORIAL INVÁLIDO'**
  String get errFactorialDomain;

  /// No description provided for @errFactorialDomainBody.
  ///
  /// In pt, this message translates to:
  /// **'O fatorial só vale para números inteiros de 0 em diante.'**
  String get errFactorialDomainBody;

  /// No description provided for @errFactorialTooLarge.
  ///
  /// In pt, this message translates to:
  /// **'FATORIAL GRANDE DEMAIS'**
  String get errFactorialTooLarge;

  /// No description provided for @errFactorialTooLargeBody.
  ///
  /// In pt, this message translates to:
  /// **'Use o fatorial só até 20!.'**
  String get errFactorialTooLargeBody;

  /// No description provided for @errEvenRoot.
  ///
  /// In pt, this message translates to:
  /// **'RAIZ DE NÚMERO NEGATIVO'**
  String get errEvenRoot;

  /// No description provided for @errEvenRootBody.
  ///
  /// In pt, this message translates to:
  /// **'A raiz quadrada de um número negativo não é um número real.'**
  String get errEvenRootBody;

  /// No description provided for @errZeroNegPower.
  ///
  /// In pt, this message translates to:
  /// **'ZERO ELEVADO A NEGATIVO'**
  String get errZeroNegPower;

  /// No description provided for @errZeroNegPowerBody.
  ///
  /// In pt, this message translates to:
  /// **'0 elevado a um expoente negativo não está definido.'**
  String get errZeroNegPowerBody;

  /// No description provided for @errComplexPower.
  ///
  /// In pt, this message translates to:
  /// **'POTÊNCIA NÃO REAL'**
  String get errComplexPower;

  /// No description provided for @errComplexPowerBody.
  ///
  /// In pt, this message translates to:
  /// **'Base negativa com expoente não inteiro não dá um número real.'**
  String get errComplexPowerBody;

  /// No description provided for @errTooLarge.
  ///
  /// In pt, this message translates to:
  /// **'NÚMERO GRANDE DEMAIS'**
  String get errTooLarge;

  /// No description provided for @errTooLargeBody.
  ///
  /// In pt, this message translates to:
  /// **'O resultado passou do limite. Tente outra estrutura.'**
  String get errTooLargeBody;

  /// No description provided for @errNotAllowed.
  ///
  /// In pt, this message translates to:
  /// **'OPERADOR FORA DO NÍVEL'**
  String get errNotAllowed;

  /// No description provided for @errNotAllowedBody.
  ///
  /// In pt, this message translates to:
  /// **'Esse operador não está liberado neste nível.'**
  String get errNotAllowedBody;

  /// No description provided for @resultTrue.
  ///
  /// In pt, this message translates to:
  /// **'IGUALDADE VERDADEIRA'**
  String get resultTrue;

  /// No description provided for @resultTrueDetail.
  ///
  /// In pt, this message translates to:
  /// **'{value} = {value} · resolvido em {seconds}s'**
  String resultTrueDetail(String value, int seconds);

  /// No description provided for @resultLate.
  ///
  /// In pt, this message translates to:
  /// **'CERTO, MAS FORA DO TEMPO'**
  String get resultLate;

  /// No description provided for @resultLateDetail.
  ///
  /// In pt, this message translates to:
  /// **'{value} = {value} · o tempo acabou antes de verificar'**
  String resultLateDetail(String value);

  /// No description provided for @revealedTitle.
  ///
  /// In pt, this message translates to:
  /// **'UMA SOLUÇÃO POSSÍVEL'**
  String get revealedTitle;

  /// No description provided for @revealedDetail.
  ///
  /// In pt, this message translates to:
  /// **'Sem pontos desta vez. {number} continua no sorteio para você tentar de novo.'**
  String revealedDetail(String number);

  /// No description provided for @revealedDetailAdventure.
  ///
  /// In pt, this message translates to:
  /// **'Sem estrelas desta vez. A fase continua aberta na trilha para você tentar de novo.'**
  String get revealedDetailAdventure;

  /// No description provided for @revealedDetailDaily.
  ///
  /// In pt, this message translates to:
  /// **'Sem pontos desta vez. Amanhã tem outra placa.'**
  String get revealedDetailDaily;

  /// No description provided for @revealedDetailRetry.
  ///
  /// In pt, this message translates to:
  /// **'Sem pontos desta vez. Você pode tentar de novo quando quiser.'**
  String get revealedDetailRetry;

  /// No description provided for @points.
  ///
  /// In pt, this message translates to:
  /// **'PONTOS'**
  String get points;

  /// No description provided for @total.
  ///
  /// In pt, this message translates to:
  /// **'TOTAL'**
  String get total;

  /// No description provided for @achievementUnlocked.
  ///
  /// In pt, this message translates to:
  /// **'Conquista: {title}'**
  String achievementUnlocked(String title);

  /// No description provided for @achievementBanner.
  ///
  /// In pt, this message translates to:
  /// **'CONQUISTA DESBLOQUEADA'**
  String get achievementBanner;

  /// No description provided for @savedReplay.
  ///
  /// In pt, this message translates to:
  /// **'{number} já estava nos seus resolvidos'**
  String savedReplay(String number);

  /// No description provided for @saving.
  ///
  /// In pt, this message translates to:
  /// **'Salvando…'**
  String get saving;

  /// No description provided for @saveError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível salvar. Verifique sua conexão.'**
  String get saveError;

  /// No description provided for @menu.
  ///
  /// In pt, this message translates to:
  /// **'MENU'**
  String get menu;

  /// No description provided for @nextNumber.
  ///
  /// In pt, this message translates to:
  /// **'PRÓXIMO NÚMERO'**
  String get nextNumber;

  /// No description provided for @historyEyebrow.
  ///
  /// In pt, this message translates to:
  /// **'SEU HISTÓRICO'**
  String get historyEyebrow;

  /// No description provided for @historyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Resolvidos'**
  String get historyTitle;

  /// No description provided for @historyLoading.
  ///
  /// In pt, this message translates to:
  /// **'TRAÇANDO SEU HISTÓRICO…'**
  String get historyLoading;

  /// No description provided for @solvedCount.
  ///
  /// In pt, this message translates to:
  /// **'RESOLVIDOS'**
  String get solvedCount;

  /// No description provided for @skippedCount.
  ///
  /// In pt, this message translates to:
  /// **'PULADOS'**
  String get skippedCount;

  /// No description provided for @filterAll.
  ///
  /// In pt, this message translates to:
  /// **'Todos'**
  String get filterAll;

  /// No description provided for @historyEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum número resolvido aqui ainda. Que tal começar?'**
  String get historyEmpty;

  /// No description provided for @historyError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar seu histórico.'**
  String get historyError;

  /// No description provided for @today.
  ///
  /// In pt, this message translates to:
  /// **'HOJE'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In pt, this message translates to:
  /// **'ONTEM'**
  String get yesterday;

  /// No description provided for @latexCopied.
  ///
  /// In pt, this message translates to:
  /// **'LaTeX copiado'**
  String get latexCopied;

  /// No description provided for @lateTag.
  ///
  /// In pt, this message translates to:
  /// **'FORA DO TEMPO'**
  String get lateTag;

  /// No description provided for @skippedEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum número pulado. Quando pular um, ele aparece aqui para você tentar de novo.'**
  String get skippedEmpty;

  /// No description provided for @skippedTimes.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{pulado 1 vez} other{pulado {count} vezes}}'**
  String skippedTimes(int count);

  /// No description provided for @skippedRevealed.
  ///
  /// In pt, this message translates to:
  /// **'solução vista'**
  String get skippedRevealed;

  /// No description provided for @tryAgain.
  ///
  /// In pt, this message translates to:
  /// **'TENTAR'**
  String get tryAgain;

  /// No description provided for @achievementsTitle.
  ///
  /// In pt, this message translates to:
  /// **'CONQUISTAS · {count}/{total}'**
  String achievementsTitle(int count, int total);

  /// No description provided for @achievementUnlockedShort.
  ///
  /// In pt, this message translates to:
  /// **'desbloqueada'**
  String get achievementUnlockedShort;

  /// No description provided for @achievementLocked.
  ///
  /// In pt, this message translates to:
  /// **'bloqueada'**
  String get achievementLocked;

  /// No description provided for @achFirstSolve.
  ///
  /// In pt, this message translates to:
  /// **'Primeira placa'**
  String get achFirstSolve;

  /// No description provided for @achFirstSolveDesc.
  ///
  /// In pt, this message translates to:
  /// **'Resolva o seu primeiro número.'**
  String get achFirstSolveDesc;

  /// No description provided for @achTenInTime.
  ///
  /// In pt, this message translates to:
  /// **'Contra o relógio'**
  String get achTenInTime;

  /// No description provided for @achTenInTimeDesc.
  ///
  /// In pt, this message translates to:
  /// **'Resolva 10 números dentro do tempo.'**
  String get achTenInTimeDesc;

  /// No description provided for @achBlind.
  ///
  /// In pt, this message translates to:
  /// **'Às cegas'**
  String get achBlind;

  /// No description provided for @achBlindDesc.
  ///
  /// In pt, this message translates to:
  /// **'Resolva um número sem os valores em tempo real.'**
  String get achBlindDesc;

  /// No description provided for @achThreeStars.
  ///
  /// In pt, this message translates to:
  /// **'Osso duro'**
  String get achThreeStars;

  /// No description provided for @achThreeStarsDesc.
  ///
  /// In pt, this message translates to:
  /// **'Resolva um número ★3.'**
  String get achThreeStarsDesc;

  /// No description provided for @achAllLevels.
  ///
  /// In pt, this message translates to:
  /// **'Escada completa'**
  String get achAllLevels;

  /// No description provided for @achAllLevelsDesc.
  ///
  /// In pt, this message translates to:
  /// **'Resolva um número em cada nível.'**
  String get achAllLevelsDesc;

  /// No description provided for @achStreak5.
  ///
  /// In pt, this message translates to:
  /// **'Embalado'**
  String get achStreak5;

  /// No description provided for @achStreak5Desc.
  ///
  /// In pt, this message translates to:
  /// **'Acerte 5 seguidos, no tempo e sem dicas.'**
  String get achStreak5Desc;

  /// No description provided for @achDaily7.
  ///
  /// In pt, this message translates to:
  /// **'Semana cheia'**
  String get achDaily7;

  /// No description provided for @achDaily7Desc.
  ///
  /// In pt, this message translates to:
  /// **'Resolva a placa do dia 7 dias seguidos.'**
  String get achDaily7Desc;

  /// No description provided for @achHundred.
  ///
  /// In pt, this message translates to:
  /// **'Centena'**
  String get achHundred;

  /// No description provided for @achHundredDesc.
  ///
  /// In pt, this message translates to:
  /// **'Resolva 100 números.'**
  String get achHundredDesc;

  /// No description provided for @settingsEyebrow.
  ///
  /// In pt, this message translates to:
  /// **'PREFERÊNCIAS'**
  String get settingsEyebrow;

  /// No description provided for @settingsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Configurações'**
  String get settingsTitle;

  /// No description provided for @theme.
  ///
  /// In pt, this message translates to:
  /// **'TEMA'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In pt, this message translates to:
  /// **'Sistema'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In pt, this message translates to:
  /// **'Claro'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In pt, this message translates to:
  /// **'Escuro'**
  String get themeDark;

  /// No description provided for @themeHint.
  ///
  /// In pt, this message translates to:
  /// **'Segue o tema do aparelho até você escolher outro.'**
  String get themeHint;

  /// No description provided for @settingsGame.
  ///
  /// In pt, this message translates to:
  /// **'JOGO'**
  String get settingsGame;

  /// No description provided for @settingsLiveValues.
  ///
  /// In pt, this message translates to:
  /// **'Valores em tempo real'**
  String get settingsLiveValues;

  /// No description provided for @settingsLiveValuesHint.
  ///
  /// In pt, this message translates to:
  /// **'Mostra quanto vale cada ramo e cada lado do = enquanto você monta.'**
  String get settingsLiveValuesHint;

  /// No description provided for @settingsHaptics.
  ///
  /// In pt, this message translates to:
  /// **'Vibração'**
  String get settingsHaptics;

  /// No description provided for @settingsReduceMotion.
  ///
  /// In pt, this message translates to:
  /// **'Reduzir animações'**
  String get settingsReduceMotion;

  /// No description provided for @settingsReduceMotionHint.
  ///
  /// In pt, this message translates to:
  /// **'Desliga as animações da árvore, da comemoração e das dicas.'**
  String get settingsReduceMotionHint;

  /// No description provided for @settingsHints.
  ///
  /// In pt, this message translates to:
  /// **'Tutorial da primeira partida'**
  String get settingsHints;

  /// No description provided for @settingsHintsHint.
  ///
  /// In pt, this message translates to:
  /// **'Ligue para refazer o passo a passo (1 × 2 × 3 = 6) na próxima partida.'**
  String get settingsHintsHint;

  /// No description provided for @seedColor.
  ///
  /// In pt, this message translates to:
  /// **'COR SEMENTE'**
  String get seedColor;

  /// No description provided for @pickColor.
  ///
  /// In pt, this message translates to:
  /// **'Escolher cor'**
  String get pickColor;

  /// No description provided for @fontSize.
  ///
  /// In pt, this message translates to:
  /// **'TAMANHO DA FONTE'**
  String get fontSize;

  /// No description provided for @fontSample.
  ///
  /// In pt, this message translates to:
  /// **'Use os quatro dígitos na ordem.'**
  String get fontSample;

  /// No description provided for @sound.
  ///
  /// In pt, this message translates to:
  /// **'SOM'**
  String get sound;

  /// No description provided for @soundEffects.
  ///
  /// In pt, this message translates to:
  /// **'Efeitos sonoros'**
  String get soundEffects;

  /// No description provided for @music.
  ///
  /// In pt, this message translates to:
  /// **'Música'**
  String get music;

  /// No description provided for @languageSection.
  ///
  /// In pt, this message translates to:
  /// **'IDIOMA'**
  String get languageSection;

  /// No description provided for @account.
  ///
  /// In pt, this message translates to:
  /// **'CONTA'**
  String get account;

  /// No description provided for @signOut.
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get signOut;

  /// No description provided for @settingsReset.
  ///
  /// In pt, this message translates to:
  /// **'RESTAURAR PADRÃO'**
  String get settingsReset;

  /// No description provided for @settingsResetTitle.
  ///
  /// In pt, this message translates to:
  /// **'Restaurar as configurações padrão?'**
  String get settingsResetTitle;

  /// No description provided for @settingsResetBody.
  ///
  /// In pt, this message translates to:
  /// **'Tema, cor, tamanho do texto, opções de jogo, som e idioma voltam ao padrão. Seu progresso, pontos e recordes não mudam.'**
  String get settingsResetBody;

  /// No description provided for @providerGoogle.
  ///
  /// In pt, this message translates to:
  /// **'Google'**
  String get providerGoogle;

  /// No description provided for @providerEmail.
  ///
  /// In pt, this message translates to:
  /// **'E-mail'**
  String get providerEmail;

  /// No description provided for @player.
  ///
  /// In pt, this message translates to:
  /// **'Jogador'**
  String get player;

  /// No description provided for @helpTitle.
  ///
  /// In pt, this message translates to:
  /// **'COMO JOGAR'**
  String get helpTitle;

  /// No description provided for @helpTabPlay.
  ///
  /// In pt, this message translates to:
  /// **'JOGAR'**
  String get helpTabPlay;

  /// No description provided for @helpTabOperators.
  ///
  /// In pt, this message translates to:
  /// **'OPERADORES'**
  String get helpTabOperators;

  /// No description provided for @helpTabScoring.
  ///
  /// In pt, this message translates to:
  /// **'PONTOS'**
  String get helpTabScoring;

  /// No description provided for @helpExample.
  ///
  /// In pt, this message translates to:
  /// **'EXEMPLO'**
  String get helpExample;

  /// No description provided for @helpExampleCaption.
  ///
  /// In pt, this message translates to:
  /// **'1236 → 1 × 2 × 3 = 6. Cada ligação sobe um andar na árvore.'**
  String get helpExampleCaption;

  /// No description provided for @helpKeys.
  ///
  /// In pt, this message translates to:
  /// **'TECLADO'**
  String get helpKeys;

  /// No description provided for @helpKeysList.
  ///
  /// In pt, this message translates to:
  /// **'Enter verificar · Esc pular · Tab seleção · Ctrl+Z desfazer · ⌫ remover · H dica\n+ − * / ^ = ( ) operadores · ! fatorial · r √ · c ∛ · a |x| · n −x · f ⌊x⌋ · F ⌈x⌉'**
  String get helpKeysList;

  /// No description provided for @helpOperatorsIntro.
  ///
  /// In pt, this message translates to:
  /// **'Os binários (+ − × ÷ xʸ) ligam dois blocos num vão. Os outros agem sobre um trecho: toque num número ou ramo e escolha.'**
  String get helpOperatorsIntro;

  /// No description provided for @opAdd.
  ///
  /// In pt, this message translates to:
  /// **'Soma'**
  String get opAdd;

  /// No description provided for @opSub.
  ///
  /// In pt, this message translates to:
  /// **'Subtração'**
  String get opSub;

  /// No description provided for @opMul.
  ///
  /// In pt, this message translates to:
  /// **'Multiplicação'**
  String get opMul;

  /// No description provided for @opDiv.
  ///
  /// In pt, this message translates to:
  /// **'Divisão'**
  String get opDiv;

  /// No description provided for @opPow.
  ///
  /// In pt, this message translates to:
  /// **'Potência'**
  String get opPow;

  /// No description provided for @opNeg.
  ///
  /// In pt, this message translates to:
  /// **'Oposto (troca o sinal)'**
  String get opNeg;

  /// No description provided for @opSqrt.
  ///
  /// In pt, this message translates to:
  /// **'Raiz quadrada'**
  String get opSqrt;

  /// No description provided for @opCbrt.
  ///
  /// In pt, this message translates to:
  /// **'Raiz cúbica'**
  String get opCbrt;

  /// No description provided for @opFact.
  ///
  /// In pt, this message translates to:
  /// **'Fatorial'**
  String get opFact;

  /// No description provided for @opAbs.
  ///
  /// In pt, this message translates to:
  /// **'Módulo (valor absoluto)'**
  String get opAbs;

  /// No description provided for @opFloor.
  ///
  /// In pt, this message translates to:
  /// **'Piso (arredonda para baixo)'**
  String get opFloor;

  /// No description provided for @opCeil.
  ///
  /// In pt, this message translates to:
  /// **'Teto (arredonda para cima)'**
  String get opCeil;

  /// No description provided for @lessonsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Aprender os operadores'**
  String get lessonsTitle;

  /// No description provided for @lessonsEyebrow.
  ///
  /// In pt, this message translates to:
  /// **'{done} DE {total} LIÇÕES'**
  String lessonsEyebrow(int done, int total);

  /// No description provided for @lessonsIntro.
  ///
  /// In pt, this message translates to:
  /// **'Cada lição mostra uma placa resolvida passo a passo usando um operador. Depois é a sua vez, sem relógio.'**
  String get lessonsIntro;

  /// No description provided for @lessonDone.
  ///
  /// In pt, this message translates to:
  /// **'lição concluída'**
  String get lessonDone;

  /// No description provided for @lessonPrev.
  ///
  /// In pt, this message translates to:
  /// **'Passo anterior'**
  String get lessonPrev;

  /// No description provided for @lessonNext.
  ///
  /// In pt, this message translates to:
  /// **'Próximo passo'**
  String get lessonNext;

  /// No description provided for @lessonPlay.
  ///
  /// In pt, this message translates to:
  /// **'Reproduzir'**
  String get lessonPlay;

  /// No description provided for @lessonNowYou.
  ///
  /// In pt, this message translates to:
  /// **'AGORA VOCÊ'**
  String get lessonNowYou;

  /// No description provided for @lessonStepStart.
  ///
  /// In pt, this message translates to:
  /// **'A placa {number}: quatro dígitos, na ordem.'**
  String lessonStepStart(String number);

  /// No description provided for @lessonStepLink.
  ///
  /// In pt, this message translates to:
  /// **'Ligamos o {a} e o {b} com {op} ({name}).'**
  String lessonStepLink(int a, int b, String op, String name);

  /// No description provided for @lessonStepUnary.
  ///
  /// In pt, this message translates to:
  /// **'Aplicamos {op} ({name}) sobre o trecho.'**
  String lessonStepUnary(String op, String name);

  /// No description provided for @lessonStepEquals.
  ///
  /// In pt, this message translates to:
  /// **'Por fim, o = entre o {a} e o {b}: os dois lados valem o mesmo.'**
  String lessonStepEquals(int a, int b);

  /// No description provided for @help1.
  ///
  /// In pt, this message translates to:
  /// **'Use os quatro dígitos da placa na ordem em que aparecem.'**
  String get help1;

  /// No description provided for @help2.
  ///
  /// In pt, this message translates to:
  /// **'O = entra entre dois números, uma única vez, e separa os dois lados.'**
  String get help2;

  /// No description provided for @help3.
  ///
  /// In pt, this message translates to:
  /// **'Toque num vão (ou arraste um sinal até ele) para ligar dois blocos com + − × ÷ xʸ. Toque num nó para trocar o operador ou aplicar √, !, |x| e outros sobre aquele trecho; ( ) agrupa o trecho. Arraste um sinal ou o = para outro vão para movê-lo; arraste para fora da árvore, ou use ⌫, para tirá-lo.'**
  String get help3;

  /// No description provided for @help4.
  ///
  /// In pt, this message translates to:
  /// **'Abra o LATEX ▾ ao lado da fórmula para vê-la em LaTeX e copiar o código. Verificar confere se os dois lados são iguais. Pular pergunta se você quer ver uma solução; se não quiser, o número volta outro dia.'**
  String get help4;

  /// No description provided for @helpEasyOps.
  ///
  /// In pt, this message translates to:
  /// **'todos, inclusive ⌊x⌋ ⌈x⌉'**
  String get helpEasyOps;

  /// No description provided for @helpFraction.
  ///
  /// In pt, this message translates to:
  /// **'Divisão com resultado não inteiro (como 5 ÷ 2) só vale no Fácil.'**
  String get helpFraction;

  /// No description provided for @helpScoringTitle.
  ///
  /// In pt, this message translates to:
  /// **'PONTUAÇÃO'**
  String get helpScoringTitle;

  /// No description provided for @helpScoringTime.
  ///
  /// In pt, this message translates to:
  /// **'TEMPO'**
  String get helpScoringTime;

  /// No description provided for @helpScoringBaseCol.
  ///
  /// In pt, this message translates to:
  /// **'BASE'**
  String get helpScoringBaseCol;

  /// No description provided for @helpScoringBase.
  ///
  /// In pt, this message translates to:
  /// **'Cada número certo vale os pontos base do nível.'**
  String get helpScoringBase;

  /// No description provided for @helpScoringBonus.
  ///
  /// In pt, this message translates to:
  /// **'Bônus de tempo: +1 ponto a cada 5 segundos que sobram no relógio quando você verifica.'**
  String get helpScoringBonus;

  /// No description provided for @helpScoringExample.
  ///
  /// In pt, this message translates to:
  /// **'Exemplo: no Intermediário ({base} base), verificar com {seconds}s restantes dá {total} pontos.'**
  String helpScoringExample(int base, int seconds, int total);

  /// No description provided for @helpScoringLate.
  ///
  /// In pt, this message translates to:
  /// **'Se o tempo acabar, ainda dá para terminar e o número conta como resolvido, mas vale 0 pontos.'**
  String get helpScoringLate;

  /// No description provided for @helpScoringReplay.
  ///
  /// In pt, this message translates to:
  /// **'Repetir um número que você já resolveu no mesmo nível não dá pontos de novo.'**
  String get helpScoringReplay;

  /// No description provided for @helpScoringHints.
  ///
  /// In pt, this message translates to:
  /// **'Dicas: a 1ª mostra onde vai o = (fica com 2/3 dos pontos), a 2ª uma primeira ligação (1/3), a 3ª revela a solução (0 pontos; o número volta ao sorteio).'**
  String get helpScoringHints;

  /// No description provided for @helpScoringBlind.
  ///
  /// In pt, this message translates to:
  /// **'Às cegas: jogando o número inteiro com os valores em tempo real desligados, os pontos valem ×1,25.'**
  String get helpScoringBlind;

  /// No description provided for @helpScoringStreak.
  ///
  /// In pt, this message translates to:
  /// **'Sequência: cada acerto seguido, no tempo e sem dicas, soma +10% (até +50%). Pular zera a sequência.'**
  String get helpScoringStreak;

  /// No description provided for @helpScoringPractice.
  ///
  /// In pt, this message translates to:
  /// **'Treino e lições não valem pontos.'**
  String get helpScoringPractice;

  /// No description provided for @helpScoringPause.
  ///
  /// In pt, this message translates to:
  /// **'Você tem uma pausa de {seconds}s por número; durante a pausa o relógio para e a árvore fica escondida.'**
  String helpScoringPause(int seconds);

  /// No description provided for @helpGotIt.
  ///
  /// In pt, this message translates to:
  /// **'ENTENDI'**
  String get helpGotIt;

  /// No description provided for @homePage.
  ///
  /// In pt, this message translates to:
  /// **'Página inicial'**
  String get homePage;

  /// No description provided for @adventureCurrent.
  ///
  /// In pt, this message translates to:
  /// **'atual'**
  String get adventureCurrent;

  /// No description provided for @adventureCollapse.
  ///
  /// In pt, this message translates to:
  /// **'Recolher {level}'**
  String adventureCollapse(String level);

  /// No description provided for @adventureExpand.
  ///
  /// In pt, this message translates to:
  /// **'Mostrar {level}'**
  String adventureExpand(String level);

  /// No description provided for @adventureStage.
  ///
  /// In pt, this message translates to:
  /// **'Fase {number}'**
  String adventureStage(int number);

  /// No description provided for @adventureLockedColumn.
  ///
  /// In pt, this message translates to:
  /// **'Abre com {count} fases concluídas no nível anterior.'**
  String adventureLockedColumn(int count);

  /// No description provided for @adventureLockedStage.
  ///
  /// In pt, this message translates to:
  /// **'Esta fase abre quando você concluir as anteriores.'**
  String get adventureLockedStage;

  /// No description provided for @adventureStarsRule.
  ///
  /// In pt, this message translates to:
  /// **'★ quando você resolve, ★★ no tempo e sem dicas, ★★★ com pelo menos metade do tempo sobrando'**
  String get adventureStarsRule;

  /// No description provided for @adventureContinue.
  ///
  /// In pt, this message translates to:
  /// **'CONTINUAR FASE {number}'**
  String adventureContinue(int number);

  /// No description provided for @adventureAllDone.
  ///
  /// In pt, this message translates to:
  /// **'Você completou a trilha inteira!'**
  String get adventureAllDone;

  /// No description provided for @adventureStarsEarned.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =0{Nenhuma estrela} =1{1 estrela} other{{count} estrelas}}'**
  String adventureStarsEarned(int count);

  /// No description provided for @adventureNext.
  ///
  /// In pt, this message translates to:
  /// **'PRÓXIMA FASE'**
  String get adventureNext;

  /// No description provided for @adventureTrail.
  ///
  /// In pt, this message translates to:
  /// **'TRILHA'**
  String get adventureTrail;

  /// No description provided for @adventureStageA11y.
  ///
  /// In pt, this message translates to:
  /// **'Fase {number}, placa {plate}, {state}'**
  String adventureStageA11y(int number, String plate, String state);

  /// No description provided for @adventureStateDone.
  ///
  /// In pt, this message translates to:
  /// **'concluída'**
  String get adventureStateDone;

  /// No description provided for @adventureStateOpen.
  ///
  /// In pt, this message translates to:
  /// **'aberta'**
  String get adventureStateOpen;

  /// No description provided for @adventureStateLocked.
  ///
  /// In pt, this message translates to:
  /// **'bloqueada'**
  String get adventureStateLocked;

  /// No description provided for @adventureOps.
  ///
  /// In pt, this message translates to:
  /// **'operadores'**
  String get adventureOps;

  /// No description provided for @challengeClockTitle.
  ///
  /// In pt, this message translates to:
  /// **'Contra o relógio'**
  String get challengeClockTitle;

  /// No description provided for @challengeClockTag.
  ///
  /// In pt, this message translates to:
  /// **'3 MIN'**
  String get challengeClockTag;

  /// No description provided for @challengeClockDesc.
  ///
  /// In pt, this message translates to:
  /// **'Resolva o máximo de placas em 3 minutos. Pular custa 10 segundos. Subir de degrau dá +10 s.'**
  String get challengeClockDesc;

  /// No description provided for @challengeRestrictedTitle.
  ///
  /// In pt, this message translates to:
  /// **'Com restrição'**
  String get challengeRestrictedTitle;

  /// No description provided for @challengeRestrictedTag.
  ///
  /// In pt, this message translates to:
  /// **'REGRA EXTRA'**
  String get challengeRestrictedTag;

  /// No description provided for @challengeRestrictedDesc.
  ///
  /// In pt, this message translates to:
  /// **'Cada placa vem com uma regra: sem +, = fixo, operador obrigatório… Você tem 3 vidas.'**
  String get challengeRestrictedDesc;

  /// No description provided for @challengeLadder.
  ///
  /// In pt, this message translates to:
  /// **'Os dois desafios começam no Fácil e sobem um degrau a cada 3 acertos, até chegar ao Difícil. Neles não há dicas nem pausa.'**
  String get challengeLadder;

  /// No description provided for @challengeRecord.
  ///
  /// In pt, this message translates to:
  /// **'RECORDE'**
  String get challengeRecord;

  /// No description provided for @challengeStreak.
  ///
  /// In pt, this message translates to:
  /// **'SEQUÊNCIA'**
  String get challengeStreak;

  /// No description provided for @challengePlays.
  ///
  /// In pt, this message translates to:
  /// **'PARTIDAS'**
  String get challengePlays;

  /// No description provided for @challengePlay.
  ///
  /// In pt, this message translates to:
  /// **'JOGAR'**
  String get challengePlay;

  /// No description provided for @runPlates.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =0{0 placas} =1{1 placa} other{{count} placas}}'**
  String runPlates(int count);

  /// No description provided for @runStep.
  ///
  /// In pt, this message translates to:
  /// **'degrau {step}'**
  String runStep(int step);

  /// No description provided for @runLives.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =0{sem vidas} =1{1 vida} other{{count} vidas}}'**
  String runLives(int count);

  /// No description provided for @runSkip.
  ///
  /// In pt, this message translates to:
  /// **'PULAR −{seconds}s'**
  String runSkip(int seconds);

  /// No description provided for @runSkipLife.
  ///
  /// In pt, this message translates to:
  /// **'PULAR −♥'**
  String get runSkipLife;

  /// No description provided for @ruleTitle.
  ///
  /// In pt, this message translates to:
  /// **'REGRA DA PLACA'**
  String get ruleTitle;

  /// No description provided for @ruleForbid.
  ///
  /// In pt, this message translates to:
  /// **'Nesta placa, o {op} não pode ser usado.'**
  String ruleForbid(String op);

  /// No description provided for @ruleRequire.
  ///
  /// In pt, this message translates to:
  /// **'Nesta placa, a igualdade precisa usar o {op}.'**
  String ruleRequire(String op);

  /// No description provided for @ruleEqualsAt.
  ///
  /// In pt, this message translates to:
  /// **'Nesta placa, o = tem que ficar entre o {a} e o {b}.'**
  String ruleEqualsAt(int a, int b);

  /// No description provided for @ruleShortForbid.
  ///
  /// In pt, this message translates to:
  /// **'sem {op}'**
  String ruleShortForbid(String op);

  /// No description provided for @ruleShortRequire.
  ///
  /// In pt, this message translates to:
  /// **'use {op}'**
  String ruleShortRequire(String op);

  /// No description provided for @ruleShortEquals.
  ///
  /// In pt, this message translates to:
  /// **'= entre {a} e {b}'**
  String ruleShortEquals(int a, int b);

  /// No description provided for @ruleBroken.
  ///
  /// In pt, this message translates to:
  /// **'Verdadeira, mas fora da regra'**
  String get ruleBroken;

  /// No description provided for @runRight.
  ///
  /// In pt, this message translates to:
  /// **'CERTO!'**
  String get runRight;

  /// No description provided for @runRightDetail.
  ///
  /// In pt, this message translates to:
  /// **'A próxima placa aparece em instantes.'**
  String get runRightDetail;

  /// No description provided for @runStepUp.
  ///
  /// In pt, this message translates to:
  /// **'Você subiu para o degrau {step} e ganhou {seconds}s no relógio.'**
  String runStepUp(int step, int seconds);

  /// No description provided for @runPlateLost.
  ///
  /// In pt, this message translates to:
  /// **'PLACA PERDIDA'**
  String get runPlateLost;

  /// No description provided for @runPlateLostDetail.
  ///
  /// In pt, this message translates to:
  /// **'Você perdeu uma vida. Esta é uma solução que segue a regra.'**
  String get runPlateLostDetail;

  /// No description provided for @runOverClock.
  ///
  /// In pt, this message translates to:
  /// **'FIM DO TEMPO'**
  String get runOverClock;

  /// No description provided for @runOverLives.
  ///
  /// In pt, this message translates to:
  /// **'SEM VIDAS'**
  String get runOverLives;

  /// No description provided for @runScoreClock.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =0{Nenhuma placa resolvida} =1{1 placa resolvida} other{{count} placas resolvidas}}'**
  String runScoreClock(int count);

  /// No description provided for @runScoreStreak.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =0{Nenhuma placa na sequência} =1{Sequência de 1 placa} other{Sequência de {count} placas}}'**
  String runScoreStreak(int count);

  /// No description provided for @runNewRecord.
  ///
  /// In pt, this message translates to:
  /// **'NOVO RECORDE!'**
  String get runNewRecord;

  /// No description provided for @runBest.
  ///
  /// In pt, this message translates to:
  /// **'Recorde: {count}'**
  String runBest(int count);

  /// No description provided for @runPlayAgain.
  ///
  /// In pt, this message translates to:
  /// **'JOGAR DE NOVO'**
  String get runPlayAgain;

  /// No description provided for @runNextPlate.
  ///
  /// In pt, this message translates to:
  /// **'PRÓXIMA PLACA'**
  String get runNextPlate;

  /// No description provided for @runLastSolution.
  ///
  /// In pt, this message translates to:
  /// **'Uma solução da última placa:'**
  String get runLastSolution;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
