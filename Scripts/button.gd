extends Area2D

@onready var sprite : Sprite2D = $Sprite2D
@onready var mat: ShaderMaterial = $Sprite2D.material
# button audio
@export var button_sound : AudioStreamWAV
@export var audio_player : AudioStreamPlayer2D
var randnum : float

@export var glowing := false

signal enter_button_clicked
signal button_one_clicked
signal button_two_clicked

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randnum = randf_range(0.9,2.5)
	input_event.connect(_on_input_event)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		print("Button pressed:", name)
		audio_player.stream = button_sound
		audio_player.pitch_scale = randnum
		audio_player.play()
		_press_animation()
		
		# for starting the main game
		if self.name == "Enter" and glowing == true: 
			SoundManager.play_sfx("Accept")
			glowing = false
			enter_button_clicked.emit()
		
		elif self.name == "Exit" and glowing == true: 
			SoundManager.play_sfx("Accept")
			glowing = false
			await get_tree().create_timer(3).timeout
			get_tree().quit()
		
		# for starting the second game
		elif self.name == "LeftButton1" and glowing == true: 
			SoundManager.play_sfx("Accept")
			glowing = false
			button_one_clicked.emit()
		
		# for starting the third game
		elif self.name == "LeftButton2" and glowing == true: 
			SoundManager.play_sfx("Accept")
			glowing = false
			button_two_clicked.emit()
		
		elif self.name == "LeftArrow":
			DialogueManager.left_arrow.emit() 
		
		elif self.name == "RightArrow":
			DialogueManager.right_arrow.emit()
		
		elif self.name == "Key12":
			DialogueManager.down_button.emit()
		
		else:
			glowing = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if glowing:
		mat.set_shader_parameter("time", Time.get_ticks_msec() / 1000.0)
		mat.set_shader_parameter("pulse_strength", 1.0) # Increase to make it pop
	else:
		mat.set_shader_parameter("pulse_strength", 0.0)


func _on_mouse_entered():
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	_hover_feedback(true)

func _on_mouse_exited():
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	_hover_feedback(false)

func _hover_feedback(hovering: bool):
	if hovering:
		# Example: make it glow or scale up slightly
		sprite.scale = Vector2(1.1, 1.1)
		sprite.modulate = Color(1.2, 1.2, 1.2)  # light glow
	else:
		sprite.scale = Vector2.ONE
		sprite.modulate = Color.WHITE

func _press_animation():
	# placing example shrinking animation when pressed
	sprite.scale = Vector2(0.9,0.9)
	await get_tree().create_timer(0.1).timeout
	sprite.scale= Vector2.ONE
