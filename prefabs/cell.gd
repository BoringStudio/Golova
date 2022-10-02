extends Spatial
class_name Cell

signal marked(item)

onready var _sprite = $Sprite

var item: int = -1
var marked: bool = false setget _set_mark
var height_offset: float = 0.1


func _ready():
	print(item)
	var size = 256
	_sprite.texture.region = Rect2((item % 8) * size, (item / 8) * size, size, size)
	print(_sprite.texture.region)


func _set_mark(value):
	var changed = marked != value
	marked = value
	if changed:
		if marked:
			_sprite.transform.origin.y += height_offset
			_sprite.modulate = Color(1, 0.5, 0.5)
			emit_signal("marked", self)
		else:
			_sprite.transform.origin.y -= height_offset
			_sprite.modulate = Color(0, 0, 0)
