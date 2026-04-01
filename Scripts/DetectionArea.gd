extends Area2D
class_name DetectionArea
@export var collision_shape: CollisionShape2D
@export var node: Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# find_closest_target(50, "Player")
	pass

func find_closest_target_at(origin:Vector2, radius:float, group:String) -> Node2D:
	var space_state = get_world_2d().direct_space_state
	
	var shape = CircleShape2D.new()
	shape.radius = radius
	
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = Transform2D(0, origin)
	query.collide_with_bodies = true
	query.collide_with_areas = true
	
	var results = space_state.intersect_shape(query, 512)
	
	var closest_distance = INF
	var closest_target: Node2D = null
	
	var validResults = 0
	for result in results:
		var body = result.collider
		if body.is_in_group(group) and is_instance_valid(body):
			validResults += 1
			# global_position might be more concise
			var square_distance = transform.get_origin().distance_squared_to(body.global_position)
			if square_distance < closest_distance:
				closest_distance = square_distance
				closest_target = result.collider
	
	print_debug(validResults)
	return closest_target

func find_closest_target(radius: int, group:String) -> Node2D:
	return find_closest_target_at(transform.get_origin(), radius, group)
