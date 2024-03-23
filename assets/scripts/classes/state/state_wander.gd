class_name State_Wander extends State

@export var actor:CharacterBody2D

var randomDirection:Vector2 = Vector2.ZERO
var randomDuration:float = 2
	
func _exit_state() -> void:
	pass

func _enter_state() -> void:
	randomDuration = randf_range(1.5, 4)
	randomDirection = Vector2(randf_range(-1, 1), randf_range(-1, 1))
	actor.velocity = randomDirection.normalized() * actor.speed
	
	await get_tree().create_timer(randomDuration).timeout
	actor.stateMachine._setState(actor.state_idle)

func _physics_update(_delta):
	var lastCollision = actor.get_last_slide_collision()
	if lastCollision:
		actor.velocity = actor.velocity.bounce(lastCollision.get_normal())
		
	actor.move_and_slide()
