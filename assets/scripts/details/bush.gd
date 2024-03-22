@tool
extends Sprite2D

var step = 20
func _enter_tree():
	self.region_rect = Rect2(randi_range(0, 2) * step, 0, 20, 23)
