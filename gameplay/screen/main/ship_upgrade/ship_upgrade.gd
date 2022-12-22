extends Control

signal upgrade_point_changed()

const pt_save_data_key:="upgrade_point"


func _ready():
	if SaveData.has_key(pt_save_data_key):
		$Panel/MarginContainer/VBoxContainer/HBoxContainer2/Label3.text=str(SaveData.read(pt_save_data_key))+" pt"
	else:
		$Panel/MarginContainer/VBoxContainer/HBoxContainer2/Label3.text="0 pt"
		SaveData.store(pt_save_data_key,0)


func _on_upgraded_or_donwgraded():
	var pt:int=SaveData.read(pt_save_data_key)
	$Panel/MarginContainer/VBoxContainer/HBoxContainer2/Label3.text=str(pt)+" pt"
	emit_signal("upgrade_point_changed",pt)
