extends ProgressBar

export var weapon_key:String="main" setget set_weapon_key
export var player_nodepath:NodePath
var player_node:Player
var timer:Timer


func _ready():
	player_node=get_node(player_nodepath)
	set_weapon_key(weapon_key)


func set_weapon_key(key:String):
	weapon_key=key
	if player_node and key!="":
		max_value=player_node.get_weapon_reload(weapon_key)
		timer=player_node.weapon_states[weapon_key].timer
		value=max_value-timer.time_left


func _on_Player_weapon_relaod_time_left_changed(key:String,t:float):
	if key==weapon_key:
		value=max_value-t


func _on_Player_weapon_reloaded(key:String):
	if key==weapon_key:
		value=max_value
