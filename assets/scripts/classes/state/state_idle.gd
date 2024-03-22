class_name State_Idle extends State

@export var actor:CharacterBody2D
@export var animator:AnimatedSprite2D
@export var headSprite:AnimatedSprite2D
	
func _exit_state() -> void:
	pass

func _enter_state() -> void:
	animator.play('idle')
	headSprite.play("idle")
	pass
