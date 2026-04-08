extends Node

@export var weapon_data : WeaponData
@export var projectile_ref: PackedScene
@export var test_detection_area: DetectionArea # Temporary testing export. Ideally this is passed in on Init
@export var projectile_holder: Node2D

var player_detection_area: DetectionArea 
var closest_enemy: Node2D

var time_till_fire: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_detection_area = test_detection_area
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_till_fire -= delta
	closest_enemy = player_detection_area.find_closest_target(weapon_data.stats.range, "Enemy")
	
	# Don't shoot if we don't have a target
	if (weapon_data.behavior.movement_type == ProjectileBase.MovementType.HOMING
			&& (closest_enemy == null or not is_instance_valid(closest_enemy))):
		return
	
	if (time_till_fire <= 0):
		fire(closest_enemy)
	pass

# Weapon must be initialized after creation
func init(_player_detection_area : DetectionArea) -> void:
	player_detection_area = _player_detection_area
	time_till_fire = weapon_data.stats.seconds_between_attacks
	pass

func level_up() -> void:
	weapon_data.upgrade()
	pass

func fire(closest_enemy : Node2D) -> void:
	time_till_fire = weapon_data.stats.seconds_between_attacks
	
	for n in weapon_data.stats.projectiles_per_attack:
		var projectile = projectile_ref.instantiate()
		projectile_holder.add_child(projectile)
		projectile.init(weapon_data.behavior, self, "Enemy", closest_enemy, weapon_data.stats)
		self.rotation += weapon_data.behavior.rotation_amount
		pass
	pass
