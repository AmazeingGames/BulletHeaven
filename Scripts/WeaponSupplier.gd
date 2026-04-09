extends Node
class_name WeaponSupplier

# Has a reference to the player's weapons
# Has a reference to weapon resources
# Supplies weapon data to weapon scenes
# Upgrades existing weapons

@export var weapon_scene: PackedScene
@export var weapons_data : Array[WeaponData]
@export var projectile_holder : Node2D
var player_detection_area : DetectionArea
var current_weapons : Array[WeaponData]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func init(detection_area: DetectionArea) -> void:
	player_detection_area = detection_area
	supply_weapon(weapons_data[2])
	pass

func supply_weapon(weapon_data: WeaponData) -> void:
	for weapon in current_weapons:
		if (weapon == weapon_data):
			print_debug("Upgraded weapon")
			weapon.upgrade()
			return
		pass
	
	var new_weapon = weapon_scene.instantiate() 
	current_weapons.append(weapon_data)
	add_child(new_weapon)
	new_weapon.init(player_detection_area, weapon_data)
	pass 
