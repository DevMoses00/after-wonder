extends Node

# for the JSON file
var finish 

func readJSON(json_file_path):
	var file = FileAccess.open(json_file_path, FileAccess.READ)
	var content = file.get_as_text()
	var json = JSON.new()
	finish = json.parse_string(content)
	return finish

@onready var text_box_scene = preload("res://Scenes/text_box.tscn")

var dialogue_lines
var current_line_index = 0

var text_box
var text_box_position : Vector2
#var text_box_tween : Tween

var is_dialogue_active = false
var can_advance_line = false


# animation cues


# signals for extra camera affects
signal camera_zoom_signaled
signal camera_reset_signaled
signal endzoom_signaled

# bad delete this later
signal joystick_moved
# which story chapter we're in
var chapter : String

# list chapters here
signal load_over
signal start_game
signal intro_over

# starting the games
signal game1_start
signal game1_cont
signal game1_over

signal game2_start
signal game2_cont
signal game2_over

signal crack_start
signal fix_start

signal game3_start
signal game3_cont
signal game3_over

signal break_game
signal endgame_over
# when pressing the enter button, will take to the next game


signal main_over 
signal conclusion_over


# character specific
signal gwen_talking
signal gwen_stop
signal arthur_talking
signal arthur_stop

#lazy buttons 
signal left_arrow
signal right_arrow
signal down_button

var character_path : String

func _ready() -> void:
	pass

# Create a new dialogue start function that takes a specific set of dialogue lines
func dialogue_player(line_key):
	if is_dialogue_active:
		return
	
	# change the chapter variable to the line key title 
	chapter = line_key
	
	dialogue_lines = finish[line_key]
	
	# if this is a regular dialogue line
	_show_text_box()
	is_dialogue_active = true

func _show_text_box():
	# for stage directions
	if dialogue_lines[current_line_index].begins_with("Time:"):
		print("this is working")
		# removes everything but the number in this line
		var timeNum = int(dialogue_lines[current_line_index].to_int())
		print(timeNum)
		can_advance_line = false
		# use it to create a timer based on that int num
		await get_tree().create_timer(timeNum).timeout 
		await get_tree().create_timer(1).timeout
		current_line_index += 1
		_show_text_box()
		return
	
	#if dialogue_lines[current_line_index].begins_with("ENCLOSE"):
		#print("Enclose")
		## send a signal
		#endgame_signaled.emit()
		#can_advance_line = false
		#await get_tree().create_timer(5).timeout
		#current_line_index += 1 
		#_show_text_box()
		#return
	
	if dialogue_lines[current_line_index].begins_with("Zoom"):
		print("camera zoom")
		# send a signal to tween the camera and zoom closer
		camera_zoom_signaled.emit()
		can_advance_line = false
		await get_tree().create_timer(0.2).timeout
		current_line_index += 1 
		_show_text_box()
		return
	
	if dialogue_lines[current_line_index].begins_with("Reset"):
		print("camera reset")
		# send a signal to tween the camera and zoom closer
		camera_reset_signaled.emit()
		can_advance_line = false
		await get_tree().create_timer(0.2).timeout
		current_line_index += 1 
		_show_text_box()
		return
	
	if dialogue_lines[current_line_index].begins_with("Endzoom"):
		print("engage end protocol")
		# send a signal to tween the camera and zoom closer
		endzoom_signaled.emit()
		can_advance_line = false
		await get_tree().create_timer(0.2).timeout
		current_line_index += 1 
		_show_text_box()
		return
		
	
	# Audio Commands
	if dialogue_lines[current_line_index].begins_with("Template"):
		print("play sounds")
		# Sound Manager play lager G
		#SoundManager.fade_in_mfx(" ",2.0)
		#SoundManager.fade_out(" ",22.0)
		can_advance_line = false
		await get_tree().create_timer(0.2).timeout
		current_line_index += 1 
		_show_text_box()
		return
	
	text_box = text_box_scene.instantiate()
	text_box.finished_displaying.connect(_on_text_box_finished_displaying)
	get_tree().root.add_child(text_box)
	
	
	if dialogue_lines[current_line_index].begins_with("G:"):
		#var sfx_standard = ["Text1","Text2","Text3"].pick_random()
		#SoundManager.play_sfx(sfx_standard,0,-15)
		gwen_talking.emit()
		text_box.global_position = Vector2(-750, 0)
		text_box.rotation_degrees = 2
		text_box.dialogue.visible = true
		
	
	if dialogue_lines[current_line_index].begins_with("A:"):
		#var sfx_standard = ["Text1","Text2","Text3"].pick_random()
		#SoundManager.play_sfx(sfx_standard,0,-15)
		text_box.global_position = Vector2(765, 0)
		text_box.rotation_degrees = -2.5
		text_box.dialogue.visible = true
	
	if dialogue_lines[current_line_index].begins_with("PG:"):
		#var sfx_standard = ["Text1","Text2","Text3"].pick_random()
		#SoundManager.play_sfx(sfx_standard,0,-15)
		gwen_talking.emit()
		text_box.global_position = Vector2(80 , 0)
		text_box.dialogue.visible = true
	
	# FOR ENDGAME LINES
	if dialogue_lines[current_line_index].begins_with("OG:"):
		#var sfx_standard = ["Text1","Text2","Text3"].pick_random()
		#SoundManager.play_sfx(sfx_standard,0,-15)
		gwen_talking.emit()
		text_box.global_position = Vector2(-600 , 225)
		text_box.dialogue.visible = true
	
	if dialogue_lines[current_line_index].begins_with("OA:"):
		#var sfx_standard = ["Text1","Text2","Text3"].pick_random()
		#SoundManager.play_sfx(sfx_standard,0,-15)
		arthur_talking.emit()
		text_box.global_position = Vector2(600 , 225)
		text_box.dialogue.visible = true
	
	text_box.display_text(dialogue_lines[current_line_index])
	# Play a random set of from soundmanager
	#var sfx_standard = ["Dialogue1","Dialogue2","Dialogue3"].pick_random()
	#SoundManager.play_sfx(sfx_standard,0,-15)
	can_advance_line = false

func _on_text_box_finished_displaying():
		can_advance_line = true
		# have gwen stop talking if she is talking 
		gwen_stop.emit()
		arthur_stop.emit()


func _unhandled_input(event: InputEvent) -> void:
	if (
		event.is_action_pressed("advance_dialogue") &&
		is_dialogue_active &&
		can_advance_line
	):
		text_box.queue_free()      
		
		current_line_index += 1
		
		
		if current_line_index >= dialogue_lines.size():
			is_dialogue_active = false
			current_line_index = 0
			# send a signal saying that this line is over and a new action must occur?
			if chapter == "Intro":
				intro_over.emit()
			elif chapter == "Load":
				load_over.emit()
			elif chapter == "GameLayout":
				game1_start.emit()
			elif chapter == "Game1":
				game1_cont.emit()
			elif chapter == "Game1a":
				game1_over.emit()
			elif chapter == "Connector1":
				game2_start.emit()
			elif chapter == "Game2":
				game2_cont.emit()
			elif chapter == "Game2a":
				game2_over.emit()
			elif chapter == "Connector2":
				crack_start.emit()
			elif chapter == "Crack":
				fix_start.emit()
			elif chapter == "Connector3":
				game3_start.emit()
			elif chapter == "Game3":
				game3_cont.emit()
			elif chapter == "Game3a":
				game3_over.emit()
			elif chapter == "Integration":
				break_game.emit()
			elif chapter == "Endgame":
				endgame_over.emit()
			elif chapter == "Conclusion":
				conclusion_over.emit()
			return
		_show_text_box()


func skip_dialogue():
	current_line_index = int(dialogue_lines.size())
	#text_box.queue_free()
	#text_box_tween.kill()
	# have their mouths stop moving
	#stop_talking.emit()
	# send a signal saying that this line is over and a new action must occur?
	#choice_make.emit()
	return
