extends Node2D

@onready var rocks = [
	$RockContainer/Rock0,
	$RockContainer/Rock1,
	$RockContainer/Rock2
]

var ring_under_index = 1  # The rock index hiding the ring
var is_final_phase = false


@onready var indicator = $Indicator
@onready var ring = $Ring

var selected_index = 0
var rock_health = [3, 3, 3]  # Number of hits needed to break each rock

func _ready():
	DialogueManager.readJSON("res://Dialogue/AW_dialogue.json")
	get_viewport().size = Vector2(700,480)
	DialogueManager.game2_cont.connect(remove_all_but.bind(1))
	DialogueManager.game2_over.connect(free_up)
	DialogueManager.gwen_talking.connect(gwen_mouth_moving)
	DialogueManager.gwen_stop.connect(gwen_mouth_stop)
	DialogueManager.left_arrow.connect(handle_left_input)
	DialogueManager.right_arrow.connect(handle_right_input)
	DialogueManager.down_button.connect(handle_down_input)
	start()
	update_indicator_position()
	ring.visible = false  # Hide ring initially

func gwen_mouth_moving():
	$PixelGwen/Mouth.play()
func gwen_mouth_stop():
	$PixelGwen/Mouth.stop()

func start():
	await get_tree().create_timer(4).timeout
	DialogueManager.dialogue_player("Game2")
	
func _unhandled_input(event):
	if event.is_action_pressed("ui_right"):
		handle_right_input()
	elif event.is_action_pressed("ui_left"):
		handle_left_input()
	elif event.is_action_pressed("ui_down"):
		handle_down_input()

func handle_right_input():
	selected_index = (selected_index + 1) % rocks.size()
	update_indicator_position()

func handle_left_input():
	selected_index = (selected_index - 1 + rocks.size()) % rocks.size()
	update_indicator_position()

func handle_down_input():
	break_selected_rock()

func _on_BreakButton_pressed():
	break_selected_rock()

func update_indicator_position():
	var selected_rock = rocks[selected_index]
	indicator.global_position = selected_rock.global_position + Vector2(0, 0)

func break_selected_rock():
	if selected_index >= rocks.size():
		return

	var rock = rocks[selected_index]

	if not rock.visible:
		return  # Don’t shake or break an already destroyed rock

	rock_health[selected_index] -= 1
	spawn_hit_effects(rock)

	if rock_health[selected_index] > 0:
		shake_camera()
		SoundManager.play_sfx("G2Hit",0,-10)
	else:
		rock.visible = false
		SoundManager.play_sfx("G2Break",0,-10)
		

		# Reveal ring only in final phase
		if selected_index == ring_under_index and is_final_phase and ring.visible == false:
			ring.global_position = rock.global_position
			ring.visible = true
			SoundManager.play_sfx("G2Win",0,-10)

	check_if_all_rocks_broken()



func remove_all_but(index: int):
	for i in range(rocks.size()):
		rocks[i].visible = true
		rock_health[i] = 3  
	is_final_phase = true
	ring.visible = false  # Still hide it until rock is broken

	for i in range(rocks.size()):
		if i != index:
			rocks[i].queue_free()

	rocks = [rocks[index]]
	rock_health = [rock_health[index]]
	selected_index = 0
	ring_under_index = 0
	update_indicator_position()
	DialogueManager.dialogue_player("Game2a")


func check_if_all_rocks_broken():
	for i in range(rocks.size()):
		if rocks[i].visible:
			return  # At least one still visible

	if not is_final_phase:
		await get_tree().create_timer(0.6).timeout
		reset_rocks()

# HELPER FUNCS
func shake_camera(amount := 8, duration := 0.2):
	var camera := get_viewport().get_camera_2d()
	if not camera:
		return

	var tween := get_tree().create_tween()
	Globals.register_tween(tween)
	var original_offset := camera.offset

	tween.tween_property(camera, "offset", original_offset + Vector2(randf_range(-amount, amount), randf_range(-amount, amount)), duration / 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(camera, "offset", original_offset, duration / 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

func spawn_hit_effects(rock: Node2D):
	var particles = rock.get_node("HitParticles")
	if particles:
		particles.restart()

func reset_rocks():
	print("Resetting rocks!")

	for i in range(rocks.size()):
		rocks[i].visible = true
		rock_health[i] = 3  # Reset health
		#spawn_respawn_effects(rocks[i])

	selected_index = 0
	update_indicator_position()

func free_up():
	await get_tree().create_timer(1.8).timeout
	SoundManager.play_sfx("Light")
	SoundManager.fade_out("Game_BG",1.0)
	await get_tree().create_timer(0.2).timeout
	queue_free()
