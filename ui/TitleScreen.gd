extends Control

export (int) var speed


# Makes the parallax constantly scroll
func _process(delta):
	$ParallaxBackground/ParallaxLayer.motion_offset.x += speed