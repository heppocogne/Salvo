extends Control


func _ready():
	for b in $Panel/VBoxContainer/HBoxContainer/MarginContainer2/HBoxContainer.get_children():
		if SaveData.has_key(b.save_data_key):
			b.set_unlocked(SaveData.read(b.save_data_key))
		else:
			SaveData.store(b.save_data_key,false)
			b.set_unlocked(false)
	
	for s in $Panel/VBoxContainer/HBoxContainer/MarginContainer2/HBoxContainer.get_children():
		s.connect("button_pressed",self,"_on_Stage_selected")


func _on_Stage_selected(n:String):
	if n=="Tutorial 1":
		get_tree().change_scene_to(preload("res://gameplay/screen/tutorial_1/tutorial_1.tscn"))
	elif n=="Stage 1":
		get_tree().change_scene_to(preload("res://gameplay/screen/stage_1/stage_1.tscn"))
	elif n=="Stage 2":
		get_tree().change_scene_to(preload("res://gameplay/screen/stage_2/stage_2.tscn"))
	elif n=="Tutorial 2":
		get_tree().change_scene_to(preload("res://gameplay/screen/tutorial_2/tutorial_2.tscn"))


func _on_Exit_pressed():
	get_tree().quit(0)


func _on_Upgrade_pressed():
	get_tree().change_scene_to(preload("res://gameplay/screen/main/ship_upgrade/ship_upgrade.tscn"))
