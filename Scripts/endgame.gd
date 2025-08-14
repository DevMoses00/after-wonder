extends Node2D

@onready var shader_mat = $CRTEffect/ColorRect.material

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SoundManager.stop("Gwen_BG")
	SoundManager.play_sfx("Glitch")
	DialogueManager.readJSON("res://Dialogue/AW_dialogue.json")
	shader_mat.set_shader_parameter("glitch_intensity", 0.5)
	#Signals Connect
	DialogueManager.gwen_talking.connect(gwen_mouth_moving)
	DialogueManager.gwen_stop.connect(gwen_mouth_stop)
	DialogueManager.arthur_talking.connect(arthur_mouth_moving)
	DialogueManager.arthur_stop.connect(arthur_mouth_stop)
	# Glitch Distotion Sound
	SoundManager.play_sfx("Thunder",0,0)
	SoundManager.play_sfx("Comp")
	await get_tree().create_timer(5).timeout
	DialogueManager.dialogue_player("Endgame")
	DialogueManager.endgame_over.connect(fixed_up)
	
	DialogueManager.conclusion_over.connect(particles_moment)

func fixed_up():
	# Audio of fixing it up
	SoundManager.play_sfx("Accept")
	# remove sprite 
	$Sprite2D.hide()
	
	# reset all shader material
	shader_mat.set_shader_parameter("pixel_size",0.03)
	shader_mat.set_shader_parameter("curvature",0.03)
	shader_mat.set_shader_parameter("scanline_intensity",0.02)
	shader_mat.set_shader_parameter("glitch_intensity",0.01)
	shader_mat.set_shader_parameter("chroma_offset",0.002)

	await get_tree().create_timer(4).timeout
	
	#fade in both characters
	fade_tween_in($PixelGwen)
	fade_tween_in($PixelArthur)
	
	await get_tree().create_timer(5).timeout
	DialogueManager.dialogue_player("Conclusion")
	

func particles_moment():
	# play a sound here
	SoundManager.fade_in_bgm("BG_1",1.0)
	await get_tree().create_timer(4).timeout
	fade_tween_out($PixelArthur)
	fade_tween_out($PixelGwen)
	await get_tree().create_timer(1.8).timeout
	$GlobalParticlesArthur.emitting = true
	$GlobalParticlesGwen.emitting = true
	await get_tree().create_timer(0.2).timeout
	grow_particles()
	await get_tree().create_timer(10).timeout
	$GlobalParticlesArthur.emitting = false
	$GlobalParticlesGwen.emitting = false
	await get_tree().create_timer(9).timeout
	SoundManager.fade_out("BG_1",1.0)
	SoundManager.fade_out("Rain",1.0)
	await get_tree().create_timer(0.4).timeout
	SoundManager.fade_in_bgs("Rain",2.0)
	SoundManager.play_sfx("Thunder",0,-10)
	SoundManager.play_sfx("Light")
	thanks_for_playing()

func grow_particles():
	var tween = get_tree().create_tween()
	tween.tween_property($GlobalParticlesArthur,"scale",Vector2(8.0,8.0),10).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property($GlobalParticlesGwen,"scale",Vector2(8.0,8.0),10).set_ease(Tween.EASE_IN_OUT)
func thanks_for_playing():
	# Play a sound
	$End.show()
	await get_tree().create_timer(3).timeout
	$End/Exit.glowing = true
	
# HELPER ANIMS
func gwen_mouth_moving():
	$PixelGwen/Mouth.play()
func gwen_mouth_stop():
	$PixelGwen/Mouth.stop()

func arthur_mouth_moving():
	$PixelArthur/Mouth.play()

func arthur_mouth_stop():
	$PixelArthur/Mouth.stop()

func fade_tween(image) -> void:
	var fadeTween = get_tree().create_tween()
	fadeTween.tween_property(image,"modulate",Color(1.0, 1.0, 1.0, 1.0), 2)
	fadeTween.tween_interval(3)
	fadeTween.tween_property(image,"modulate",Color(1.0, 1.0, 1.0, 0.0), 2)

func fade_tween_in(image) -> void:
	var fadeTween = get_tree().create_tween()
	fadeTween.tween_property(image,"modulate",Color(1.0, 1.0, 1.0, 1.0), 2)

func fade_tween_out(image) -> void:
	var fadeTween = get_tree().create_tween()
	fadeTween.tween_property(image,"modulate",Color(1.0, 1.0, 1.0, 0.0), 2)
