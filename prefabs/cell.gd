extends Spatial
class_name Cell

var atlas1 = preload("res://materials/items_atlas.tres")
var atlas2 = preload("res://materials/items_atlas2.tres")

onready var _sprite_root = $SpriteRoot
onready var _sprite = $SpriteRoot/Sprite
onready var _particles = $Particles
onready var _animation = $AnimationPlayer

var item: int = -1
var marked: bool = false
var locked: bool = false
var height_offset: float = 0.1
var eaten: bool = false

var _timer = 1.0

func _ready():
	_particles.emitting = false
	_particles.visible = false

	_sprite.material_override.set_shader_param("albedo", [atlas1, atlas2][item / 64].duplicate())
	var t = item % 64

	var size = 256
	_sprite.texture.region = Rect2((t % 8) * size, (t / 8) * size, size, size)


func _process(delta):
	if _timer < 1.0:
		_timer += delta
		if _timer < 0.07:
			_sprite_root.scale = lerp(Vector3( 0.4, 0.4, 1 ), Vector3( 0.471872, 0.353191, 1), _timer / 0.07)
		elif _timer < 0.2:
			_sprite_root.scale = lerp(Vector3( 0.471872, 0.353191, 1), Vector3( 0.4, 0.4, 1 ), (_timer - 0.07) / (0.2 - 0.07))


func set_marked(value):
	var changed = marked != value
	marked = value
	_timer = 0.0
	if changed:
		_sprite.material_override.set_shader_param("marked", marked)


func set_eaten(value):
	if value:
		_particles.emitting = true
		_particles.visible = true
