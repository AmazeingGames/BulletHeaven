extends Node

@export var player : Player
@export var ui_manager : UIManager
@export var weapon_supplier : WeaponSupplier

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ui_manager.init(player.find_child("HealthComponent"))
	weapon_supplier.init(player.find_child("DetectionArea"))
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
