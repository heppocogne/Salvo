extends Ship

var player_detected:=false


func _ready():
	pass


func _physics_process(_delta:float):
	if !GlobalScript.node2d_root.has_node("Player"):
		return
	if main_weapon_ready and position.distance_to(GlobalScript.node2d_root.get_node("Player").position)<=main_weapons[0].get_range():
		fire_main_weapon(GlobalScript.node2d_root.get_node("Player").position)
