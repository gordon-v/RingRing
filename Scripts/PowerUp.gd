extends Node3D
class_name PowerUp

# Called when the node enters the scene tree for the first time.
var ring: Ring
signal power_up_collected
var flag = true
func _ready() -> void:
	ring = get_tree().get_first_node_in_group("Ring")

func _process(_delta: float) -> void:
	if(ring.global_position.z<=global_position.z):
		collect()

func collect() -> void:
	if flag:
		GlobalVariables.AudioManagerInstance.play_powerup_collect()
		power_up_collected.emit()
		flag = false
		var mesh = (get_node("MeshInstance3D") as MeshInstance3D).mesh
		var tw = create_tween().set_parallel(true).set_trans(Tween.TRANS_EXPO)
		tw.tween_property(mesh,"inner_radius",3,0.8)
		tw.tween_property(mesh,"outer_radius",3.6,0.8)
	
	
