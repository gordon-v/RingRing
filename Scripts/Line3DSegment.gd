extends Area3D

class_name Line3DSegment

@export var Origin: Marker3D
@export var Endpoint: Marker3D
var _Cylinder: MeshInstance3D

var _originPos: Vector3
var _endPointPos: Vector3

signal line_removed
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#_originPos = Origin.position
	#_endPointPos = Endpoint.position
	_Cylinder = get_node("MeshInstance3D")
	point_at_target()

# Creates a cylinder between origin and endpoint. Returns the endpoint for chaining
func create(origin: Vector3, endpoint: Vector3) -> Vector3:
	_originPos = origin
	_endPointPos = endpoint
	point_at_target()
	return _endPointPos

#Points and adjusts the size of the cylinder to reach from origin to endpoint
func point_at_target() -> void:
	_resize_mesh()
	if(Origin.position != _endPointPos):
		look_at(_endPointPos)

func _resize_mesh()-> void:
	var distance = _originPos.distance_to(_endPointPos)
	var newPosition = (_originPos+_endPointPos)/2
	_Cylinder.mesh.set("height",distance)
	$CollisionShape3D.shape.height = distance
	$CollisionShape3D.shape.radius = 0.05
	set("position", newPosition)

func cap_bottom() -> void: #this closes the cylinder, so that the line looks continuous when connecting to Line3D Segments
	_Cylinder.mesh.set("cap_bottom",true)

func get_endpoint() -> Vector3:
	return _endPointPos

func get_startpoint() -> Vector3:
	return _originPos

func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	queue_free() # Replace with function body.
	line_removed.emit()


func _on_body_entered(_body: Node) -> void:
	get_parent().get_parent().emit_signal("collided_with_player")
