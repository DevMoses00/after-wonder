extends Node2D

var target_angle := 0.0
var current_angle := 0.0
var sway_speed := 1.5
var max_angle := 8.0
var lerp_speed := 5.0

var build_up := 0.0
var joystick_x := 0.0

@onready var baby_sprite := self
@onready var particle_node := $RockParticles
@export var world_particles_path: NodePath
@onready var world_particles := get_node(world_particles_path)

# Rocking motion range
@export var rock_offset := Vector2(8, 0)  # Small horizontal nudge

func _ready():
	if DialogueManager.has_signal("joystick_moved"):
		DialogueManager.joystick_moved.connect(_on_joystick_input)
	else:
		print("Warning: joystick_moved signal not found.")

func _on_joystick_input(vec: Vector2):
	joystick_x = vec.x

func _physics_process(delta):
	var key_input := Input.get_action_strength("rock_right") - Input.get_action_strength("rock_left")
	var total_input = clamp(joystick_x + key_input, -1.0, 1.0)

	# 🌀 Rocking sway (rotation)
	target_angle = total_input * max_angle
	current_angle = lerp(current_angle, target_angle, delta * lerp_speed)
	rotation_degrees = current_angle

	# ➡️ Nudge the sprite slightly in rocking direction
	var offset = rock_offset * total_input
	baby_sprite.position = offset

	trigger_particles(abs(total_input))

func trigger_particles(intensity: float):
	if not particle_node:
		return

	if intensity > 0.5:
		if not particle_node.emitting:
			particle_node.emitting = true
			build_up += 10
			update_world_particles(build_up)
	else:
		if particle_node.emitting:
			particle_node.emitting = false

func update_world_particles(amount: float):
	if not world_particles:
		return

	amount = clamp(amount, 0, 1000)
	world_particles.amount = 15 + int(amount)
	SoundManager.play_sfx("Cradle", 0, -10)
