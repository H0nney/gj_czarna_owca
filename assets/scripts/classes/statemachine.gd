class_name StateMachine extends Node

@export var actor:CharacterBody2D
@export var defaultState:State

var lastState:State = null
var state:State : set = _setState

func _ready():
	_setState(defaultState)
	
func _setState(new_state:State):
	if state is State:
		lastState = state
		state._exit_state()
		
	state = new_state
	state._enter_state()

func _physics_process(delta):
	#if state:
		#$"../Debug".text = str(state.name)
	state._physics_update(delta)
