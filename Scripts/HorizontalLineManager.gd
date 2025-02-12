extends Node

class_name HorizontalLineManager

@export var line_segment: PackedScene
@export var lines_at_a_time: int
var rand = RandomNumberGenerator.new()
var last_segment: Node3D
var last_endpoint: Vector3 = Vector3.ZERO
var line_segment_counter: int = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_create_segment(Vector3.ZERO,_generate_point())
	
func _process(_delta: float) -> void:
	last_endpoint = last_segment.position
	while (get_node("HorizontalLines").get_child_count()<lines_at_a_time):
		_create_segment(last_endpoint,_generate_point())
		
func _create_segment(_origin: Vector3, endpoint: Vector3) -> void:
	var segment = line_segment.instantiate() as Node3D
	segment.position = endpoint
	get_node("HorizontalLines").add_child(segment)

	line_segment_counter += 1
	last_endpoint = endpoint
	last_segment = segment

func _generate_point() -> Vector3:
	var point = Vector3(0, 0, last_endpoint.z-4)
	return point
