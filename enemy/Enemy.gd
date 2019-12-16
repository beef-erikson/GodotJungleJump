extends KinematicBody2D

export (int) var speed
export (int) var gravity

var velocity = Vector2()
var facing = 1


# Moves enemy right/left, changing direction when a collision is detected and hurts player
func _physics_process(delta):
	# Sets enemy velocity / facing direction and gets it moving
	$Sprite.flip_h = velocity.x > 0
	velocity.y += gravity * delta
	velocity.x = facing * speed
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
	# Checks collisions
	for idx in range(get_slide_count()):
		var collision = get_slide_collision(idx)
		
		# Player collision, hurt player
		if collision.collider.name == 'Player':
			collision.collider.hurt()
		
		# Change direction, giving a small upward velocity to make it more 'natural'
		if collision.normal.x != 0:
			facing = sign(collision.normal.x)
			velocity.y = -100
	
	# Destroy enemy if it 'falls forever'
	if position.y > 1000:
		queue_free()


# Enemy took damage, play animation and disabled collision / physics
func take_damage():
	$AnimationPlayer.play('death')
	$CollisionShape2D.disabled = true
	set_physics_process(false)


# Death animation finished, remove enemy
func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == 'death':
		queue_free()