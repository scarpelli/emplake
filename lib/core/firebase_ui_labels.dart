import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class BrazilianFirebaseUILabels extends PtLocalizations {
  const BrazilianFirebaseUILabels();

  @override
  String get cancelLabel => 'Cancelar';

  @override
  String get enterSMSCodeText => 'Digite o código do SMS';

  @override
  String get passwordResetEmailSentText =>
      'Mandamos para o seu email um link para você criar uma senha nova. Confira sua caixa de entrada.';

  @override
  String get signInWithEmailLinkSentText =>
      'Mandamos um link de acesso para o seu email. Abra sua caixa de entrada e toque no link para entrar.';

  @override
  String get uploadButtonText => 'Enviar arquivo';

  @override
  String get invalidVerificationCodeErrorText => 'O código que você digitou não é válido. Tente de novo.';

  @override
  String get ulinkProviderAlertTitle => 'Desvincular provedor';

  @override
  String get confirmUnlinkButtonLabel => 'Desvincular';

  @override
  String get unlinkProviderAlertMessage => 'Tem certeza de que quer desvincular este provedor?';

  @override
  String get confirmDeleteAccountAlertTitle => 'Confirmar exclusão da conta';

  @override
  String get confirmDeleteAccountAlertMessage => 'Tem certeza de que quer excluir sua conta?';

  @override
  String get confirmDeleteAccountButtonLabel => 'Sim, excluir';
}

class AppFirebaseUILocalizationsDelegate extends LocalizationsDelegate<FirebaseUILocalizations> {
  const AppFirebaseUILocalizationsDelegate();

  static const _base = FirebaseUILocalizations.delegate;

  @override
  bool isSupported(Locale locale) => _base.isSupported(locale);

  @override
  Future<FirebaseUILocalizations> load(Locale locale) {
    if (locale.languageCode == 'pt') {
      return SynchronousFuture(FirebaseUILocalizations(locale, const BrazilianFirebaseUILabels()));
    }
    return _base.load(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<FirebaseUILocalizations> old) => false;
}
