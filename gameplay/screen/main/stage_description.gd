@tool
class_name StageDescription
extends HBoxContainer

signal button_pressed(n)

@export var unlocked:=false : set = set_unlocked
@export var save_data_key:String="stage_#_unlocked"
@export var stage_name:String="Stage #" : set = set_stage_name
@export var description:String : set = set_description


func _ready():
	set_unlocked(unlocked)
	set_stage_name(stage_name)
	set_description(description)


func set_unlocked(u:bool):
	unlocked=u
	if has_node("Button"):
		$Button.disabled=!unlocked
	set_description(description)


func set_stage_name(n:String):
	stage_name=n
	if has_node("Button"):
		$Button.text=n


func set_description(d:String):
	description=d
	if !has_node("Description"):
		return
	if unlocked:
		$Description.text=d
	else:
		$Description.text="???"


func _on_Button_pressed():
	emit_signal("button_pressed",stage_name)
