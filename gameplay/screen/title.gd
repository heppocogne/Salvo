extends Control


func _ready():
	pass


func _on_Start_pressed():
	get_tree().change_scene_to(preload("res://gameplay/screen/main/main.tscn"))


func _on_Options_pressed():
	get_tree().change_scene_to(preload("res://gameplay/screen/options/options.tscn"))


func _on_Exit_pressed():
	get_tree().quit(0)
