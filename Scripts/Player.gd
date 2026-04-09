class_name Player
extends CharacterBody2D

@export var movement_speed : float = 500
@onready var animated_sprite := $AnimatedSprite2D
@onready var health_component := $HealthComponent
@export var detection_area: DetectionArea

var characterDirection : Vector2

func _ready() -> void:
	# print_debug(health_component == null)
	health_component.health_changed.connect(_on_health_changed)
	pass

func _physics_process(delta):
	characterDirection.x = Input.get_axis("move_left", "move_right")
	characterDirection.y = Input.get_axis("move_up", "move_down")
	characterDirection = characterDirection.normalized();
	
	if characterDirection.x > 0: animated_sprite.flip_h = false
	elif characterDirection.x < 0: animated_sprite.flip_h = true 
	
	if characterDirection:
		velocity = characterDirection * movement_speed
		if animated_sprite.animation != "walk": animated_sprite.animation = "walk"
	else:
		velocity = velocity.move_toward(Vector2.ZERO, movement_speed)
		if animated_sprite.animation != "idle": animated_sprite.animation = "idle"
		
	move_and_slide()	

func _on_health_changed(old_value, new_value, max_value):
	print_debug("Player health changed")
	# Flash
	# Play SFX
	pass

func _on_health_depleted():
	# Game end
	pass
