extends Node2D

enum GAMESTATE {NONE, INTERMISSION, HUNT, DEFENSE, END, ALLDEAD}

@onready var dayUi = $DayUi
@onready var camera = $Camera

const DEER = preload("res://scenes/deer.tscn")
const INTERMISSION = preload("res://scenes/game/intermission.tscn")
const ALLDEAD = preload("res://scenes/game/alldead.tscn")
const PLAYFIELD = preload("res://scenes/game/playfield.tscn")
const LOSE = preload("res://scenes/game/lose.tscn")

var currentIntermission:CanvasLayer = null
var currentPlayField:Node2D = null
var currentAllDead:CanvasLayer = null
var currentLose:CanvasLayer = null

var currentDay:int = 1
var infestation:float = 0.2
var deerCount:int = 0 : set = _setDeerCount
var lockControls:bool = true
	
#LEVEL TIMER
var start_time = null
func set_start_time():
	start_time = Time.get_ticks_msec()

func time_convert(time_in_sec):
	if !state == GAMESTATE.DEFENSE:
		var seconds = time_in_sec%60
		var minutes = (time_in_sec/60)%60
		
		#returns a string with the format "HH:MM:SS"
		if time_in_sec > 180:
			state = GAMESTATE.DEFENSE
			return "Oh no..."
		else:
			return "%02d:%02d" % [minutes, seconds]

func elapsed_time():
	return Time.get_ticks_msec() - start_time 
	
func _physics_process(_delta):
	if start_time && state == GAMESTATE.HUNT:
		$HuntUi/HuntUiContainer/Time/PanelContainer/MarginContainer/HBoxContainer/TimeLabel.text = time_convert(elapsed_time() / 1000) 
		
	
const spawnArea = Vector2(490, 340)
func rollDirection() -> Vector2:
	return Vector2(randf_range(-1, 1), randf_range(-1, 1))
	
const appearSFX = preload("res://assets/sfx/pop.wav")
func spawnDeer(amount) -> void:
	var test_area = currentPlayField.get_node("TestArea")
	global.tower.spawnCollision(false)
	for i in amount:
		test_area.set_deferred("position", spawnArea * rollDirection())
		await get_tree().physics_frame
		
		while test_area.get_overlapping_bodies().size() > 0:
			test_area.set_deferred("position", spawnArea * rollDirection())
			await get_tree().physics_frame
			
		var newDeer = DEER.instantiate()
		newDeer.position = test_area.position
		newDeer.died.connect(_onDeerDeath.bind(newDeer))
		currentPlayField.add_child(newDeer)
		soundController.spawnSoundEffect("SFX", appearSFX, newDeer.global_position, true, 8)
		newDeer.appear()
		deerCount += 1
		
	global.tower.spawnCollision(true)
		
		

var state:GAMESTATE = GAMESTATE.NONE : set = _setGameState
func _setGameState(newState):
	state = newState
	match state:
		GAMESTATE.INTERMISSION:
			soundController.stream = soundController.INTERMISSION
			soundController.play()
			currentIntermission = INTERMISSION.instantiate()
			var textVbox = currentIntermission.get_node_or_null("TextVBox")
			if textVbox:
				var currentLocale 
				if !locale.localeMap.has(currentDay):
					currentLocale = locale.localeMap[99]
				else:
					currentLocale = locale.localeMap[currentDay]
				
					
				textVbox.get_node("Title").text = currentLocale.title
				textVbox.get_node("Text").text = currentLocale.text
				textVbox.get_node("Cta").text = currentLocale.cta
				
			self.add_child(currentIntermission)
			global.runTransition(false)
			
		GAMESTATE.HUNT:
			global.lockTimeSkip = true
			if currentIntermission:
				currentIntermission.queue_free()
				currentIntermission = null
			
				currentPlayField = PLAYFIELD.instantiate()
				self.add_child(currentPlayField)
				spawnDeer(pow(currentDay+1, 2))
				global.hideMouse()
				global.crosshair.show()
				set_start_time()
				
				$DayUi/TextVBox/DayLabel.text = "Day " + str(currentDay)
				$DayUi.show()
				
				await global.runTransition(false)
				global.lockTimeSkip = false
			
		GAMESTATE.DEFENSE:
			soundController.stream = soundController.BOSS
			soundController.play()
			triggerInfections()
			for deer in get_tree().get_nodes_in_group("infected"):
				deer.showInfection(true)
			
		GAMESTATE.END:
			if !global.transitionRunning:
				global.lockTimeSkip = true
				await global.runTransition(true)
				if currentPlayField:
					$HuntUi.hide()
					currentPlayField.queue_free()
					currentPlayField = null
					
				currentLose = LOSE.instantiate()
				currentLose._setScore(global.score)
				global.showMouse()
				self.add_child(currentLose)
				
				await global.runTransition(false)
				global.lockTimeSkip = false
				
			
		GAMESTATE.ALLDEAD:
			if !global.transitionRunning:
				await global.runTransition(true)
				if currentPlayField:
					$HuntUi.hide()
					currentPlayField.queue_free()
					currentPlayField = null
					
				currentAllDead = ALLDEAD.instantiate()
				global.showMouse()
				self.add_child(currentAllDead)
				
				global.runTransition(false)
			
			
func _unhandled_input(event):
	if !global.transitionRunning:
		if event is InputEventMouseButton:
			if event.button_index == 1 && event.pressed == true:
				match state:
					GAMESTATE.INTERMISSION:
						await global.runTransition(true)
						state = GAMESTATE.HUNT
				
					GAMESTATE.HUNT:
						if $DayUi.visible:
							$DayUi.hide()
							lockControls = false
							global.lockTimeSkip = false
					
					GAMESTATE.ALLDEAD:
						if currentAllDead:
							global.root._progressLevel(currentDay+1)
					
					GAMESTATE.END:
						await global.runTransition(true)
						global.root._initMenu()

func _ready():
	global.currentGame = self
	state = GAMESTATE.INTERMISSION
	updateScore()

func toggleBinoculars():
	if state == GAMESTATE.HUNT:
		camera.toggleBinoculars()
	
func _setDeerCount(x):
	deerCount = x
	#dobra chuj z tym lecymy po koniec
	$HuntUi/HuntUiContainer/Day/HBoxContainer/PanelContainer2/MarginContainer/HBoxContainer/AliveLabel.text = str(deerCount)
	if deerCount <= 0:
		state = GAMESTATE.ALLDEAD

func skipTime():
	global.root.distortion(true)
	start_time -= 180000
	
func getAliveInfected() -> Array:
	var infected = get_tree().get_nodes_in_group("infected")
	var aliveInfected = []
	for i in infected:
		if i.alive:
			aliveInfected.append(i)
			
	return aliveInfected
	
func triggerInfections():
	await get_tree().create_timer(2).timeout
	var aliveInfected = getAliveInfected()
	if aliveInfected.size():
		for deer in aliveInfected:
			deer.triggerInfection(true)
	else:
		global.root._progressLevel(currentDay+1)

	global.root.distortion(false)

func _onDeerDeath(deer):
	deerCount -= 1
	if deer.infection:
		global.score += 10
	else:
		global.score -= 10
		
	if state == GAMESTATE.DEFENSE:
		var aliveInfected = getAliveInfected()
			
		if !aliveInfected.size():
			global.lockTimeSkip = true
			global.root._progressLevel(currentDay+1)
	
func updateScore():
	$HuntUi/HuntUiContainer/Score/ScoreLabel.applyShake()
	$HuntUi/HuntUiContainer/Score/ScoreLabel.text = str(global.score)

func playerLost():
	await global.runTransition(true)
	state = GAMESTATE.END
