tool
class_name Player
extends Ship

const line_color:=Color.darkgray
const line_length:=32.0

var mouse_pos:Vector2


func _ready():
	pass


func _draw():
	var dir:=mouse_pos.normalized()
	draw_line(Vector2.ZERO,line_length*dir,line_color)
	pass


func _process(_delta:float):
	pass


func _input(event:InputEvent):
	if event is InputEventMouseMotion:
		mouse_pos=get_local_mouse_position()
		update()
	elif event is InputEventMouseButton:
		var mb:=event as InputEventMouseButton
		if mb.pressed:
			if mb.button_index==BUTTON_LEFT and main_weapon_ready:
				fire_main_weapon(mouse_pos.angle())


func _physics_process(delta:float):
	if Engine.editor_hint:
		return
	
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


func get_projectile_instance(projectile_scene:PackedScene)->Projectile:
	var i:Projectile=projectile_scene.instance()
	i.set_collision_layer_bit(4,true)
	i.set_collision_mask_bit(3,true)
	return i


func fire_main_weapon(rot:float):
	.fire_main_weapon(rot)
	
	var i:Projectile=get_projectile_instance(main_weapons[0].projectile_scene)
	var a:=0.5*i.gravity
	var b:float=main_weapons[0].get_muzzle_velocity()*sin(rot)
	var c:=global_position.y-500
	var t:=(-b+sqrt(b*b-4*a*c))/(2*a)
	var pos:=Vector2(main_weapons[0].get_muzzle_velocity()*cos(rot)*t+global_position.x,500)
	
	var dist2_min:float=INF
	for n in GlobalScript.node2d_root.get_children():
		if "is_enemy" in n and n!=self:
			if n.global_position.distance_squared_to(pos)<dist2_min:
				dist2_min=n.global_position.distance_squared_to(pos)
	if dist2_min!=INF:
		GlobalScript.player_salvo_diff.push_back(dist2_min)
