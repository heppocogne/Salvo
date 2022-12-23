class_name BattleScreen
extends Control

export var clear_count_key:String
export var pt_per_damage:=1.0
export var pt_aiming:=1.0
export var first_reawrd:=0

var _player_salvo_diff:Array
var _damage_sum:=0.0

onready var tween:Tween=$VBoxContainer/ViewportContainer/Viewport/Node2DRoot/Tween


func _ready():
	_player_salvo_diff=[]
	GlobalScript.node2d_root=$VBoxContainer/ViewportContainer/Viewport/Node2DRoot
	GlobalScript.water_area=$VBoxContainer/ViewportContainer/Viewport/Node2DRoot/WaterArea


func _process(_delta:float):
	pass


func spawn_enemy_ship(scene:PackedScene, x:float)->Ship:
	var ship:Ship=scene.instance()
	GlobalScript.node2d_root.add_child(ship)
	ship.position.y=500
	ship.connect("damaged",self,"_on_Enemy_damaged")
	tween.interpolate_property(
		ship,
		"position:x",
		1500,
		x,
		1.0,
		Tween.TRANS_QUAD,
		Tween.EASE_OUT
	)
	tween.start()
	return ship


func set_label_text(text:String):
	var l:Label=$VBoxContainer/ViewportContainer/CenterContainer/VBoxContainer/Label
	l.text=text
	l.percent_visible=0.0
	var t:Tween=l.get_node("Tween")
	t.interpolate_property(
		l,
		"percent_visible",
		0.0,
		1.0,
		0.5,	# duration
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
	)
	t.start()


func _on_Timer_timeout():
	pass


func _on_Button_pressed():
	get_tree().change_scene_to(load("res://gameplay/screen/main/main.tscn"))


func _on_Player_player_fired(diff:float):
	_player_salvo_diff.push_back(diff)


func _on_Enemy_damaged(d:int):
	_damage_sum+=d
