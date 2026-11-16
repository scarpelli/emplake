# Desenvolvimento

Como o código está organizado, como configurar o Firebase, rodar, testar e publicar o Emplake.

[← documentação](README.md) · [← README do projeto](../README.md)

## Versões

O app usa Flutter 3.50 e Dart 3.14. A `main` continua com `package:flutter/material.dart`. O motivo
está no [README do projeto](../README.md#flutter-350-e-material_ui).

## Estrutura

```
lib/
  main.dart, app.dart          inicialização, tema, idiomas e MaterialApp.router
  core/
    router.dart                rotas (go_router, StatefulShellRoute) e restauração da última página
    prefs.dart                 SharedPreferences como provider do Riverpod
    theme/                     tema "Planta" a partir da cor semente, claro e escuro
    audio/                     efeitos sonoros e música (começam desligados)
    widgets/                   componentes visuais comuns e o indicador de carregamento
    web/                       cor da barra do navegador acompanhando o tema
  data/                        Firestore: perfil, resolvidos, pulados, placa do dia
  features/
    game/domain/               motor: árvore, avaliação exata, solver, catálogo, texto e LaTeX
    game/application/          GameController (Riverpod): seleção, desfazer, relógio, pausa, partida salva
    game/presentation/         árvore animada, paleta, fórmula e LaTeX, folha de resultado
    adventure/ challenges/     trilha da Aventura e Desafios (telas e recordes)
    daily/                     placa do dia, estatísticas do dia e texto para compartilhar
    educational/               lições do modo Educacional
    achievements/              conquistas e o aviso de conquista
    avatar/                    criador do robô do jogador
    auth/                      login (firebase_ui_auth), Google e modo convidado
    cover/ setup/ history/ settings/ help/ shell/
  l10n/                        textos em pt, en e es (ARB e classes geradas)
test/                          testes do motor, do controlador, dos modos e das telas
dev/preview_main.dart          app sem Firebase, com usuário falso, para mexer na interface
tool/gen_arb.py                gera os três ARB a partir de uma tabela única
tool/gen_catalog_test.dart     mantém assets/catalog.json e gera docs/catalogo/
docs/                          game design, catálogo documentado e imagens do README
```

## Configurar o Firebase (plano Spark, gratuito)

1. Em <https://console.firebase.google.com>, crie o projeto no plano Spark.
2. Em **Authentication → Sign-in method**, ative **E-mail/senha**, **Google** e **Anônimo**. O
   anônimo é o modo convidado.
3. Em **Firestore Database**, crie o banco em modo de produção, na região `southamerica-east1`.
4. No terminal, dentro desta pasta:

   ```sh
   firebase login
   dart pub global run flutterfire_cli:flutterfire configure --platforms=web,android
   firebase use --add            # escolha o projeto criado
   firebase deploy --only firestore:rules
   ```

   O `flutterfire configure` substitui o `lib/firebase_options.dart`.

As regras do Firestore estão em [`firestore.rules`](../firestore.rules). Cada jogador lê e escreve só os
próprios documentos. A única coleção compartilhada é `dailyStats`, a contagem da placa do dia, que só
pode crescer.

## Rodar, testar e publicar

```sh
flutter test                                        # testes
flutter analyze                                     # análise estática
flutter run -d chrome                               # app real (precisa do Firebase)
flutter run -d chrome -t dev/preview_main.dart      # sem Firebase, para mexer na interface
flutter run -d chrome -t dev/preview_main.dart --dart-define=PREVIEW_GUEST=true   # começa sem usuário

flutter build web --release
firebase deploy --only hosting
```

O site fica em <https://emplake.web.app>, o site `emplake` do Firebase Hosting definido em
[`firebase.json`](../firebase.json).

No preview, o Firestore não existe. Por isso, a folha de resultado mostra o aviso de que não foi
possível salvar, e a tela de login do firebase_ui_auth só abre no app real.

## Textos e idiomas

Todos os textos visíveis vêm de `lib/l10n/app_pt.arb`, `app_en.arb` e `app_es.arb`, gerados pelo
`flutter_localizations` (`flutter gen-l10n`). A fonte dos três arquivos é a tabela em
[`tool/gen_arb.py`](../tool/gen_arb.py), uma linha por texto com as três traduções lado a lado. Para
acrescentar ou alterar um texto, edite a tabela e rode:

```sh
python tool/gen_arb.py lib/l10n && flutter gen-l10n
```

## Catálogo de placas

O jogo sorteia só placas de [`assets/catalog.json`](../assets/catalog.json), todas com solução
verificada. Para regenerar o catálogo e a documentação em `docs/catalogo/`:

```sh
flutter test tool/gen_catalog_test.dart
```

O teste `test/catalog_test.dart` falha se os documentos ficarem desatualizados.
