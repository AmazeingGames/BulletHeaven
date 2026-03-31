extends Node2D
class_name Enemy

#Simple follow enemy, holds a player reference that it uses to target.

#region Enumerators
enum EnemyState {IDLE, FOLLOW, HURT, ATTACK}
	# Controls animation flow:
	#   Idle: Stationary movement.
	#   Follow: Active movement towards player.
	#   Hurt: Taking damage.
	#   Attack: Simple attack animation if any.
#endregion

@export_category("Exported References")
@export var health : HealthComponent
@export var stats : StatComponent
@export var sprite : AnimatedSprite2D
@export var hurtbox : HurtBox
@export var push_zone : Area2D

@export_category("Enemy Properties")
@export var max_stun : int
@export var current_stun : int
@export var far_distance : float

@export var target : Player
var current_state : EnemyState
var personal_space : Dictionary[String,Enemy]


var smooth_direction = Vector2 (0.0,0.0)


func _ready() -> void:
	current_state = EnemyState.FOLLOW
	pass

func _process(delta: float) -> void:
	if !target: return
	match current_state:
		EnemyState.IDLE:
			update_idle()
		EnemyState.FOLLOW:
			update_follow(delta)
		EnemyState.HURT:
			pass
		EnemyState.ATTACK:
			pass
	
	if current_stun > 0:
		current_stun = current_stun - 1
	pass

func update_idle():
	## call animation code here
	if current_stun > 0: return

func update_follow(delta):
	var direction = (position - target.position).normalized()
	var speed = stats.get_speed() * delta

	var adjustor = Vector2 (0.0, 0.0)

	for enemy in personal_space:
		var e = personal_space[enemy]
		adjustor = adjustor + (position - e.position).normalized()

	if personal_space.size() > 0:
		adjustor = adjustor/personal_space.size()

	adjustor = adjustor.normalized() / 2.0

	var difference = position - target.position

	if abs(difference.x) < far_distance:
		direction.x = 0
	elif abs(difference.x) > 5 * far_distance:
		direction.x -= adjustor.x

	if abs(difference.y) < far_distance:
		direction.y = 0
	elif abs(difference.y) > 5 * far_distance:
		direction.y -= adjustor.y
	
	smooth_direction = lerp(smooth_direction,direction,delta)
	
	position -= smooth_direction * Vector2(speed, speed)

func _on_damage_taken(value: int):
	health.damage(value)

func _on_speed_debuff(value: int, duration: float):
	stats.add_speed_debuff(value,duration)
	pass


func _on_push_zone_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("Enemy") and self != area.get_parent():
		var enemy = area.get_parent()
		personal_space[enemy.name] = enemy
	pass

func _on_push_zone_area_exited(area: Area2D) -> void:
	if area.get_parent().is_in_group("Enemy"):
		var enemy = area.get_parent()
		personal_space.erase(enemy.name)
	pass
