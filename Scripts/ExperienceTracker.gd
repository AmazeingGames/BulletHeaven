extends Node
class_name ExperienceTracker

# Knows current and max experience
# Tells level up screen when experience is full
# Increases the experience threshold after leveling up
# Resets current experience after level up

@export var level_up_threshhold : int
var current_experience : int

signal level_up

# Called when the node enters the scene tree for the first time.sa
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func gain_experience(experience_amount : int) -> void:
	current_experience += experience_amount
	print_debug("Gained experience")
	
	if (current_experience >= level_up_threshhold):
		print_debug("Emit level up")
		level_up.emit()
		current_experience -= level_up_threshhold
	pass
