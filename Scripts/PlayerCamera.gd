extends Camera3D
class_name PlayerCamera

@export var period = 0.1
@export var magnitude = 0.02
var moving: bool = false
var speed: float = 0.1
func _process(_delta: float) -> void:
	if moving:
		global_position.z -= speed * _delta * 2.5
 
func set_moving(_moving: bool):
	moving = _moving

func set_speed(_speed: float) -> void:
	speed = _speed

func super_shake():
	magnitude = 1
	period = 0.5
	_camera_shake()

func shake():
	period = 0.1
	magnitude = 0.02
	_camera_shake()

func reset_position(pos_z: float):
	var pos = Vector3(global_position.x,global_position.y,pos_z+3.839)
	set_moving(false)
	var tw = create_tween().set_trans(Tween.TRANS_EXPO)
	tw.tween_property(self,"global_position",pos,0.35)
func _camera_shake():
	var initial_transform = self.transform 
	var elapsed_time = 0.0

	while elapsed_time < period:
		var offset = Vector3(
			randf_range(-magnitude, magnitude),
			randf_range(-magnitude, magnitude),
			0.0
		)

		self.transform.origin = initial_transform.origin + offset
		elapsed_time += get_process_delta_time()
		await get_tree().process_frame

	self.transform = initial_transform
