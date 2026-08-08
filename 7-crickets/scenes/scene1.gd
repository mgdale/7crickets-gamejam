extends Control

@onready var background = $Background
@onready var dialogue_text = $DialogueText
@onready var next_button = $NextButton

const NEXT_SCENE = "res://scene2.tscn"  # ajusta cuando exista escena 2

func _ready():
	dialogue_text.visible = false
	next_button.visible = false
	next_button.pressed.connect(_on_next_pressed)

	await get_tree().create_timer(2.5).timeout  # tiempo "dormido"
	wake_up()


func wake_up():
	# placeholder: aquí se cambia background.texture a la imagen "despierto"
	dialogue_text.text = "..."  # texto real lo pone tu compañero
	dialogue_text.visible = true
	next_button.visible = true


func _on_next_pressed():
	get_tree().change_scene_to_file(NEXT_SCENE)
