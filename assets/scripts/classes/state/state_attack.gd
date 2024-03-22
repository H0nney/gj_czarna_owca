class_name State_Attack extends State

@export var actor:CharacterBody2D
@export var animator:AnimatedSprite2D
@export var headSprite:AnimatedSprite2D
@export var navigationAgent:NavigationAgent2D
	
func _exit_state() -> void:
	pass

func _enter_state() -> void:
	navigationAgent.target_position = global.tower.global_position
	pass
	
func _physics_update(_delta) -> void:
	actor.velocity = actor.global_position.direction_to(navigationAgent.get_next_path_position()) * actor.speed
	actor.move_and_slide()
