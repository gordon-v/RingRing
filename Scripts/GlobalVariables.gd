extends Node

var AudioManagerInstance: AudioManager
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioManagerInstance = get_tree().get_first_node_in_group("AudioManager")
