extends Control


func _ready():
	for b in $Panel/VBoxContainer/HBoxContainer/GridContainer.get_children():
		if SaveData.has_key(b.save_data_key):
			b.unlocked=SaveData.read(b.save_data_key)


func _on_Tutorial_pressed():
	get_tree().change_scene_to(preload("res://gameplay/screen/tutorial/tutorial.tscn"))


func _on_Stage_1_pressed():
	pass # Replace with function body.
