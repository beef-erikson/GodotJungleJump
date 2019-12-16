extends Node

var num_levels = 2
var current_level = 1

var game_scene = 'res://Main.tscn'
var title_screen = 'res://ui/TitleScreen.tscn'


# Restart the game, loads title screen
func restart():
	get_tree().change_scene(title_screen)


# Proceeds to next level if available
func next_level():
	current_level += 1
	if current_level <= num_levels:
		get_tree().reload_current_scene()
