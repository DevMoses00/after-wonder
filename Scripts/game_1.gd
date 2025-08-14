extends Node2D


@onready var grid = $Grid
@onready var gwen = $Grid/Gwen
@onready var arthur = $Grid/Arthur

const CELL_SIZE = Vector2(80, 32)
const NUM_CELLS = 6

var index_a = 0     # A starts on left
var index_b = 5     # B starts on right

var row_a = 0 
var row_b = 1

var mode = "separate"
var turn = "a"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DialogueManager.readJSON("res://Dialogue/AW_dialogue.json")
	get_viewport().size = Vector2(700,480)
	DialogueManager.game1_cont.connect(change_mode)
	DialogueManager.game1_over.connect(free_up)
	DialogueManager.gwen_talking.connect(gwen_mouth_moving)
	DialogueManager.gwen_stop.connect(gwen_mouth_stop)
	DialogueManager.left_arrow.connect(handle_left_input)
	DialogueManager.right_arrow.connect(handle_right_input)
	start()

func gwen_mouth_moving():
	$PixelGwen/Mouth.play()
func gwen_mouth_stop():
	$PixelGwen/Mouth.stop()
	
func start():
	await get_tree().create_timer(4).timeout
	DialogueManager.dialogue_player("Game1")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func change_mode():
	mode = "shared"
	await get_tree().create_timer(1).timeout
	DialogueManager.dialogue_player("Game1a")

func _unhandled_input(event):
	if not event.is_pressed():
		return

	if Input.is_action_just_pressed("ui_left"):
		handle_left_input()
	elif Input.is_action_just_pressed("ui_right"):
		handle_right_input()

	

func handle_right_input():
	if mode == "separate":
		index_a += 1
		if index_a >= NUM_CELLS:
			index_a = 0
			row_a = 1 if row_a == 0 else 0  # Swap row

		index_b -= 1
		if index_b < 0:
			index_b = NUM_CELLS - 1
			row_b = 1 if row_b == 0 else 0

		face_right(gwen, true)
		face_right(arthur, false)
		SoundManager.play_sfx("G1Step1")
		SoundManager.play_sfx("G1Step2")

	elif mode == "shared":
		index_a = (index_a + 1) % NUM_CELLS
		face_right(gwen, true)
		face_right(arthur, true)
		SoundManager.play_sfx("G1Step3")
	
	update_player_position()

func handle_left_input():
	if mode == "separate":
		index_a -= 1
		if index_a < 0:
			index_a = NUM_CELLS - 1
			row_a = 1 if row_a == 0 else 0

		index_b += 1
		if index_b >= NUM_CELLS:
			index_b = 0
			row_b = 1 if row_b == 0 else 0

		face_right(gwen, false)
		face_right(arthur, true)
		SoundManager.play_sfx("G1Step4")
		SoundManager.play_sfx("G1Step5")

	elif mode == "shared":
		index_a = (index_a - 1 + NUM_CELLS) % NUM_CELLS
		face_right(gwen, false)
		face_right(arthur, false)
		SoundManager.play_sfx("G1Step3")

	update_player_position()

func face_right(sprite: AnimatedSprite2D, is_right: bool):
	sprite.scale.x = 1 if is_right else -1

func row_to_y(row: int) -> float:
	return -65 if row == 0 else 65

func update_player_position():
	if mode == "separate":
		gwen.position = Vector2(index_a * CELL_SIZE.x - 200, row_to_y(row_a))
		arthur.position = Vector2(index_b * CELL_SIZE.x - 200, row_to_y(row_b))
	else:
		var shared_pos = Vector2(index_a * CELL_SIZE.x - 200, row_to_y(0))
		gwen.position = shared_pos
		arthur.position = shared_pos + Vector2(0, 130)  # 65 + 65 separation


func free_up():
	await get_tree().create_timer(1.8).timeout
	SoundManager.play_sfx("Light")
	SoundManager.fade_out("Game_BG",1.0)
	await get_tree().create_timer(0.2).timeout
	queue_free()
