class_name HealthComponent
extends Node

@export var max_health: int

signal health_changed(old_value, new_value, max_value)
signal health_depleted

var current_health: int = max_health
var invincibilityFrames: int
var currentInvincibilityFrames: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_health = max_health
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	currentInvincibilityFrames -= 1
	pass

func take_damage(damageAmount: int) -> void:

	if (currentInvincibilityFrames > 0):
		return
		
	print_debug("Health component take damage")
	var old_health = current_health
	current_health -= damageAmount
	
	health_changed.emit(old_health, current_health, max_health)
	currentInvincibilityFrames = invincibilityFrames
	
	if (current_health <= 0):
		health_depleted.emit()
	pass

func heal(healAmount:int) -> void:
	var old_health = current_health
	current_health += healAmount
	
	health_changed.emit(old_health, max_health)
	pass
