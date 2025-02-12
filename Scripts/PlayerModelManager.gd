extends Node
class_name PlayerModelManager

@export
var models_path = "res://Models/Ring Models/"
@export
var model_container: Node3D

var player_stats: PlayerStats
var user_rings_dict: Dictionary
var selected_model: String = "Opal"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_stats = get_tree().get_first_node_in_group("PlayerStats") as PlayerStats
	refresh()
	_apply_model()

func set_next_model(next: bool) -> void:
	var models_array: Array = user_rings_dict.keys()
	var index_of_next_model
	if(next):
		index_of_next_model = (models_array.find(selected_model) + 1)%models_array.size()
	else:
		index_of_next_model = (models_array.find(selected_model) - 1)%models_array.size()
	var next_model = models_array[index_of_next_model]
	print_debug("Changed model to:  "+ next_model)
	_change_model(next_model)
	
func _change_model(next_model: String):
	selected_model = next_model
	_apply_model()
	
func _apply_model():
	var full_model_path = models_path+selected_model+".tscn" 
	var loaded_model_scene = (load(full_model_path) as PackedScene)
	var loaded_model: Node3D 
	
	
	if loaded_model_scene == null:
		loaded_model = Node3D.new()
	else:
		loaded_model = loaded_model_scene.instantiate()
	var models = model_container.get_children()
	for m in models:
		model_container.remove_child(m)
	model_container.add_child(loaded_model)
	
func refresh() -> void:
	user_rings_dict = player_stats.getUserRingsDict()
	print_debug("refreshing model manager")
	
func get_selected_model_owned() -> bool:
	return user_rings_dict[selected_model]["owned"]

func get_selected_model_price() -> String:
	return user_rings_dict[selected_model]["price"]
	

func get_selected_model_stars() -> String:
	return user_rings_dict[selected_model]["stars"]

func acquire_model_ownership(_price: String, v_stars: String) -> bool:
	var price = int(_price)
	var _stars = int(v_stars)
	var coins = player_stats.get_coins()
	var stars = player_stats.stars
	
	if coins >= price:
		player_stats.remove_coins(price)
		_update_owned_models()
		return true
	elif stars>=_stars:
		player_stats.remove_stars(_stars)
		_update_owned_models()
		return true
	else:
		return false
		
func _update_owned_models():
	user_rings_dict[selected_model]["owned"] = true
	player_stats.saveUserRingsDict(user_rings_dict)
