extends Node
class_name StatComponent

enum Stats {SPEED}

@export_category("Unit Non-Health Stats")
@export var base_speed : int
@export var max_stun_time : int

var time_elapsed : float
var wait_time := 1.0

## In pixels per second
var current_speed : int
var debuff : Dictionary[int,Vector3] # Dictionary over array for easy deletion

func _process(delta):
	time_elapsed += delta
	if time_elapsed >= wait_time:
		update_debuffs()
		time_elapsed = 0

func add_speed_debuff(value: int, duration: int):
	debuff[debuff.size()] = (Vector3 (Stats.SPEED,duration,value))

func update_debuffs():
	for key in debuff:
		if debuff[key].y  > 0:
			debuff[key].y = debuff[key].y - 1
		else:
			debuff.erase(key)

func get_speed():
	var speed = base_speed
	
	for key in debuff:
		if debuff[key].x == Stats.SPEED:
			speed = speed - debuff[key].z
	
	return speed
