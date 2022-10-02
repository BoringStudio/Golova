extends Spatial

export(float) var camera_distance = 4.0
export(float) var min_distance = 2.0
export(float) var max_distance = 10.0
export(float) var movement_speed = 1.0

export(float) var angle = 45.0
export(int) var scroll_speed = 1

onready var _camera = $Camera
onready var _target = $CameraTarget
onready var _sprite = $AnimatedSprite3D
onready var _area = $Area

var current_cell: Cell = null
var marking: Cell = null


func _ready():
	_sprite.connect("animation_finished", self, "_on_animation_finished")


func _process(delta):
	var direction = _get_direction()
	transform.origin += direction * delta * movement_speed

	if direction.x != 0:
		if direction.x > 0:
			_sprite.scale.x = 1
		else:
			_sprite.scale.x = -1

	if marking == null && Input.is_action_pressed("mark"):
		var areas = _area.get_overlapping_areas()

		var closest: Cell = null
		for i in range(len(areas)):
			var area = areas[i]
			if area is Cell:
				closest = area

		if closest != null:
			marking = closest

	if marking != null:
		if marking.global_transform.origin.x > global_transform.origin.x:
			_sprite.scale.x = 1
		else:
			_sprite.scale.x = -1

	var animation = _get_new_animation(direction)
	if animation != _sprite.animation:
		_sprite.play(animation)


func set_cell(cell: Cell):
	current_cell = cell


func _get_direction():
	return Vector3(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		0,
		Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	)


func _get_new_animation(direction: Vector3):
	if marking != null:
		return "mark"
	elif direction.length_squared() > 0.1:
		return "walk"
	else:
		return "idle"


func _on_animation_finished():
	if marking != null:
		marking.marked = !marking.marked
		marking = null
