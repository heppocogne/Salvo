extends ProgressBar


func _ready():
	var lvl:int=SaveData.read("upgrade_emergency_repair")
	if lvl==0:
		visible=false
		$"../RepairTime".visible=false


func _on_Player_repair_cooldown_started(c:float):
	max_value=c
	value=0


func _on_Player_repair_cooldown_left_changed(t:float):
	value=max_value-t
