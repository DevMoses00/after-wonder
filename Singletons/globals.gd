extends Node
  
var active_tweens: Array = []

func register_tween(tween):
	active_tweens.append(tween)

func kill_all_tweens():
	for tween in active_tweens:
		if tween and tween.is_valid():
			tween.kill()
	active_tweens.clear()
