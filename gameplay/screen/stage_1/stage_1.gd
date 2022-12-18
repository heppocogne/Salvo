extends BattleScreen


func _ready():
	pass


func _on_Timer_timeout():
	set_label_text("敵艦隊を撃沈せよ")
	spawn_enemy_ship(preload("res://gameplay/ship/enemy/old_dd.tscn"),600)
	spawn_enemy_ship(preload("res://gameplay/ship/enemy/old_dd.tscn"),700)
	spawn_enemy_ship(preload("res://gameplay/ship/enemy/old_dd.tscn"),800)
