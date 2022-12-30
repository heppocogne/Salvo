extends "res://gameplay/screen/weapon_reload_bar.gd"

onready var weap_name:Label=$"../WeaponName"


func _ready():
	pass


func set_weapon_key(key:String):
	.set_weapon_key(key)
	if !get_parent():
		return
	if key=="":
		get_parent().visible=false
	else:
		get_parent().visible=true
		if key=="aa":
			weap_name.text="[対空兵装]"
		elif key=="secondary":
			weap_name.text="[副砲]"
