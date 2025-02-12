extends Node3D
class_name Coin

# Called when the node enters the scene tree for the first time.
var ring: Ring
var anim_player : AnimationPlayer
signal coin_collected
var flag = true
func _ready() -> void:
	anim_player = (get_node("AnimationPlayer") as AnimationPlayer)
	ring = get_tree().get_first_node_in_group("Ring")
	anim_player.animation_finished.connect(func(_string:String):queue_free())

func _process(_delta: float) -> void:
	if(ring.global_position.z<=global_position.z):
		set("global_position",Vector3(ring.global_position.x,global_position.y,ring.global_position.z))
		collect()
func collect() -> void:
	if flag:
		GlobalVariables.AudioManagerInstance.play_coin_collect()
		coin_collected.emit()
		flag = false
	anim_player.play("collect")
	
	
	
