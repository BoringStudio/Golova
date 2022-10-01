extends Spatial
class_name Cell

const Item = preload("res://prefabs/item.gd")

signal marked(item)

onready var _sprite = $Sprite

var _item: Item
var marked: bool = false setget _set_mark


func _ready():
	pass


func set_item(item: Item):
	_item = item


func _set_mark(value):
	marked = value
	if marked:
		_sprite.modulate = Color(1, 0.5, 0.5)
		emit_signal("marked", _item)
	else:
		_sprite.modulate = Color(0, 0, 0)
