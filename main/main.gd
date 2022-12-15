extends Control


func _ready():
	get_tree().change_scene_to(preload("res://gameplay/screen/tutorial/tutorial.tscn"))
