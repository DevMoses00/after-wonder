extends Area2D

@onready var sprite : Sprite2D = $Sprite2D
#@onready var crt_material: ShaderMaterial = $"../../CRTEffect/ColorRect".material
@onready var mat: ShaderMaterial = $Sprite2D.material

#button sound
@export var button_sound : AudioStreamWAV
@export var audio_player : AudioStreamPlayer2D

var glowing := true
var pressed_once := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	input_event.connect(_on_input_event)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if glowing and not pressed_once:
			pressed_once = true
			glowing = false
			sprite.modulate = Color.WHITE  # Reset to normal look

			# Trigger CRT glitch burst
			#crt_material.set_shader_parameter("glitch_intensity", 1.40)
			await get_tree().create_timer(0.4).timeout
			#crt_material.set_shader_parameter("glitch_intensity", 0.02)
			DialogueManager.start_game.emit()
			print("Game Started!") # You can call your start logic here
		else:
			print("Button clicked again, but does nothing now.")
		print("Button pressed:", name)
		_press_animation()
		audio_player.stream = button_sound
		audio_player.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if glowing:
		mat.set_shader_parameter("time", Time.get_ticks_msec() / 1000.0)
		mat.set_shader_parameter("pulse_strength", 1.5) # Increase to make it pop
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
