extends Area3D

var lines_intersecting: int = 0

var current_line_beginning: Vector3
signal exited_line
signal new_line(pos: Vector3)

func _on_area_entered(area: Area3D) -> void:
	current_line_beginning = (area as Line3DSegment).get_startpoint()
	new_line.emit(current_line_beginning)
	lines_intersecting+=1

func _on_area_exited(_area: Area3D) -> void:
	lines_intersecting-=1
	is_around_line()
	
func is_around_line() -> bool:
	if lines_intersecting > 0:
		return true
	exited_line.emit()
	return false
	
