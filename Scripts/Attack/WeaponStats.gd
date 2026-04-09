extends Resource
class_name WeaponStats
# Stats are put in separate resource to avoid clutter when setting upgrade data properties
	# but it's not necessaray

# When adding new stats, make sure to improve them when leveling up
@export_category("Universal Stats")
@export var scale : Vector2
@export var effect_value: float
@export var seconds_between_attacks: float
@export var projectiles_per_attack: int
## How fast a projectile travels in pixels per second.
@export var projectile_speed: float 
# @export var homing_range: int

@export_category("Behavior Dependent")
## The range an enemy needs to be in to fire a projectile.
## Does not apply to standard projectiles.
@export var detection_range: int
## The distance (from the player) a lob projectile will land when firing towards an enemy. 
## Only applies to lob projectiles.
@export var lob_distance: int
@export var lifetime_range: Vector2
@export var max_collisions: int

# Used to upgrade weapon properties
func improve_stats(improvement_stats : WeaponStats) -> void:	
	scale += improvement_stats.scale
	effect_value += improvement_stats.effect_value
	seconds_between_attacks -= improvement_stats.seconds_between_attacks
	seconds_between_attacks = clamp (seconds_between_attacks, .1, INF)
	projectiles_per_attack += improvement_stats.projectiles_per_attack
	projectile_speed += improvement_stats.projectile_speed
	lifetime_range += improvement_stats.lifetime_range
	max_collisions += improvement_stats.max_collisions
	detection_range += improvement_stats.detection_range
	pass
