extends Node3D
class_name NearMissLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

	
func show_label() -> void:
	var tw = create_tween().set_parallel(true)
	tw.tween_callback(func():visible = true)
	tw.tween_property($Sprite3D,"modulate",Color.WHITE,0.2)
	tw.tween_property($Sprite3D/NearMissLabel,"modulate",Color.WHITE,0.2)
	tw.tween_property($Sprite3D/NearMissLabel,"outline_modulate", Color.BLACK,0.2)
	tw.set_parallel(false)
	tw.tween_interval(1)
	tw.set_parallel(true)
	tw.tween_property(self,"global_position",Vector3(global_position.x,global_position.y+0.2,global_position.z),0.3)
	tw.tween_property($Sprite3D,"modulate",Color.TRANSPARENT,0.3)
	tw.tween_property($Sprite3D/NearMissLabel,"modulate",Color.TRANSPARENT,0.3)
	tw.tween_property($Sprite3D/NearMissLabel,"outline_modulate", Color.TRANSPARENT,0.3)

func set_text(_str: String) -> void:
	$Sprite3D/NearMissLabel.text = _str
