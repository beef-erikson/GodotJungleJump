extends Node2D

signal score_changed

var score

# Caches the pickups
onready var pickups = $Pickups
var Collectible = preload('res://collectible/Collectible.tscn')

# Hides pickups, puts the player at spawn location and inits score/camera
func _ready():
	spawn_pickups()
	score = 0
	emit_signal('score_changed', score)
	pickups.hide()
	$Player.start($PlayerSpawn.position)
	set_camera_limits()


# Player camera matches size of map with a 5 tile buffer on each end
func set_camera_limits():
	var map_size = $World.get_used_rect()
	var cell_size = $World.cell_size
	$Player/Camera2D.limit_left = (map_size.position.x - 5) * cell_size.x
	$Player/Camera2D.limit_right = (map_size.end.x + 5) * cell_size.x


# Spawns items from cache;
# Iterates through array of collectible tiles and sets tiles values to an id
func spawn_pickups():
	for cell in pickups.get_used_cells():
		var id = pickups.get_cellv(cell)
		var type = pickups.tile_set.tile_get_name(id)
		
		if type in ['gem', 'cherry']:
			var c = Collectible.instance()
			var pos = pickups.map_to_world(cell)
			c.init(type, pos + pickups.cell_size / 2)
			add_child(c)
			c.connect('pickup', self, '_on_Collectible_pickup')


# Add to score, collectible picked up
func _on_Collectible_pickup():
	score += 1
	emit_signal('score_changed', score)


# Player death
func _on_Player_dead():
	pass