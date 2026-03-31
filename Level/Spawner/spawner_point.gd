extends Node2D
class_name ZoneSpawner

@export var width : float
@export var height : float

func spawn_enemies(number : int, enemy_instance_path : String):
	var enemy := load(enemy_instance_path)
	
	var x_size = width / 2
	var y_size = height / 2
	
	for n in number:
		var new_enemy = enemy.instantiate()
		
		# place any enemy start behavior/needed changes here
		
		var random_x = randf_range(global_position.x - x_size, global_position.x + x_size)
		var random_y = randf_range(global_position.y - y_size, global_position.y + y_size)
		
		new_enemy.global_position = Vector2(random_x,random_y)
		get_parent().add_child(new_enemy)
