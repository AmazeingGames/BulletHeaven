extends Node2D
class_name Projectile
# Main projectile controller.
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
@export var projectile: ProjectileBase # Data resource that defines projectile behavior.

@export_category("Projectile Values")
## Movement direction (in degres) for standard projectiles.
@export var direction : float = 45

## Target position (used for lob).
@export var target_position : Vector2

## Target position (used for homing).
@export var target : Node2D

@export_category("Exported References")
@export var sprite : AnimatedSprite2D
@export var lifetime_timer : Timer

#region Internal Variables
var current_state := AnimationState.START # Current animation state.
var target_group: String # Group this projectile can interact with.
var starting_position : Vector2 # Initial spawn position (used in lob calculations).

var targets = {}
	# Stores targets hit:
	#   Key: Area2D
	#   Value: Parent node (actual entity)

const delete_time = 60 # Default lifetime if not using timed behavior.

func _ready() -> void:
	starting_position = position
	sprite.sprite_frames = projectile.sprite_frame

	## Assigns timer value with special case for timed projectiles.
	if projectile.lifetime_type == projectile.Lifetime.TIMED:
		lifetime_timer.start(projectile.lifetime)
	else:
		lifetime_timer.start(delete_time)
		lifetime_timer.timeout.connect(_on_death)
	pass

#region Travel Behavior
# Runs every physics frame.
func _physics_process(delta: float) -> void:
	animation_state_machine() # Update animation first.
	
	if current_state != AnimationState.TRAVEL: return
	
	if projectile.movement_type == projectile.MovementType.STANDARD:
		update_standard(delta)
	elif projectile.movement_type == projectile.MovementType.HOMING:
		update_homing(delta)
	elif projectile.movement_type == projectile.MovementType.LOB:
		update_lob(delta)
	pass

## Straight movement in a fixed direction.
func update_standard (delta: float): 
	var projectile_speed = projectile.projectile_speed * delta
	
	rotation = direction
	
	position.x = position.x + projectile_speed * cos(direction)
	position.y = position.y + projectile_speed * sin(direction)
	pass

## Moves toward a target (mouse position).
func update_homing (delta: float):
	var projectile_speed = projectile.projectile_speed * delta
	
	look_at(target.position) # Rotate toward target.
	
	position.x = position.x + projectile_speed * cos(rotation)
	position.y = position.y + projectile_speed * sin(rotation)
	pass

## Arcing motion toward a target position.
func update_lob (delta: float):
	var projectile_speed = projectile.projectile_speed * delta
	
	var angle = position.angle_to_point(target_position)
	
	var numerator = target_position.x - position.x
	var denominator = target_position.x - starting_position.x
	
	var scale_factor = numerator / denominator
	# Used to fake arc height using scale.
	
	scale.x = sin(PI * scale_factor)*2 + 1
	scale.y = sin(PI * scale_factor)*2 + 1
	
	#rotate(10*delta)
	
	position.x = position.x + projectile_speed * cos(angle)
	position.y = position.y + projectile_speed * sin(angle)
	pass
#endregion


#region Goal Check
func _process(_delta: float) -> void:
	if current_state != AnimationState.TRAVEL: return
	
	if projectile.lifetime_type == projectile.Lifetime.TIMED:
		check_timed()
	elif projectile.lifetime_type == projectile.Lifetime.COLLISION:
		check_collision()
	elif projectile.lifetime_type == projectile.Lifetime.TARGET:
		check_target()
	pass

## Ends when timer runs out.
func check_timed():
	if lifetime_timer.time_left > 0: return
	
	current_state = AnimationState.END
	apply_effect()

## Ends after hitting enough targets.
func check_collision():
	if targets.size() < projectile.max_collisions: return
	
	current_state = AnimationState.END

## Ends when reaching target position.
func check_target():
	if abs(position.x - target_position.x) > 5: return
	
	current_state = AnimationState.END
	apply_effect()
#endregion

#region Effects
func apply_effect():
	if projectile.damage_type == projectile.DamageType.DIRECT:
		pass
	elif projectile.effect_type == projectile.EffectType.HEALTH:
		for n in targets:
			print(targets[n].name, " takes ", projectile.affect_value)
	elif projectile.damage_type == projectile.DamageType.AOE:
		print("area of effect summoned at ", round(position))
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
		
		if projectile.damage_type == projectile.DamageType.DIRECT:
			if projectile.effect_type == projectile.EffectType.HEALTH:
				print(targets[area].name, " takes ", projectile.affect_value)
			elif projectile.effect_type == projectile.EffectType.SPEED:
				print(targets[area].name, " slows by ", projectile.affect_value)
		
		if projectile.movement_type == projectile.MovementType.HOMING:
			if target == targets[area]:
				current_state = AnimationState.END
				apply_effect()
	
#endregion
