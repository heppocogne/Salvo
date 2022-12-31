extends BattleScreen

enum{
	NONE,
	MOVE_TUTORIAL,
	FIRE_TUTORIAL,
	KILL_TUTORIAL,
	TUTORIAL_END,
}
var step:=NONE
var move_left:=false
var move_right:=false
var left_clicked:=false
var enemy_killed:=false


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
			return
	
	elif step==FIRE_TUTORIAL:
		if left_clicked:
			var flag:=false
			for n in GlobalScript.node2d_root.get_children():
				if n is Projectile:
					flag=true
					return
			
			if !flag:
				set_label_text("敵を撃沈せよ")
				step=KILL_TUTORIAL
				var ship:=spawn_enemy_ship(preload("res://gameplay/ship/enemy/tutorial_target.tscn"),500)
				var m:Marker=preload("res://gameplay/misc/marker.tscn").instance()
				m.target_node=ship
				m.popup_offset=Vector2(0,-15)
				ship.add_child(m)
				ship.connect("killed",self,"_on_Enemy_Killed")
				return
		
		if Input.is_mouse_button_pressed(BUTTON_LEFT):
			for n in GlobalScript.node2d_root.get_children():
				if n is Projectile:
					left_clicked=true
					return
	
	if step==KILL_TUTORIAL:
		if enemy_killed:
			set_label_text("チュートリアル 1 完了")
			stage_complete()
			step=TUTORIAL_END
			SaveData.store("stage_1_unlocked",true)


func _on_Enemy_Killed():
	enemy_killed=true
