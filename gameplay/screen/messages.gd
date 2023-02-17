extends VBoxContainer

@onready var panel_container:=$"../PanelContainer"


func _ready():
	pass


func _on_VBoxContainer_minimum_size_changed():
	panel_container.custom_minimum_size=size+Vector2(16,16)


func _on_Label_visibility_changed():
	panel_container.visible=$Label.visible
