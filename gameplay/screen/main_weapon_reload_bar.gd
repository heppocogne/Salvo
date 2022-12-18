extends ProgressBar

var player_node:Ship
var timer:Timer


func _ready():
	player_node=$"../../../../ViewportContainer/Viewport/Node2DRoot/Player"
	max_value=player_node.get_main_weapon_reload()
	timer=player_node.get_node("MainWeaponReloadTimer")


func _on_Player_main_weapon_relaod_time_left_changed(t:float):
	value=max_value-t


func _on_Player_main_weapon_reloaded():
	value=max_value
