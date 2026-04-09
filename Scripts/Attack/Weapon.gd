extends Node

@export var projectile_ref: PackedScene
# @export var test_detection_area: DetectionArea # Temporary testing export. Ideally this is passed in on Init
# @export var projectile_holder: Node2D

var weapon_data : WeaponData
var player_detection_area: DetectionArea 
var closest_enemy: Node2D
var has_been_initialized: bool
var rotation_amount: int

var time_till_fire: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# player_detection_area = test_detection_area
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (!has_been_initialized):
		return
	
	time_till_fire -= delta
	closest_enemy = player_detection_area.find_closest_target(weapon_data.stats.detection_range, "Enemy")
	
	# Don't shoot if we don't have a target
	match weapon_data.behavior.movement_type:
		ProjectileBase.MovementType.HOMING, ProjectileBase.MovementType.LOB:
			if (closest_enemy == null or not is_instance_valid(closest_enemy)):
				return
			pass

	if (time_till_fire <= 0):
		fire(closest_enemy)
	pass

# Weapon must be initialized after creation
func init(_player_detection_area : DetectionArea, _weapon_data: WeaponData) -> void:
	# print_debug("initialized!")
	player_detection_area = _player_detection_area
	weapon_data = _weapon_data
	time_till_fire = weapon_data.stats.seconds_between_attacks
	
	has_been_initialized = true
	pass

func level_up() -> void:
	weapon_data.upgrade()
	pass

func fire(closest_enemy : Node2D) -> void:
	# dsdprint_debug("fire")
	time_till_fire = weapon_data.stats.seconds_between_attacks
	
	for n in weapon_data.stats.projectiles_per_attack:
		var projectile : Projectile
		projectile = projectile_ref.instantiate()
		add_child(projectile)
		projectile.init(weapon_data.behavior, player_detection_area, "Enemy", closest_enemy, weapon_data.stats, rotation_amount)
		rotation_amount += weapon_data.behavior.rotation_amount
		# self.rotation += weapon_data.behavior.rotation_amount
		pass
	pass
