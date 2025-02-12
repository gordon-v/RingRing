extends Node3D
class_name VerticalLinesContainer

func update_position(ring_pos: Vector3) -> void:
	var newPos = Vector3(0,0,ring_pos.z)
	set("position",newPos)
