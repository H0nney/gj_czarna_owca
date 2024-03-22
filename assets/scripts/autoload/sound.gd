extends AudioStreamPlayer
const BGM = preload("res://assets/music/bgm.mp3")

func _ready():
	stream = BGM
	bus = "Music"
	play()

func spawnSoundEffect(busString:String, effect:Resource, pos:Vector2, randomPitch:bool, boost:float = 0.0, globalSound = false) -> void:
	var newSoundEffect
	if !globalSound:
		newSoundEffect = AudioStreamPlayer2D.new()
		newSoundEffect.position = pos
	else:
		newSoundEffect = AudioStreamPlayer.new()
		
	newSoundEffect.bus = busString
	newSoundEffect.stream = effect
	if boost:
		newSoundEffect.volume_db += boost
		
	if randomPitch:
		newSoundEffect.pitch_scale = randf_range(0.9, 1.1)	
		
	newSoundEffect.finished.connect(newSoundEffect.queue_free)
	
	if global.currentGame && !globalSound:
		global.currentGame.add_child(newSoundEffect)
	else:
		global.root.add_child(newSoundEffect)
		
	newSoundEffect.play()
