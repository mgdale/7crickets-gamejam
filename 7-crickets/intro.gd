extends Control

const RUTA_LOGO_SORORA := "res://images/sorora_logo.png"
const RUTA_TITULO := "res://images/zodiance_titulo.png"
const ESCENA_MENU := "res://main_menu.tscn"

@export var color_arriba: Color = Color(1.0, 0.93, 0.55)
@export var color_abajo: Color = Color(1.0, 0.76, 0.86)

@export var tamano_logo: Vector2 = Vector2(1000, 700)
@export var tamano_titulo: Vector2 = Vector2(1500, 800)

@export var pausa_inicial: float = 0.8
@export var duracion_fade_in: float = 1.0
@export var tiempo_visible: float = 2.0
@export var duracion_fade_out: float = 0.8
@export var pausa_entre_pantallas: float = 0.4

var avanzando := false


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_crear_fondo()

	await get_tree().create_timer(pausa_inicial).timeout
	if avanzando:
		return

	await _mostrar_pantalla(RUTA_LOGO_SORORA, tamano_logo, "")
	if avanzando:
		return

	await get_tree().create_timer(pausa_entre_pantallas).timeout
	if avanzando:
		return

	await _mostrar_pantalla(RUTA_TITULO, tamano_titulo, "Zodiance")
	if avanzando:
		return

	_ir_al_menu()


func _crear_fondo() -> void:
	var degradado := Gradient.new()
	degradado.set_color(0, color_arriba)
	degradado.set_color(1, color_abajo)

	var textura := GradientTexture2D.new()
	textura.gradient = degradado
	textura.fill_from = Vector2(0.5, 0.0)
	textura.fill_to = Vector2(0.5, 1.0)
	textura.width = 8
	textura.height = 512

	var fondo := TextureRect.new()
	fondo.texture = textura
	fondo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	fondo.stretch_mode = TextureRect.STRETCH_SCALE
	fondo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fondo)
	fondo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func _mostrar_pantalla(ruta: String, tamano: Vector2, texto_respaldo: String) -> void:
	var contenido := _crear_contenido(ruta, tamano, texto_respaldo)
	if contenido == null:
		return

	contenido.modulate.a = 0.0
	add_child(contenido)
	contenido.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var t_in := create_tween()
	t_in.tween_property(contenido, "modulate:a", 1.0, duracion_fade_in)
	await t_in.finished
	if avanzando:
		return

	await get_tree().create_timer(tiempo_visible).timeout
	if avanzando:
		return

	var t_out := create_tween()
	t_out.tween_property(contenido, "modulate:a", 0.0, duracion_fade_out)
	await t_out.finished

	contenido.queue_free()


func _crear_contenido(ruta: String, tamano: Vector2, texto_respaldo: String) -> Control:
	var centro := CenterContainer.new()
	centro.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if ResourceLoader.exists(ruta):
		var imagen := TextureRect.new()
		imagen.texture = load(ruta)
		imagen.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		imagen.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		imagen.custom_minimum_size = tamano
		imagen.mouse_filter = Control.MOUSE_FILTER_IGNORE
		centro.add_child(imagen)
	elif texto_respaldo != "":
		var texto := Label.new()
		texto.text = texto_respaldo
		texto.add_theme_font_size_override("font_size", 120)
		texto.add_theme_color_override("font_color", Color(0.85, 0.15, 0.15))
		texto.add_theme_font_override("font", load("res://fonts/chinese rocks rg.otf"))
		centro.add_child(texto)
	else:
		centro.free()
		return null

	return centro


func _unhandled_input(event: InputEvent) -> void:
	var tecla: bool = event is InputEventKey and event.pressed and not event.is_echo()
	var clic: bool = event is InputEventMouseButton and event.pressed
	if tecla or clic:
		_ir_al_menu()


func _ir_al_menu() -> void:
	if avanzando:
		return
	avanzando = true
	get_tree().change_scene_to_file(ESCENA_MENU)
