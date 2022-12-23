tool
class_name Player
extends Ship

signal player_fired(diff)
signal main_weapon_relaod_time_left_changed(t)

const line_color:=Color.darkgray
const line_length:=64.0

var mouse_pos:Vector2
var _class_Ship=load("res://gameplay/ship/ship.gd")


func _ready():
	pass


func _draw():
	var dir:=mouse_pos.normalized()
	draw_line(Vector2.ZERO,line_length*dir,line_color)
	pass


func _process(_delta:float):
	if Engine.editor_hint:
		return
	if !main_weapon_reload_timer.is_stopped():
		emit_signal("main_weapon_relaod_time_left_changed",main_weapon_reload_timer.time_left)


func _input(event:InputEvent):
	if event is InputEventMouseMotion:
		mouse_pos=get_local_mouse_position()
		update()
	elif event is InputEventMouseButton:
		var mb:=event as InputEventMouseButton
		if mb.pressed:
			if mb.button_index==BUTTON_LEFT and main_weapon_ready:
				var rot:=mouse_pos.angle()
				var i:Projectile=get_projectile_instance(main_weapons[0].projectile_scene)
				var a:=0.5*i.gravity
				var b:float=main_weapons[0].get_muzzle_velocity()*sin(rot)
				var c:=global_position.y-500
				var sqrt_d:=sqrt(b*b-4*a*c)
				var t:=(-b+sqrt_d)/(2*a)
				var pos:=Vector2(main_weapons[0].get_muzzle_velocity()*cos(rot)*t+global_position.x,500)
				
				i.queue_free()
				fire_main_weapon2(pos,rot)
				
				var dist_min:float=INF
				for n in GlobalScript.node2d_root.get_children():
					if n is _class_Ship and n!=self:
						if n.global_position.distance_to(pos)<dist_min:
							dist_min=n.global_position.distance_to(pos)
				if dist_min!=INF:
					emit_signal("player_fired",dist_min)


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


func fire_main_weapon2(pos:Vector2,approx_rot:float):
	for w in main_weapons:
		var v_diff:=pos-position
		var i:Projectile=get_projectile_instance(main_weapons[0].projectile_scene)
		var rot:float
		var v:float=w.get_muzzle_velocity()
		var a:=0.5*i.gravity*v_diff.x*v_diff.x/(v*v)
		if a!=0.0:
			var b:=v_diff.x
			var c:=a-v_diff.y
			var tan_theta:float
			var sqrt_d:=sqrt(b*b-4*a*c)
			tan_theta=(-b-sqrt_d)/(2*a)
			var rot1:=atan((-b-sqrt_d)/(2*a))
			var rot2:=atan((-b+sqrt_d)/(2*a))
			if approx_rot<-PI/2:
				rot1-=PI
				rot2-=PI
			if abs(rot1-approx_rot)<abs(rot2-approx_rot):
				rot=rot1
			else:
				rot=rot2
		else:
			if 0<v_diff.y:
				rot=-PI/2
			else:
				rot=PI/2
		w.put_projectile(rot,get_main_weapon_dispersion(),get_main_weapon_accuracy())
	main_weapon_ready=false
	main_weapon_reload_timer.start(get_main_weapon_reload())


func _damage_popup(d:int,pos:Vector2):
	var popup:DamageIndicator=preload("res://gameplay/ship/damage_indicator.tscn").instance()
	popup.text=str(d)
	popup.font_color=Color.red
	popup.rect_position=pos+Vector2(0,-64)
	GlobalScript.node2d_root.add_child(popup)


func _add_sinking_ship():
	var sinking:SinkingShip=preload("res://gameplay/ship/sinking_ship.tscn").instance()
	sinking.texture=$Sprite.texture
	sinking.get_node("Sprite").scale=scale*get_node("Sprite").scale
	GlobalScript.node2d_root.add_child(sinking)
	sinking.global_position=global_position
