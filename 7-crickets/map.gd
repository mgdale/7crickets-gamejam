extends Control

@onready var charm_memory = $CharmMemory
@onready var charm_find_queen = $CharmFindQueen
@onready var charm_simon = $CharmSimon
@onready var fondo: Control = get_node_or_null("TextureRect")

var textura_charm: Texture2D = load("res://images/charm_juegos.png")
var textura_caja: Texture2D = load("res://images/caja_texto.png")
var fuente_dialogo: Font = load("res://fonts/Chinese_Ruler.ttf")

var mensajes_puzzle := {
	"find_queen": "Are you ready to find the queen?",
	"memory": "Now let's test your memory!",
	"simon": "Let's see how well you can follow directions...",
}

var popup_activo: CanvasLayer = null

@export var fondo_intensidad: float = 12.0
@export var fondo_suavizado: float = 2.5
@export var fondo_escala: float = 1.06

var fondo_pos_original: Vector2
var charms_pos_original: Dictionary = {}


func _ready():
	_configurar_charm(charm_memory, "memory")
	_configurar_charm(charm_find_queen, "find_queen")
	_configurar_charm(charm_simon, "simon")

	if fondo:
		fondo.pivot_offset = fondo.size / 2.0
		fondo.scale = Vector2(fondo_escala, fondo_escala)
		fondo_pos_original = fondo.position

	for charm in [charm_memory, charm_find_queen, charm_simon]:
		charms_pos_original[charm] = charm.position

	update_charms()


func _process(delta: float) -> void:
	if not fondo:
		return

	var viewport_size := get_viewport_rect().size
	var mouse_pos := get_viewport().get_mouse_position()
	var centro := viewport_size / 2.0
	var desplazamiento := (mouse_pos - centro) / centro

	var objetivo_fondo := fondo_pos_original - desplazamiento * fondo_intensidad
	fondo.position = fondo.position.lerp(objetivo_fondo, delta * fondo_suavizado)

	for charm in charms_pos_original.keys():
		var pos_original: Vector2 = charms_pos_original[charm]
		var objetivo_charm := pos_original - desplazamiento * fondo_intensidad
		charm.position = charm.position.lerp(objetivo_charm, delta * fondo_suavizado)


func _configurar_charm(charm: BaseButton, puzzle_id: String) -> void:
	var vacio := StyleBoxEmpty.new()
	charm.add_theme_stylebox_override("normal", vacio)
	charm.add_theme_stylebox_override("hover", vacio)
	charm.add_theme_stylebox_override("pressed", vacio)
	charm.add_theme_stylebox_override("focus", vacio)
	charm.add_theme_stylebox_override("disabled", vacio)

	if charm is TextureButton:
		charm.texture_normal = textura_charm
		charm.ignore_texture_size = true
		charm.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	elif charm is Button:
		charm.text = ""
		charm.icon = textura_charm
		charm.expand_icon = true
		charm.flat = true

	charm.focus_mode = Control.FOCUS_NONE
	charm.pivot_offset = charm.size / 2.0
	charm.resized.connect(func(): charm.pivot_offset = charm.size / 2.0)

	var escala_base := Vector2(0.78, 0.78)
	charm.scale = escala_base

	charm.mouse_entered.connect(func():
		var t := create_tween()
		t.tween_property(charm, "scale", escala_base * 1.18, 0.15)\
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		t.parallel().tween_property(charm, "modulate", Color(1.35, 1.35, 1.1), 0.15)
	)

	charm.mouse_exited.connect(func():
		var t := create_tween()
		t.tween_property(charm, "scale", escala_base, 0.15)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		t.parallel().tween_property(charm, "modulate", Color(1, 1, 1), 0.15)
	)

	charm.pressed.connect(func(): _mostrar_confirmacion(puzzle_id))


func update_charms():
	charm_memory.visible = not GameState.puzzles_solved["memory"]
	charm_find_queen.visible = not GameState.puzzles_solved["find_queen"]
	charm_simon.visible = not GameState.puzzles_solved["simon"]


func _mostrar_confirmacion(puzzle_id: String) -> void:
	if popup_activo:
		return

	var capa := CanvasLayer.new()
	capa.layer = 200
	get_tree().current_scene.add_child(capa)
	popup_activo = capa

	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.offset_left = 0
	overlay.offset_top = 0
	overlay.offset_right = 0
	overlay.offset_bottom = 0
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	capa.add_child(overlay)

	var t_fade := create_tween()
	t_fade.tween_property(overlay, "color", Color(0, 0, 0, 0.5), 0.2)

	var panel := PanelContainer.new()
	var estilo := StyleBoxTexture.new()
	estilo.texture = textura_caja
	estilo.texture_margin_left = 60
	estilo.texture_margin_right = 60
	estilo.texture_margin_top = 40
	estilo.texture_margin_bottom = 40
	estilo.content_margin_left = 50
	estilo.content_margin_right = 50
	estilo.content_margin_top = 35
	estilo.content_margin_bottom = 35
	estilo.modulate_color = Color(1, 1, 1, 0.6)
	panel.add_theme_stylebox_override("panel", estilo)
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -300
	panel.offset_right = 300
	panel.offset_top = -130
	panel.offset_bottom = 130
	panel.pivot_offset = Vector2(300, 130)
	panel.scale = Vector2(0.7, 0.7)
	panel.modulate.a = 0
	overlay.add_child(panel)

	var t_pop := create_tween()
	t_pop.tween_property(panel, "scale", Vector2(1.0, 1.0), 0.25)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t_pop.parallel().tween_property(panel, "modulate:a", 1.0, 0.2)

	var contenido := VBoxContainer.new()
	contenido.add_theme_constant_override("separation", 25)
	contenido.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(contenido)

	var pregunta := Label.new()
	pregunta.text = mensajes_puzzle.get(puzzle_id, "Are you ready?")
	pregunta.add_theme_font_size_override("font_size", 34)
	pregunta.add_theme_color_override("font_color", Color(0.35, 0.1, 0.1))
	pregunta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pregunta.autowrap_mode = TextServer.AUTOWRAP_WORD
	if fuente_dialogo:
		pregunta.add_theme_font_override("font", fuente_dialogo)
	contenido.add_child(pregunta)

	var fila_botones := HBoxContainer.new()
	fila_botones.alignment = BoxContainer.ALIGNMENT_CENTER
	fila_botones.add_theme_constant_override("separation", 60)
	contenido.add_child(fila_botones)

	var boton_no := _crear_boton_simbolo("✗", Color(0.75, 0.15, 0.15))
	var boton_si := _crear_boton_simbolo("✓", Color(0.15, 0.55, 0.2))
	fila_botones.add_child(boton_no)
	fila_botones.add_child(boton_si)

	boton_si.pressed.connect(func():
		_cerrar_confirmacion()
		GameState.go_to_puzzle(puzzle_id)
	)
	boton_no.pressed.connect(func():
		_cerrar_confirmacion()
	)


func _crear_boton_simbolo(simbolo: String, color: Color) -> Button:
	var boton := Button.new()
	boton.text = simbolo
	boton.custom_minimum_size = Vector2(90, 90)
	boton.add_theme_font_size_override("font_size", 48)
	boton.add_theme_color_override("font_color", color)
	boton.add_theme_color_override("font_hover_color", color.lightened(0.25))
	boton.add_theme_color_override("font_pressed_color", color.darkened(0.15))
	boton.focus_mode = Control.FOCUS_NONE
	boton.flat = true

	var vacio := StyleBoxEmpty.new()
	boton.add_theme_stylebox_override("normal", vacio)
	boton.add_theme_stylebox_override("hover", vacio)
	boton.add_theme_stylebox_override("pressed", vacio)
	boton.add_theme_stylebox_override("focus", vacio)
	boton.add_theme_stylebox_override("disabled", vacio)

	boton.pivot_offset = boton.custom_minimum_size / 2.0
	boton.mouse_entered.connect(func():
		var t := create_tween()
		t.tween_property(boton, "scale", Vector2(1.2, 1.2), 0.12)\
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	)
	boton.mouse_exited.connect(func():
		var t := create_tween()
		t.tween_property(boton, "scale", Vector2(1.0, 1.0), 0.12)
	)

	return boton


func _cerrar_confirmacion() -> void:
	if not popup_activo:
		return
	var capa := popup_activo
	popup_activo = null
	var overlay := capa.get_child(0)
	var t := create_tween()
	t.tween_property(overlay, "modulate:a", 0.0, 0.15)
	t.tween_callback(func(): capa.queue_free())
