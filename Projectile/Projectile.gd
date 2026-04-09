extends Node2D
class_name Projectile
# Main projectile_behavior controller.
# Responsible for:
#   - Movement behavior
#   - Lifetime handling
#   - Animation states
#   - Target interaction

#region Enumerators
enum AnimationState {START,TRAVEL,END}
	# Controls animation flow:
	#   START: Spawn animation
	#   TRAVEL: Active movement
	#   END: Final animation before deletion
#endregion

@export_category("Projectile resource")
var projectile_behavior: ProjectileBase # Data resource that defines projectile_behavior behavior.

@export_category("Projectile Values")
## Movement direction (in degres) for standard projectiles.
@export var direction : float = 45

## Target global_position (used for lob).
var target_position : Vector2

## Target global_position (used for homing).
var target : Node2D

@export_category("Exported References")
@export var sprite : AnimatedSprite2D
@export var lifetime_timer : Timer
@export var hitbox : CollisionShape2D

#region Internal Variables
var current_state := AnimationState.START # Current animation state.
var target_group: String # Group this projectile_behavior can interact with.
var starting_position : Vector2 # Initial spawn global_position (used in lob calculations).
var reference_scale : Vector2 # Projectile size set in projectile data. Used to calculate scale
var weapon_stats : WeaponStats # Stats that upgrade over time, like damage, range, size, or speed

## Stores targets hit.
## Key: Area2D.
## Value: Parent node (actual entity).
var targets = {}

const delete_time = 60 # Default lifetime if not using timed behavior.

func init(_behavior: ProjectileBase, _origin: Node2D, _target_group: String, 
		closest_target: Node2D, stats: WeaponStats) -> void:
	projectile_behavior = _behavior
	
	direction = _origin.rotation
	global_position = _origin.global_position
	target_group = _target_group
	weapon_stats = stats
	
	starting_position = global_position
	sprite.sprite_frames = projectile_behavior.sprite_frame
	
	match projectile_behavior.movement_type:
		projectile_behavior.MovementType.LOB:
			assert(closest_target != null, "Closest target should not be null when the projectile is initialized.")
			var dir = (closest_target.global_position - _origin.global_position).normalized()
			target_position = _origin.global_position + dir * weapon_stats.lob_distance
			
			# We don't set scale for lob since it's determined by a calculation
			reference_scale = stats.reference_scale

			# Only damage enemies on explosion
			hitbox.disabled = true

		projectile_behavior.MovementType.HOMING:
			assert(closest_target != null, "Closest target should not be null when the projectile is initialized.")
			target = closest_target
			scale = weapon_stats.effect_scale 
		_:
			scale = weapon_stats.effect_scale 
		pass

	# Assigns timer value with special case for timed projectiles.
	if projectile_behavior.lifetime_type == projectile_behavior.Lifetime.TIMED:
		var lifetime = randf_range(projectile_behavior.lifetime_range.x, projectile_behavior.lifetime_range.y)
		lifetime_timer.start(lifetime)
	else:
		lifetime_timer.start(delete_time)
		lifetime_timer.timeout.connect(_on_death)
	pass

#region Travel Behavior
# Runs every physics frame.
func _physics_process(delta: float) -> void:
	animation_state_machine() # Update animation first.
	
	if current_state != AnimationState.TRAVEL: return
	
	if projectile_behavior.movement_type == projectile_behavior.MovementType.STANDARD:
		update_standard(delta)
	elif projectile_behavior.movement_type == projectile_behavior.MovementType.HOMING:
		update_homing(delta)
	elif projectile_behavior.movement_type == projectile_behavior.MovementType.LOB:
		update_lob(delta)
	pass

## Straight movement in a fixed direction.
func update_standard (delta: float): 
	var projectile_speed = weapon_stats.projectile_speed * delta
	
	rotation = direction
	
	global_position.x = global_position.x + projectile_speed * cos(direction)
	global_position.y = global_position.y + projectile_speed * sin(direction)
	pass

## Moves toward a target
func update_homing (delta: float):
	var projectile_speed = weapon_stats.projectile_speed * delta
	
	if target == null or not is_instance_valid(target):
		return	
	
	look_at(target.global_position) # Rotate toward target.
	
	global_position.x = global_position.x + projectile_speed * cos(rotation)
	global_position.y = global_position.y + projectile_speed * sin(rotation)
	pass

## Arcing motion toward a target global_position.
func update_lob (delta: float):
	var projectile_speed = weapon_stats.projectile_speed * delta
	
	var angle = global_position.angle_to_point(target_position)
	
	var numerator = target_position.x - global_position.x
	var denominator = target_position.x - starting_position.x
	
	var scale_factor = numerator / denominator
	# Used to fake arc height using scale.
	
	scale.x = sin(PI * scale_factor) * reference_scale.x + 1
	scale.y = sin(PI * scale_factor) * reference_scale.y + 1
	
	#rotate(10*delta)
	
	global_position.x = global_position.x + projectile_speed * cos(angle)
	global_position.y = global_position.y + projectile_speed * sin(angle)
	pass
#endregion


#region Goal Check
func _process(_delta: float) -> void:
	if current_state != AnimationState.TRAVEL: return
	
	if projectile_behavior.lifetime_type == projectile_behavior.Lifetime.TIMED:
		check_timed()
		
	elif projectile_behavior.lifetime_type == projectile_behavior.Lifetime.COLLISION:
		check_collision()
		
	elif projectile_behavior.lifetime_type == projectile_behavior.Lifetime.TARGET:
		check_target()
	pass

## Ends when timer runs out.
func check_timed():
	if lifetime_timer.time_left > 0: return
	
	current_state = AnimationState.END
	apply_effect()

## Ends after hitting enough targets.
func check_collision():
	if targets.size() < weapon_stats.max_collisions: return
	
	current_state = AnimationState.END

## Ends when reaching target global_position.
func check_target():
	if abs(global_position.x - target_position.x) > 5: return
	
	current_state = AnimationState.END
	apply_effect()
#endregion

#region Effects
func apply_effect():
	if projectile_behavior.damage_type == projectile_behavior.DamageType.DIRECT:
		pass

	elif projectile_behavior.effect_type == projectile_behavior.EffectType.HEALTH:
		for n in targets:
			# print(targets[n].name, " took ", weapon_stats.effect_value)
			pass

	elif projectile_behavior.damage_type == projectile_behavior.DamageType.AOE:
		# print("area of effect summoned at ", round(global_position))
		pass
	pass
#endregion

#region Animation State Machine
func animation_state_machine():
	match current_state:
		AnimationState.START:
			if sprite.animation != "Start":
				sprite.play("Start")
			else:
				current_state = AnimationState.TRAVEL
		
		AnimationState.TRAVEL:
			if sprite.animation != "Travel":
				sprite.play("Travel")
		
		AnimationState.END:
			if sprite.animation != "End":
				sprite.play("End")
				if (projectile_behavior.movement_type == ProjectileBase.MovementType.LOB):
					explode()
			# explode
			elif !sprite.is_playing():
				_on_death()
	pass
#endregion

#region Signal Connected Functions
func _on_death():
	self.queue_free()

func explode() -> void:
	print_debug("create explosion")
	hitbox.disabled = false
	var explosionScale = weapon_stats.effect_scale
	scale = explosionScale
	pass

func _on_area_entered(area: Area2D) -> void:
	var should_apply_effects = area.is_in_group(target_group) and !targets.has(area)	
	if !should_apply_effects:
		return

	targets[area] = area.get_parent()
	
	if projectile_behavior.effect_type == projectile_behavior.EffectType.HEALTH:
		if (area.has_method("take_damage")):
			area.take_damage(weapon_stats.effect_value)
			# print(targets[area].name, " takes ", projectile_behavior.affect_value)

	elif projectile_behavior.effect_type == projectile_behavior.EffectType.SPEED:
		print(targets[area].name, " slows by ", projectile_behavior.affect_value)
#endregion
