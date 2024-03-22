class_name State_Dead extends State

@export var actor:CharacterBody2D
@export var hitBox:Area2D
@export var collision:CollisionShape2D

@export var sprite:AnimatedSprite2D
@export var deadSprite:Sprite2D
	
func _exit_state() -> void:
	pass

const deathSFX = preload("res://assets/sfx/death.wav")
func _enter_state() -> void:
	actor.alive = false
	sprite.hide()
	deadSprite.show()
	soundController.spawnSoundEffect("SFX", deathSFX, actor.global_position, true, 8)
	hitBox.call_deferred("queue_free")
	collision.call_deferred("queue_free")
	actor.died.emit()
