extends Area2D
class_name Experience
# Drops from enemies on death
# Notifies the player and disappears on collision 

@export var experience_amount : int

var experience_tracker : ExperienceTracker

signal collect_experience (_experience_amount)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		print_debug("Collided with player")
		experience_tracker.gain_experience(experience_amount)
		queue_free()
		pass
	pass

func init(_experience_tracker) -> void:
	experience_tracker = _experience_tracker
	pass
