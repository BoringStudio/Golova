extends Spatial

signal finished_eating

export(float) var ray_target_height = 0.5

onready var _animation_player = $AnimationPlayer
onready var _eyes_animation_player = $EyesAnimationPlayer

onready var _ray = $Ray
onready var _ray_origin = $Head/RayOrigin
onready var _left_eye = $Head/EyeLeft
onready var _left_eye_sprite = $Head/EyeLeft/Sprite
onready var _right_eye = $Head/EyeRight
onready var _right_eye_sprite = $Head/EyeRight/Sprite
export(float) var eye_range = 0.1

export(NodePath) var eye_target

onready var _eye_target: Spatial = get_node(eye_target)

var _eating: Cell = null

func _ready():
	_animation_player.play("idle")
	_eyes_animation_player.connect("animation_finished", self, "_on_animation_finished")
	_reset_animation()


func _physics_process(_delta):
	if _eye_target != null:
		var target = _eye_target.global_transform.origin
		_compute_eye_position(_left_eye, _left_eye_sprite, target)
		_compute_eye_position(_right_eye, _right_eye_sprite, target)

	_ray.visible = _eating != null
	if _eating != null:
		var ray_target = _eating.global_transform.origin + Vector3.UP * ray_target_height
		var ray_origin = _ray_origin.global_transform.origin

		var target_distance = (ray_target - ray_origin).length()
		_ray.global_transform.origin = ray_origin
		_ray.global_transform = _ray.global_transform.looking_at(ray_target, Vector3.UP);
		_ray.scale = Vector3(1.0, 1.0, target_distance * 10);
		_ray.visible = true


func eat(cell: Cell):
	_eating = cell
	_eyes_animation_player.play("eat")


func make_angry():
	_eyes_animation_player.play("no")


func _compute_eye_position(eye: Spatial, sprite: Spatial, target: Vector3):
	var dir_to_target = target - eye.global_transform.origin
	sprite.global_transform.origin = eye.global_transform.origin + dir_to_target.normalized() * 0.07


func _on_animation_finished(_anim_name):
	if _eating != null:
		_reset_animation()
		emit_signal("finished_eating")


func _reset_animation():
	_eating = null
	_ray.visible = false
