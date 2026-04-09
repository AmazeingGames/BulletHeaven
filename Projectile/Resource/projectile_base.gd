extends Resource
class_name ProjectileBase
# Resource intended to hold all data components of the projectile node. 
# Does not have any methods, i.e. requires implementation.

#region Enumerators
enum MovementType {STANDARD,HOMING,LOB} 
	# Types of movement behavior for arrow:
	#   Standard: typical arrow-like behavior, straight path of travel.
	#   Homing: projectile curves and follows a chosen target/targets.
	#   Lob: projectile travels above scene and lands onto a target position.

enum DamageType {DIRECT, AOE}
	# Types of movement behavior for arrow:
	#   Direct: applies damage effect on initial collision of target.
	#   AOE: applies damage effect within a specified area.

enum EffectType {HEALTH,SPEED}
	# Types of damage effects:
	#   Health: affects the units health stat.
	#   SpeedDebuff: affects the units speed stat.

enum Lifetime { TIMED, COLLISION, TARGET }
	# Projectile life behvaior types:
	#   Timed: Projectile is destroyed after a certain amount of time.
	#   Collision: Projectile is destoryed after a certain amount of collisions.
	#   Target: Projectile is destroyed after target position is reached.
#endregion

#region Exported Variables
@export_category("Projectile Behaviors")
@export var movement_type: MovementType
@export var damage_type: DamageType
@export var effect_type: EffectType
@export var lifetime_type : Lifetime
## The amount to rotate the projectile spawner after each fire.
@export var rotation_amount: int

@export_category("Exported References")
@export var sprite_frame: SpriteFrames
@export var ui_icon: Texture2D
	# Projectiles sprite_frames require the following animations (can be static):
	#   Start: Plays as projectile spawns, before movement.
	#   Travel: Plays as projectile is moving.
	#   End: Plays at end of projectile life.
#endregion
