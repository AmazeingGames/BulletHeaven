extends Resource
class_name WeaponData

@export var stats: WeaponStats
@export var upgrade_amount: WeaponStats
@export var behavior: ProjectileBase

@export_category("Behavior Stats")
var rotation_amount: int # Amount in degrees to rotate the projectile's parent after each fire

func upgrade():
	stats.improve_stats(upgrade_amount)
	pass
	
