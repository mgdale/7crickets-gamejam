extends Control

@onready var grid = $GridContainer
@onready var win_message = $WinMessage
@onready var lose_message = $LoseMessage

var cards = []
var first_card = null
var second_card = null
var waiting = false

var textura_coneja: Texture2D = load("res://images/coneja.png")
var textura_caja: Texture2D = load("res://images/caja_texto.png")
var fuente_titulo: Font = load("res://fonts/chinese rocks rg.otf")
var fuente_dialogo: Font = load("res://fonts/Chinese_Ruler.ttf")

@export var titulo_texto: String = "Find your match"
@export var coneja_tamano: Vector2 = Vector2(560, 560)
@export var coneja_offset_y: float = -50.0
@export var coneja_duracion_caminata: float = 2.2
@export var coneja_duracion_por_texto: float = 1.8
@export var coneja_indice_en_arbol: int = 1

var dialogos_coneja := [
	"oh! sweetie its such a shame that you have to rush so much on your first day!",
	"but dont worry! you can make it! just like in love, you have to find your perfect match!"
]


func _ready():
	win_message.visible = false
	lose_message.visible = false
	cards = grid.get_children()
	for card in cards:
		card.textura_dorso = load("res://images/classic.png")
	assign_ids()
	show_face_up()

	_crear_titulo()
	await _mostrar_coneja()

	for card in cards:
		card.pressed.connect(_on_card_pressed.bind(card))
	await get_tree().create_timer(1.2).timeout
	hide_cards()


func _crear_titulo() -> void:
	var panel := PanelContainer.new()
	var estilo := StyleBoxTexture.new()
	estilo.texture = textura_caja
	estilo.texture_margin_left = 50
	estilo.texture_margin_right = 50
	estilo.texture_margin_top = 25
	estilo.texture_margin_bottom = 25
	estilo.content_margin_left = 30
	estilo.content_margin_right = 30
	estilo.content_margin_top = 18
	estilo.content_margin_bottom = 18
	estilo.modulate_color = Color(1, 1, 1, 0.6)
	panel.add_theme_stylebox_override("panel", estilo)

	var viewport_size := get_viewport_rect().size
	var zona_libre_izq: float = grid.position.x + grid.size.x
	var zona_libre_ancho: float = viewport_size.x - zona_libre_izq

	var ancho: float = min(380.0, zona_libre_ancho - 40.0)
	var alto := 100.0
	panel.position = Vector2(zona_libre_izq + (zona_libre_ancho - ancho) / 2.0, 30.0)
	panel.size = Vector2(ancho, alto)
	add_child(panel)

	var titulo := Label.new()
	titulo.text = titulo_texto
	titulo.add_theme_font_size_override("font_size", 32)
	titulo.add_theme_color_override("font_color", Color(0.35, 0.1, 0.1))
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	titulo.autowrap_mode = TextServer.AUTOWRAP_WORD
	if fuente_titulo:
		titulo.add_theme_font_override("font", fuente_titulo)
	panel.add_child(titulo)


func _mostrar_coneja() -> void:
	var viewport_size := get_viewport_rect().size
	var zona_libre_izq: float = grid.position.x + grid.size.x
	var zona_libre_ancho: float = viewport_size.x - zona_libre_izq

	var tamano_final := coneja_tamano
	tamano_final.x = min(tamano_final.x, zona_libre_ancho - 40.0)
	tamano_final.y = tamano_final.x

	var coneja := TextureRect.new()
	coneja.texture = textura_coneja
	coneja.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	coneja.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	coneja.custom_minimum_size = tamano_final
	coneja.size = tamano_final
	add_child(coneja)
	move_child(coneja, min(coneja_indice_en_arbol, get_child_count() - 1))

	var y_inicio := viewport_size.y / 2.0
	var x_inicio := -tamano_final.x
	var x_final := zona_libre_izq + (zona_libre_ancho - tamano_final.x) / 2.0
	var y_final := viewport_size.y - tamano_final.y - 20.0

	coneja.position = Vector2(x_inicio, y_inicio + coneja_offset_y)

	var tween_mov := create_tween()
	tween_mov.set_parallel(true)
	tween_mov.tween_property(coneja, "position:x", x_final, coneja_duracion_caminata)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween_mov.tween_property(coneja, "position:y", y_final + coneja_offset_y, coneja_duracion_caminata)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween_mov.finished

	await _hablar_coneja(coneja)

	var t_oscurecer := create_tween()
	t_oscurecer.tween_property(coneja, "modulate", Color(0.55, 0.55, 0.55, 0.55), 0.4)
	await t_oscurecer.finished

func _hablar_coneja(coneja: TextureRect) -> void:
	var burbuja := PanelContainer.new()
	var estilo := StyleBoxTexture.new()
	estilo.texture = textura_caja
	estilo.texture_margin_left = 40
	estilo.texture_margin_right = 40
	estilo.texture_margin_top = 20
	estilo.texture_margin_bottom = 20
	estilo.content_margin_left = 35
	estilo.content_margin_right = 35
	estilo.content_margin_top = 18
	estilo.content_margin_bottom = 18
	estilo.modulate_color = Color(1, 1, 1, 0.6)
	burbuja.add_theme_stylebox_override("panel", estilo)
	burbuja.z_index = 5
	burbuja.custom_minimum_size = Vector2(340, 120)
	burbuja.size = Vector2(340, 120)
	burbuja.pivot_offset = Vector2(170, 60)
	coneja.add_child(burbuja)
	burbuja.position = Vector2(coneja_tamano.x / 2.0 - 170, -140)
	burbuja.modulate.a = 0
	burbuja.scale = Vector2(0.7, 0.7)

	var texto := Label.new()
	texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	texto.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	texto.autowrap_mode = TextServer.AUTOWRAP_WORD
	texto.add_theme_font_size_override("font_size", 26)
	texto.add_theme_color_override("font_color", Color(0.35, 0.1, 0.1))
	if fuente_dialogo:
		texto.add_theme_font_override("font", fuente_dialogo)
	burbuja.add_child(texto)

	coneja.pivot_offset = Vector2(coneja_tamano.x / 2.0, coneja_tamano.y)
	var coneja_y_base := coneja.position.y

	for i in range(dialogos_coneja.size()):
		texto.text = dialogos_coneja[i]

		var t := create_tween()
		if i == 0:
			t.tween_property(burbuja, "modulate:a", 1.0, 0.2)
			t.parallel().tween_property(burbuja, "scale", Vector2(1.0, 1.0), 0.2)\
				.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		else:
			var y_base := burbuja.position.y
			t.tween_property(burbuja, "position:y", y_base - 18, 0.12)\
				.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			t.tween_property(burbuja, "position:y", y_base, 0.15)\
				.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
			t.parallel().tween_property(coneja, "position:y", coneja_y_base - 22, 0.12)\
				.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			t.chain().tween_property(coneja, "position:y", coneja_y_base, 0.15)\
				.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		await t.finished
		await get_tree().create_timer(coneja_duracion_por_texto).timeout

	var t_fin := create_tween()
	t_fin.tween_property(burbuja, "modulate:a", 0.0, 0.25)
	await t_fin.finished
	burbuja.queue_free()


func assign_ids():
	var indices = range(cards.size())
	indices.shuffle()
	var pair_1 = indices[0]
	var pair_2 = indices[1]
	for i in range(cards.size()):
		if i == pair_1 or i == pair_2:
			cards[i].card_id = 1
			cards[i].textura_frente = load("res://images/match.png")
		else:
			cards[i].card_id = 100 + i
			cards[i].textura_frente = load("res://images/generic.png")


func show_face_up():
	for card in cards:
		card.flip(true)


func hide_cards():
	for card in cards:
		if not card.found:
			card.flip(false)


func _on_card_pressed(card):
	if waiting or card.found or card.face_up:
		return
	card.flip(true)
	if first_card == null:
		first_card = card
	else:
		second_card = card
		waiting = true
		compare_cards()


func compare_cards():
	if first_card.card_id == second_card.card_id:
		first_card.found = true
		second_card.found = true
		win_message.visible = true
		await get_tree().create_timer(1.5).timeout
		win_message.visible = false
		GameState.puzzles_solved[GameState.current_puzzle] = true
		var find_queen_lista = GameState.puzzles_solved.get("find_queen", false)
		var simon_listo = GameState.puzzles_solved.get("simon", false)
		if find_queen_lista and simon_listo:
			get_tree().change_scene_to_file("res://scenes/escena_17.tscn")
		else:
			get_tree().change_scene_to_file(GameState.MAP_SCENE)
	else:
		lose_message.visible = true
		await get_tree().create_timer(1.5).timeout
		lose_message.visible = false
		await get_tree().create_timer(0.5).timeout
		restart_game()


func restart_game():
	first_card = null
	second_card = null
	waiting = false
	assign_ids()
	show_face_up()
	await get_tree().create_timer(1.5).timeout
	hide_cards()
