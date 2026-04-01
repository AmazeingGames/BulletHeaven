extends Resource
class_name WeaponStats
# Stats are put in separate resource to avoid clutter when setting upgrade data properties
	# but it's not necessaray

# When adding new stats, make sure to improve them when leveling up
@export_category("Upgrade Stats")
@export var scale : Vector2
@export var damage : int
@export var seconds_between_attacks: float
@export var projectiles_per_attack: int
@export var range: int

# Used to upgrade weapon properties
func improve_stats(improvement_stats : WeaponStats) -> void:	
	scale += improvement_stats.scale
	damage += improvement_stats.damage
	seconds_between_attacks -= improvement_stats.seconds_between_attacks
	seconds_between_attacks = clamp (seconds_between_attacks, .1, INF)
	projectiles_per_attack += improvement_stats.projectiles_per_attack
	range += improvement_stats.range
	pass
