extends Node
class_name MessageManager
# Called when the node enters the scene tree for the first time.

#gems can only be 1,2,3,4. Any other value will result in error
func push_message(gems:int, title: String, msg: String) -> void:
	if gems < 1 or gems > 4	:
		print_debug("Could not create message, invalid icon number")
	var pM = (ResourceLoader.load(
		"res://Scenes/PushMessage.tscn"
		) as PackedScene).instantiate() as PushMessage

	var icon_path = "res://Images/gem" + str(gems) + ".png"
	pM.create_push_message(icon_path,title,msg)
	var MC = get_tree().get_first_node_in_group("MessageContainer")
	if MC.get_child_count(true) > 0:
		return
	MC.add_child(pM)
