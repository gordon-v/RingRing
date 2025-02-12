extends Node
class_name PlayerStats
var score = 0
var high_score: int = 0
var coins: int = 2000
var stars: int = 2000

var rings_str: String = "{\"Blue\":{\"owned\":false,\"price\":\"1000\",\"stars\":\"50\"},\"ChocolateSprinkle\":{\"owned\":false,\"price\":\"250\",\"stars\":\"30\"},\"GoldSpring\":{\"owned\":false,\"price\":\"500\",\"stars\":\"50\"},\"Mandarin\":{\"owned\":false,\"price\":\"250\",\"stars\":\"30\"},\"Opal\":{\"owned\":true,\"price\":\"0\"},\"PinkFrostedSprinkle\":{\"owned\":true,\"price\":\"250\",\"stars\":\"30\"},\"Rainbow\":{\"owned\":false,\"price\":\"1000\",\"stars\":\"99\"},\"Watermelon\":{\"owned\":false,\"price\":\"250\",\"stars\":\"30\"}}"
var noads: bool = false
var noads_token: String = ""
@export
var score_label: Score
@export
var stars_label: Label
var stars_label_shop: Label
@export
var coins_label: Label

signal ads_off
signal updated_rings
func _ready() -> void:
	SnapshotsClient.load_game("testsave1")

func get_stars() -> int:
	return stars

func get_coins() -> int:
	return coins

func get_score() -> int:
	return score

func get_high_score() -> int:
	return high_score
	
func set_high_score(val: int) -> void:
	high_score = val

func _add_score(score_to_add: int = 1) -> void:
	score += score_to_add
	if(score_to_add == -1): #reset score
		score = 0
	score_label.update_score(score)

func collect_coin() -> int:
	coins += 1
	coins_label.text = ": " + str(coins)
	to_json()
	return coins
	
func ring_add_coins(_coins: int) -> int:
		coins += _coins
		return coins

func add_stars(_stars: int):
	stars += _stars
	var _str =  ": "+ str(stars)
	
	print("stars = "+ str(stars))
	var l = (get_tree().get_first_node_in_group("Shop_Stars"))
	if l != null:
		(l as Label).text = _str
	stars_label.text = _str
	save_data()
	
func remove_coins(_coins: int) -> void:
	if _coins <= coins:
		coins -= _coins
	coins_label.text = ": " + str(coins)
	
		
func remove_stars(_stars: int) -> void:
	if _stars <= stars:
		stars -= _stars
	stars_label.text = ": " + str(stars)
	
func removeAds():
	ads_off.emit()
	if noads:
		return
	noads=true
	saveUserRingsDict(JSON.parse_string(rings_str))

	
func getAdStatus():
	return noads

func getUserRingsDict() -> Dictionary:
	print_debug("getting user rings dict" )
	return JSON.parse_string(rings_str)

func saveUserRingsDict(dict: Dictionary) -> void:
	rings_str = JSON.stringify(dict)
	print_debug("saving")
	var data_to_save = JSON.stringify(to_json()).to_utf8_buffer()
	SnapshotsClient.save_game("testsave1","first save",data_to_save)
	
func save_data() -> void:
	print_debug("saving")
	var save_data = JSON.stringify(to_json()).to_utf8_buffer()
	SnapshotsClient.save_game("testsave1","first save",save_data)

func to_json() -> Dictionary:
	var dict: Dictionary = {"score":0,"high_score":high_score,"coins":coins,"stars":stars,"noads":noads,"noads_token":noads_token,"rings_str":rings_str}
	return dict

func from_string(data: String) -> void:
	var dict: Dictionary = JSON.parse_string(data)
	high_score = dict["high_score"]
	coins = dict["coins"]
	stars = dict["stars"]
	noads = dict["noads"]
	noads_token = dict["noads_token"]
	print_debug("loaded data ")
	rings_str = dict["rings_str"]
	updated_rings.emit()
	update_labels()

func update_labels() -> void:
	coins_label.text = ": " + str(coins)
	stars_label.text = ": " + str(stars)
	
