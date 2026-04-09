extends Node2D
class_name ZoneSpawner

@export var width : float
@export var height : float

func spawn_enemies(number : int, enemy_factory : EnemyFactory):
	print_debug("spawning")
	var x_size = width / 2
	var y_size = height / 2
	
	for n in number:
		var random_x = randf_range(global_position.x - x_size, global_position.x + x_size)
		var random_y = randf_range(global_position.y - y_size, global_position.y + y_size)
		var random_position = Vector2(random_x, random_y)
		
		var enemy = enemy_factory.create_enemy(random_position)
		# get_parent().add_child(enemy)
