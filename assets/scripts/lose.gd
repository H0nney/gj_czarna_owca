extends CanvasLayer

func _setScore(x):
	$TextVBox/Text.text = "FINAL SCORE: " + str(x)
