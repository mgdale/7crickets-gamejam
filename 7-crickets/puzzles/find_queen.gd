extends Control

@export var rondas_necesarias: int = 3
@export var cerdo_tamano: Vector2 = Vector2(660, 660)
@export var cerdo_offset_y: float = -50.0
@export var cerdo_duracion_caminata: float = 2.2
@export var cerdo_duracion_por_texto: float = 1.8
@export var cerdo_indice_en_arbol: int = 1
@export var tiempo_mostrar: float = 1.5
@export var pasos_mezcla: int = 5
@export var duracion_swap: float = 0.45
@export var pausa_tras_fallo: float = 1.0
@export var pausa_tras_acierto: float = 1.2
@export var pausa_entre_swaps: float = 0.12

var aciertos := 0
var label_progreso: Label

var cards = []
var positions = []
var queen_id = 1

var textura_cerdo: Texture2D = load("res://images/cerdo.png")
var textura_caja: Texture2D = load("res://images/caja_texto.png")
var fuente_titulo: Font = load("res://fonts/chinese rocks rg.otf")
var fuente_dialogo: Font = load("res://fonts/Chinese_Ruler.ttf")

var bloqueado := true

var titulos_por_idioma := {
	"en": "Find the fortune",
	"es": "Busca la fortuna",
	"fr": "Trouve la fortune",
}

var instrucciones_por_idioma := {
	"en": "Hey, little fella! The preparations for the new year are ready, so pay attention!\n\nWatch which card holds the fortune, then follow the cards as they shuffle. Find it 3 times in a row! If you miss, you start over.",
	"es": "¡Oye, pequeño! Los preparativos para el año nuevo están listos, ¡así que presta atención!\n\nMira qué carta guarda la fortuna y sigue las cartas mientras se mezclan. ¡Encuéntrala 3 veces seguidas! Si fallas, empiezas de nuevo.",
	"fr": "Hé, petit ! Les préparatifs pour la nouvelle année sont prêts, alors fais bien attention !\n\nRegarde quelle carte cache la fortune, puis suis les cartes pendant qu'elles se mélangent. Trouve-la 3 fois de suite ! Si tu te trompes, tu recommences.",
}

var dialogos_cerdo_por_idioma := {
	"en": [
		"Hey, little fella! You better hurry!",
		"All the preparations for the new year are ready! So pay attention and make the right move!",
	],
	"es": [
		"¡Oye, pequeño! ¡Más te vale apurarte!",
		"¡Todos los preparativos para el año nuevo están listos! ¡Así que presta atención y haz el movimiento correcto!",
	],
	"fr": [
		"Hé, petit ! Tu ferais mieux de te dépêcher !",
		"Tous les préparatifs pour la nouvelle année sont prêts ! Alors fais bien attention et fais le bon choix !",
	],
}

@export var burbuja_offset_y: float = -110.0

var cerdo_actual: TextureRect = null

var frases_por_idioma := {
	"en": {
		"mira": "Remember where the fortune is!",
		"sigue": "Follow the cards closely!",
		"ronda_ok": "Correct! Once more!",
		"fallo": "Not that one! Let's start over!",
		"acierto": "Well done! You found the fortune!",
	},
	"es": {
		"mira": "¡Recuerda dónde está la fortuna!",
		"sigue": "¡Sigue las cartas con atención!",
		"ronda_ok": "¡Correcto! ¡Otra vez!",
		"fallo": "¡Esa no era! ¡Empezamos de nuevo!",
		"acierto": "¡Bien hecho! ¡Encontraste la fortuna!",
	},
	"fr": {
		"mira": "Souviens-toi où est la fortune !",
		"sigue": "Suis bien les cartes !",
		"ronda_ok": "Correct ! Encore une fois !",
		"fallo": "Pas celle-là ! On recommence !",
		"acierto": "Bravo ! Tu as trouvé la fortune !",
	},
}

var dialogos_cerdo := []

func _colocar_cerdo() -> void:
	var viewport_size := get_viewport_rect().size
	var cerdo := TextureRect.new()
	cerdo.texture = textura_cerdo
	cerdo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	cerdo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	cerdo.custom_minimum_size = cerdo_tamano
	cerdo.size = cerdo_tamano
	cerdo.modulate = Color(0.55, 0.55, 0.55, 0.55)
	add_child(cerdo)
	move_child(cerdo, min(cerdo_indice_en_arbol, get_child_count() - 1))
	cerdo.position = Vector2(
		viewport_size.x - cerdo_tamano.x - 20.0,
		viewport_size.y - cerdo_tamano.y - 10.0 + cerdo_offset_y
	)
	cerdo_actual = cerdo

func _ready():
	cards = get_children().filter(func(n): return n.has_method("flip"))
	for card in cards:
		card.textura_dorso = load("res://images/sobre_queen.png")
		positions.append(card.position)
	assign_queen()

	_crear_titulo()
	_crear_progreso()
	await Instrucciones.mostrar(textura_cerdo, titulos_por_idioma[Lang.actual], instrucciones_por_idioma[Lang.actual])
	_colocar_cerdo()

	for card in cards:
		card.pressed.connect(_on_card_pressed.bind(card))
	await _iniciar_ronda()

func _crear_titulo() -> void:
	var panel := PanelContainer.new()
	var estilo := StyleBoxTexture.new()
	estilo.texture = textura_caja
	estilo.texture_margin_left = 50
	estilo.texture_margin_right = 50
	estilo.texture_margin_top = 25
	estilo.texture_margin_bottom = 25
	estilo.content_margin_left = 45
	estilo.content_margin_right = 45
	estilo.content_margin_top = 18
	estilo.content_margin_bottom = 18
	estilo.modulate_color = Color(1, 1, 1, 0.6)
	panel.add_theme_stylebox_override("panel", estilo)

	var viewport_size := get_viewport_rect().size
	var ancho := 520.0
	var alto := 110.0
	panel.position = Vector2((viewport_size.x - ancho) / 2.0, 30.0)
	panel.size = Vector2(ancho, alto)
	add_child(panel)

	var titulo := Label.new()
	titulo.text = titulos_por_idioma[Lang.actual]
	titulo.add_theme_font_size_override("font_size", 44)
	titulo.add_theme_color_override("font_color", Color(0.35, 0.1, 0.1))
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	titulo.autowrap_mode = TextServer.AUTOWRAP_OFF
	titulo.clip_text = false
	if fuente_titulo:
		titulo.add_theme_font_override("font", fuente_titulo)
	panel.add_child(titulo)


func assign_queen():
	cards.shuffle()
	cards[0].card_id = queen_id
	cards[0].textura_frente = load("res://images/queen.png")
	cards[1].card_id = 101
	cards[1].textura_frente = load("res://images/carta_vacia.png")
	cards[2].card_id = 102
	cards[2].textura_frente = load("res://images/carta_vacia.png")


func show_face_up():
	for card in cards:
		card.flip(true)


func hide_cards():
	for card in cards:
		card.flip(false)


func shuffle():
	for i in range(pasos_mezcla + aciertos * 2):
		var a = randi() % cards.size()
		var b = randi() % cards.size()
		while b == a:
			b = randi() % cards.size()
		await swap(cards[a], cards[b])
		await get_tree().create_timer(pausa_entre_swaps).timeout


func swap(card_a, card_b):
	var pos_a = card_a.position
	var pos_b = card_b.position
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(card_a, "position", pos_b, duracion_swap)
	tween.parallel().tween_property(card_b, "position", pos_a, duracion_swap)
	await tween.finished

func _on_card_pressed(card):
	if bloqueado:
		return
	bloqueado = true
	card.flip(true)

	if card.card_id == queen_id:
		aciertos += 1
		_actualizar_progreso()
		if aciertos >= rondas_necesarias:
			_cerdo_dice(frases_por_idioma[Lang.actual]["acierto"])
			await get_tree().create_timer(pausa_tras_acierto).timeout
			GameState.puzzles_solved[GameState.current_puzzle] = true
			var memoria_lista = GameState.puzzles_solved.get("memory", false)
			var simon_listo = GameState.puzzles_solved.get("simon", false)
			if memoria_lista and simon_listo:
				get_tree().change_scene_to_file("res://scenes/escena_17.tscn")
			else:
				get_tree().change_scene_to_file(GameState.MAP_SCENE)
		else:
			_cerdo_dice(frases_por_idioma[Lang.actual]["ronda_ok"])
			await get_tree().create_timer(pausa_tras_acierto).timeout
			restart()
	else:
		aciertos = 0
		_actualizar_progreso()
		_cerdo_dice(frases_por_idioma[Lang.actual]["fallo"])
		await get_tree().create_timer(pausa_tras_fallo).timeout
		restart()

func _cerdo_dice(mensaje: String) -> void:
	if cerdo_actual == null:
		return

	var ancho_b := 340.0
	var alto_b := 100.0
	var burbuja := PanelContainer.new()
	var estilo := StyleBoxTexture.new()
	estilo.texture = textura_caja
	estilo.texture_margin_left = 35
	estilo.texture_margin_right = 35
	estilo.texture_margin_top = 18
	estilo.texture_margin_bottom = 18
	estilo.content_margin_left = 28
	estilo.content_margin_right = 28
	estilo.content_margin_top = 14
	estilo.content_margin_bottom = 14
	estilo.modulate_color = Color(1, 1, 1, 0.85)
	burbuja.add_theme_stylebox_override("panel", estilo)
	burbuja.z_index = 6
	burbuja.custom_minimum_size = Vector2(ancho_b, alto_b)
	burbuja.size = Vector2(ancho_b, alto_b)
	burbuja.pivot_offset = Vector2(ancho_b / 2.0, alto_b / 2.0)

	# Hija de la escena (no del cerdo) para no heredar su transparencia
	add_child(burbuja)
	burbuja.position = cerdo_actual.position + Vector2(
		cerdo_actual.size.x / 2.0 - ancho_b / 2.0, burbuja_offset_y
	)
	burbuja.modulate.a = 0
	burbuja.scale = Vector2(0.7, 0.7)

	var texto := Label.new()
	texto.text = mensaje
	texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	texto.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	texto.autowrap_mode = TextServer.AUTOWRAP_WORD
	texto.add_theme_font_size_override("font_size", 24)
	texto.add_theme_color_override("font_color", Color(0.35, 0.1, 0.1))
	if fuente_dialogo:
		texto.add_theme_font_override("font", fuente_dialogo)
	burbuja.add_child(texto)

	var t := create_tween()
	t.tween_property(burbuja, "modulate:a", 1.0, 0.15)
	t.parallel().tween_property(burbuja, "scale", Vector2(1.0, 1.0), 0.15)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_interval(1.2)
	t.tween_property(burbuja, "modulate:a", 0.0, 0.2)
	t.tween_callback(burbuja.queue_free)
	
func _crear_progreso() -> void:
	label_progreso = Label.new()
	label_progreso.add_theme_font_size_override("font_size", 56)
	label_progreso.add_theme_color_override("font_color", Color(0.35, 0.1, 0.1))
	label_progreso.add_theme_color_override("font_outline_color", Color(1, 1, 1, 0.8))
	label_progreso.add_theme_constant_override("outline_size", 6)
	label_progreso.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_progreso.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var viewport_size := get_viewport_rect().size
	label_progreso.size = Vector2(600, 70)
	label_progreso.pivot_offset = Vector2(300, 35)
	label_progreso.position = Vector2((viewport_size.x - 600) / 2.0, 150.0)
	add_child(label_progreso)
	_actualizar_progreso()

func _actualizar_progreso() -> void:
	label_progreso.text = "●".repeat(aciertos) + "○".repeat(max(rondas_necesarias - aciertos, 0))
	label_progreso.scale = Vector2(1.25, 1.25)
	var t := create_tween()
	t.tween_property(label_progreso, "scale", Vector2(1.0, 1.0), 0.25)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
func _iniciar_ronda() -> void:
	show_face_up()
	_cerdo_dice(frases_por_idioma[Lang.actual]["mira"])
	await get_tree().create_timer(tiempo_mostrar).timeout
	hide_cards()
	await get_tree().create_timer(0.3).timeout
	_cerdo_dice(frases_por_idioma[Lang.actual]["sigue"])
	await shuffle()
	bloqueado = false

func restart():
	for card in cards:
		card.found = false
	hide_cards()
	await get_tree().create_timer(0.3).timeout
	assign_queen()
	await _iniciar_ronda()
