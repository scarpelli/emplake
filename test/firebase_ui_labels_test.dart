import 'package:emplake/core/firebase_ui_labels.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Portuguese Firebase UI labels use Brazilian wording', () async {
    const delegate = AppFirebaseUILocalizationsDelegate();
    final pt = await delegate.load(const Locale('pt'));
    expect(pt.labels.passwordResetEmailSentText, isNot(contains('Enviámos')));
    expect(pt.labels.confirmDeleteAccountButtonLabel, 'Sim, excluir');
    final en = await delegate.load(const Locale('en'));
    expect(en.labels.forgotPasswordViewTitle, 'Forgotten password');
  });
}
