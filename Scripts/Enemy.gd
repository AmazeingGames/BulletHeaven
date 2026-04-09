extends Area2D
class_name Enemy

#Simple follow enemy, holds a player reference that it uses to target.

#region Enumerators
enum EnemyState {IDLE, FOLLOW, HURT, ATTACK, DEATH}
	# Controls animation flow:
	#   Idle: Stationary movement.
	#   Follow: Active movement towards player.
	#   Hurt: Taking damage.
	#   Attack: Simple attack animation if any.
	#   Death: Enemy died.
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


@export var animation_player: AnimationPlayer
@export var effect_player: AnimationPlayer
@export var gpu_particles_2d: GPUParticles2D

var current_state : EnemyState
var personal_space : Dictionary[String,Enemy]

@export var testing_experience_factory: ExperienceFactory
@export var test_target : Player

var target : Player
var experience_factory : ExperienceFactory

var smooth_direction = Vector2 (0.0,0.0)

func _ready() -> void:
	health.health_changed.connect(_on_health_changed)
	health.health_depleted.connect(_on_health_depleted)
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

## Requires a reference to the experience factory in order to spawn experience on death.
func init(_experience_factory : ExperienceFactory, _target : Player) -> void:
	experience_factory = _experience_factory
	target = _target
	pass

func update_idle():
	## call animation code here
	if current_stun > 0:
		self_modulate = Color (255,255,255)
		return
	
	if get_direction().length() > 0.1:
		current_state = EnemyState.FOLLOW
		animation_player.play("Walk")
		#set follow animations

func update_follow(delta):
	smooth_direction = lerp(smooth_direction, get_direction(), delta)
	var speed = stats.get_speed() * delta
	
	if smooth_direction.length() > 0.1:
		position -= smooth_direction * Vector2(speed, speed)
	else:
		current_state = EnemyState.IDLE
	pass

func update_hurt():
	## play animation
	#if animation.is_stopped():
	current_state = EnemyState.IDLE
	self_modulate = Color (255,200,200)
	pass

func _on_damage_taken(value: int):
	health.damage(value)
	current_state = EnemyState.HURT
	current_stun = max_stun

func _on_speed_debuff(value: int, duration: float):
	stats.add_speed_debuff(value,duration)
	pass

func get_direction():
	var difference = position - target.position
	var direction = difference.normalized()
	var adjustor = Vector2 (0.0, 0.0)

	for enemy in personal_space:
		adjustor = adjustor + (position - personal_space[enemy].position).normalized()

	if personal_space.size() > 0:
		adjustor = adjustor/personal_space.size()
	adjustor = adjustor.normalized() / 2.0

	if abs(difference.x) < far_distance:
		direction.x = 0
	elif abs(difference.x) > 5 * far_distance:
		direction.x -= adjustor.x

	if abs(difference.y) < far_distance:
		direction.y = 0
	elif abs(difference.y) > 5 * far_distance:
		direction.y -= adjustor.y
	
	return direction

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

func _on_health_changed(old_value, new_value, max_value):
	var did_take_damage = old_value > new_value
	var did_heal = new_value > old_value
	
	if (did_take_damage):
		# Plays SFX, creates particles, flashes white
		# print_debug("took damage")
		effect_player.play("TakeDamage")
		gpu_particles_2d.restart()
		pass
	else: if (did_heal):
		pass
	pass

func _on_health_depleted(unit : Node2D):
	animation_player.play("Die")
	current_state = EnemyState.DEATH
	pass

## Create experience. Called from the animation player.
func _on_death_animation_finish() -> void:
	experience_factory.create_experience(global_position)
	pass
#endregion

func _on_area_entered(area: Area2D) -> void:
	if !area.is_in_group("Player"):
		return
	# print_debug("damage player")
	
	if (area.has_method("take_damage")):
		area.take_damage(stats.damage)
	pass
