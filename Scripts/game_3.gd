extends Node2D

func _ready():
	DialogueManager.readJSON("res://Dialogue/AW_dialogue.json")
	get_viewport().size = Vector2(700,480)
	DialogueManager.game3_cont.connect(hideparticles)
	DialogueManager.game3_over.connect(free_up)
	DialogueManager.gwen_talking.connect(gwen_mouth_moving)
	DialogueManager.gwen_stop.connect(gwen_mouth_stop)
	start()

func gwen_mouth_moving():
	$PixelGwen/Mouth.play()
func gwen_mouth_stop():
	$PixelGwen/Mouth.stop()

func start():
	await get_tree().create_timer(4).timeout
	DialogueManager.dialogue_player("Game3")

func hideparticles():
	$Baby/RockParticles.hide()
	$GlobalParticles.emitting = false
	DialogueManager.dialogue_player("Game3a")

func free_up():
	DialogueManager.joystick_moved.disconnect($Baby._on_joystick_input)
	await get_tree().create_timer(1.8).timeout
	SoundManager.play_sfx("Light")
	SoundManager.fade_out("Game_BG",1.0)
	await get_tree().create_timer(0.2).timeout
	queue_free()
