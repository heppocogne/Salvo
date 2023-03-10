extends Control

signal upgrade_point_changed()

const pt_save_data_key:="upgrade_point"


func _ready():
	if SaveData.has_key(pt_save_data_key):
		$ColorRect/MarginContainer/VBoxContainer/HBoxContainer2/Label3.text=str(SaveData.read(pt_save_data_key))+" pt"
	else:
		$ColorRect/MarginContainer/VBoxContainer/HBoxContainer2/Label3.text="0 pt"
		SaveData.store(pt_save_data_key,0)
	
	for u in $ColorRect/MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer.get_children():
		if u is UpgradeFeature:
			connect("upgrade_point_changed",u,"_on_upgrade_point_changed")
			u.connect("upgraded_or_donwgraded",self,"_on_upgraded_or_donwgraded")
	
	var v_scrollbar:VScrollBar=$ColorRect/MarginContainer/VBoxContainer/ScrollContainer.get_v_scrollbar()
	v_scrollbar.theme=preload("res://gui/vscrollbar_theme.tres")
	v_scrollbar.rect_min_size=Vector2(8,0)


func _on_upgraded_or_donwgraded():
	var pt:int=SaveData.read(pt_save_data_key)
	$ColorRect/MarginContainer/VBoxContainer/HBoxContainer2/Label3.text=str(pt)+" pt"
	emit_signal("upgrade_point_changed",pt)


func _on_Return_pressed():
	SaveData.save_to_file()
	get_tree().change_scene_to(load("res://gameplay/screen/main/main.tscn"))
