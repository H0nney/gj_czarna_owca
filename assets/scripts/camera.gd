extends Camera2D

@export var binocularsUi:CanvasLayer

var distance_max = 400
var modifier = 1.7

var randomStrength:float = 55.0
var shakeFade:float = 10.0
var rng = RandomNumberGenerator.new()
var shakeStrength:float = 0.0

func applyShake():
	shakeStrength = randomStrength
	
func randomOffset() -> Vector2:
	return Vector2(rng.randf_range(-shakeStrength, shakeStrength), rng.randf_range(-shakeStrength, shakeStrength))
	
func _process(delta):
	if shakeStrength >= 4:
		shakeStrength = lerpf(shakeStrength, 0, shakeFade * delta)
		offset =  offset + randomOffset()
			

func _ready():
	get_tree().get_root().size_changed.connect(_resize)
	_resize()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if !binocularsUi.visible:
		var mousePos = get_viewport().get_mouse_position()
		var mousePos_distance = global.screenCenter.distance_to(mousePos)
		var mousePos_direction = global.screenCenter.direction_to(mousePos)
		if mousePos_distance >= distance_max:
			self.offset = lerp(self.offset, mousePos_direction.normalized() * distance_max/modifier, 0.04)
		else:
			self.offset = lerp(self.offset, mousePos_direction.normalized() * mousePos_distance/modifier, 0.04)

func _input(event):
	if event is InputEventMouseMotion:
		self.position += event.relative / 10

func _resize():
	global.screenCenter = get_viewport_rect().size / 2.0

func toggleBinoculars():
	if !global.transitionRunning:
		await global.runTransition(true, 0.35)
		self.position = get_global_mouse_position()
		
		if !binocularsUi.visible:
			binocularsUi.visible = !binocularsUi.visible
			self.offset = Vector2.ZERO
			global.captureMouse()
			self.zoom = Vector2(3.5, 3.5)
			for deer in get_tree().get_nodes_in_group("infected"):
				deer.showInfection(true)
			global.lockTimeSkip = true
		else:
			self.position = global.tower.position
			global.hideMouse()
			self.zoom = Vector2(2, 2)
			
			for deer in get_tree().get_nodes_in_group("infected"):
				deer.showInfection(false)
			global.lockTimeSkip = false
			binocularsUi.visible = !binocularsUi.visible

		await global.runTransition(false, 0.35)
