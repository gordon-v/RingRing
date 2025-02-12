extends Node3D
class_name BackgroundRing

@export var rotation_speed: float = 0.005

var ring_container: Node3D
func _ready() -> void:
	ring_container = get_node("Container")

func update_position(ring_pos: Vector3) -> void:
	var newPos = Vector3(0,position.y,ring_pos.z-61.992)
	set("position",newPos)
	var rotation_y = fmod(ring_container.rotation.y + 0.01,6.28318)
	var rotation_val = Vector3(0,rotation_y,0)
	ring_container.set("rotation",rotation_val)
	
func increase_rotation_speed() -> void:
	if(rotation_speed<= 0.5):
		rotation_speed += 0.01
		
func reset_rotation() -> void:
	var tw = create_tween().set_trans(Tween.TRANS_SPRING)
	tw.tween_property(ring_container,"rotation",Vector3.ZERO,1.5)
	await tw.finished
