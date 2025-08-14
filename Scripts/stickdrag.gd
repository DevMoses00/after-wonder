extends Area2D

@onready var joystick_sprite: Sprite2D = $"../StickSprite"
@export var button_sound : AudioStreamWAV
@export var audio_player : AudioStreamPlayer2D

var randnum : float
var dragging := false
var max_tilt := 12.0
var default_rotation := 0.0

func _ready():
	randnum = randf_range(0.9,1.5)
	input_event.connect(_on_input_event)
	mouse_exited.connect(_on_mouse_exited)
	mouse_entered.connect(_on_mouse_entered)
func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		dragging = event.pressed

func _on_mouse_entered():
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	_hover_feedback(true)
	
func _on_mouse_exited():
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	_hover_feedback(false)
	dragging = false

func _hover_feedback(hovering: bool):
	if hovering:
		# Example: make it glow or scale up slightly
		joystick_sprite.scale = Vector2(1.1, 1.1)
		joystick_sprite.modulate = Color(1.2, 1.2, 1.2)  # light glow
	else:
		joystick_sprite.scale = Vector2.ONE
		joystick_sprite.modulate = Color.WHITE
		
func _process(delta):
	if dragging:
		var local_mouse := to_local(get_global_mouse_position())
		var tilt_angle = clamp(local_mouse.angle(), -deg_to_rad(max_tilt), deg_to_rad(max_tilt))
		joystick_sprite.rotation = tilt_angle
		audio_player.stream = button_sound
		audio_player.pitch_scale = randnum
		audio_player.play()
	else:
		joystick_sprite.rotation = lerp(joystick_sprite.rotation, default_rotation, 10 * delta)
