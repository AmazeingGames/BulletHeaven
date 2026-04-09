class_name UIManager
extends Node

@export var health_bar : ProgressBar
@export var upgrade_menu : UpgradeMenu

var weapons_data : Array[WeaponData]

func _ready() -> void:
	upgrade_menu.visible = false
	pass

func init(health_component : HealthComponent, _weapons_data : Array[WeaponData], experience_tracker : ExperienceTracker) -> void:
	health_bar.min_value = 0
	health_bar.max_value = health_component.max_health
	health_bar.value = health_component.current_health
	
	health_component.health_changed.connect(_on_player_health_changed)
	
	weapons_data = _weapons_data
	experience_tracker.level_up.connect(display_upgrade_menu)
	pass

func _process(delta: float) -> void:
	if (Input.is_physical_key_pressed(KEY_O)):
		display_upgrade_menu()
		pass
	pass

func _on_player_health_changed(old_value, new_value, max_value):
	health_bar.value = new_value
	pass

func get_weapon_selections() -> Array[WeaponSelection]:
	return upgrade_menu.weapon_selections
	pass

func display_upgrade_menu() -> void:
	print_debug("Display upgrade menu")
	upgrade_menu.display_selections(weapons_data)
	pass
