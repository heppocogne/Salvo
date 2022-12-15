class_name Player
extends Ship


func _ready():
	pass


func _physics_process(delta:float):
	var l:=Input.is_action_pressed("game_left")
	var r:=Input.is_action_pressed("game_right")
	
	var v:float
	if r and !l:
		v=get_speed()
	elif l and !r:
		v=-get_speed()
	else:
		v=0.0
	
	position.x=clamp(position.x+v*delta,0,OS.window_size.x)


func get_projectile_prototype(projectile_scene:PackedScene)->Projectile:
	var i:Projectile=projectile_scene.instance()
	i.set_collision_layer_bit(4,true)
	i.set_collision_mask_bit(3,true)
	return i
