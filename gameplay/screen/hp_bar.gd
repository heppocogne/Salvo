extends ProgressBar

var player_node:Ship


func _ready():
	player_node=$"../../../../ViewportContainer/Viewport/Node2DRoot/Player"
	max_value=player_node.get_max_hp()
	value=player_node.hp


func _on_Player_damaged():
	value=player_node.hp
