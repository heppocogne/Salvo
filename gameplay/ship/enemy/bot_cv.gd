@tool
extends "res://gameplay/ship/enemy/bot_ship.gd"

const f1_scene:PackedScene=preload("res://gameplay/aircraft/fighter.tscn")
const f2_scene:PackedScene=preload("res://gameplay/aircraft/fighter2.tscn")
const fb_scene:PackedScene=preload("res://gameplay/aircraft/fighter_bomber.tscn")
const b1_scene:PackedScene=preload("res://gameplay/aircraft/bomber.tscn")
const b2_scene:PackedScene=preload("res://gameplay/aircraft/bomber2.tscn")

@export var fighter_takeoff_duration:float=6.0
@export var fighter_y_min:float=360
@export var fighter_y_max:float=400
@export var bomber_takeoff_duration:float=6.0
@export var bomber_y_min:float=100
@export var bomber_y_max:float=150


func _ready():
	if Engine.is_editor_hint():
		return
	$FighterTakeoffTimer.wait_time=fighter_takeoff_duration
	$FighterTakeoffTimer.start()
	$BomberTakeoffTimer.wait_time=bomber_takeoff_duration
	$BomberTakeoffTimer.start()


func spawn_aircraft(aircraft_scene:PackedScene)->Aircraft:
	var a:Aircraft=aircraft_scene.instantiate()
	a.connect("damaged",Callable(GlobalScript.battele_screen,"_on_Enemy_damaged"))
	a.connect("weapon_fired",Callable(GlobalScript.battele_screen,"_on_Enemy_fired"))
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
	a.target_velocity=Vector2(a.get_velocity(),0).rotated(deg_to_rad(225))
	a._actual_velocity=a.target_velocity
	a.target_y=randf_range(fighter_y_min,fighter_y_max)


func _on_BomberTakeoffTimer_timeout():
	if !GlobalScript.node2d_root.has_node("Player"):
		return
	
	var a:Bomber
	if randf()<0:
		a=spawn_aircraft(b1_scene)
	else:
		a=spawn_aircraft(b2_scene)
	
	a.position=global_position
	a.target_velocity=Vector2(a.get_velocity(),0).rotated(deg_to_rad(240))
	a._actual_velocity=a.target_velocity
	a.get_node("AscendingTimer").start(2.0/sqrt(3)*(global_position.y-randf_range(bomber_y_min,bomber_y_max))/a.get_velocity())

