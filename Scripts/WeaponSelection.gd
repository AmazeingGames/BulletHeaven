extends Node
# Has some weapon data given to it by some other class
# On click, notifies the weapon supplier to supply the player with a kind of weapon

@export var button : Button
@export var texture_rect : TextureRect
var weapon_data : WeaponData
signal gain_weapon(_weapon_data)
 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button.pressed.connect(_on_press)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_press() -> void:
	gain_weapon.emit(weapon_data)
	pass

# Prepares the button to give a weapon on press
func set_weapon(_weapon_data : WeaponData) -> void:
	weapon_data = _weapon_data
	texture_rect.texture = weapon_data.behavior.ui_icon
	pass
