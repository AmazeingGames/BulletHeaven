extends Node
class_name UpgradeMenu

@export var selection_container : Container
var weapon_selections : Array[WeaponSelection]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	weapon_selections.append_array(selection_container.get_children())
	for selection in weapon_selections:
		selection.select_weapon.connect(_on_select_weapon)
		pass
	pass # Replace with function body.

func _on_select_weapon(weapon_data: WeaponData) -> void:
	self.visible = false
	pass

func display_selections(weapons_data: Array[WeaponData]) -> void:
	if (self.visible == true):
		# print_debug("Already visible")
		return
		
	self.visible = true
	var pool := weapons_data.duplicate()
	pool.shuffle()
	var count = min(pool.size(), weapon_selections.size())
	
	for i in count:
		var weapon_data = pool[i]
		weapon_selections[i].set_weapon(weapon_data)
	pass
