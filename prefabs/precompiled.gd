extends Spatial

var _count_down = 2

func _ready():
	pass


func _process(delta):
	if _count_down > 0:
		_count_down -= 1;
		if _count_down == 0:
			visible = false
