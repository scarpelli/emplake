# Emplake

Engenharia reversa do jogo [Emplake](https://www.cyan-lang.org/emplake/), concebido pelo Prof. Walter A. Carnielli. O objetivo é usar os quatro dígitos da placa, na ordem, para montar uma igualdade verdadeira.

Equipe: Bruna Scarpelli, Gustavo Kis e Ricardo Suzuki.

## Como se joga nesta versão

A expressão é montada como uma **árvore que cresce para cima**:

- toque num **vão** entre dois blocos e escolha `+ − × ÷ xʸ` para ligá-los (a ordem das ligações define o agrupamento);
- o `=` entra num vão, uma única vez, e separa os dois lados;
- toque num **nó** (número ou ramo) para aplicar `−x √ ∛ ! |x| ⌊x⌋ ⌈x⌉`, trocar o operador, pôr `( )` ou remover um operador;
- cada nó mostra o valor calculado na hora, e logo abaixo da fórmula aparece a mesma fórmula renderizada em LaTeX.

| Nível | Operadores |
|---|---|
| Fácil | + − × ÷ ( ) √ ∛ ! xʸ \|x\| ⌊x⌋ ⌈x⌉ (aceita divisão não inteira) |
| Intermediário | + − × ÷ ( ) √ ∛ ! xʸ \|x\| |
| Avançado | + − × ÷ ( ) √ ! \|x\| |
| Difícil | + − × ÷ ( ) \|x\| |

No desktop: `Enter` verifica, `Esc` pula, `Tab` alterna a seleção, `Ctrl+Z` desfaz e `+ - * / ^ = ! ( )` aplicam operadores.

## Estrutura

```
lib/
  main.dart, app.dart          inicialização, tema, idiomas
  core/                        rotas (go_router), tema "Planta", som, preferências
  data/                        Firestore (perfil, resolvidos, pulados)
  features/
    game/domain/               motor: árvore, avaliação exata, texto e LaTeX
    game/application/          GameController (Riverpod): seleção, desfazer, tempo, pausa
    game/presentation/         árvore animada, paleta, fórmula, resultado
    auth/ cover/ setup/ history/ settings/ help/ shell/
  l10n/                        textos em pt, en, es (ARB + gerados)
test/                          testes do motor e do controlador
dev/preview_main.dart          app sem Firebase, com usuário falso (só desenvolvimento)
tool/gen_arb.py                gera os três ARB a partir de uma tabela
```

## Configurar o Firebase (plano Spark, gratuito)

1. Em <https://console.firebase.google.com>, crie o projeto (plano Spark).
2. **Authentication → Sign-in method**: ative **E-mail/senha** e **Google**.
3. **Firestore Database**: crie o banco em modo de produção (região `southamerica-east1`).
4. No terminal, dentro desta pasta:

   ```sh
   firebase login
   dart pub global run flutterfire_cli:flutterfire configure --platforms=web,android
   firebase use --add            # escolha o projeto criado
   firebase deploy --only firestore:rules
   ```

   O `flutterfire configure` substitui o `lib/firebase_options.dart` provisório.

## Rodar e publicar

```sh
flutter test
flutter run -d chrome                               # app real (precisa do Firebase)
flutter run -d chrome -t dev/preview_main.dart      # sem Firebase, para mexer na interface

flutter build web --release
firebase deploy --only hosting
```

O site fica em `https://<id-do-projeto>.web.app`.

## Textos e idiomas

Os textos ficam em `lib/l10n/app_*.arb`. Para acrescentar ou alterar um texto, edite a tabela em `tool/gen_arb.py` e rode:

```sh
python tool/gen_arb.py lib/l10n && flutter gen-l10n
```

## Entrega no AVA

Somente os `.dart` de `lib/` (inclui os gerados em `lib/l10n/` e o `lib/firebase_options.dart`).

## Créditos

Os efeitos sonoros e a música foram sintetizados para este projeto. Os direitos do jogo Emplake são do Prof. Walter A. Carnielli.
