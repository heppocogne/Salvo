tool
class_name Bomber
extends Aircraft

enum{
	UNDEFINED,
	NORMAL,
	DIVE,
}

var player_node:Player
var _action:=UNDEFINED


func _ready():
	if !Engine.editor_hint:
		get_projectile_instance().queue_free()
		weapon_states["main"].timer.stop()
		weapon_states["main"].ready=true
		player_node=GlobalScript.node2d_root.get_node("Player")


func _physics_process(delta:float):
	if Engine.editor_hint:
		return
	
	# set bomb range
	var g:float=weapon_states["main"].projectile_prototype.gravity
	var sv:=sin(_actual_velocity.angle())
	var d:=_actual_velocity.length_squared()*sv*sv-2*g*(position.y-water_level)
	if d<0:
		return
	
	var t:=(-_actual_velocity.length()*sv+sqrt(d))/g
	var p:=_actual_velocity*t+Vector2(0,0.5*g*t*t)+position
	var r:=(p-position).length()
	
	if !weakref(player_node).get_ref():
		return
	
	for n in weapon_states["main"].nodes:
		n._set_range(r)
	
	if p.x<=player_node.position.x and weapon_states["main"].ready and 0<=_actual_velocity.y:
		fire_weapon("main",p)
		if _action==DIVE:
			target_velocity=polar2cartesian(get_speed(),PI)
	elif _action==UNDEFINED and 0<=_actual_velocity.y and player_node.position.distance_to(position)<r*1.1:
		if randf()<0.5:
			_action=DIVE
			target_velocity=polar2cartesian(get_speed(),deg2rad(150))
		else:
			_action=NORMAL
	elif _action==DIVE and 400<position.y:
		target_velocity=polar2cartesian(get_speed(),PI)


func fire_weapon(key:String,_pos:Vector2):
	var n:=0
	var ws:WeaponState=weapon_states[key]
	var v:=_actual_velocity
	var vl:=v.length()
	for w in ws.nodes:
		var i:Projectile=get_projectile_instance(key)
		w.base_muzzle_velocity=vl
		w.put_projectile(i,v.angle(),get_weapon_dispersion(key),get_weapon_accuracy(key))
		
		n+=w.num_barrels
	
	ws.ready=false

	emit_signal("weapon_fired",key,n)


func _on_AscendingTimer_timeout():
	target_velocity=get_speed()*Vector2.LEFT
