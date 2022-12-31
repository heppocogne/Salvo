class_name Airport
extends NavaelBaseObject

const f1_scene:PackedScene=preload("res://gameplay/aircraft/fighter.tscn")
const f2_scene:PackedScene=preload("res://gameplay/aircraft/fighter2.tscn")
const b1_scene:PackedScene=preload("res://gameplay/aircraft/bomber.tscn")
const b2_scene:PackedScene=preload("res://gameplay/aircraft/bomber2.tscn")

export var fighter_takeoff_duration:float=4.0
export var fighter_y_min:float=360
export var fighter_y_max:float=400
export var bomber_takeoff_duration:float=6.0
export var bomber_y_min:float=100
export var bomber_y_max:float=150


func _ready():
	pass


func set_active(f:bool):
	active=f
	if active:
		$FighterTakeoffTimer.wait_time=fighter_takeoff_duration
		$FighterTakeoffTimer.start()
		$BomberTakeoffTimer.wait_time=bomber_takeoff_duration
		$BomberTakeoffTimer.start()
	else:
		$FighterTakeoffTimer.stop()
		$BomberTakeoffTimer.stop()


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
		set_active(false)
		$Smoke.emitting=true


func spawn_aircraft(aircraft_scene:PackedScene)->Aircraft:
	var a:Aircraft=aircraft_scene.instance()
	a.connect("damaged",GlobalScript.battele_screen,"_on_Enemy_damaged")
	a.connect("weapon_fired",GlobalScript.battele_screen,"_on_Enemy_fired")
	GlobalScript.node2d_root.add_child(a)
	return a


func _on_FighterTakeoffTimer_timeout():
	if !GlobalScript.node2d_root.has_node("Player"):
		return
	
	var a:Fighter
	if randf()<0.5:
		a=spawn_aircraft(f1_scene)
	else:
		a=spawn_aircraft(f2_scene)
	
	a.position=global_position
	a.target_velocity=polar2cartesian(a.get_speed(),deg2rad(225))
	a._actual_velocity=a.target_velocity
	a.target_y=rand_range(fighter_y_min,fighter_y_max)


func _on_BomberTakeoffTimer_timeout():
	if !GlobalScript.node2d_root.has_node("Player"):
		return
	
	var a:Bomber
	if randf()<0:
		a=spawn_aircraft(b1_scene)
	else:
		a=spawn_aircraft(b2_scene)
	
	a.position=global_position
	a.target_velocity=polar2cartesian(a.get_speed(),deg2rad(240))
	a._actual_velocity=a.target_velocity
	a.get_node("AscendingTimer").start(2.0/sqrt(3)*(global_position.y-rand_range(bomber_y_min,bomber_y_max))/a.get_speed())
