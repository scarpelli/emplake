# Documentação do Emplake

| Documento | O que tem |
|---|---|
| [desenvolvimento.md](desenvolvimento.md) | Estrutura do código, configuração do Firebase, como rodar, testar e publicar, textos e idiomas. |
| [modos.md](modos.md) | Game design da Aventura, dos Desafios e da placa do dia: regras, motivos e onde está cada parte no código. |
| [catalogo/README.md](catalogo/README.md) | O catálogo de 150 placas: formato, distribuição, critérios e como regenerar. |
| [catalogo/facil.md](catalogo/facil.md) · [intermediario.md](catalogo/intermediario.md) · [avancado.md](catalogo/avancado.md) · [dificil.md](catalogo/dificil.md) | Cada placa com sua solução: notação linear, LaTeX, valor de cada lado, operadores, se é trivial, número da fase na Aventura e variantes com restrição. |
| [catalogo/licoes.md](catalogo/licoes.md) | As lições do modo Educacional. |

Os arquivos de `catalogo/` são **gerados** por `flutter test tool/gen_catalog_test.dart` a partir de
`assets/catalog.json`. O teste `test/catalog_test.dart` falha se ficarem desatualizados.
