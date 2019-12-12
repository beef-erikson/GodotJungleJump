extends Area2D

signal pickup

var textures = {'cherry': 'res://assets/sprites/cherry.png',
				'gem': 'res://assets/sprites/gem.png'}


# Sets texture and position to given values
func init(type, pos):
	$Sprite.texture = load(textures[type])
	position = pos


# Item has been picked up, emit and delete
func _on_Collectible_body_entered(body):
	emit_signal('pickup')
	queue_free()
