extends Label
class_name Title
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _show_highscore(score: int) -> void:
	get_parent().get_node("Highscore Label").visible = true
	var tw = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tw.tween_method(func(sc):text=str(sc),0,score,2)
	await tw.finished
	return
	
func _show_game_name() -> void:
	text = "RingRing"
	set("visible_characters",0)
	get_parent().get_node("Highscore Label").visible = false
	var tw = create_tween()
	tw.tween_property(self,"visible_characters", 8, 1)
	await tw.finished
	return

func _show_gameover() -> void:
	text = "GameOver"
	set("visible_characters",0)
	get_parent().get_node("Highscore Label").visible = false
	var tw = create_tween()
	tw.tween_property(self,"visible_characters", 8, 1)
	await tw.finished
	return
