extends Control

export (int) var speed


# Makes the parallax constantly scroll
func _process(delta):
	$ParallaxBackground/ParallaxLayer.motion_offset.x += speed


# Moves to level one when space is hit
func _input(event):
	if event.is_action_pressed('ui_select'):
		get_tree().change_scene(GameState.game_scene)
