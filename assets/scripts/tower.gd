extends StaticBody2D

@onready var weapon = $Weapon
@onready var weaponSprite = $Weapon/GunSprite
@onready var barrel = $Weapon/Barrel
@onready var shootRaycast = $Weapon/ShootRaycast
@onready var shootParticles = $ShootParticles
@onready var towerInitCollision = $TowerInitCollision
@onready var timeSkipArea = $TimeSkipArea

var mousePos_global:Vector2 = Vector2.ZERO
var mousePos_local:Vector2 = Vector2.ZERO

var isReady:bool = false
func _ready():
	global.tower = self
	isReady = true

func _process(_delta):
	if isReady:
		mousePos_global = get_global_mouse_position()
		mousePos_local = get_local_mouse_position()

		weapon.rotation = lerp_angle(weapon.rotation, mousePos_global.normalized().angle(), 0.1)
		weaponSprite.flip_v = mousePos_local.x < 0

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 && event.pressed:
			if weaponSprite.animation != "reload":
				shoot()
		
		if event.button_index == 2 && event.pressed:
			global.currentGame.toggleBinoculars()

const shootSFX = preload("res://assets/sfx/rifle.wav")
func shoot():
	if !global.currentGame.lockControls:
		var shootTarget = barrel.global_position * 20
		var collider = shootRaycast.get_collider()
		if collider:
			shootTarget = collider.global_position
			collider.get_owner().die(self.global_position)
		
		var pointCount:int = 64
		var points = get_points_between(barrel.global_position, shootTarget, pointCount)
		shootParticles.emission_points = points
		shootParticles.emitting = true
		
		weaponSprite.play('reload')
		soundController.spawnSoundEffect("SFX", shootSFX, self.global_position, true)
	
func get_points_between(start_point, end_point, num_points):
	var points = []
	for i in range(num_points + 1):
		var t = float(i) / float(num_points)
		var point = start_point.lerp(end_point, t)
		points.append(point)

	return points
	
func spawnCollision(param):
	towerInitCollision.set_deferred("disabled", param)
	
func _on_gun_sprite_animation_finished():
	if weaponSprite.animation == "reload":
		weaponSprite.play('idle')
		
var skippingTime:bool = false
func _physics_process(delta):
	if $TimeSkipUi.visible && !skippingTime:
		if $TimeSkipUi/TimeSkipBar.value >= 100:
			global.currentGame.skipTime()
			$TimeSkipUi.hide()
			$TimeSkipUi.mouse_filter = 2
			$TimeSkipArea.set_deferred("monitoring", false)
			$TimeSkipUi/TimeSkipBar.value = 0
		
		if Input.is_action_pressed("click"):
			$TimeSkipUi/TimeSkipBar.value += 3
		else:
			$TimeSkipUi/TimeSkipBar.value -= 0.25
			

func _on_time_skip_area_area_entered(area):
	if !skippingTime:
		$TimeSkipUi.show()

func _on_time_skip_area_area_exited(area):
	#ugly
	if !skippingTime:
		$TimeSkipUi.hide()
		$TimeSkipUi/TimeSkipBar.value = 0

func takeDamage(x):
	global.health -= x
	
func updateHealth():
	$HpBar.value = global.health

func showHealthBar():
	$HpBar.show()
	$HpBar/HpBarTimer.start()
	
func _on_hp_bar_timer_timeout():
	$HpBar.hide()
