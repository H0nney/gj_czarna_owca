extends CharacterBody2D

#FLAGS
var alive:bool = true
var infection:bool = false : set = _setInfection
var speed:int = 50

#STATEMACHINE
@onready var stateMachine = $StateMachine
@onready var state_idle = $StateMachine/State_Idle
@onready var state_dead = $StateMachine/State_Dead
@onready var state_wander = $StateMachine/State_Wander
@onready var state_eat = $StateMachine/State_Eat

#UTILITY
@onready var blood_particles = $BloodParticles
@onready var main_sprite = $MainSprite
@onready var head_sprite = $MainSprite/HeadSprite
var rng = RandomNumberGenerator.new()
signal died
				
const defaultHead = preload("res://assets/gfx/animationResources/head_1.tres")
var pickedHead = null
var infectionDict:Dictionary = {
	"body": [
		preload("res://assets/gfx/infection/body_2.png"),
		preload("res://assets/gfx/infection/body_3.png"),
		preload("res://assets/gfx/infection/body_4.png")
	],
	"head": [
		{
			"sprite": preload("res://assets/gfx/infection/head_2.png"),
			"animation": preload("res://assets/gfx/animationResources/head_2.tres")
		},
		{
			"sprite": preload("res://assets/gfx/infection/head_3.png"),
			"animation": preload("res://assets/gfx/animationResources/head_3.tres")
		},
		{
			"sprite": preload("res://assets/gfx/infection/head_4.png"),
			"animation": preload("res://assets/gfx/animationResources/head_4.tres")
		}
	],
	"legs": [
		preload("res://assets/gfx/infection/legs_2.png"),
		preload("res://assets/gfx/infection/legs_3.png"),
		preload("res://assets/gfx/infection/legs_4.png"),
	]
}

func _setInfection(x):
	infection = x
	if infection:
		self.add_to_group("infected")
		var infected_part = ["body", "legs"].pick_random()
		var newSprite = Sprite2D.new()
		newSprite.texture = infectionDict[infected_part].pick_random()
		main_sprite.add_child(newSprite)

		for i in ["body", "head", "legs"]:
			if i != infected_part:
				var roll = rng.randf()
				
				if roll <= 0.5:
					if i == "head":
						head_sprite.sprite_frames = infectionDict[i].pick_random().animation
						pickedHead = head_sprite.sprite_frames
					else:
						var newSprite2 = Sprite2D.new()
						newSprite.texture = infectionDict[i].pick_random()
						main_sprite.add_child(newSprite2)
					
		showInfection(false)

func _on_behavior_timer_timeout():
	if rng.randf() <= 0.3 && !stateMachine.state == state_dead:
		stateMachine._setState([state_wander, state_eat].pick_random())

func die(damageTarget):
	var angle = damageTarget.direction_to(self.global_position)
	blood_particles.direction = angle
	blood_particles.emitting = true
	stateMachine._setState(state_dead)
	#spawn decals with a delay

func _ready():
	rng.randomize()
	if rng.randf() <= 0.2:
		infection = true
	
func showInfection(param):
	for sprite in main_sprite.get_children():
		if !sprite is AnimatedSprite2D:
			sprite.visible = param
		else:
			if param:
				head_sprite.sprite_frames = pickedHead
			else:
				head_sprite.sprite_frames = defaultHead

func appear():
	$AnimationPlayer.play("appear")
