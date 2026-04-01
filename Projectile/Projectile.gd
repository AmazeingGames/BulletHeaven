extends Node2D
class_name Projectile
# Main projectile_data controller.
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
@export var projectile_data: ProjectileBase # Data resource that defines projectile_data behavior.

@export_category("Projectile Values")
## Movement direction (in degres) for standard projectiles.
@export var direction : float = 45

## Target global_position (used for lob).
@export var target_position : Vector2

## Target global_position (used for homing).
@export var target : Node2D

@export_category("Exported References")
@export var sprite : AnimatedSprite2D
@export var lifetime_timer : Timer


var detection_area : DetectionArea

#region Internal Variables
var current_state := AnimationState.START # Current animation state.
var target_group: String # Group this projectile_data can interact with.
var starting_position : Vector2 # Initial spawn global_position (used in lob calculations).
var reference_scale : Vector2 # Projectile size set in projectile data. Used to calculate scale

var targets = {}
	# Stores targets hit:
	#   Key: Area2D
	#   Value: Parent node (actual entity)

const delete_time = 60 # Default lifetime if not using timed behavior.

func init(_projectile_base: ProjectileBase, _origin: Node2D, _target_group: String, 
		closest_target: Node2D) -> void:
	projectile_data = _projectile_base
	
	reference_scale = projectile_data.scale
	direction = _origin.rotation
	global_position = _origin.global_position
	target_group = _target_group
	
	match projectile_data.movement_type:
		projectile_data.MovementType.LOB:
			assert(closest_target != null, "Closest target should not be null when the projectile is initialized. 
				Ensure `RequiresTarget` is set to true on WeaponData resource.")
			var dir = (closest_target.global_position - _origin.global_position).normalized()
			target_position = _origin.global_position + dir * 800
		projectile_data.MovementType.HOMING:
			assert(closest_target != null, "Closest target should not be null when the projectile is initialized. 
				Ensure `RequiresTarget` is set to true on WeaponData resource.")
		_:
			# We don't set scale in lob since that's determined by a calculation
			scale = projectile_data.scale 
		pass
	
	starting_position = global_position
	sprite.sprite_frames = projectile_data.sprite_frame

	## Assigns timer value with special case for timed projectiles.
	if projectile_data.lifetime_type == projectile_data.Lifetime.TIMED:
		var lifetime = randf_range(projectile_data.lifetime_range.x, projectile_data.lifetime_range.y)
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
	
	if projectile_data.movement_type == projectile_data.MovementType.STANDARD:
		update_standard(delta)
	elif projectile_data.movement_type == projectile_data.MovementType.HOMING:
		update_homing(delta)
	elif projectile_data.movement_type == projectile_data.MovementType.LOB:
		update_lob(delta)
	pass

## Straight movement in a fixed direction.
func update_standard (delta: float): 
	var projectile_speed = projectile_data.projectile_speed * delta
	
	rotation = direction
	
	global_position.x = global_position.x + projectile_speed * cos(direction)
	global_position.y = global_position.y + projectile_speed * sin(direction)
	pass

## Moves toward a target
func update_homing (delta: float):
	var projectile_speed = projectile_data.projectile_speed * delta
	
	if target == null or not is_instance_valid(target):
		target = detection_area.find_closest_target_at(global_position, 10000, target_group)
	
	if target == null or not is_instance_valid(target):
		return			
	
	look_at(target.global_position) # Rotate toward target.
	
	global_position.x = global_position.x + projectile_speed * cos(rotation)
	global_position.y = global_position.y + projectile_speed * sin(rotation)
	pass

## Arcing motion toward a target global_position.
func update_lob (delta: float):
	var projectile_speed = projectile_data.projectile_speed * delta
	
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
	
	if projectile_data.lifetime_type == projectile_data.Lifetime.TIMED:
		check_timed()
	elif projectile_data.lifetime_type == projectile_data.Lifetime.COLLISION:
		check_collision()
	elif projectile_data.lifetime_type == projectile_data.Lifetime.HOMING:
		check_target()
	pass

## Ends when timer runs out.
func check_timed():
	if lifetime_timer.time_left > 0: return
	
	current_state = AnimationState.END
	apply_effect()

## Ends after hitting enough targets.
func check_collision():
	if targets.size() < projectile_data.max_collisions: return
	
	current_state = AnimationState.END

## Ends when reaching target global_position.
func check_target():
	if abs(global_position.x - target_position.x) > 5: return
	
	current_state = AnimationState.END
	apply_effect()
#endregion

#region Effects
func apply_effect():
	if projectile_data.damage_type == projectile_data.DamageType.DIRECT:
		pass
	elif projectile_data.effect_type == projectile_data.EffectType.HEALTH:
		for n in targets:
			print(targets[n].name, " takes ", projectile_data.affect_value)
	elif projectile_data.damage_type == projectile_data.DamageType.AOE:
		print("area of effect summoned at ", round(global_position))
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
			elif !sprite.is_playing():
				_on_death()
	pass
#endregion

#region Signal Connected Functions
func _on_death():
	self.queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group(target_group) and !targets.has(area):
		targets[area] = area.get_parent()
		
		if projectile_data.damage_type == projectile_data.DamageType.DIRECT:
			if projectile_data.effect_type == projectile_data.EffectType.HEALTH:
				print(targets[area].name, " takes ", projectile_data.affect_value)
			elif projectile_data.effect_type == projectile_data.EffectType.SPEED:
				print(targets[area].name, " slows by ", projectile_data.affect_value)
		
		if projectile_data.movement_type == projectile_data.MovementType.HOMING:
			if target == targets[area]:
				current_state = AnimationState.END
				apply_effect()
	
#endregion
