extends KinematicBody2D

signal life_changed
signal dead

export (int) var run_speed
export (int) var jump_speed
export (int) var gravity

# State machine
enum {IDLE, RUN, JUMP, HURT, DEAD, CROUCH}

var state
var anim
var new_anim

# Jump support
var max_jumps = 2
var jump_count = 0
var starting_dust = false

# Movement support
var velocity = Vector2()

# Player health support
var life


# At start, have state set to IDLE
func _ready():
	change_state(IDLE)


# Add gravity to velocity and use move_and_slide for movement
func _physics_process(delta):
	if state != DEAD:
		velocity.y += gravity * delta
		get_input()
	
	# Plays animation if different than current
	if new_anim != anim:
		anim = new_anim
		$AnimationPlayer.play(anim)
	
	# Moves player (second vector property defines direction surface is facing, in this case top)
	if state != DEAD:
		velocity = move_and_slide(velocity, Vector2(0, -1))
	
	# Checks if player hit danger layer (takes damage if not already in hurt state)
	if state == HURT:
		return
	for idx in range(get_slide_count()):
		var collision = get_slide_collision(idx)
		
		if collision.collider.name == 'Danger':
			hurt()
		
		# Checks if player has jumped on enemy using its y coord, otherwise player is hurt
		if collision.collider.is_in_group('enemies'):
			var player_feet = (position + $CollisionShape2D.shape.extents).y
			# Enemy hurt
			if player_feet < collision.collider.position.y:
				$EnemyHurtSound.play()
				collision.collider.take_damage()
				velocity.y = -200
			# Player hurt
			else:
				hurt()

	# If player is 'infinitely falling', change to dead after y is 1000
	if position.y > 1000:
		change_state(DEAD)

	# State changes
	if state == JUMP and is_on_floor():
		change_state(IDLE)
		if starting_dust == true:
			$Dust.emitting = true
	if state == JUMP and velocity.y > 0:
		new_anim = 'jump_down'


# Starts the player at the given position and sets initial properties
func start(pos):
	position = pos
	show()
	change_state(IDLE)
	life = 3
	emit_signal('life_changed', life)


# Player is hurt by either spike or enemy
func hurt():
	if state != HURT:
		change_state(HURT)


# Handles inputs
func get_input():
	# Gets inputs if not hurt and assigns them to a var
	if state == HURT:
		return
	var right = Input.is_action_pressed('right')
	var left = Input.is_action_pressed('left')
	var jump = Input.is_action_just_pressed('jump')
	var down = Input.is_action_pressed('crouch')
	
	# -- Movement
	velocity.x = 0
	
	# Moving left and right
	if right:
		velocity.x += run_speed
		$Sprite.flip_h = false
	if left:
		velocity.x -= run_speed
		$Sprite.flip_h = true
	
	# Jump and double jump
	if jump and state == JUMP and jump_count < max_jumps:
		new_anim = 'jump_up'
		velocity.y = jump_speed / 1.5
		jump_count += 1
	if jump and is_on_floor():
		starting_dust = true
		$JumpSound.play()		
		change_state(JUMP)
		velocity.y = jump_speed

	# Crouching
	if down and is_on_floor():
		change_state(CROUCH)
	if !down and state == CROUCH:
		change_state(IDLE)
	
	# State transitions during movement
	if state in [IDLE, CROUCH] and velocity.x != 0:
		change_state(RUN)
	if state == RUN and velocity.x == 0:
		change_state(IDLE)
	if state in [IDLE, RUN] and !is_on_floor():
		change_state(JUMP)


# Handles the changing of states, assigning them to an animation
func change_state(new_state):
	state = new_state
	match state:
		IDLE:
			new_anim = 'idle'
		RUN:
			new_anim = 'run'
		HURT:
			# Bounces away from inury, subtracts life, and changes to idle after 0.5 seconds
			new_anim = 'hurt'
			velocity.x = -200
			velocity.y = -100 * sign(velocity.x)
			life -= 1
			emit_signal('life_changed', life)
			if life >= 0:
				$HurtSound.play()
			if life <= 0:
				velocity.x = 0
				velocity.y = 0
				change_state(DEAD)
			if state != DEAD:
				yield(get_tree().create_timer(0.5), 'timeout')
			change_state(IDLE)
			
		JUMP:
			new_anim = 'jump_up'
			jump_count = 1
		DEAD:
			emit_signal('dead')
			hide()
		CROUCH:
			new_anim = 'crouch'