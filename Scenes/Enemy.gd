extends Node2D

@export var animation_player: AnimationPlayer
@export var effect_player: AnimationPlayer
@export var health_component : HealthComponent

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health_component.health_changed.connect(_on_health_changed)
	health_component.health_depleted.connect(_on_health_depleted)
	animation_player.play("Walk")
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_physical_key_pressed(KEY_0):
		_on_health_depleted()
	if Input.is_physical_key_pressed(KEY_1):
		_on_health_changed(1, 0, 4)
	pass


func _on_health_changed(old_value, new_value, max_value):
	var tookDamage = old_value > new_value
	var healed = new_value > old_value
	
	if (tookDamage):
		# Plays SFX, creates particles, flashes white
		# Particles don't play when called in rapid succession
		effect_player.play("TakeDamage")
		pass
	else: if (healed):
		pass
	pass

func _on_health_depleted():
	animation_player.play("Die")
	pass
