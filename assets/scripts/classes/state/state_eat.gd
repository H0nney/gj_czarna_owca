class_name State_Eat extends State

@export var actor:CharacterBody2D
@export var animator:AnimatedSprite2D
@export var headSprite:AnimatedSprite2D

var randomDuration:float = 2

func _ready():
	animator.animation_finished.connect(onEatingPrep)
	
func onEatingPrep():
	if animator.animation == "eat_start": 
		animator.play("eating")
		headSprite.play("eat")
	
func _exit_state() -> void:
	pass

func _enter_state() -> void:
	randomDuration = randf_range(1.5, 5)
	animator.play("eat_start")
	headSprite.play("eat_start")
	
	await get_tree().create_timer(randomDuration).timeout
	actor.stateMachine._setState(actor.state_idle)
