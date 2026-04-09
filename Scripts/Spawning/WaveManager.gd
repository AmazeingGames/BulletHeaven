extends Node2D
class_name WaveManager

var spawners : Array[ZoneSpawner]
var enemy_factory : EnemyFactory

func _ready() -> void:
	spawners.append_array(get_children())
	pass
	
func init(_enemy_factory: EnemyFactory) -> void:
	enemy_factory = _enemy_factory
	
	for spawner in spawners:
		spawner.spawn_enemies(20, enemy_factory)
	pass
