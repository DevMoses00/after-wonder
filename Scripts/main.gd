extends Node2D

@onready var arcade_viewport = $ArcadeScreen/ArcadeViewport
var game1_scene: PackedScene = preload("res://Scenes/game1.tscn")
var game2_scene: PackedScene = preload("res://Scenes/game2.tscn")
var game3_scene: PackedScene = preload("res://Scenes/game3.tscn")

var change = true
var key_check = false
var break_fix = false
## FOR GAME 3
@onready var joystick := $ArcadeBase/Pod/Area2D
#
#
var fix:bool = false
@onready var keys = $ArcadeBase/Keys.get_children()
signal connector_3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Sound Manager Audio
	SoundManager.fade_in_bgs("Rain",2.0)
	# Read JSON File
	DialogueManager.readJSON("res://Dialogue/AW_dialogue.json")
	# Connect Signals
	signals_connect()
	# Logo Reveal
	await get_tree().create_timer(4).timeout
	fade_tween($Logo)
	SoundManager.play_sfx("Thunder",0,-10)
	await get_tree().create_timer(7).timeout
	
	# new setup 
	SoundManager.fade_out("Rain",5.0)
	SoundManager.fade_in_bgs("Rain",2.0,0,-30)
	await get_tree().create_timer(2).timeout
	SoundManager.play_sfx("Setup1")
	await get_tree().create_timer(2).timeout
	SoundManager.stop("Rain")
	dialogue_go("Load")

func signals_connect():
	DialogueManager.load_over.connect(load_game)
	DialogueManager.start_game.connect(start_game)
	DialogueManager.gwen_talking.connect(gwen_mouth_moving)
	DialogueManager.gwen_stop.connect(gwen_mouth_stop)
	DialogueManager.intro_over.connect(enter_glow)
	$ArcadeBase/Enter.enter_button_clicked.connect(setup_games)
	DialogueManager.game1_start.connect(game1start)
	DialogueManager.game1_over.connect(game1end)
	DialogueManager.game2_start.connect(leftbutton_glow)
	$ArcadeBase/LeftButton1.button_one_clicked.connect(game2start)
	DialogueManager.game2_over.connect(game2end)
	DialogueManager.crack_start.connect(crack_screen)
	DialogueManager.fix_start.connect(fix_sequence)
	connector_3.connect(game_fixed)
	DialogueManager.game3_start.connect(lowerbutton_glow)
	$ArcadeBase/LeftButton2.button_two_clicked.connect(game3start)
	DialogueManager.game3_over.connect(integration)
	DialogueManager.break_game.connect(change_file)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	all_keys_off()
	if fix == true and key_check == true: 
		if break_fix == false:
			print("keys are all pressed")
			connector_3.emit()
			break_fix = true


# MAIN FUNCS
func load_game():
	SoundManager.play_sfx("Accept")
	await get_tree().create_timer(4).timeout
	SoundManager.play_sfx("Setup2")
	await get_tree().create_timer(1).timeout
	SoundManager.play_sfx("Light")
	$ArcadeBase.visible = true
	SoundManager.fade_in_bgm("BG_1",4.0)
	
func start_game():
	# fade out bg music
	SoundManager.fade_out("BG_1",3.0)
	SoundManager.play_sfx("Call")
	# fade out title and start button
	fade_tween_out($ArcadeBase/AWTitle)
	# calling ring sound 
	await get_tree().create_timer(4.0).timeout
	SoundManager.play_sfx("Ring",0,-10)
	# show call sprite/anim
	$ArcadeBase/PhoneRoot.show()
	$ArcadeBase/PhoneRoot/AnimationPlayer.play("ring")
	await get_tree().create_timer(3.0).timeout
	SoundManager.play_sfx("Ring",0,-10)
	await get_tree().create_timer(3.0).timeout
	# call accept sound
	$ArcadeBase/PhoneRoot.hide()
	$ArcadeBase/PhoneRoot/AnimationPlayer.stop()
	SoundManager.play_sfx("Accept")
	# replace call sprite with accept sprite
	await get_tree().create_timer(2).timeout
	# show Gwen sprite
	fade_tween_in($ArcadeBase/Gwen)
	SoundManager.play_bgm("Gwen_BG",0,-20)
	await get_tree().create_timer(5).timeout
	dialogue_go("Intro")


func enter_glow():
	$ArcadeBase/Enter.glowing = true
func leftbutton_glow():
	$ArcadeBase/LeftButton1.glowing = true
func lowerbutton_glow():
	$ArcadeBase/LeftButton2.glowing = true

func setup_games():
	# something that fades Gwen from the screen
	fade_tween_out($ArcadeBase/Gwen)
	SoundManager.fade_out("Gwen_BG",2.0)
	await get_tree().create_timer(4).timeout
	# accompanying sound effect
	SoundManager.play_sfx("Setup2")
	await get_tree().create_timer(1).timeout
	SoundManager.play_sfx("Light")
	# turns into the Pixel Gwen and Title
	$ArcadeBase/PixelTitle.show()
	await get_tree().create_timer(3).timeout
	fade_tween_in($ArcadeBase/PixelGwen)
	SoundManager.fade_in_bgm("Game_BG",2.0,0,-20)
	await get_tree().create_timer(4).timeout
	# begin the next set of dialogue 
	dialogue_go("GameLayout")

func game1start():
	# hide the pixel title amd Gwen
	$ArcadeBase/PixelTitle.hide()
	fade_tween_out($ArcadeBase/PixelGwen)
	# flash in the level with characters and grid
	await get_tree().create_timer(2).timeout
	SoundManager.play_sfx("Setup2")
	await get_tree().create_timer(1).timeout
	SoundManager.play_sfx("Light")
	var game_instance = game1_scene.instantiate()
	arcade_viewport.add_child(game_instance)
	
	
	if game_instance.has_method("start"):
		print("working!")
		game_instance.start()
	# zoom camera in
	zoom_to_arcade()
	$ArcadeBase/LeftArrow.glowing = true
	$ArcadeBase/RightArrow.glowing = true


func game1end():
	$ArcadeBase/LeftArrow.glowing = false
	$ArcadeBase/RightArrow.glowing = false
	# quit the scene
	# scene should quit already
	# zoom camera out maybe
	await get_tree().create_timer(4).timeout
	# show large pixel Gwen
	SoundManager.play_bgm("Gwen_BG",0,-20)
	fade_tween_in($ArcadeBase/LargePixelGwen)
	# continue with Connector 1 Dialogue
	await get_tree().create_timer(5).timeout
	dialogue_go("Connector1")


func game2start():
	await get_tree().create_timer(2).timeout
	# hide the pixel title amd Gwen
	fade_tween_out($ArcadeBase/LargePixelGwen)
	SoundManager.fade_out("Gwen_BG",2.0)
	# flash in the level with characters and grid
	await get_tree().create_timer(2).timeout
	SoundManager.play_sfx("Setup2")
	await get_tree().create_timer(1).timeout
	SoundManager.play_sfx("Light")
	var game_instance = game2_scene.instantiate()
	arcade_viewport.add_child(game_instance)
	SoundManager.fade_in_bgm("Game_BG",2.0,0,-20)

	
	if game_instance.has_method("start"):
		print("working!")
		game_instance.start()
	# zoom camera in
	zoom_to_arcade()
	$ArcadeBase/LeftArrow.glowing = true
	$ArcadeBase/RightArrow.glowing = true
	$ArcadeBase/Keys/Key12.glowing = true


func game2end():
	# quit the scene
	$ArcadeBase/LeftArrow.glowing = false
	$ArcadeBase/RightArrow.glowing = false
	$ArcadeBase/Keys/Key12.glowing = false
	# scene should quit already
	# zoom camera out maybe
	await get_tree().create_timer(4).timeout
	# show large pixel Gwen
	SoundManager.play_bgm("Gwen_BG",0,-20)
	fade_tween_in($ArcadeBase/LargePixelGwen)
	# continue with Connector 1 Dialogue
	await get_tree().create_timer(5).timeout
	dialogue_go("Connector2")


func crack_screen():
	SoundManager.play_sfx("Thunder",0,0)
	SoundManager.stop("Gwen_BG")
	# play crack screen audio
	SoundManager.play_sfx("Glitch")
	# swap pixel gwen with other gwen
	$ArcadeBase/LargePixelGwen.hide()
	$ArcadeBase/Gwen.modulate.a = 1.00
	$ArcadeBase/Gwen.modulate.r = 0.00
	$ArcadeBase/Gwen.show()
	$ArcadeBase/Gwen/Eyes.stop()
	
	await get_tree().create_timer(2).timeout
	SoundManager.play_sfx("Glitch")
	await get_tree().create_timer(1).timeout
	dialogue_go("Crack")

func fix_sequence():
	# After Arthur runs the commands in the dialogue
	# Play fix audio
	SoundManager.play_sfx("Accept")
	# Hide Gwen 
	$ArcadeBase/Gwen.hide()
	fade_tween_out($ArcadeBase/Gwen)
	
	#Boot up a couple of keys to light up
	$ArcadeBase/Keys/Key1.glowing = true
	$ArcadeBase/Keys/Key7.glowing = true
	$ArcadeBase/Keys/Key8.glowing = true
	$ArcadeBase/Keys/Key11.glowing = true
	$ArcadeBase/Keys/Key3.glowing = true
	$ArcadeBase/Keys/Key5.glowing = true
	$ArcadeBase/Keys/Key10.glowing = true
	# turn on fix mode
	fix = true 


func game_fixed():
	SoundManager.play_sfx("Call")
	await get_tree().create_timer(3).timeout
	# fade out title and start button
	fade_tween_out($ArcadeBase/AWTitle)
	# calling ring sound 
	await get_tree().create_timer(4.0).timeout
	SoundManager.play_sfx("Ring",0,-10)
	# show call sprite/anim
	$ArcadeBase/PhoneRoot.show()
	$ArcadeBase/PhoneRoot/AnimationPlayer.play("ring")
	await get_tree().create_timer(3.0).timeout
	SoundManager.play_sfx("Ring",0,-10)
	await get_tree().create_timer(3.0).timeout
	# call accept sound
	$ArcadeBase/PhoneRoot.hide()
	$ArcadeBase/PhoneRoot/AnimationPlayer.stop()
	SoundManager.play_sfx("Accept")
	# replace call sprite with accept sprite
	await get_tree().create_timer(2).timeout
	# show Gwen sprite
	SoundManager.play_bgm("Gwen_BG",0,-20)
	$ArcadeBase/Gwen.show()
	$ArcadeBase/Gwen/Eyes.play()
	fade_tween_in($ArcadeBase/Gwen)
	await get_tree().create_timer(5).timeout
	dialogue_go("Connector3")

func game3start():
	await get_tree().create_timer(1.5).timeout
	# hide the pixel title amd Gwen
	
	fade_tween_out($ArcadeBase/Gwen)
	SoundManager.fade_out("Gwen_BG",2.0)
	# flash in the level with characters and grid
	await get_tree().create_timer(2).timeout
	SoundManager.play_sfx("Setup2")
	await get_tree().create_timer(1).timeout
	SoundManager.play_sfx("Light")
	var game_instance = game3_scene.instantiate()
	arcade_viewport.add_child(game_instance)
	SoundManager.fade_in_bgm("Game_BG",2.0,0,-20)
	# Find the baby node and assign the joystick reference
	#  var baby = game_instance.get_node("Baby")  # adjust path as needed
	#baby.joystick = joystick
	if game_instance.has_method("start"):
		print("working!")
		game_instance.start()
	# zoom camera in
	zoom_to_arcade()
	$ArcadeBase/Pod/Area2D.glowing = true


func integration():
	# quit the scene
	$ArcadeBase/Pod/Area2D.glowing = false  
	# scene should quit already
	# zoom camera out maybe
	fade_tween_out($ArcadeBase/LargePixelGwen)
	await get_tree().create_timer(4).timeout
	$ArcadeBase/LargePixelGwen.show()
	# show large pixel Gwen
	SoundManager.play_bgm("Gwen_BG",0,-20)
	fade_tween_in($ArcadeBase/LargePixelGwen) 
	
	# continue with Connector 1 Dialogue
	await get_tree().create_timer(5).timeout
	dialogue_go("Integration")


func change_file():
	await get_tree().create_timer(0.4).timeout
	Globals.kill_all_tweens()
	get_tree().change_scene_to_file("res://Scenes/endgame.tscn")



# HELPER ANIMS
func gwen_mouth_moving():
	$ArcadeBase/Gwen/Mouth.play()
	$ArcadeBase/PixelGwen/Mouth.play()
	$ArcadeBase/LargePixelGwen/Mouth.play()
func gwen_mouth_stop():
	$ArcadeBase/Gwen/Mouth.stop()
	$ArcadeBase/PixelGwen/Mouth.stop()
	$ArcadeBase/LargePixelGwen/Mouth.stop()

# HELPER FADES
func fade_tween(image) -> void:
	var fadeTween = get_tree().create_tween()
	Globals.register_tween(fadeTween)
	fadeTween.tween_property(image,"modulate",Color(1.0, 1.0, 1.0, 1.0), 2)
	fadeTween.tween_interval(3)
	fadeTween.tween_property(image,"modulate",Color(1.0, 1.0, 1.0, 0.0), 2)
	fadeTween.bind_node(self)
func fade_tween_in(image) -> void:
	var fadeTween = get_tree().create_tween()
	Globals.register_tween(fadeTween)
	fadeTween.tween_property(image,"modulate",Color(1.0, 1.0, 1.0, 1.0), 2)
	fadeTween.bind_node(self)
func fade_tween_out(image) -> void:
	var fadeTween = get_tree().create_tween()
	Globals.register_tween(fadeTween)
	fadeTween.tween_property(image,"modulate",Color(1.0, 1.0, 1.0, 0.0), 2)
	fadeTween.bind_node(self)
# CAMERA ZOOM
func zoom_to_arcade():
	var tween = get_tree().create_tween()
	Globals.register_tween(tween)
	tween.tween_property($Camera2D, "zoom", Vector2(1.3, 1.3), 1.0).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property($Camera2D, "zoom", Vector2(1.0, 1.0), 1.0).set_ease(Tween.EASE_IN_OUT)
	tween.bind_node(self)
# DIALOGUE MANAGER
func dialogue_go(dialogue_key):
	DialogueManager.dialogue_player(dialogue_key)

# HELPER GLOWS
func all_keys_off():
	if fix == true: 
		for key in keys:
			if key.glowing:
				key_check = false
				return
		key_check = true
