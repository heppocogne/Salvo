@tool
class_name PlayEvaluation
extends HBoxContainer

const colors:={
	"S":Color.PURPLE,
	"A":Color.SKY_BLUE,
	"B":Color.LIGHT_GREEN,
	"C":Color.YELLOW,
	"D":Color.ORANGE_RED,
}

@export var title_name:String : set = set_title_name
var evaluation:String : set = set_evaluation


func _ready():
	pass


func set_title_name(n:String):
	title_name=n
	if has_node("Title"):
		$Title.text=n


func set_evaluation(e:String):
	evaluation=e
	if has_node("Evaluation"):
		$Evaluation.text=e
		if colors.has(e):
			$Evaluation.add_theme_color_override("font_color",colors[e])
