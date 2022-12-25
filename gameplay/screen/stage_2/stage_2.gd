extends BattleScreen


func _ready():
	pass

func _on_Timer_timeout():
	_fadeout_mission_text("敵艦隊を撃沈せよ",4.0)
