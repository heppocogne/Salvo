tool
extends Fighter


func _ready():
	if !Engine.editor_hint:
		get_projectile_instance("main2").queue_free()
		weapon_states["main2"].timer.stop()
		weapon_states["main2"].ready=true


func _physics_process(_delta:float):
	if Engine.editor_hint:
		return
	
	# set bomb range
	var g:float=weapon_states["main2"].projectile_prototype.gravity
	var sv:=sin(_actual_velocity.angle())
	var d:=_actual_velocity.length_squared()*sv*sv-2*g*(position.y-water_level)
	if d<0:
		return
	
	var t:=(-_actual_velocity.length()*sv+sqrt(d))/g
	var p:=_actual_velocity*t+Vector2(0,0.5*g*t*t)+position
	var r:=(p-position).length()
	
	if !weakref(player_node).get_ref():
		return
	
	for n in weapon_states["main2"].nodes:
		n._set_range(r)
	
	if p.x<=player_node.position.x and weapon_states["main2"].ready and 0<=_actual_velocity.y:
		drop_bomb()


func drop_bomb():
	var n:=0
	var ws:WeaponState=weapon_states["main2"]
	var v:=_actual_velocity
	var vl:=v.length()
	for w in ws.nodes:
		var i:Projectile=get_projectile_instance("main2")
		w.base_muzzle_velocity=vl
		w.put_projectile(i,v.angle(),get_weapon_dispersion("main2"),get_weapon_accuracy("main2"))
		
		n+=w.num_barrels
	
	ws.ready=false

	emit_signal("weapon_fired","main2",n)
