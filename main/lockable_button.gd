tool
class_name LockableButton
extends Button

export var unlocked:=true setget set_unlocked
export var save_data_key:String


func _ready():
	if save_data_key!="":
		unlocked=SaveData.read(save_data_key)


func set_unlocked(u:bool):
	unlocked=u
	disabled=!u
	if save_data_key!="":
		SaveData.store(save_data_key,true)
