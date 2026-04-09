extends Node
class_name EnemyFactory

@export var enemy_scene: PackedScene
var experience_factory : ExperienceFactory
var target : Player
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func init(_experience_factory : ExperienceFactory, _target) -> void:
	experience_factory = _experience_factory
	var enemy_position = Vector2(-80, -80)
	target = _target
	
	# create_enemy(enemy_position)
	# enemy_position = Vector2(80, 80)
	# create_enemy(enemy_position)
	# enemy_position = Vector2(0, -80)
	# create_enemy(enemy_position)
	# enemy_position = Vector2(0, -160)
	# create_enemy(enemy_position)
	# enemy_position = Vector2(0, 160)
	# create_enemy(enemy_position)
	pass

func create_enemy(position : Vector2) -> Enemy:
	var enemy : Enemy
	enemy = enemy_scene.instantiate()
	enemy.init(experience_factory, target)
	enemy.add_to_group("Enemy")
	add_child(enemy)
	enemy.global_position = position
	return enemy
