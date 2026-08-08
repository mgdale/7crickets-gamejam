extends Control
func _ready() -> void:
	%mainButtons.show()
	%settingsMenu.hide()
	%creditsMenu.hide()
	
	%mainButtons.add_theme_constant_override("separation", 15)
	%settingsMenu.add_theme_constant_override("separation", 15)
	%creditsMenu.add_theme_constant_override("separation", 15)
	
	if $CenterContainer/settingsMenu/fullscreen:
		$CenterContainer/settingsMenu/fullscreen.add_theme_constant_override("h_separation", 15)
		$CenterContainer/settingsMenu/fullscreen.add_theme_font_size_override("font_size", 22)

	var btn_back_settings = $CenterContainer/settingsMenu/play
	if btn_back_settings:
		if not btn_back_settings.is_connected("pressed", Callable(self, "_on_settings_back_pressed")):
			btn_back_settings.pressed.connect(_on_settings_back_pressed)

	var btn_back_credits = $CenterContainer/creditsMenu/back
	if btn_back_credits:
		if not btn_back_credits.is_connected("pressed", Callable(self, "_on_back_pressed")):
			btn_back_credits.pressed.connect(_on_back_pressed)
# --- NAVEGACIÓN PRINCIPAL ---

func _on_play_pressed() -> void:
	var fade := ColorRect.new()
	fade.color = Color(0, 0, 0, 0)
	fade.size = get_viewport_rect().size
	fade.z_index = 100
	add_child(fade)

	var tween := create_tween()
	tween.tween_property(fade, "color:a", 1.0, 0.5)
	tween.tween_callback(func():
		get_tree().change_scene_to_file("res://Escenas/escena1.tscn")
	)

func _on_settings_pressed() -> void:
	%mainButtons.hide()
	%creditsMenu.hide()
	%settingsMenu.show()

func _on_credits_pressed() -> void:
	%mainButtons.hide()
	%settingsMenu.hide()
	%creditsMenu.show()

func _on_quit_pressed() -> void:
	get_tree().quit()

# --- FUNCIONES DE REGRESO (PANTALLA PRINCIPAL) ---

func _on_settings_back_pressed() -> void:
	%settingsMenu.hide()
	%creditsMenu.hide()
	%mainButtons.show()

func _on_back_pressed() -> void:
	%settingsMenu.hide()
	%creditsMenu.hide()
	%mainButtons.show()

# --- FULLSCREEN ---

func _on_fullscreen_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
