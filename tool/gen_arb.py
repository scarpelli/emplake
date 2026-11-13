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
s('loginOr', 'OU', 'OR', 'O')
s('loginGoogle', 'Entrar com Google', 'Sign in with Google', 'Entrar con Google')
s('loginGoogleError', 'Não foi possível entrar com o Google. Tente de novo.', 'Could not sign in with Google. Please try again.',
  'No se pudo entrar con Google. Inténtalo de nuevo.')

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
s('modeDaily', 'Placa do dia', 'Plate of the day', 'Placa del día')
s('modeDailyDesc', 'O mesmo número para todo mundo hoje. Uma tentativa; compartilhe o resultado.',
  'The same number for everyone today. One attempt; share your result.',
  'El mismo número para todos hoy. Un intento; comparte tu resultado.')
s('dailyAlreadyPlayed', 'Você já jogou a placa de hoje. Volte amanhã para uma nova!',
  'You already played today\'s plate. Come back tomorrow for a new one!',
  'Ya jugaste la placa de hoy. ¡Vuelve mañana por una nueva!')
s('dailyCopy', 'COPIAR RESULTADO', 'COPY RESULT', 'COPIAR RESULTADO')
s('blindShort', 'às cegas', 'blind', 'a ciegas')
s('hintsCount', '{count, plural, =0{sem dicas} =1{1 dica} other{{count} dicas}}',
  '{count, plural, =0{no hints} =1{1 hint} other{{count} hints}}',
  '{count, plural, =0{sin pistas} =1{1 pista} other{{count} pistas}}', {'count': INT})
s('streakShort', '🔥 {count}', '🔥 {count}', '🔥 {count}', {'count': INT})
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
s('levelBasePoints', '{points} pts base', '{points} base pts', '{points} pts base', {'points': INT})
s('fourDigitNumber', 'NÚMERO DE 4 DÍGITOS', '4-DIGIT NUMBER', 'NÚMERO DE 4 DÍGITOS')
s('typeFourDigits', 'Digite os 4 dígitos.', 'Type the 4 digits.', 'Escribe los 4 dígitos.')
s('noSolutionOnLevel', '{number} não tem solução no {level}. Tente no: {others}.',
  '{number} has no solution on {level}. Try: {others}.',
  '{number} no tiene solución en {level}. Prueba en: {others}.',
  {'number': STR, 'level': STR, 'others': STR})
s('noSolutionAnyLevel', '{number} não tem solução em nenhum nível. Escolha outro número.',
  '{number} has no solution on any level. Pick another number.',
  '{number} no tiene solución en ningún nivel. Elige otro número.', {'number': STR})
s('start', 'COMEÇAR', 'START', 'EMPEZAR')
s('levelProgress', '{done} / {total} resolvidos', '{done} / {total} solved', '{done} / {total} resueltos',
  {'done': INT, 'total': INT})
s('practiceMode', 'Treino (sem relógio)', 'Practice (no clock)', 'Práctica (sin reloj)')
s('practiceModeHint', 'Jogue no seu ritmo. Não vale pontos e não entra no histórico.',
  'Play at your own pace. No points and it is not saved to your history.',
  'Juega a tu ritmo. No suma puntos ni se guarda en tu historial.')
s('practiceShort', 'treino', 'practice', 'práctica')
s('practiceTimer', 'sem relógio', 'no clock', 'sin reloj')
s('practiceNoPoints', 'Treino: sem pontos, no seu ritmo.', 'Practice: no points, at your own pace.',
  'Práctica: sin puntos, a tu ritmo.')

# Game
s('pointsShort', '{points} pts', '{points} pts', '{points} pts', {'points': INT})
s('treeGrowsHint', 'a árvore cresce para cima\nconforme você liga os números',
  'the tree grows upward\nas you link the numbers', 'el árbol crece hacia arriba\na medida que unes los números')
s('hintStart', 'Toque entre dois números e escolha um operador, ou arraste o sinal até o vão. O = entra do mesmo jeito, uma única vez. Arraste um sinal para outro vão para movê-lo, ou para fora da árvore para tirá-lo.',
  'Tap between two numbers and pick an operator, or drag the sign onto the gap. The = goes in the same way, only once. Drag a sign to another gap to move it, or off the tree to remove it.',
  'Toca entre dos números y elige un operador, o arrastra el signo al hueco. El = entra igual, una sola vez. Arrastra un signo a otro hueco para moverlo, o fuera del árbol para quitarlo.')
s('paletteBetween', 'ENTRE NÚMEROS', 'BETWEEN NUMBERS', 'ENTRE NÚMEROS')
s('paletteOver', 'SOBRE UM TRECHO', 'ON A SEGMENT', 'SOBRE UN TRAMO')
s('paletteTapGap', 'toque num vão entre números', 'tap a gap between numbers', 'toca un hueco entre números')
s('paletteTapNode', 'toque num número ou ramo', 'tap a number or branch', 'toca un número o rama')
s('paletteGapSelected', 'vão selecionado', 'gap selected', 'hueco seleccionado')
s('paletteNodeSelected', 'nó selecionado: {node}', 'selected node: {node}', 'nodo seleccionado: {node}', {'node': STR})
s('gapLabel', 'vão {n}', 'gap {n}', 'hueco {n}', {'n': INT})
s('removeOperator', 'Remover sinal', 'Remove sign', 'Quitar signo')
s('hintTitle', 'DICA {n} DE 3', 'HINT {n} OF 3', 'PISTA {n} DE 3', {'n': INT})
s('hintEquals', 'O = fica entre o {a} e o {b}.', 'The = goes between {a} and {b}.', 'El = va entre {a} y {b}.',
  {'a': INT, 'b': INT})
s('hintLink', 'Comece ligando o {a} e o {b} com {op}.', 'Start by linking {a} and {b} with {op}.',
  'Empieza uniendo {a} y {b} con {op}.', {'a': INT, 'b': INT, 'op': STR})
s('hintTooltip', 'Dica {n} (custa 1/3 dos pontos)', 'Hint {n} (costs 1/3 of the points)', 'Pista {n} (cuesta 1/3 de los puntos)',
  {'n': INT})
s('hintTooltipReveal', 'Revelar a solução (sem pontos)', 'Reveal the solution (no points)', 'Revelar la solución (sin puntos)')
s('hintRevealTitle', 'REVELAR A SOLUÇÃO?', 'REVEAL THE SOLUTION?', '¿REVELAR LA SOLUCIÓN?')
s('hintRevealBody', 'Este número termina sem pontos e volta ao sorteio para você tentar outro dia.',
  'This number ends with no points and goes back to the draw so you can try another day.',
  'Este número termina sin puntos y vuelve al sorteo para que lo intentes otro día.')
s('secondsLeftA11y', '{seconds} segundos restantes', '{seconds} seconds left', 'quedan {seconds} segundos', {'seconds': INT})
s('tutorialTapGap', 'Toque no vão entre o {a} e o {b} (o quadradinho tracejado).',
  'Tap the gap between {a} and {b} (the dashed square).', 'Toca el hueco entre {a} y {b} (el cuadrito punteado).',
  {'a': INT, 'b': INT})
s('tutorialPickTimes', 'Agora escolha × para ligar os dois. Dá também para arrastar o sinal até o vão.',
  'Now pick × to link them. You can also drag the sign onto the gap.',
  'Ahora elige × para unirlos. También puedes arrastrar el signo al hueco.')
s('tutorialLinkThree', 'A árvore cresceu! Ligue o resultado com o 3: toque no próximo vão.',
  'The tree grew! Link the result with 3: tap the next gap.', '¡El árbol creció! Une el resultado con el 3: toca el siguiente hueco.')
s('tutorialEqualsGap', '1 × 2 × 3 vale 6. Toque no último vão para pôr o =.',
  '1 × 2 × 3 is 6. Tap the last gap to place the =.', '1 × 2 × 3 vale 6. Toca el último hueco para poner el =.')
s('tutorialPickEquals', 'Escolha o =.', 'Pick =.', 'Elige =.')
s('tutorialVerify', '6 = 6! Toque em Verificar para conferir.', '6 = 6! Tap Check to confirm.', '¡6 = 6! Toca Verificar para comprobar.')
s('tutorialOffScript', 'Tudo bem experimentar! Para seguir o tutorial, use ↶ desfazer até voltar ao passo anterior.',
  'Experimenting is fine! To follow the tutorial, use ↶ undo to go back a step.',
  '¡Está bien experimentar! Para seguir el tutorial, usa ↶ deshacer para volver al paso anterior.')
s('tutorialSkip', 'PULAR TUTORIAL', 'SKIP TUTORIAL', 'SALTAR TUTORIAL')
s('liveValuesShow', 'Mostrar valores em tempo real', 'Show live values', 'Mostrar valores en tiempo real')
s('liveValuesHide', 'Esconder valores em tempo real', 'Hide live values', 'Ocultar valores en tiempo real')
s('toggleParens', 'Parênteses', 'Parentheses', 'Paréntesis')
s('undo', 'Desfazer', 'Undo', 'Deshacer')
s('skip', 'PULAR', 'SKIP', 'SALTAR')
s('skipTitle', 'PULAR ESTE NÚMERO?', 'SKIP THIS NUMBER?', '¿SALTAR ESTE NÚMERO?')
s('skipBody', 'Quer ver uma solução? Se preferir, não revelamos nada: o número volta ao sorteio para você tentar outro dia.',
  'Do you want to see a solution? If you prefer, we reveal nothing: the number goes back to the draw so you can try another day.',
  '¿Quieres ver una solución? Si prefieres, no revelamos nada: el número vuelve al sorteo para que lo intentes otro día.')
s('skipYes', 'SIM, MOSTRAR', 'YES, SHOW ME', 'SÍ, MOSTRAR')
s('skipNo', 'NÃO, PULAR', 'NO, JUST SKIP', 'NO, SALTAR')
s('seeSolution', 'Ver uma solução', 'See a solution', 'Ver una solución')
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
s('allSolvedCatalog', 'Você resolveu todos os números deste nível por enquanto! Tente outro nível ou digite um número no modo Específico.',
  'You solved every number on this level for now! Try another level or type a number in Specific mode.',
  '¡Resolviste todos los números de este nivel por ahora! Prueba otro nivel o escribe un número en el modo Específico.')
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
s('revealedTitle', 'UMA SOLUÇÃO POSSÍVEL', 'ONE POSSIBLE SOLUTION', 'UNA SOLUCIÓN POSIBLE')
s('revealedDetail', 'Sem pontos desta vez. {number} continua no sorteio para você tentar de novo.',
  'No points this time. {number} stays in the draw so you can try again.',
  'Sin puntos esta vez. {number} sigue en el sorteo para que lo intentes de nuevo.', {'number': STR})
s('points', 'PONTOS', 'POINTS', 'PUNTOS')
s('total', 'TOTAL', 'TOTAL', 'TOTAL')
s('pointsBreakdown', '{base} base + {bonus} pelo tempo', '{base} base + {bonus} for time', '{base} base + {bonus} por tiempo',
  {'base': INT, 'bonus': INT})
s('pointsLateZero', 'Fora do tempo não vale pontos.', 'No points when out of time.', 'Fuera de tiempo no suma puntos.')
s('pointsReplayZero', 'Número já resolvido neste nível: sem pontos.', 'Number already solved on this level: no points.',
  'Número ya resuelto en este nivel: sin puntos.')
s('howScoringWorks', 'Como funciona?', 'How does it work?', '¿Cómo funciona?')
s('scoreHints', 'dicas ×{percent}%', 'hints ×{percent}%', 'pistas ×{percent}%', {'count': INT, 'percent': INT})
s('scoreBlind', 'às cegas ×1,25', 'blind ×1.25', 'a ciegas ×1,25')
s('scoreStreak', 'sequência {count}: +{percent}%', 'streak {count}: +{percent}%', 'racha {count}: +{percent}%',
  {'count': INT, 'percent': INT})
s('achievementUnlocked', 'Conquista: {title}', 'Achievement: {title}', 'Logro: {title}', {'title': STR})
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
s('skippedEmpty', 'Nenhum número pulado. Quando pular um, ele aparece aqui para você tentar de novo.',
  'No skipped numbers. When you skip one, it shows up here so you can try again.',
  'Ningún número saltado. Cuando saltes uno, aparecerá aquí para que lo intentes de nuevo.')
s('skippedTimes', '{count, plural, =1{pulado 1 vez} other{pulado {count} vezes}}',
  '{count, plural, =1{skipped once} other{skipped {count} times}}',
  '{count, plural, =1{saltado 1 vez} other{saltado {count} veces}}', {'count': INT})
s('skippedRevealed', 'solução vista', 'solution seen', 'solución vista')
s('tryAgain', 'TENTAR', 'TRY', 'INTENTAR')
s('achievementsTitle', 'CONQUISTAS · {count}/{total}', 'ACHIEVEMENTS · {count}/{total}', 'LOGROS · {count}/{total}',
  {'count': INT, 'total': INT})
s('achievementUnlockedShort', 'desbloqueada', 'unlocked', 'desbloqueado')
s('achievementLocked', 'bloqueada', 'locked', 'bloqueado')
s('achFirstSolve', 'Primeira placa', 'First plate', 'Primera placa')
s('achFirstSolveDesc', 'Resolva o seu primeiro número.', 'Solve your first number.', 'Resuelve tu primer número.')
s('achTenInTime', 'Contra o relógio', 'Beat the clock', 'Contra el reloj')
s('achTenInTimeDesc', 'Resolva 10 números dentro do tempo.', 'Solve 10 numbers in time.', 'Resuelve 10 números a tiempo.')
s('achBlind', 'Às cegas', 'Blindfolded', 'A ciegas')
s('achBlindDesc', 'Resolva um número sem os valores em tempo real.', 'Solve a number without live values.',
  'Resuelve un número sin los valores en tiempo real.')
s('achThreeStars', 'Osso duro', 'Tough nut', 'Hueso duro')
s('achThreeStarsDesc', 'Resolva um número ★3.', 'Solve a ★3 number.', 'Resuelve un número ★3.')
s('achAllLevels', 'Escada completa', 'Full ladder', 'Escalera completa')
s('achAllLevelsDesc', 'Resolva um número em cada nível.', 'Solve a number on every level.', 'Resuelve un número en cada nivel.')
s('achStreak5', 'Embalado', 'On a roll', 'En racha')
s('achStreak5Desc', 'Acerte 5 seguidos, no tempo e sem dicas.', 'Get 5 in a row, in time and without hints.',
  'Acierta 5 seguidos, a tiempo y sin pistas.')
s('achDaily7', 'Semana cheia', 'Full week', 'Semana completa')
s('achDaily7Desc', 'Resolva a placa do dia 7 dias seguidos.', 'Solve the plate of the day 7 days in a row.',
  'Resuelve la placa del día 7 días seguidos.')
s('achHundred', 'Centena', 'Century', 'Centena')
s('achHundredDesc', 'Resolva 100 números.', 'Solve 100 numbers.', 'Resuelve 100 números.')

# Settings
s('settingsEyebrow', 'PREFERÊNCIAS', 'PREFERENCES', 'PREFERENCIAS')
s('settingsTitle', 'Configurações', 'Settings', 'Ajustes')
s('theme', 'TEMA', 'THEME', 'TEMA')
s('themeSystem', 'Sistema', 'System', 'Sistema')
s('themeLight', 'Claro', 'Light', 'Claro')
s('themeDark', 'Escuro', 'Dark', 'Oscuro')
s('themeHint', 'Segue o tema do aparelho até você escolher outro.', 'Follows your device theme until you pick another.',
  'Sigue el tema del dispositivo hasta que elijas otro.')
s('settingsGame', 'JOGO', 'GAME', 'JUEGO')
s('settingsLiveValues', 'Valores em tempo real', 'Live values', 'Valores en tiempo real')
s('settingsLiveValuesHint', 'Mostra quanto vale cada ramo e cada lado do = enquanto você monta.',
  'Shows the value of each branch and of each side of = while you build.',
  'Muestra cuánto vale cada rama y cada lado del = mientras armas.')
s('settingsHaptics', 'Vibração', 'Vibration', 'Vibración')
s('settingsReduceMotion', 'Reduzir animações', 'Reduce motion', 'Reducir animaciones')
s('settingsReduceMotionHint', 'Desliga as animações da árvore, da comemoração e das dicas.',
  'Turns off the tree, celebration and hint animations.', 'Desactiva las animaciones del árbol, la celebración y las pistas.')
s('settingsHints', 'Tutorial da primeira partida', 'First-game tutorial', 'Tutorial de la primera partida')
s('settingsHintsHint', 'Ligue para refazer o passo a passo (1 × 2 × 3 = 6) na próxima partida.',
  'Turn on to redo the walkthrough (1 × 2 × 3 = 6) in your next game.',
  'Actívalo para repetir el paso a paso (1 × 2 × 3 = 6) en tu próxima partida.')
s('seedColor', 'COR SEMENTE', 'SEED COLOR', 'COLOR SEMILLA')
s('pickColor', 'Escolher cor', 'Pick a color', 'Elegir color')
s('fontSize', 'TAMANHO DA FONTE', 'FONT SIZE', 'TAMAÑO DE FUENTE')
s('fontSample', 'Use os quatro dígitos na ordem.', 'Use the four digits in order.', 'Usa los cuatro dígitos en orden.')
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
s('helpTabPlay', 'JOGAR', 'PLAY', 'JUGAR')
s('helpTabOperators', 'OPERADORES', 'OPERATORS', 'OPERADORES')
s('helpTabScoring', 'PONTOS', 'POINTS', 'PUNTOS')
s('helpExample', 'EXEMPLO', 'EXAMPLE', 'EJEMPLO')
s('helpExampleCaption', '1236 → 1 × 2 × 3 = 6. Cada ligação sobe um andar na árvore.',
  '1236 → 1 × 2 × 3 = 6. Each link adds a floor to the tree.', '1236 → 1 × 2 × 3 = 6. Cada unión sube un piso en el árbol.')
s('helpKeys', 'TECLADO', 'KEYBOARD', 'TECLADO')
s('helpKeysList', 'Enter verificar · Esc pular · Tab seleção · Ctrl+Z desfazer · ⌫ remover · H dica\n+ − * / ^ = ( ) operadores · ! fatorial · r √ · c ∛ · a |x| · n −x · f ⌊x⌋ · F ⌈x⌉',
  'Enter check · Esc skip · Tab selection · Ctrl+Z undo · ⌫ remove · H hint\n+ − * / ^ = ( ) operators · ! factorial · r √ · c ∛ · a |x| · n −x · f ⌊x⌋ · F ⌈x⌉',
  'Enter verificar · Esc saltar · Tab selección · Ctrl+Z deshacer · ⌫ quitar · H pista\n+ − * / ^ = ( ) operadores · ! factorial · r √ · c ∛ · a |x| · n −x · f ⌊x⌋ · F ⌈x⌉')
s('helpOperatorsIntro', 'Os binários (+ − × ÷ xʸ) ligam dois blocos num vão. Os outros agem sobre um trecho: toque num número ou ramo e escolha.',
  'Binary operators (+ − × ÷ xʸ) link two blocks at a gap. The others act on a segment: tap a number or branch and pick one.',
  'Los binarios (+ − × ÷ xʸ) unen dos bloques en un hueco. Los demás actúan sobre un tramo: toca un número o rama y elige.')
s('opAdd', 'Soma', 'Addition', 'Suma')
s('opSub', 'Subtração', 'Subtraction', 'Resta')
s('opMul', 'Multiplicação', 'Multiplication', 'Multiplicación')
s('opDiv', 'Divisão', 'Division', 'División')
s('opPow', 'Potência', 'Power', 'Potencia')
s('opNeg', 'Oposto (troca o sinal)', 'Negation (flips the sign)', 'Opuesto (cambia el signo)')
s('opSqrt', 'Raiz quadrada', 'Square root', 'Raíz cuadrada')
s('opCbrt', 'Raiz cúbica', 'Cube root', 'Raíz cúbica')
s('opFact', 'Fatorial', 'Factorial', 'Factorial')
s('opAbs', 'Módulo (valor absoluto)', 'Absolute value', 'Valor absoluto')
s('opFloor', 'Piso (arredonda para baixo)', 'Floor (rounds down)', 'Piso (redondea hacia abajo)')
s('opCeil', 'Teto (arredonda para cima)', 'Ceiling (rounds up)', 'Techo (redondea hacia arriba)')
s('lessonsTitle', 'Aprender os operadores', 'Learn the operators', 'Aprender los operadores')
s('lessonsEyebrow', '{done} DE {total} LIÇÕES', '{done} OF {total} LESSONS', '{done} DE {total} LECCIONES',
  {'done': INT, 'total': INT})
s('lessonsIntro', 'Cada lição mostra uma placa resolvida passo a passo usando um operador. Depois é a sua vez, sem relógio.',
  'Each lesson shows a plate solved step by step with one operator. Then it is your turn, without the clock.',
  'Cada lección muestra una placa resuelta paso a paso con un operador. Después es tu turno, sin reloj.')
s('lessonDone', 'lição concluída', 'lesson done', 'lección completada')
s('lessonPrev', 'Passo anterior', 'Previous step', 'Paso anterior')
s('lessonNext', 'Próximo passo', 'Next step', 'Paso siguiente')
s('lessonPlay', 'Reproduzir', 'Play', 'Reproducir')
s('lessonNowYou', 'AGORA VOCÊ', 'NOW YOU', 'AHORA TÚ')
s('lessonNowYouHint', 'Você joga outra placa que também usa este operador, sem relógio e sem pontos.',
  'You play another plate that also uses this operator, with no clock and no points.',
  'Juegas otra placa que también usa este operador, sin reloj y sin puntos.')
s('lessonStepStart', 'A placa {number}: quatro dígitos, na ordem.', 'Plate {number}: four digits, in order.',
  'La placa {number}: cuatro dígitos, en orden.', {'number': STR})
s('lessonStepLink', 'Ligamos o {a} e o {b} com {op} ({name}).', 'We link {a} and {b} with {op} ({name}).',
  'Unimos {a} y {b} con {op} ({name}).', {'a': INT, 'b': INT, 'op': STR, 'name': STR})
s('lessonStepUnary', 'Aplicamos {op} ({name}) sobre o trecho.', 'We apply {op} ({name}) to the segment.',
  'Aplicamos {op} ({name}) sobre el tramo.', {'op': STR, 'name': STR})
s('lessonStepEquals', 'Por fim, o = entre o {a} e o {b}: os dois lados valem o mesmo.',
  'Finally, the = between {a} and {b}: both sides are worth the same.',
  'Por último, el = entre {a} y {b}: ambos lados valen lo mismo.', {'a': INT, 'b': INT})
s('help1', 'Use os quatro dígitos da placa na ordem em que aparecem.', 'Use the four digits of the plate in the order they appear.',
  'Usa los cuatro dígitos de la placa en el orden en que aparecen.')
s('help2', 'O = entra entre dois números, uma única vez, e separa os dois lados.',
  'The = goes between two numbers, only once, and splits the two sides.',
  'El = va entre dos números, una sola vez, y separa los dos lados.')
s('help3', 'Toque num vão (ou arraste um sinal até ele) para ligar dois blocos com + − × ÷ xʸ. Toque num nó para trocar o operador ou aplicar √, !, |x| e outros sobre aquele trecho; ( ) agrupa o trecho. Arraste um sinal ou o = para outro vão para movê-lo; arraste para fora da árvore, ou use ⌫, para tirá-lo.',
  'Tap a gap (or drag a sign onto it) to link two blocks with + − × ÷ xʸ. Tap a node to change its operator or apply √, !, |x| and others to that segment; ( ) groups the segment. Drag a sign or the = to another gap to move it; drag it off the tree, or use ⌫, to remove it.',
  'Toca un hueco (o arrastra un signo hasta él) para unir dos bloques con + − × ÷ xʸ. Toca un nodo para cambiar el operador o aplicar √, !, |x| y otros sobre ese tramo; ( ) agrupa el tramo. Arrastra un signo o el = a otro hueco para moverlo; arrástralo fuera del árbol, o usa ⌫, para quitarlo.')
s('help4', 'Abra o LATEX ▾ ao lado da fórmula para vê-la em LaTeX e copiar o código. Verificar confere se os dois lados são iguais. Pular pergunta se você quer ver uma solução; se não quiser, o número volta outro dia.',
  'Open LATEX ▾ next to the formula to see it typeset in LaTeX and copy the code. Check tests whether both sides are equal. Skip asks whether you want to see a solution; if not, the number comes back another day.',
  'Abre LATEX ▾ junto a la fórmula para verla en LaTeX y copiar el código. Verificar comprueba si ambos lados son iguales. Saltar pregunta si quieres ver una solución; si no, el número vuelve otro día.')
s('helpEasyOps', 'todos, inclusive ⌊x⌋ ⌈x⌉', 'all, including ⌊x⌋ ⌈x⌉', 'todos, incluso ⌊x⌋ ⌈x⌉')
s('helpFraction', 'Divisão com resultado não inteiro (como 5 ÷ 2) só vale no Fácil.',
  'Division with a non-integer result (like 5 ÷ 2) is only allowed on Easy.',
  'La división con resultado no entero (como 5 ÷ 2) solo vale en Fácil.')
s('helpScoringTitle', 'PONTUAÇÃO', 'SCORING', 'PUNTUACIÓN')
s('helpScoringTime', 'TEMPO', 'TIME', 'TIEMPO')
s('helpScoringBaseCol', 'BASE', 'BASE', 'BASE')
s('helpScoringBase', 'Cada número certo vale os pontos base do nível.', "Each solved number is worth the level's base points.",
  'Cada número resuelto vale los puntos base del nivel.')
s('helpScoringBonus', 'Bônus de tempo: +1 ponto a cada 5 segundos que sobram no relógio quando você verifica.',
  'Time bonus: +1 point for every 5 seconds left on the clock when you check.',
  'Bono de tiempo: +1 punto por cada 5 segundos que quedan en el reloj al verificar.')
s('helpScoringExample', 'Exemplo: no Intermediário ({base} base), verificar com {seconds}s restantes dá {total} pontos.',
  'Example: on Intermediate ({base} base), checking with {seconds}s left gives {total} points.',
  'Ejemplo: en Intermedio ({base} base), verificar con {seconds}s restantes da {total} puntos.',
  {'base': INT, 'seconds': INT, 'total': INT})
s('helpScoringLate', 'Se o tempo acabar, ainda dá para terminar e o número conta como resolvido, mas vale 0 pontos.',
  'If time runs out you can still finish and the number counts as solved, but it is worth 0 points.',
  'Si se acaba el tiempo, aún puedes terminar y el número cuenta como resuelto, pero vale 0 puntos.')
s('helpScoringReplay', 'Repetir um número que você já resolveu no mesmo nível não dá pontos de novo.',
  'Replaying a number you already solved on the same level gives no points again.',
  'Repetir un número que ya resolviste en el mismo nivel no da puntos otra vez.')
s('helpScoringHints', 'Dicas: a 1ª mostra onde vai o = (fica com 2/3 dos pontos), a 2ª uma primeira ligação (1/3), a 3ª revela a solução (0 pontos; o número volta ao sorteio).',
  'Hints: the 1st shows where the = goes (you keep 2/3 of the points), the 2nd a first link (1/3), the 3rd reveals the solution (0 points; the number goes back to the draw).',
  'Pistas: la 1ª muestra dónde va el = (conservas 2/3 de los puntos), la 2ª una primera unión (1/3), la 3ª revela la solución (0 puntos; el número vuelve al sorteo).')
s('helpScoringBlind', 'Às cegas: jogando o número inteiro com os valores em tempo real desligados, os pontos valem ×1,25.',
  'Blind: playing the whole number with live values off multiplies the points by 1.25.',
  'A ciegas: jugando todo el número con los valores en tiempo real apagados, los puntos valen ×1,25.')
s('helpScoringStreak', 'Sequência: cada acerto seguido, no tempo e sem dicas, soma +10% (até +50%). Pular zera a sequência.',
  'Streak: each answer in a row, in time and without hints, adds +10% (up to +50%). Skipping resets it.',
  'Racha: cada acierto seguido, a tiempo y sin pistas, suma +10% (hasta +50%). Saltar la reinicia.')
s('helpScoringPractice', 'Treino e lições não valem pontos.', 'Practice and lessons give no points.',
  'La práctica y las lecciones no dan puntos.')
s('helpScoringPause', 'Você tem uma pausa de {seconds}s por número; durante a pausa o relógio para e a árvore fica escondida.',
  'You get one {seconds}s pause per number; while paused the clock stops and the tree is hidden.',
  'Tienes una pausa de {seconds}s por número; durante la pausa el reloj se detiene y el árbol se oculta.',
  {'seconds': INT})
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
