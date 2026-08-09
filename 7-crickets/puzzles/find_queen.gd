extends Control

@onready var win_message = $WinMessage
@onready var lose_message = $LoseMessage

var cards = []
var positions = []
var queen_id = 1

var textura_cerdo: Texture2D = load("res://images/cerdo.png")
var textura_caja: Texture2D = load("res://images/caja_texto.png")
var fuente_titulo: Font = load("res://fonts/chinese rocks rg.otf")
var fuente_dialogo: Font = load("res://fonts/Chinese_Ruler.ttf")

@export var cerdo_tamano: Vector2 = Vector2(660, 660)
@export var cerdo_offset_y: float = -50.0
@export var cerdo_duracion_caminata: float = 2.2
@export var cerdo_duracion_por_texto: float = 1.8
@export var cerdo_indice_en_arbol: int = 1

var dialogos_cerdo := [
	"Hey, little fella! you better hurry",
	"all the preparations for the new year are ready! so better pay attention a make the right move!"
]


func _ready():
	win_message.visible = false
	lose_message.visible = false
	cards = get_children().filter(func(n): return n.has_method("flip"))
	for card in cards:
		card.textura_dorso = load("res://images/sobre_queen.png")
		positions.append(card.position)
	assign_queen()
	show_face_up()

	_crear_titulo()
	await _mostrar_cerdo()

	for card in cards:
		card.pressed.connect(_on_card_pressed.bind(card))
	await get_tree().create_timer(3.0).timeout
	hide_cards()
	await shuffle()
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
	var ancho := 460.0
	var alto := 110.0
	panel.position = Vector2((viewport_size.x - ancho) / 2.0, 30.0)
	panel.size = Vector2(ancho, alto)
	add_child(panel)

	var titulo := Label.new()
	titulo.text = "Find the fortune"
	titulo.add_theme_font_size_override("font_size", 44)
	titulo.add_theme_color_override("font_color", Color(0.35, 0.1, 0.1))
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	titulo.autowrap_mode = TextServer.AUTOWRAP_OFF
	titulo.clip_text = false
	if fuente_titulo:
		titulo.add_theme_font_override("font", fuente_titulo)
	panel.add_child(titulo)


func _mostrar_cerdo() -> void:
	var cerdo := TextureRect.new()
	cerdo.texture = textura_cerdo
	cerdo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	cerdo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	cerdo.custom_minimum_size = cerdo_tamano
	cerdo.size = cerdo_tamano
	add_child(cerdo)
	move_child(cerdo, min(cerdo_indice_en_arbol, get_child_count() - 1))

	var viewport_size := get_viewport_rect().size
	var y_inicio := viewport_size.y / 2.0
	if cards.size() > 0:
		y_inicio = 0.0
		for card in cards:
			y_inicio += card.position.y
		y_inicio /= cards.size()

	var x_inicio := -cerdo_tamano.x
	var x_final := viewport_size.x - cerdo_tamano.x - 20.0
	var y_final := viewport_size.y - cerdo_tamano.y - 10.0

	cerdo.position = Vector2(x_inicio, y_inicio + cerdo_offset_y)

	var tween_mov := create_tween()
	tween_mov.set_parallel(true)
	tween_mov.tween_property(cerdo, "position:x", x_final, cerdo_duracion_caminata)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween_mov.tween_property(cerdo, "position:y", y_final + cerdo_offset_y, cerdo_duracion_caminata)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween_mov.finished

	await _hablar_cerdo(cerdo)

	var t_oscurecer := create_tween()
	t_oscurecer.tween_property(cerdo, "modulate", Color(0.55, 0.55, 0.55, 0.55), 0.4)
	await t_oscurecer.finished


func _hablar_cerdo(cerdo: TextureRect) -> void:
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
	cerdo.add_child(burbuja)
	burbuja.position = Vector2(cerdo_tamano.x / 2.0 - 170, -140)
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

	cerdo.pivot_offset = Vector2(cerdo_tamano.x / 2.0, cerdo_tamano.y)
	var cerdo_y_base := cerdo.position.y

	for i in range(dialogos_cerdo.size()):
		texto.text = dialogos_cerdo[i]

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
			t.parallel().tween_property(cerdo, "position:y", cerdo_y_base - 22, 0.12)\
				.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			t.chain().tween_property(cerdo, "position:y", cerdo_y_base, 0.15)\
				.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		await t.finished
		await get_tree().create_timer(cerdo_duracion_por_texto).timeout

	var t_fin := create_tween()
	t_fin.tween_property(burbuja, "modulate:a", 0.0, 0.25)
	await t_fin.finished
	burbuja.queue_free()
	
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
	for i in range(4):
		var a = randi() % cards.size()
		var b = randi() % cards.size()
		if a != b:
			await swap(cards[a], cards[b])


func swap(card_a, card_b):
	var pos_a = card_a.position
	var pos_b = card_b.position
	var tween = create_tween()
	tween.tween_property(card_a, "position", pos_b, 0.4)
	tween.parallel().tween_property(card_b, "position", pos_a, 0.4)
	await tween.finished


func _on_card_pressed(card):
	card.flip(true)
	if card.card_id == queen_id:
		win_message.visible = true
		await get_tree().create_timer(1.5).timeout
		win_message.visible = false
		GameState.puzzles_solved[GameState.current_puzzle] = true
		var memoria_lista = GameState.puzzles_solved.get("memory", false)
		var simon_listo = GameState.puzzles_solved.get("simon", false)
		if memoria_lista and simon_listo:
			get_tree().change_scene_to_file("res://scenes/escena_17.tscn")
		else:
			get_tree().change_scene_to_file(GameState.MAP_SCENE)
	else:
		lose_message.visible = true
		await get_tree().create_timer(1.5).timeout
		lose_message.visible = false
		await get_tree().create_timer(0.5).timeout
		restart()


func restart():
	for card in cards:
		card.found = false
	assign_queen()
	show_face_up()
	await get_tree().create_timer(3.0).timeout
	hide_cards()
	await shuffle()
