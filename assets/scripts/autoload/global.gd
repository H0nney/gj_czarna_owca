extends Node

#Player node
var tower:StaticBody2D = null
var health:int = 10 : set = _setHealth

func _setHealth(x):
	health = x
	if is_instance_valid(tower):
		tower.updateHealth()
		tower.showHealthBar()

#UTILITY
var root:Node2D = null
var currentGame:Node2D = null
var screenCenter:Vector2 = Vector2.ZERO

func hideMouse():
	crosshair.show()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
func captureMouse():
	crosshair.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func showMouse():
	crosshair.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
var transition:ColorRect = null
var transitionRunning:bool = false
func runTransition(forward:bool, duration:float = 0.8) -> bool: 
	transitionRunning = true
	var targetValue = int(forward)
	var newTween = get_tree().create_tween()
	newTween.tween_property(transition, "material:shader_parameter/progress", targetValue, duration).set_ease(Tween.EASE_IN_OUT)
	await newTween.finished
	transitionRunning = false
	return true

#GAME
const GAME:PackedScene = preload("res://scenes/game.tscn")
var crosshair:Area2D = null

#OPTIONS
const MENU = preload("res://scenes/menu.tscn")
var crtShader:ColorRect = null

var audioBuses:Array = ["Master", "Music", "SFX"]
const SOUND_OPTION:PackedScene = preload("res://scenes/ui/soundOption.tscn")
func onVolumeChange(value, busIdx, valLabel):
	valLabel.text = str(value * 100) + "%"
	AudioServer.set_bus_volume_db(busIdx, linear_to_db(value))
	
func constructSoundOptions(node):
	for audioBus in audioBuses:
		var optionUi = SOUND_OPTION.instantiate()
		var busName:Label = optionUi.get_node_or_null("BusName")
		var volumeSlider:HSlider = optionUi.get_node_or_null("SliderContainer/VolumeSlider")
		var valueLabel:Label = optionUi.get_node_or_null("SliderContainer/ValueLabel")
		
		if busName:
			busName.text = audioBus
			
		var busIndex = AudioServer.get_bus_index(audioBus)
		var busVolume = AudioServer.get_bus_volume_db(busIndex)
		if volumeSlider:
			volumeSlider.value = db_to_linear(busVolume)
			valueLabel.text = "%.f" % (db_to_linear(busVolume) * 100) + "%"
			volumeSlider.value_changed.connect(onVolumeChange.bind(busIndex, valueLabel))
		
		node.add_child(optionUi)
	
