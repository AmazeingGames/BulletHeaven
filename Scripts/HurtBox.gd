class_name HurtBox
extends Area2D

@export var health_component: HealthComponent
@export var damaging_group: String

func take_damage(damage: int) -> void:
	health_component.damage(damage)
	# print_debug("took damage")
	pass
