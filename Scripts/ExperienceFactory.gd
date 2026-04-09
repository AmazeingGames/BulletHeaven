extends Node
class_name ExperienceFactory

@export var experience_scene: PackedScene
var experience_tracker : ExperienceTracker

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func init(_experience_tracker) -> void:
	experience_tracker = _experience_tracker
	pass

func create_experience(position : Vector2) -> Experience:
	var experience : Experience
	experience = experience_scene.instantiate()
	experience.init(experience_tracker)
	add_child(experience)
	experience.global_position = position
	return experience
