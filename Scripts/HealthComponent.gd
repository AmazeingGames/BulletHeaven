extends Node
class_name HealthComponent

signal health_changed(old_value, new_value, max_value)
signal health_depleted (unit)

@export var max_health: int
@export var max_invincibility_frames: int

var current_health: int
var current_invincibility_frame: int

func _ready() -> void:
	current_health = max_health
	pass

func _process(_delta: float) -> void:
	if current_invincibility_frame:
		current_invincibility_frame -= 1
	

func damage(damage_value: int):
	if current_invincibility_frame > 0: return
	current_invincibility_frame = max_invincibility_frames
	
	var old_health = current_health
	current_health = clamp(current_health - damage_value, 0, max_health) #prevents negative health
	health_changed.emit(old_health, current_health, max_health)
	
	if (current_health == 0):
		health_depleted.emit(get_parent())
	pass

func heal (heal_value: int) -> void:
	var old_health = current_health
	current_health = clamp(current_health + heal_value, 0, max_health) #clamp prevents unintended overheal.
	health_changed.emit(old_health, current_health, max_health)
