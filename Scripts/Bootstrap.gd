extends Node

@export var player : Player
@export var ui_manager : UIManager
@export var weapon_supplier : WeaponSupplier
@export var experience_tracker: ExperienceTracker
@export var experience_factory: ExperienceFactory
@export var enemy_factory: EnemyFactory


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ui_manager.init(player.health_component, weapon_supplier.weapons_data, experience_tracker)
	weapon_supplier.init(player.detection_area, ui_manager.get_weapon_selections())
	experience_factory.init(experience_tracker)
	enemy_factory.init(experience_factory, player)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
