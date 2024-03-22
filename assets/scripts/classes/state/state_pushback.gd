class_name State_Pushback extends State

@export var actor:CharacterBody2D
	
var direction:Vector2 = Vector2.ZERO
var pushPower_init:float = 500
var pushBuffer:float = 0
func _exit_state() -> void:
	pass

func _enter_state() -> void:
	pushBuffer = pushPower_init
	direction = global.tower.global_position.direction_to(actor.global_position)

func _physics_update(_delta) -> void:
	pushBuffer = lerp(pushBuffer, 0.00, 0.08)
	if pushBuffer <= 5:
		state_finished.emit()
	else:
		actor.velocity = direction * pushBuffer 
		actor.move_and_slide()
	
