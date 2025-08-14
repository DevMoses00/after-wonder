extends Area2D

@onready var stick_sprite = $StickSprite 
var dragging := false
var max_distance := 20.0
var default_position := Vector2.ZERO
@export var button_sound : AudioStreamWAV
@export var audio_player : AudioStreamPlayer2D

signal joystick_moved(direction: Vector2)
var last_direction := Vector2.ZERO

var randnum: float
var output_vector: Vector2 = Vector2.ZERO
@export var glowing := false

signal pod_vector
func _ready():
	randnum = randf_range(0.6,0.9)
	default_position = stick_sprite.position  # Save its starting position
	mouse_exited.connect(_on_mouse_exited)
	mouse_entered.connect(_on_mouse_entered)

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		dragging = event.pressed

func _on_mouse_exited():
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	_hover_feedback(false)
	dragging = false

func _on_mouse_entered():
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	_hover_feedback(true)

func _hover_feedback(hovering: bool):
	if hovering:
		# Example: make it glow or scale up slightly
		stick_sprite.scale = Vector2(1.1, 1.1)
		stick_sprite.modulate = Color(1.2, 1.2, 1.2)  # light glow
	else:
		stick_sprite.scale = Vector2.ONE
		stick_sprite.modulate = Color.WHITE


func _process(delta):
	if dragging:
		var local_mouse := to_local(get_global_mouse_position()) - default_position
		if local_mouse.length() > max_distance:
			local_mouse = local_mouse.normalized() * max_distance
		stick_sprite.position = default_position + local_mouse
	else:
		stick_sprite.position = stick_sprite.position.lerp(default_position, 10 * delta)
		## button sound
		#audio_player.stream = button_sound
		#audio_player.pitch_scale = randnum
		#audio_player.play()
	
	var dir = get_input_vector()
	if dir != last_direction:
		last_direction = dir
		call_deferred("_emit_joystick", dir)
		
	if glowing:
		stick_sprite.material.set_shader_parameter("time", Time.get_ticks_msec() / 1000.0)
		stick_sprite.material.set_shader_parameter("pulse_strength", 1.0) # Increase to make it pop
	else:
		stick_sprite.material.set_shader_parameter("pulse_strength", 0.0)

func get_input_vector() -> Vector2:
	var offset = stick_sprite.position - default_position
	var input_vector = offset / max_distance  # Normalize to range -1 to 1
	return input_vector

func _emit_joystick(vec: Vector2):
	DialogueManager.joystick_moved.emit(vec)
