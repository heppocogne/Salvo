tool
class_name Artillery
extends NavaelBaseObject

signal weapon_fired(key,n)

export var reload:float=10
export var projectile_scene:PackedScene setget set_projectile_scene
export var base_muzzle_velocity:float setget set_base_muzzle_velocity
export var muzzle_position:Vector2
export var _range:float=-1  setget _set_range,get_range

onready var timer:Timer=$Timer

var player_node:Player


func _ready():
	$Timer.wait_time=reload
	player_node=GlobalScript.node2d_root.get_node("Player")


func _physics_process(_delta:float):
	if Engine.editor_hint:
		return
	
	if !active:
		return
	
	if !weakref(player_node).get_ref():
		return
	
	if player_node.position.distance_to(global_position)<=get_range() and timer.time_left==0.0:
		var v_diff:Vector2=player_node.position-global_position
		var i:Projectile=projectile_scene.instance()
		var v:float=get_muzzle_velocity()
		var a:=0.5*i.gravity*v_diff.x*v_diff.x/(v*v)
		var rot:float
		if a!=0.0:
			var b:=v_diff.x
			var c:=a-v_diff.y
			var d:=b*b-4*a*c
			if 0<=d:
				var tan_theta:float
				var sqrt_d:=sqrt(b*b-4*a*c)
				if abs(-b+sqrt_d)<abs(-b-sqrt_d):
					tan_theta=(-b-sqrt_d)/(2*a)
					rot=atan(tan_theta)
				else:
					tan_theta=(-b+sqrt_d)/(2*a)
					rot=atan(tan_theta)+PI
			else:
				if 0<v_diff.x:
					rot=-PI/4
				else:
					rot=-3*PI/4
		else:
			if 0<v_diff.y:
				rot=-PI/2
			else:
				rot=PI/2
		put_projectile(i,rot,0.1,1.0)
		if !$AudioStreamPlayer.playing:
			$AudioStreamPlayer.play()
		emit_signal("weapon_fired","artillery",1)
		timer.start(reload)


func set_projectile_scene(scene:PackedScene):
	projectile_scene=scene
	_range=-1
	get_range()


func set_base_muzzle_velocity(v:float):
	base_muzzle_velocity=v
	_range=-1
	get_range()


func get_muzzle_velocity()->float:
	return base_muzzle_velocity


func _set_range(_r:float):
	push_warning("'_range' is read only")


func get_range()->float:
	if projectile_scene:
		if _range<0.0:
			var instance:Projectile=projectile_scene.instance()
			if instance:
				var v:=get_muzzle_velocity()
				if instance.gravity==0.0:
					_range=INF
				else:
					_range=v*v/instance.gravity
				instance.queue_free()
			else:
				_range=-1.0
	else:
		_range=-1.0
	return _range


func put_projectile(projectile_prototype:Projectile,rot:float,dispersion:float,accuracy:float):
	var instance:Projectile=projectile_prototype.duplicate()
	if instance:
		GlobalScript.node2d_root.add_child(instance)
		instance.global_position=to_global(muzzle_position)
		
		rot+=PI/4*Weapon.get_random_dispersion(dispersion,accuracy)
		if instance.sync_rotation:
			instance.rotation=rot
		instance.velocity=Vector2(cos(rot),sin(rot))*get_muzzle_velocity()


func damage(p:Projectile):
	if hp<=0:
		return
	
	var dmg:=p.get_damage()
	hp-=dmg
	emit_signal("damaged",dmg)
	GlobalScript.damage_popup(dmg,p.position)
	if hp<=0:
		emit_signal("killed")
		var explosion:Particles2D=preload("res://gameplay/effect/explosion.tscn").instance()
		GlobalScript.node2d_root.add_child(explosion)
		explosion.global_position=global_position
		explosion.scale=0.2*Vector2(1,1)
		
		GlobalScript.play_sound("res://gameplay/effect/tm2_bom002.wav")
		active=false
		$Smoke.emitting=true
