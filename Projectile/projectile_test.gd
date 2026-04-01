extends Node2D

@onready var projectile_ref = preload("res://Projectile/Projectile.tscn")
@onready var bomb_resource = preload("res://Projectile/Sample Projectiles/Bomb.tres")
@onready var bullet_resource = preload("res://Projectile/Sample Projectiles/Bullet.tres")
@onready var slime_resource = preload("res://Projectile/Sample Projectiles/Slime.tres")

@export var bomb_lobber : Sprite2D
@export var bullet_summoner : Sprite2D
@export var slime_summoner : Sprite2D
@export var detection_area: DetectionArea

var spawn_angle : float
var bomb_spawn_position = Vector2 (200, 0)
var slime_spawn_position = Vector2 (1000, 700)
var bomb_goal_y : int
var slime_goal_y : int

var bomb_break : int
var slime_break : int

const target_y_1 = 50
const target_y_2 = 650

func _process(delta: float) -> void:
	spawn_angle += 1
	
	slime_spawn_position.y = move_toward(slime_spawn_position.y,slime_goal_y,200*delta)
	if slime_spawn_position.y >= target_y_2:
		slime_goal_y = target_y_1
	elif slime_spawn_position.y <= target_y_1:
		slime_goal_y = target_y_2
	
	# bomb_spawn_position.y = move_toward(bomb_spawn_position.y,bomb_goal_y,200*delta)
	if bomb_spawn_position.y >= target_y_2:
		bomb_goal_y = target_y_1
	elif bomb_spawn_position.y <= target_y_1:
		bomb_goal_y = target_y_2
	
	# bomb_lobber.position = bomb_spawn_position
	slime_summoner.position = slime_spawn_position

func _on_timer_timeout() -> void:
	var bullet = projectile_ref.instantiate()
	bullet_summoner.rotation = spawn_angle
	bullet.init(bullet_resource, bullet_summoner, "Enemy", detection_area)
	add_child(bullet)
	
	if bomb_break > 2:
		var lob = projectile_ref.instantiate()
		lob.init(bomb_resource, bomb_lobber, "Enemy", detection_area)
		
		add_child(lob)
		bomb_break = 0
	else:
		bomb_break += 1
	
	if slime_break > 3:
		var slime = projectile_ref.instantiate()
		slime.init(slime_resource, slime_summoner, "Enemy", detection_area)

		add_child(slime)
		slime_break = 0
	else:
		slime_break += 1
	
