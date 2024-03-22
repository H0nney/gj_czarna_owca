extends CanvasLayer

@onready var menuContainer:Control = $MenuContainer
func showMenu(panelName:String) -> void:
	var panel = menuContainer.get_node_or_null(panelName)
	if panel:
		hideAll()
		panel.show()
		

func hideAll():
	for child in menuContainer.get_children():
		child.hide()

signal startGame
func _on_start_button_pressed():
	startGame.emit()

func _on_options_button_pressed():
	showMenu("Options")

func _on_exit_button_pressed():
	get_tree().quit()

#OPTIONS SETUP
@onready var soundOptionsContainer = $MenuContainer/Options/MarginContainer/OptionsMain/SoundOptions

func _ready():
	global.constructSoundOptions(soundOptionsContainer)

func _on_back_pressed():
	showMenu("Main")

func _on_check_box_toggled(_toggled_on):
	global.crtShader.visible = !global.crtShader.visible
