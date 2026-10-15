extends Control

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

var titulos_por_idioma := {
	"en": "Find the fortune",
	"es": "Busca la fortuna",
	"fr": "Trouve la fortune",
}

var instrucciones_por_idioma := {
	"en": "Hey, little fella! The preparations for the new year are ready, so pay attention!\n\nWatch which card holds the fortune, then follow the cards as they shuffle. Pick the right one!",
	"es": "¡Oye, pequeño! Los preparativos para el año nuevo están listos, ¡así que presta atención!\n\nMira qué carta guarda la fortuna y sigue las cartas mientras se mezclan. ¡Elige la correcta!",
	"fr": "Hé, petit ! Les préparatifs pour la nouvelle année sont prêts, alors fais bien attention !\n\nRegarde quelle carte cache la fortune, puis suis les cartes pendant qu'elles se mélangent. Choisis la bonne !",
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

func _ready():
	cards = get_children().filter(func(n): return n.has_method("flip"))
	for card in cards:
		card.textura_dorso = load("res://images/sobre_queen.png")
		positions.append(card.position)
	assign_queen()

	_crear_titulo()
	await Instrucciones.mostrar(textura_cerdo, titulos_por_idioma[Lang.actual], instrucciones_por_idioma[Lang.actual])
	_colocar_cerdo()
	show_face_up()

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
		await get_tree().create_timer(1.5).timeout
		GameState.puzzles_solved[GameState.current_puzzle] = true
		var memoria_lista = GameState.puzzles_solved.get("memory", false)
		var simon_listo = GameState.puzzles_solved.get("simon", false)
		if memoria_lista and simon_listo:
			get_tree().change_scene_to_file("res://scenes/escena_17.tscn")
		else:
			get_tree().change_scene_to_file(GameState.MAP_SCENE)
	else:
		await get_tree().create_timer(1.5).timeout
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
