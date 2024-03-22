extends Node2D

var menu:CanvasLayer = null
var started:bool = false

func _enter_tree():
	global.root = self

func _ready():
	#Initial assigns
	global.crtShader = $Shaders/CrtShader
	global.transition = $Shaders/Transition
	$Shaders.show()
	_initMenu()
	
	global.crosshair = $Crosshair
	global.showMouse()
	global.crosshair.hide()
	
func _initMenu():
	started = false
	if global.currentGame:
		global.currentGame.queue_free()
		global.currentGame = null
		
	menu = global.MENU.instantiate()
	menu.startGame.connect(_startGame)
	self.add_child(menu)
	
	global.runTransition(false)
	
func _process(_delta):
	global.crosshair.position = get_global_mouse_position()

func _startGame():
	if !started:
		started = true
		await global.runTransition(true)
		menu.queue_free()
		var newGame = global.GAME.instantiate()
		global.currentGame = newGame
		self.add_child(newGame)
		
func distortion(param):
	$Shaders/SkipUi.visible = param
	
	
