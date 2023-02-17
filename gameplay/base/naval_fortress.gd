class_name NavalFortress
extends Area2D


func _ready():
	$CollisionPolygon2D.position=$Polygon2D.position
	$CollisionPolygon2D.polygon=$Polygon2D.polygon
	
	for n in get_children():
		if n is NavaelBaseObject:
			n.connect("damaged",Callable(GlobalScript.battele_screen,"_on_Enemy_damaged"))
			if n is Artillery:
				n.connect("weapon_fired",Callable(GlobalScript.battele_screen,"_on_Enemy_fired"))
