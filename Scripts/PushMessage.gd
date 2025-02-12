extends Control
class_name PushMessage

@export
var title: Label 
@export
var message: Label
@export
var icon_rect: TextureRect# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var tw = create_tween().set_trans(Tween.TRANS_ELASTIC)
	position = Vector2(0,-250)
	tw.tween_property(self,"position",position+Vector2(0,400),1)
	tw.tween_interval(5)
	tw.tween_property(self,"position",position+Vector2(0,-250),1)
	tw.tween_callback(func():queue_free())
	
func create_push_message(_icon: String, _title: String, _msg: String):
	
	print("creating push message with msg"+ _msg)
	icon_rect.texture = ResourceLoader.load(_icon)
	title.set("text",_title)
	message.set("text",_msg)
	visible = true
