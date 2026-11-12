"""Generates lib/l10n/app_{pt,en,es}.arb from one table, keeping keys in sync.

Usage: python tool/gen_arb.py lib/l10n && flutter gen-l10n
"""
import json, sys, os

OUT = sys.argv[1]

# key: (pt, en, es, placeholders-dict or None)
S = {}
def s(key, pt, en, es, ph=None):
    S[key] = (pt, en, es, ph)

STR = {'type': 'String'}
INT = {'type': 'int'}

s('appTitle', 'Emplake', 'Emplake', 'Emplake')
s('soundOn', 'Som ligado', 'Sound on', 'Sonido activado')
s('soundOff', 'Som desligado', 'Sound off', 'Sonido desactivado')
s('soundOffShort', 'som desligado', 'sound off', 'sonido apagado')
s('navHome', 'Início', 'Home', 'Inicio')
s('navHistory', 'Resolvidos', 'Solved', 'Resueltos')
s('navGame', 'Jogo', 'Game', 'Juego')
s('navHelp', 'Ajuda', 'Help', 'Ayuda')
s('navSettings', 'Configurações', 'Settings', 'Ajustes')
s('notFound', 'Página não encontrada.', 'Page not found.', 'Página no encontrada.')
s('back', 'Voltar', 'Back', 'Volver')
s('cancel', 'Cancelar', 'Cancel', 'Cancelar')
s('ok', 'OK', 'OK', 'OK')
s('retry', 'Tentar de novo', 'Try again', 'Reintentar')

# Cover
s('coverSheet', 'FL. 00 · CAPA', 'SH. 00 · COVER', 'HJ. 00 · PORTADA')
s('plateCountry', 'BRASIL', 'BRAZIL', 'BRASIL')
s('coverTagline', 'Use os quatro dígitos da placa, na ordem, para montar uma igualdade verdadeira.',
  'Use the four digits of the plate, in order, to build a true equation.',
  'Usa los cuatro dígitos de la placa, en orden, para formar una igualdad verdadera.')
s('coverTap', 'TOQUE PARA COMEÇAR', 'TAP TO START', 'TOCA PARA EMPEZAR')
s('coverProject', 'PROJETO', 'PROJECT', 'PROYECTO')
s('coverScale', 'ESCALA', 'SCALE', 'ESCALA')
s('coverYear', 'ANO', 'YEAR', 'AÑO')

# Login
s('loginSubtitle', 'Entre para salvar seus números resolvidos.', 'Sign in to save the numbers you solve.',
  'Inicia sesión para guardar los números que resuelvas.')
s('loginTeam', 'EQUIPE', 'TEAM', 'EQUIPO')
s('loginMember', 'INTEGRANTE {n}', 'MEMBER {n}', 'INTEGRANTE {n}', {'n': INT})
s('loginCredit', 'Jogo concebido por Prof. Walter A. Carnielli', 'Game conceived by Prof. Walter A. Carnielli',
  'Juego concebido por el Prof. Walter A. Carnielli')
s('language', 'Idioma', 'Language', 'Idioma')

# Modes
s('greeting', 'OLÁ, {name} · {points} PTS', 'HI, {name} · {points} PTS', 'HOLA, {name} · {points} PTS',
  {'name': STR, 'points': INT})
s('stepOf', 'PASSO {step} DE {total}', 'STEP {step} OF {total}', 'PASO {step} DE {total}', {'step': INT, 'total': INT})
s('modeQuestion', 'Como você quer jogar?', 'How do you want to play?', '¿Cómo quieres jugar?')
s('modeEducational', 'Educacional', 'Educational', 'Educativo')
s('modeEducationalDesc', 'Exemplos resolvidos passo a passo para aprender os operadores.',
  'Step-by-step solved examples to learn the operators.',
  'Ejemplos resueltos paso a paso para aprender los operadores.')
s('modeRandom', 'Aleatório', 'Random', 'Aleatorio')
s('modeRandomDesc', 'Os números são sorteados entre os que você ainda não resolveu.',
  'Numbers are drawn from the ones you have not solved yet.',
  'Los números se sortean entre los que aún no resolviste.')
s('modeSpecific', 'Específico', 'Specific', 'Específico')
s('modeSpecificDesc', 'Você digita o número de 4 dígitos que quer resolver.',
  'You type the 4-digit number you want to solve.',
  'Escribes el número de 4 dígitos que quieres resolver.')
s('modeChallenges', 'Desafios', 'Challenges', 'Desafíos')
s('modeChallengesDesc', 'Conjunto de desafios com diferentes dificuldades.',
  'A set of challenges with different difficulties.',
  'Un conjunto de desafíos con distintas dificultades.')
s('modeAdventure', 'Aventura', 'Adventure', 'Aventura')
s('modeAdventureDesc', 'Uma placa por cidade, numa viagem pelo Brasil.',
  'One plate per city, on a trip across Brazil.',
  'Una placa por ciudad, en un viaje por Brasil.')
s('comingSoon', 'EM BREVE', 'COMING SOON', 'PRÓXIMAMENTE')
s('continueLabel', 'CONTINUAR', 'CONTINUE', 'CONTINUAR')

# Levels
s('modeLabel', 'MODO: {mode}', 'MODE: {mode}', 'MODO: {mode}', {'mode': STR})
s('chooseLevel', 'Escolha o nível', 'Choose the level', 'Elige el nivel')
s('levelEasy', 'Fácil', 'Easy', 'Fácil')
s('levelIntermediate', 'Intermediário', 'Intermediate', 'Intermedio')
s('levelAdvanced', 'Avançado', 'Advanced', 'Avanzado')
s('levelHard', 'Difícil', 'Hard', 'Difícil')
s('levelEasyShort', 'Fácil', 'Easy', 'Fácil')
s('levelIntermediateShort', 'Interm.', 'Interm.', 'Interm.')
s('levelAdvancedShort', 'Avanç.', 'Adv.', 'Avanz.')
s('levelHardShort', 'Difícil', 'Hard', 'Difícil')
s('levelEasyNote', 'Único nível que aceita divisão não inteira (5 ÷ 2).',
  'The only level that accepts non-integer division (5 ÷ 2).',
  'Único nivel que acepta división no entera (5 ÷ 2).')
s('levelIntermediateNote', 'Divisões precisam dar resultado inteiro.', 'Divisions must give an integer result.',
  'Las divisiones deben dar un resultado entero.')
s('levelAdvancedNote', 'Sem raiz cúbica e sem potência.', 'No cube root and no power.', 'Sin raíz cúbica ni potencia.')
s('levelHardNote', 'Só as quatro operações e módulo.', 'Only the four operations and absolute value.',
  'Solo las cuatro operaciones y valor absoluto.')
s('operatorCount', '{count, plural, =1{1 operador} other{{count} operadores}}',
  '{count, plural, =1{1 operator} other{{count} operators}}',
  '{count, plural, =1{1 operador} other{{count} operadores}}', {'count': INT})
s('secondsPerNumber', '{seconds}s por número', '{seconds}s per number', '{seconds}s por número', {'seconds': INT})
s('fourDigitNumber', 'NÚMERO DE 4 DÍGITOS', '4-DIGIT NUMBER', 'NÚMERO DE 4 DÍGITOS')
s('typeFourDigits', 'Digite os 4 dígitos.', 'Type the 4 digits.', 'Escribe los 4 dígitos.')
s('start', 'COMEÇAR', 'START', 'EMPEZAR')

# Game
s('pointsShort', '{points} pts', '{points} pts', '{points} pts', {'points': INT})
s('treeGrowsHint', 'a árvore cresce para cima\nconforme você liga os números',
  'the tree grows upward\nas you link the numbers', 'el árbol crece hacia arriba\na medida que unes los números')
s('hintStart', 'Toque entre dois números e escolha um operador para ligá-los. O = entra do mesmo jeito, uma única vez.',
  'Tap between two numbers and pick an operator to link them. The = goes in the same way, only once.',
  'Toca entre dos números y elige un operador para unirlos. El = entra igual, una sola vez.')
s('paletteBetween', 'ENTRE NÚMEROS', 'BETWEEN NUMBERS', 'ENTRE NÚMEROS')
s('paletteOver', 'SOBRE UM TRECHO', 'ON A SEGMENT', 'SOBRE UN TRAMO')
s('paletteTapGap', 'toque num vão entre números', 'tap a gap between numbers', 'toca un hueco entre números')
s('paletteTapNode', 'toque num número ou ramo', 'tap a number or branch', 'toca un número o rama')
s('paletteGapSelected', 'vão selecionado', 'gap selected', 'hueco seleccionado')
s('paletteNodeSelected', 'nó selecionado: {node}', 'selected node: {node}', 'nodo seleccionado: {node}', {'node': STR})
s('gapLabel', 'vão {n}', 'gap {n}', 'hueco {n}', {'n': INT})
s('removeOperator', 'Remover operador', 'Remove operator', 'Quitar operador')
s('toggleParens', 'Parênteses', 'Parentheses', 'Paréntesis')
s('undo', 'Desfazer', 'Undo', 'Deshacer')
s('skip', 'PULAR', 'SKIP', 'SALTAR')
s('verify', 'VERIFICAR', 'CHECK', 'VERIFICAR')
s('linksLeft', '{count, plural, =1{FALTA 1 LIGAÇÃO} other{FALTAM {count} LIGAÇÕES}}',
  '{count, plural, =1{1 LINK LEFT} other{{count} LINKS LEFT}}',
  '{count, plural, =1{FALTA 1 UNIÓN} other{FALTAN {count} UNIONES}}', {'count': INT})
s('fixError', 'CORRIJA O ERRO', 'FIX THE ERROR', 'CORRIGE EL ERROR')
s('latex', 'LATEX', 'LATEX', 'LATEX')
s('copy', 'Copiar', 'Copy', 'Copiar')
s('copied', 'Copiado!', 'Copied!', '¡Copiado!')
s('pause', 'Pausar', 'Pause', 'Pausar')
s('pausedTitle', 'PAUSADO', 'PAUSED', 'EN PAUSA')
s('pausedBody', 'A árvore fica escondida durante a pausa.', 'The tree is hidden while paused.',
  'El árbol queda oculto durante la pausa.')
s('resume', 'Continuar', 'Resume', 'Continuar')
s('timeUp', 'tempo esgotado', 'time is up', 'se acabó el tiempo')
s('leftSide', 'esquerda {value}', 'left {value}', 'izquierda {value}', {'value': STR})
s('rightSide', 'direita {value}', 'right {value}', 'derecha {value}', {'value': STR})
s('equalityTrue', 'igualdade verdadeira', 'true equation', 'igualdad verdadera')
s('equalityFalse', 'igualdade falsa', 'false equation', 'igualdad falsa')
s('loadingNumber', 'SORTEANDO UM NÚMERO…', 'DRAWING A NUMBER…', 'SORTEANDO UN NÚMERO…')
s('allSolved', 'Você já resolveu todos os números deste nível!', 'You have solved every number on this level!',
  '¡Ya resolviste todos los números de este nivel!')
s('alreadySolved', 'Você já resolveu este número neste nível. Pode jogar de novo, mas sem pontos.',
  'You already solved this number on this level. You can play again, but without points.',
  'Ya resolviste este número en este nivel. Puedes jugar de nuevo, pero sin puntos.')
s('noGame', 'Nenhuma partida em andamento.', 'No game in progress.', 'No hay ninguna partida en curso.')
s('newGame', 'NOVA PARTIDA', 'NEW GAME', 'NUEVA PARTIDA')
s('treeTitleDesktop', 'ÁRVORE DA EXPRESSÃO · clique num nó · Tab alterna',
  'EXPRESSION TREE · click a node · Tab cycles', 'ÁRBOL DE LA EXPRESIÓN · haz clic en un nodo · Tab alterna')
s('formula', 'FÓRMULA', 'FORMULA', 'FÓRMULA')
s('infoNumber', 'NÚMERO', 'NUMBER', 'NÚMERO')
s('infoDigits', 'DÍGITOS', 'DIGITS', 'DÍGITOS')
s('infoMode', 'MODO', 'MODE', 'MODO')
s('infoLevel', 'NÍVEL', 'LEVEL', 'NIVEL')
s('wrongTitle', 'IGUALDADE FALSA', 'FALSE EQUATION', 'IGUALDAD FALSA')
s('wrongBody', 'O lado esquerdo vale {left} e o direito vale {right}. Ajuste e tente de novo.',
  'The left side is {left} and the right side is {right}. Adjust and try again.',
  'El lado izquierdo vale {left} y el derecho vale {right}. Ajusta e inténtalo de nuevo.',
  {'left': STR, 'right': STR})

# Errors
s('errDivisionByZero', 'DIVISÃO POR ZERO', 'DIVISION BY ZERO', 'DIVISIÓN POR CERO')
s('errDivisionByZeroBody', 'Não dá para dividir por zero. Troque o nó destacado.',
  'You cannot divide by zero. Change the highlighted node.', 'No se puede dividir por cero. Cambia el nodo resaltado.')
s('errNonIntegerDivision', 'DIVISÃO NÃO INTEIRA: {a} ÷ {b} = {result}', 'NON-INTEGER DIVISION: {a} ÷ {b} = {result}',
  'DIVISIÓN NO ENTERA: {a} ÷ {b} = {result}', {'a': STR, 'b': STR, 'result': STR})
s('errNonIntegerDivisionBody', 'No nível {level}, toda divisão precisa ter resultado inteiro. Troque o nó destacado ou mude a estrutura.',
  'On the {level} level every division must give an integer. Change the highlighted node or the structure.',
  'En el nivel {level}, toda división debe dar un entero. Cambia el nodo resaltado o la estructura.', {'level': STR})
s('errFactorialDomain', 'FATORIAL INVÁLIDO', 'INVALID FACTORIAL', 'FACTORIAL NO VÁLIDO')
s('errFactorialDomainBody', 'O fatorial só vale para números inteiros de 0 em diante.',
  'Factorial only works for whole numbers from 0 up.', 'El factorial solo vale para enteros desde 0.')
s('errFactorialTooLarge', 'FATORIAL GRANDE DEMAIS', 'FACTORIAL TOO LARGE', 'FACTORIAL DEMASIADO GRANDE')
s('errFactorialTooLargeBody', 'Use o fatorial só até 20!.', 'Use factorial only up to 20!.', 'Usa el factorial solo hasta 20!.')
s('errEvenRoot', 'RAIZ DE NÚMERO NEGATIVO', 'ROOT OF A NEGATIVE NUMBER', 'RAÍZ DE UN NÚMERO NEGATIVO')
s('errEvenRootBody', 'A raiz quadrada de um número negativo não é um número real.',
  'The square root of a negative number is not a real number.', 'La raíz cuadrada de un número negativo no es real.')
s('errZeroNegPower', 'ZERO ELEVADO A NEGATIVO', 'ZERO TO A NEGATIVE POWER', 'CERO ELEVADO A NEGATIVO')
s('errZeroNegPowerBody', '0 elevado a um expoente negativo não está definido.',
  '0 raised to a negative exponent is undefined.', '0 elevado a un exponente negativo no está definido.')
s('errComplexPower', 'POTÊNCIA NÃO REAL', 'NON-REAL POWER', 'POTENCIA NO REAL')
s('errComplexPowerBody', 'Base negativa com expoente não inteiro não dá um número real.',
  'A negative base with a non-integer exponent is not a real number.',
  'Una base negativa con exponente no entero no da un número real.')
s('errTooLarge', 'NÚMERO GRANDE DEMAIS', 'NUMBER TOO LARGE', 'NÚMERO DEMASIADO GRANDE')
s('errTooLargeBody', 'O resultado passou do limite. Tente outra estrutura.',
  'The result went past the limit. Try another structure.', 'El resultado superó el límite. Prueba otra estructura.')
s('errNotAllowed', 'OPERADOR FORA DO NÍVEL', 'OPERATOR NOT IN THIS LEVEL', 'OPERADOR FUERA DEL NIVEL')
s('errNotAllowedBody', 'Esse operador não está liberado neste nível.', 'This operator is not available on this level.',
  'Este operador no está disponible en este nivel.')

# Result
s('resultTrue', 'IGUALDADE VERDADEIRA', 'TRUE EQUATION', 'IGUALDAD VERDADERA')
s('resultTrueDetail', '{value} = {value} · resolvido em {seconds}s', '{value} = {value} · solved in {seconds}s',
  '{value} = {value} · resuelto en {seconds}s', {'value': STR, 'seconds': INT})
s('resultLate', 'CERTO, MAS FORA DO TEMPO', 'RIGHT, BUT OUT OF TIME', 'CORRECTO, PERO FUERA DE TIEMPO')
s('resultLateDetail', '{value} = {value} · o tempo acabou antes de verificar',
  '{value} = {value} · time ran out before checking', '{value} = {value} · el tiempo se acabó antes de verificar',
  {'value': STR})
s('points', 'PONTOS', 'POINTS', 'PUNTOS')
s('total', 'TOTAL', 'TOTAL', 'TOTAL')
s('savedSolved', '{number} salvo nos seus resolvidos', '{number} saved to your solved numbers',
  '{number} guardado en tus resueltos', {'number': STR})
s('savedCounts', '{number} conta como resolvido', '{number} counts as solved', '{number} cuenta como resuelto',
  {'number': STR})
s('savedReplay', '{number} já estava nos seus resolvidos', '{number} was already in your solved numbers',
  '{number} ya estaba en tus resueltos', {'number': STR})
s('saving', 'Salvando…', 'Saving…', 'Guardando…')
s('saveError', 'Não foi possível salvar. Verifique sua conexão.', 'Could not save. Check your connection.',
  'No se pudo guardar. Revisa tu conexión.')
s('menu', 'MENU', 'MENU', 'MENÚ')
s('nextNumber', 'PRÓXIMO NÚMERO', 'NEXT NUMBER', 'SIGUIENTE NÚMERO')

# History
s('historyEyebrow', 'SEU HISTÓRICO', 'YOUR HISTORY', 'TU HISTORIAL')
s('historyTitle', 'Resolvidos', 'Solved', 'Resueltos')
s('historyLoading', 'TRAÇANDO SEU HISTÓRICO…', 'DRAWING YOUR HISTORY…', 'TRAZANDO TU HISTORIAL…')
s('solvedCount', 'RESOLVIDOS', 'SOLVED', 'RESUELTOS')
s('skippedCount', 'PULADOS', 'SKIPPED', 'SALTADOS')
s('filterAll', 'Todos', 'All', 'Todos')
s('historyEmpty', 'Nenhum número resolvido aqui ainda. Que tal começar?', 'No solved numbers here yet. Shall we start?',
  'Aún no hay números resueltos aquí. ¿Empezamos?')
s('historyError', 'Não foi possível carregar seu histórico.', 'Could not load your history.', 'No se pudo cargar tu historial.')
s('today', 'HOJE', 'TODAY', 'HOY')
s('yesterday', 'ONTEM', 'YESTERDAY', 'AYER')
s('latexCopied', 'LaTeX copiado', 'LaTeX copied', 'LaTeX copiado')
s('lateTag', 'FORA DO TEMPO', 'OUT OF TIME', 'FUERA DE TIEMPO')

# Settings
s('settingsEyebrow', 'PREFERÊNCIAS', 'PREFERENCES', 'PREFERENCIAS')
s('settingsTitle', 'Configurações', 'Settings', 'Ajustes')
s('theme', 'TEMA', 'THEME', 'TEMA')
s('themeSystem', 'Sistema', 'System', 'Sistema')
s('themeLight', 'Claro', 'Light', 'Claro')
s('themeDark', 'Escuro', 'Dark', 'Oscuro')
s('themeHint', 'Segue o tema do aparelho até você escolher outro.', 'Follows your device theme until you pick another.',
  'Sigue el tema del dispositivo hasta que elijas otro.')
s('presets', 'TEMAS PRONTOS', 'READY-MADE THEMES', 'TEMAS LISTOS')
s('presetBlueprint', 'Planta', 'Blueprint', 'Plano')
s('presetGraphite', 'Grafite', 'Graphite', 'Grafito')
s('presetSepia', 'Sépia', 'Sepia', 'Sepia')
s('presetForest', 'Floresta', 'Forest', 'Bosque')
s('seedColor', 'COR SEMENTE', 'SEED COLOR', 'COLOR SEMILLA')
s('pickColor', 'Escolher cor', 'Pick a color', 'Elegir color')
s('fontSize', 'TAMANHO DA FONTE', 'FONT SIZE', 'TAMAÑO DE FUENTE')
s('fontSample', 'Use os quatro dígitos na ordem.', 'Use the four digits in order.', 'Usa los cuatro dígitos en orden.')
s('fontFamily', 'TIPO DE FONTE', 'FONT', 'TIPO DE FUENTE')
s('sound', 'SOM', 'SOUND', 'SONIDO')
s('soundEffects', 'Efeitos sonoros', 'Sound effects', 'Efectos de sonido')
s('music', 'Música', 'Music', 'Música')
s('languageSection', 'IDIOMA', 'LANGUAGE', 'IDIOMA')
s('account', 'CONTA', 'ACCOUNT', 'CUENTA')
s('signOut', 'Sair', 'Sign out', 'Cerrar sesión')
s('providerGoogle', 'Google', 'Google', 'Google')
s('providerEmail', 'E-mail', 'Email', 'Correo')
s('player', 'Jogador', 'Player', 'Jugador')

# Help
s('helpTitle', 'COMO JOGAR', 'HOW TO PLAY', 'CÓMO JUGAR')
s('help1', 'Use os quatro dígitos da placa na ordem em que aparecem.', 'Use the four digits of the plate in the order they appear.',
  'Usa los cuatro dígitos de la placa en el orden en que aparecen.')
s('help2', 'O = entra entre dois números, uma única vez, e separa os dois lados.',
  'The = goes between two numbers, only once, and splits the two sides.',
  'El = va entre dos números, una sola vez, y separa los dos lados.')
s('help3', 'Toque num vão para ligar dois blocos com + − × ÷ xʸ. Toque num nó para trocar o operador ou aplicar √, !, |x| e outros sobre aquele trecho; ( ) agrupa o trecho.',
  'Tap a gap to link two blocks with + − × ÷ xʸ. Tap a node to change its operator or apply √, !, |x| and others to that segment; ( ) groups the segment.',
  'Toca un hueco para unir dos bloques con + − × ÷ xʸ. Toca un nodo para cambiar el operador o aplicar √, !, |x| y otros sobre ese tramo; ( ) agrupa el tramo.')
s('help4', 'Logo abaixo da sua fórmula aparece a mesma fórmula em LaTeX. Verificar confere se os dois lados são iguais; Pular troca por outro número ainda não resolvido.',
  'Right below your formula you see the same formula in LaTeX. Check tests whether both sides are equal; Skip swaps to another unsolved number.',
  'Justo debajo de tu fórmula aparece la misma fórmula en LaTeX. Verificar comprueba si ambos lados son iguales; Saltar cambia a otro número sin resolver.')
s('helpEasyOps', 'todos, inclusive ⌊x⌋ ⌈x⌉', 'all, including ⌊x⌋ ⌈x⌉', 'todos, incluso ⌊x⌋ ⌈x⌉')
s('helpFraction', 'Divisão com resultado não inteiro (como 5 ÷ 2) só vale no Fácil.',
  'Division with a non-integer result (like 5 ÷ 2) is only allowed on Easy.',
  'La división con resultado no entero (como 5 ÷ 2) solo vale en Fácil.')
s('helpGotIt', 'ENTENDI', 'GOT IT', 'ENTENDIDO')

os.makedirs(OUT, exist_ok=True)
for idx, lang in enumerate(['pt', 'en', 'es']):
    d = {'@@locale': lang}
    for k, (pt, en, es, ph) in S.items():
        d[k] = (pt, en, es)[idx]
        if lang == 'pt' and ph:
            d['@' + k] = {'placeholders': {n: dict(t) for n, t in ph.items()}}
    with open(os.path.join(OUT, f'app_{lang}.arb'), 'w', encoding='utf-8') as f:
        json.dump(d, f, ensure_ascii=False, indent=2)
        f.write('\n')
print(len(S), 'keys')
