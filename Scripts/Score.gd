extends Label

class_name Score

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set("text","Score: 0")
	pass # Replace with function body.

func update_score(score: int) -> void:
	var score_text = "Score: " + str(score)
	set("text",score_text)
