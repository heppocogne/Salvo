extends Control

@onready var current_volume:Label=$ColorRect/MarginContainer/VBoxContainer/SoundVolume/CurrentVolume


func _ready():
	var lang:OptionButton=$ColorRect/MarginContainer/VBoxContainer/Language/OptionButton
#	lang.theme=Theme.new()
#	lang.theme.default_font=preload("res://gui/fonts/SourceHanSansHW-Regular.16.tres")
	if SystemSaveData.read("language")=="ja":
		lang.select(0)
	else:
		lang.select(1)
	$ColorRect/MarginContainer/VBoxContainer/SoundVolume/CenterContainer/HBoxContainer/HSlider.value=SystemSaveData.read("se_volume")
	$ColorRect/MarginContainer/VBoxContainer/UseCursor/CheckBox.button_pressed=SystemSaveData.read("use_default_cursor")
	$ColorRect/MarginContainer/VBoxContainer/ShowFps/CheckBox.button_pressed=SystemSaveData.read("show_fps")


func _on_Return_pressed():
	SystemSaveData.save_to_file()
	get_tree().change_scene_to_packed(load("res://gameplay/screen/title.tscn"))


func _on_Language_item_selected(index:int):
	if index==0:
		TranslationServer.set_locale("ja")
		SystemSaveData.store("language","ja")
	elif index==1:
		TranslationServer.set_locale("en")
		SystemSaveData.store("language","en")


func _on_HSlider_value_changed(value:float):
	current_volume.text=str(int(value))+"%"
	SystemSaveData.store("se_volume",value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), (value-100)/5)


func _on_UseCursor_toggled(button_pressed:bool):
	SystemSaveData.store("use_default_cursor",button_pressed)


func _on_ShowFps_toggled(button_pressed:bool):
	SystemSaveData.store("show_fps",button_pressed)


func _on_Button_pressed():
	SystemSaveData.reset()
	if SystemSaveData.read("language")=="ja":
		$ColorRect/MarginContainer/VBoxContainer/Language/OptionButton.select(0)
		TranslationServer.set_locale("ja")
	else:
		$ColorRect/MarginContainer/VBoxContainer/Language/OptionButton.select(1)
		TranslationServer.set_locale("en")
	$ColorRect/MarginContainer/VBoxContainer/SoundVolume/CenterContainer/HBoxContainer/HSlider.value=SystemSaveData.read("se_volume")

	$ColorRect/MarginContainer/VBoxContainer/UseCursor/CheckBox.button_pressed=SystemSaveData.read("use_default_cursor")
	$ColorRect/MarginContainer/VBoxContainer/ShowFps/CheckBox.button_pressed=SystemSaveData.read("show_fps")

