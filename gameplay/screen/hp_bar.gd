extends ProgressBar

var player_node:Player


func _ready():
	player_node=$"../../../../../ViewportContainer/Viewport/Node2DRoot/Player"
	max_value=player_node.get_max_hp()
	value=player_node.hp


func _on_Player_hp_changed(_d:int):
	value=player_node.hp
