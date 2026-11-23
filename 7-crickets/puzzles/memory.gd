extends Control

const ESCENA_17 := "res://scenes/escena_17.tscn"
const COLUMNAS := 4
const PAREJAS := 6  # 6 parejas = 12 cartas (4x3)
const TEXTURA_REVERSO := "res://images/classic.png"
const TEXTURAS_FRENTE := [
	"res://images/match.png",
	"res://images/generic.png",
	"res://images/pareja1.png",
	"res://images/pareja2.png",
	"res://images/pareja3.png",
	"res://images/pareja4.png",
]
const SFX_ACIERTO := "res://music/memory_acierto.mp3"
const SFX_FALLO := "res://music/memory_fallo.mp3"
const SEPARACION := 24

@export var tablero_pos: Vector2 = Vector2(254, 223)

@export var tamano_carta: Vector2 = Vector2(190, 190)
@export var tiempo_mostrar_todas: float = 3.0
@export var barajar_al_fallar: bool = false
@export var coneja_tamano: Vector2 = Vector2(560, 560)
@export var coneja_offset_y: float = -50.0
@export var coneja_indice_en_arbol: int = 1
@export var burbuja_offset_y: float = -110.0

var grid: GridContainer
var textura_reverso: Texture2D = load(TEXTURA_REVERSO)
var textura_coneja: Texture2D = load("res://images/coneja.png")
var textura_caja: Texture2D = load("res://images/caja_texto.png")
var fuente_titulo: Font = load("res://fonts/chinese rocks rg.otf")
var fuente_dialogo: Font = load("res://fonts/Chinese_Ruler.ttf")

var titulos_por_idioma := {
	"en": "Find your match",
	"es": "Tu pareja ideal",
	"fr": "Ta paire idéale",
}

var instrucciones_por_idioma := {
	"en": "Oh, sweetie, what a shame you have to rush on your first day! But you can make it!\n\nMemorize where each pair is before the cards flip. Then turn over two cards: if they match, keep going. If you miss, all the cards are shown again and you start over. Find every pair!",
	"es": "¡Oh, cariño, qué pena que tengas que apurarte en tu primer día! ¡Pero tú puedes!\n\nMemoriza dónde está cada pareja antes de que las cartas se volteen. Luego voltea dos cartas: si coinciden, sigue con las demás. Si fallas, todas se muestran otra vez y empiezas de nuevo. ¡Encuentra todas las parejas!",
	"fr": "Oh, mon cœur, quel dommage de devoir te dépêcher le premier jour ! Mais tu vas y arriver !\n\nMémorise où se trouve chaque paire avant que les cartes se retournent. Retourne ensuite deux cartes : si elles correspondent, continue. Si tu te trompes, toutes les cartes sont montrées à nouveau et tu recommences. Trouve toutes les paires !",
}

var frases_por_idioma := {
	"en": {"acierto": "Great, keep going!", "fallo": "Oh no! Memorize them again!", "final": "You found them all!"},
	"es": {"acierto": "¡Muy bien, sigue así!", "fallo": "¡Oh no! ¡Memorízalas otra vez!", "final": "¡Las encontraste todas!"},
	"fr": {"acierto": "Très bien, continue !", "fallo": "Oh non ! Mémorise-les encore !", "final": "Tu les as toutes trouvées !"},
}

var frentes: Array[Texture2D] = []
var es_placeholder: Array[bool] = []
var etiquetas: Array[Label] = []
var cartas: Array[TextureButton] = []
var valores: Array[int] = []
var emparejadas: Array[bool] = []
var arriba: Array[bool] = []
var volteadas: Array[int] = []
var bloqueado := true
var coneja_actual: TextureRect = null


func _ready() -> void:
	_crear_tablero()
	for i in range(PAREJAS):
		_cargar_frente(i)
	_barajar()

	await get_tree().process_frame  # el grid calcula su tamaño final
	_crear_titulo()
	await Instrucciones.mostrar(textura_coneja, titulos_por_idioma[Lang.actual], instrucciones_por_idioma[Lang.actual])
	_colocar_coneja()
	await _iniciar_ronda()


# ---------- tablero ----------
func _crear_tablero() -> void:
	# Quita el GridContainer viejo de la escena, si todavía existe
	var viejo := get_node_or_null("GridContainer")
	if viejo:
		remove_child(viejo)
		viejo.queue_free()

	grid = GridContainer.new()
	grid.name = "Tablero"
	grid.columns = COLUMNAS
	grid.add_theme_constant_override("h_separation", SEPARACION)
	grid.add_theme_constant_override("v_separation", SEPARACION)
	add_child(grid)

	for i in range(PAREJAS * 2):
		var c := TextureButton.new()
		c.texture_normal = textura_reverso
		c.ignore_texture_size = true
		c.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		c.custom_minimum_size = tamano_carta
		c.pivot_offset = tamano_carta / 2.0
		c.focus_mode = Control.FOCUS_NONE
		c.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		c.pressed.connect(_on_carta_pressed.bind(i))

		var et := Label.new()
		et.set_anchors_preset(Control.PRESET_FULL_RECT)
		et.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		et.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		et.add_theme_font_size_override("font_size", 90)
		et.add_theme_color_override("font_color", Color(0.2, 0.1, 0.1))
		et.mouse_filter = Control.MOUSE_FILTER_IGNORE
		et.visible = false
		c.add_child(et)
		etiquetas.append(et)

		grid.add_child(c)
		cartas.append(c)
		emparejadas.append(false)
		arriba.append(false)

	# Posición y tamaño fijos del tablero
	var filas := ceili(float(PAREJAS * 2) / COLUMNAS)
	var ancho := COLUMNAS * tamano_carta.x + (COLUMNAS - 1) * SEPARACION
	var alto := filas * tamano_carta.y + (filas - 1) * SEPARACION
	grid.global_position = tablero_pos
	grid.size = Vector2(ancho, alto)

func _cargar_frente(i: int) -> void:
	if i < TEXTURAS_FRENTE.size() and ResourceLoader.exists(TEXTURAS_FRENTE[i]):
		frentes.append(load(TEXTURAS_FRENTE[i]))
		es_placeholder.append(false)
	else:
		var img := Image.create(int(tamano_carta.x), int(tamano_carta.y), false, Image.FORMAT_RGBA8)
		img.fill(Color.from_hsv(float(i) / PAREJAS, 0.5, 0.9))
		frentes.append(ImageTexture.create_from_image(img))
		es_placeholder.append(true)


func _barajar() -> void:
	valores.clear()
	for p in range(PAREJAS):
		valores.append(p)
		valores.append(p)
	valores.shuffle()


# ---------- título y coneja ----------
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
	var zona_libre_izq: float = grid.global_position.x + grid.size.x
	var zona_libre_ancho: float = viewport_size.x - zona_libre_izq

	var ancho: float = min(380.0, zona_libre_ancho - 40.0)
	var alto := 100.0
	panel.size = Vector2(ancho, alto)
	add_child(panel)
	panel.global_position = Vector2(zona_libre_izq + (zona_libre_ancho - ancho) / 2.0, 30.0)

	var titulo := Label.new()
	titulo.text = titulos_por_idioma[Lang.actual]
	titulo.add_theme_font_size_override("font_size", 32)
	titulo.add_theme_color_override("font_color", Color(0.35, 0.1, 0.1))
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	titulo.autowrap_mode = TextServer.AUTOWRAP_WORD
	if fuente_titulo:
		titulo.add_theme_font_override("font", fuente_titulo)
	panel.add_child(titulo)

func _colocar_coneja() -> void:
	var viewport_size := get_viewport_rect().size
	var zona_libre_izq: float = grid.global_position.x + grid.size.x
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
	coneja.modulate = Color(0.55, 0.55, 0.55, 0.55)
	add_child(coneja)
	move_child(coneja, min(coneja_indice_en_arbol, get_child_count() - 1))
	coneja.global_position = Vector2(
		zona_libre_izq + (zona_libre_ancho - tamano_final.x) / 2.0,
		viewport_size.y - tamano_final.y - 20.0 + coneja_offset_y
	)
	coneja_actual = coneja


func _coneja_dice(mensaje: String) -> void:
	if coneja_actual == null:
		return

	var ancho_b := 320.0
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

	# Hija de la escena (no de la coneja) para no heredar su transparencia
	add_child(burbuja)
	burbuja.global_position = coneja_actual.global_position + Vector2(
		coneja_actual.size.x / 2.0 - ancho_b / 2.0, burbuja_offset_y
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


# ---------- Juego ----------

func _iniciar_ronda() -> void:
	bloqueado = true
	volteadas.clear()
	for i in range(emparejadas.size()):
		emparejadas[i] = false
	await get_tree().create_timer(0.5).timeout
	await _voltear_todas(true)
	await get_tree().create_timer(tiempo_mostrar_todas).timeout
	await _voltear_todas(false)
	bloqueado = false


func _voltear_todas(boca_arriba: bool) -> void:
	for i in range(cartas.size()):
		_voltear(i, boca_arriba)
	await get_tree().create_timer(0.35).timeout


func _voltear(i: int, boca_arriba: bool) -> void:
	if arriba[i] == boca_arriba:
		return
	arriba[i] = boca_arriba
	var c := cartas[i]
	var t := create_tween()
	t.tween_property(c, "scale:x", 0.0, 0.12)
	t.tween_callback(func():
		c.texture_normal = frentes[valores[i]] if boca_arriba else textura_reverso
		etiquetas[i].visible = boca_arriba and es_placeholder[valores[i]]
		etiquetas[i].text = char(65 + valores[i])
	)
	t.tween_property(c, "scale:x", 1.0, 0.12)


func _on_carta_pressed(i: int) -> void:
	if bloqueado or emparejadas[i] or arriba[i]:
		return

	volteadas.append(i)
	_voltear(i, true)

	if volteadas.size() < 2:
		return

	bloqueado = true
	var a := volteadas[0]
	var b := volteadas[1]
	volteadas.clear()
	await get_tree().create_timer(0.4).timeout

	if valores[a] == valores[b]:
		emparejadas[a] = true
		emparejadas[b] = true
		_sfx(SFX_ACIERTO)
		if not emparejadas.has(false):
			_coneja_dice(frases_por_idioma[Lang.actual]["final"])
			await get_tree().create_timer(1.4).timeout
			_terminar()
			return
		_coneja_dice(frases_por_idioma[Lang.actual]["acierto"])
		bloqueado = false
	else:
		_sfx(SFX_FALLO)
		_coneja_dice(frases_por_idioma[Lang.actual]["fallo"])
		await get_tree().create_timer(0.7).timeout
		await _voltear_todas(false)
		if barajar_al_fallar:
			_barajar()
		await _iniciar_ronda()


func _terminar() -> void:
	GameState.puzzles_solved[GameState.current_puzzle] = true
	var todos := true
	for id in GameState.puzzles_solved.keys():
		if not GameState.puzzles_solved[id]:
			todos = false
	if todos:
		get_tree().change_scene_to_file(ESCENA_17)
	else:
		get_tree().change_scene_to_file(GameState.MAP_SCENE)


func _sfx(ruta: String) -> void:
	if ResourceLoader.exists(ruta):
		MusicManager.reproducir_sfx(ruta)
