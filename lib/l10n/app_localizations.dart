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

  /// No description provided for @coverSheet.
  ///
  /// In pt, this message translates to:
  /// **'FL. 00 · CAPA'**
  String get coverSheet;

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

  /// No description provided for @coverProject.
  ///
  /// In pt, this message translates to:
  /// **'PROJETO'**
  String get coverProject;

  /// No description provided for @coverScale.
  ///
  /// In pt, this message translates to:
  /// **'ESCALA'**
  String get coverScale;

  /// No description provided for @coverYear.
  ///
  /// In pt, this message translates to:
  /// **'ANO'**
  String get coverYear;

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
  /// **'Conjunto de desafios com diferentes dificuldades.'**
  String get modeChallengesDesc;

  /// No description provided for @modeAdventure.
  ///
  /// In pt, this message translates to:
  /// **'Aventura'**
  String get modeAdventure;

  /// No description provided for @modeAdventureDesc.
  ///
  /// In pt, this message translates to:
  /// **'Uma placa por cidade, numa viagem pelo Brasil.'**
  String get modeAdventureDesc;

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

  /// No description provided for @start.
  ///
  /// In pt, this message translates to:
  /// **'COMEÇAR'**
  String get start;

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
  /// **'Toque entre dois números e escolha um operador para ligá-los. O = entra do mesmo jeito, uma única vez.'**
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
  /// **'toque num vão entre números'**
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

  /// No description provided for @gapLabel.
  ///
  /// In pt, this message translates to:
  /// **'vão {n}'**
  String gapLabel(int n);

  /// No description provided for @removeOperator.
  ///
  /// In pt, this message translates to:
  /// **'Remover operador'**
  String get removeOperator;

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

  /// No description provided for @savedSolved.
  ///
  /// In pt, this message translates to:
  /// **'{number} salvo nos seus resolvidos'**
  String savedSolved(String number);

  /// No description provided for @savedCounts.
  ///
  /// In pt, this message translates to:
  /// **'{number} conta como resolvido'**
  String savedCounts(String number);

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

  /// No description provided for @presets.
  ///
  /// In pt, this message translates to:
  /// **'TEMAS PRONTOS'**
  String get presets;

  /// No description provided for @presetBlueprint.
  ///
  /// In pt, this message translates to:
  /// **'Planta'**
  String get presetBlueprint;

  /// No description provided for @presetGraphite.
  ///
  /// In pt, this message translates to:
  /// **'Grafite'**
  String get presetGraphite;

  /// No description provided for @presetSepia.
  ///
  /// In pt, this message translates to:
  /// **'Sépia'**
  String get presetSepia;

  /// No description provided for @presetForest.
  ///
  /// In pt, this message translates to:
  /// **'Floresta'**
  String get presetForest;

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

  /// No description provided for @fontFamily.
  ///
  /// In pt, this message translates to:
  /// **'TIPO DE FONTE'**
  String get fontFamily;

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
  /// **'Toque num vão para ligar dois blocos com + − × ÷ xʸ. Toque num nó para trocar o operador ou aplicar √, !, |x| e outros sobre aquele trecho; ( ) agrupa o trecho.'**
  String get help3;

  /// No description provided for @help4.
  ///
  /// In pt, this message translates to:
  /// **'Logo abaixo da sua fórmula aparece a mesma fórmula em LaTeX. Verificar confere se os dois lados são iguais; Pular troca por outro número ainda não resolvido.'**
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

  /// No description provided for @helpGotIt.
  ///
  /// In pt, this message translates to:
  /// **'ENTENDI'**
  String get helpGotIt;
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
