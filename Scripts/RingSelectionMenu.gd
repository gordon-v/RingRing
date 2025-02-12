extends Control

class_name RingSelectionMenu

var player_model_manager: PlayerModelManager
var main_button : Button

var b_price: String
var b_stars: String

signal enabled
signal disabled
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_button = get_node("VBoxContainer/HBoxContainer2/Button")
	player_model_manager = get_tree().get_first_node_in_group("PlayerModelManager")

func _on_button_pressed() -> void:
	if player_model_manager.get_selected_model_owned():
		disappear()
	else:
		var purchase_success = player_model_manager.acquire_model_ownership(b_price,b_stars)
		if(!purchase_success):
			(get_tree().get_first_node_in_group("MessageManager") as MessageManager).push_message(1,"Check the star shop!","You can purchase stars,\nor get them free!")
		_check_model_owned()
	
	
func appear() -> void:
	var tw = create_tween().set_trans(Tween.TRANS_EXPO)
	tw.tween_callback(func():enabled.emit())
	tw.tween_callback(_toggle_visibility)
	tw.tween_property(self,"modulate",Color.WHITE,0.7)
	

func disappear() -> void:
	var tw = create_tween().set_trans(Tween.TRANS_EXPO)
	tw.tween_callback(func():disabled.emit())
	tw.tween_property(self,"modulate",Color.TRANSPARENT,0.7)
	tw.tween_callback(_toggle_visibility)
	
func _toggle_visibility() -> void:
	set("visible", !visible)


func _on_left_arrow_pressed() -> void:
	player_model_manager.set_next_model(false)
	_check_model_owned()
	

func _on_right_arrow_pressed() -> void:
	player_model_manager.set_next_model(true)
	_check_model_owned()
	
func _check_model_owned() -> void:
	var owned = player_model_manager.get_selected_model_owned()
	if(owned):
		main_button.set("text","Select")
		main_button.set("icon",null)
	else:
		b_price = player_model_manager.get_selected_model_price()
		b_stars = player_model_manager.get_selected_model_stars()
		var _str = b_price+"\n"+b_stars
		main_button.set("text",_str)
		main_button.icon = ResourceLoader.load("res://Images/coin_over_gem.png")
		


func _on_player_stats_updated_rings() -> void:
	player_model_manager.refresh()
