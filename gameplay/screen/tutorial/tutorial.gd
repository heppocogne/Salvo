extends BattleScreen

enum{
	NONE,
	MOVE_TUTORIAL,
	FIRE_TUTORIAL,
	KILL_TUTORIAL,
}
var step:=NONE
var move_left:=false
var move_right:=false
var left_clicked:=false


func _ready():
	pass


func _on_Timer_timeout():
	set_label_text("矢印キー←→で左右に移動")
	step=MOVE_TUTORIAL


func _physics_process(_delta:float):
	if step==MOVE_TUTORIAL:
		if !move_left and Input.is_action_pressed("game_left"):
			move_left=true
		
		if !move_right and Input.is_action_pressed("game_right"):
			move_right=true
		
		if move_left and move_right:
			set_label_text("左クリックで主砲を発射")
			step=FIRE_TUTORIAL
	
	elif step==FIRE_TUTORIAL:
		if left_clicked:
			var flag:=false
			for n in GlobalScript.node2d_root.get_children():
				if n is Projectile:
					flag=true
					return
			
			if !flag:
				set_label_text("敵を撃沈して下さい")
				step=KILL_TUTORIAL
				spawn_enemy_ship(preload("res://gameplay/ship/enemy/tutorial_target.tscn"),500)
		
		if Input.is_mouse_button_pressed(BUTTON_LEFT):
			left_clicked=true


func set_label_text(text:String):
	var l:Label=$VBoxContainer/ViewportContainer/CenterContainer/Label
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
