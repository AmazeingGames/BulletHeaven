extends Resource
class_name WeaponData

@export var stats: WeaponStats
@export var upgrade_amount: WeaponStats
@export var projectile_data: ProjectileBase

@export_category("Behavior Stats")
var rotation_amount: int # Amount in degrees to rotate the projectile's parent after each fire
var needs_target_to_fire: bool 

func upgrade():
	stats.improve_stats(upgrade_amount)
	pass
	
