extends ProgressBar

var player_node:Ship
var timer:Timer


func _ready():
	player_node=$"../../../../ViewportContainer/Viewport/Node2DRoot/Player"
	max_value=player_node.get_weapon_reload("main")
	timer=player_node.weapon_states["main"].timer


func _on_Player_main_weapon_relaod_time_left_changed(key:String,t:float):
	if key=="main":
		value=max_value-t


func _on_Player_main_weapon_reloaded(key:String):
	if key=="main":
		value=max_value
