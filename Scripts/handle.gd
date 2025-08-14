extends Node2D

@onready var handle_sprite := $HandleSprite
@onready var handle_area := $HandleSprite/Area2D
@export var rect : ColorRect

@export var camera_node_path: NodePath
@onready var zoom_camera := get_node(camera_node_path)

var handle_start := Vector2.ZERO
var handle_end := Vector2(-81, -92) # Local movement vector
var dragging := false
var drag_offset := Vector2.ZERO
var max_skew_deg := 20.0

@export var button_sound : AudioStreamWAV
@export var audio_player : AudioStreamPlayer2D
var randnum : float

func _ready():
	randnum = randf_range(0.9,2.5)
	handle_area.mouse_exited.connect(_on_mouse_exited)
	handle_area.mouse_entered.connect(_on_mouse_entered)
	handle_start = handle_sprite.position
	handle_end = handle_start + Vector2(-81, -92)  # stay in local coordinates
	handle_area.input_event.connect(_on_area_2d_input_event)

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		dragging = false

func _process(delta):
	if not dragging:
		return

	var mouse_local := to_local(get_global_mouse_position()) - drag_offset

	var track_vector := handle_end - handle_start
	var direction := track_vector.normalized()

	var to_mouse := mouse_local - handle_start
	var length = clamp(to_mouse.dot(direction), 0, track_vector.length())
	var percent = length / track_vector.length()

	# Move handle in local space
	handle_sprite.position = handle_start + direction * length

	# Apply skew
	handle_sprite.skew = deg_to_rad(percent * max_skew_deg)
	set_glitch_intensity(percent)
	update_camera_zoom()


	# Optional: update glitch
func set_glitch_intensity(percent: float):
	var intensity = 0.02 - percent * 0.02 # fade out as handle goes up
	var glitch = 0.01 - percent * 0.01
	var shader_mat = rect.material
	if shader_mat:
		shader_mat.set_shader_parameter("scanline_intensity", intensity)
		shader_mat.set_shader_parameter("glitch_intensity", glitch)


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		dragging = true
		drag_offset = to_local(get_global_mouse_position()) - handle_sprite.position
		audio_player.stream = button_sound
		audio_player.pitch_scale = randnum
		audio_player.play()
		

func _on_mouse_entered():
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	_hover_feedback(true)

func _on_mouse_exited():
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	_hover_feedback(false)

func _hover_feedback(hovering: bool):
	if hovering:
		# Example: make it glow or scale up slightly
		handle_sprite.scale = Vector2(1.1, 1.1)
		handle_sprite.modulate = Color(1.2, 1.2, 1.2)  # light glow
	else:
		handle_sprite.scale = Vector2.ONE
		handle_sprite.modulate = Color.WHITE

func update_camera_zoom():
	if not zoom_camera:
		return

	var handle_pos = handle_sprite.position.y
	var t = inverse_lerp(handle_start.y + handle_end.y, handle_start.y - handle_end.y, handle_pos)
	t = clamp(t, 0.0, 1.0)

	# Adjust these to your desired min/max zoom
	var min_zoom = Vector2(0.8, 0.8)  # Zoomed in
	var max_zoom = Vector2(1.2, 1.2)  # Zoomed out

	zoom_camera.zoom = min_zoom.lerp(max_zoom, t)
