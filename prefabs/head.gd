extends Spatial

signal finished_eating

export(float) var ray_target_height = 0.5

onready var _sprite = $AnimatedSprite3D
onready var _ray = $Ray

var _eating = false

func _ready():
	_reset_animation()


func eat(cell: Cell):
	_eating = true
	_sprite.play("eat")
	_sprite.connect("animation_finished", self, "_on_animation_finished")

	var ray_target = cell.global_transform.origin + Vector3.UP * ray_target_height

	var target_distance = (ray_target - _ray.global_transform.origin).length()
	print("DISTANCE ", target_distance)
	_ray.global_transform = _ray.global_transform.looking_at(cell.global_transform.origin, Vector3.UP);
	_ray.scale = Vector3(1.0, 1.0, target_distance * 10);
	_ray.visible = true


func _on_animation_finished():
	if _eating:
		_reset_animation()
		emit_signal("finished_eating")


func _reset_animation():
	_eating = false
	_sprite.play("idle")
	_ray.visible = false
