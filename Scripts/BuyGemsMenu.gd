extends Control


var ad_manager: AdManager
var billing_controller: BillingController
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	billing_controller = get_tree().get_first_node_in_group("BillingController")
	ad_manager = get_tree().get_first_node_in_group("AdManager")
	$VBoxContainer/HBoxContainer5/Gems.text =": "+ str((get_tree().get_first_node_in_group("PlayerStats") as PlayerStats).get_stars())
	#ad_manager.load_rewarded_ad()

func _on_watch_add_button_pressed() -> void:
	ad_manager.play_rewarded_ad()


func _on_back_button_pressed() -> void:
	queue_free()


func _on_buy_stars_button_1_pressed() -> void:
	billing_controller.purchase100()


func _on_button_2_pressed() -> void:
	billing_controller.purchase500()



func _on_button_3_pressed() -> void:
	billing_controller.purchase1500()
	
	

func _on_button_4_pressed() -> void:
	billing_controller.purchase5000()
