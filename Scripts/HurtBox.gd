class_name HurtBox
extends Area2D

@export var health_component: HealthComponent

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area_entered.connect(_on_area_entered)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_entered(hit: Area2D) -> void:
	if (hit is HitBox and health_component and hit.is_in_group("Player")):
		health_component.take_damage(hit.damage)
		get_parent().queue_free()
	pass
