class_name UIManager
extends Node

@export var health_bar : ProgressBar

func init(health_component : HealthComponent) -> void:
	health_bar.min_value = 0
	health_bar.max_value = health_component.max_health
	health_bar.value = health_component.current_health
	
	health_component.health_changed.connect(_on_player_health_changed)
	pass

func _on_player_health_changed(new_value, max_value):
	health_bar.value = new_value
	pass
