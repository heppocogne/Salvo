extends Ship

var player_detected:=false


func _ready():
	pass


func _physics_process(delta:float):
	if !GlobalScript.node2d_root.has_node("Player"):
		return
	if main_weapon_ready and position.distance_to(GlobalScript.node2d_root.get_node("Player").position)<=main_weapons[0].get_range():
		var i:Projectile=get_projectile_instance(main_weapons[0].projectile_scene)
		var p_diff:Vector2=GlobalScript.node2d_root.get_node("Player").global_position-main_weapons[0].global_position
		var a:float=i.gravity*0.5*p_diff.x*p_diff.x/(main_weapons[0].get_muzzle_velocity()*main_weapons[0].get_muzzle_velocity())
		var b:=p_diff.x
		var c:=a-p_diff.y
		var d:=b*b-4*a*c
#		print_debug("d=",d)
		var tan_th:=(-b-sqrt(b*b-4*a*c))/(2*a)
		i.queue_free()
		fire_main_weapon(PI+atan(tan_th))
