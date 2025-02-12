extends Node
class_name LineManager

@export var line_segment: PackedScene
@export var new_segment_timer: Timer
@export var lines: Node3D
var rand = RandomNumberGenerator.new()
var last_segment: Line3DSegment
var last_endpoint: Vector3 = Vector3.ZERO
var line_segment_counter: int = 0
var coin_scene = (load("res://Scenes/Coin.tscn") as PackedScene)
var power_up_scene = load("res://Scenes/PowerUp.tscn") as PackedScene
@warning_ignore("unused_signal")
signal collided_with_player
signal coin_collected
signal power_up_collected
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_create_segment(Vector3.ZERO,_generate_point())
	generate_segments_coroutine()
	#new_segment_timer.start()


func generate_segments_coroutine()->void:
		while(get_node("Lines").get_child_count()<7):
			last_endpoint = last_segment.get_endpoint()
			_create_segment(last_endpoint,_generate_point())
		
func _generate_point() -> Vector3:
	var x = rand.randf_range(-1,1)
	var z = rand.randf_range(last_endpoint.z-3,last_endpoint.z-10)
	var point = Vector3(x, 0, z)
	return point
	
func _create_segment(origin: Vector3, endpoint: Vector3) -> void:
	var segment = line_segment.instantiate() as Line3DSegment
	segment.line_removed.connect(generate_segments_coroutine)
	get_node("Lines").add_child(segment)
	segment.create(origin,endpoint)
	if(line_segment_counter == 0):
		segment.cap_bottom()
	line_segment_counter += 1
	last_endpoint = endpoint
	last_segment = segment
	
	#diceroll to create coin
	var diceroll = rand.randf_range(0,1)
	if diceroll > 0.4:
		create_coin(segment)
	if diceroll < 0.1:
		create_power_up(segment)
	

	
func create_power_up(segment: Line3DSegment):
	var power_up = power_up_scene.instantiate() as PowerUp
	segment.add_child(power_up)
	power_up.power_up_collected.connect(on_power_up_collect)

func create_coin(segment: Line3DSegment):
	var coin = coin_scene.instantiate() as Coin
	segment.add_child(coin)
	coin.coin_collected.connect(on_coin_collect)
	
func on_coin_collect()-> void:
	coin_collected.emit()

func on_power_up_collect() -> void:
	power_up_collected.emit()

func reset(ring_position: Vector3) -> void:
	var lines_to_delete = get_node("Lines").get_children()
	for line in lines_to_delete:
		line.free()
	print("generating segments with "+str(get_node("Lines").get_child_count())+" < 7")
	var first_line_position = Vector3(0, 0, ring_position.z)
	line_segment_counter = 0
	last_endpoint = first_line_position
	_create_segment(first_line_position,_generate_point())
	generate_segments_coroutine()
	
