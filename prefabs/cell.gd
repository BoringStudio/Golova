extends Spatial
class_name Cell

signal marked(item)

onready var _sprite = $Sprite
onready var _particles = $Particles

var item: int = -1
var marked: bool = false setget _set_mark
var height_offset: float = 0.1
var eaten: bool = false setget _set_eaten


func _ready():
	_particles.emitting = false
	_particles.visible = false

	var size = 256
	_sprite.texture.region = Rect2((item % 8) * size, (item / 8) * size, size, size)


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


func _set_eaten(value):
	if value:
		_particles.emitting = true
		_particles.visible = true
