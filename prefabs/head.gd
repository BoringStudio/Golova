extends Spatial

signal finished_eating(damage, last_damage)

const Item = preload("res://prefabs/item.gd")

export(float) var ray_target_height = 0.5
export(ShaderMaterial) var head_material: ShaderMaterial;
export(ShaderMaterial) var back_material: ShaderMaterial;
export(Array, Texture) var damaged_textures: Array;
export(Color) var damaged_color: Color;

onready var _animation_player = $AnimationPlayer
onready var _eyes_animation_player = $EyesAnimationPlayer

onready var _ray = $Ray
onready var _ray_origin = $Head/RayOrigin
onready var _particles: Particles = $Head/RayOrigin/Particles
onready var _left_eye = $Head/EyeLeft
onready var _left_eye_sprite = $Head/EyeLeft/Sprite
onready var _right_eye = $Head/EyeRight
onready var _right_eye_sprite = $Head/EyeRight/Sprite
onready var _audio = $Audio
onready var _mouth: MeshInstance = $Head/Mouth

export(float) var eye_range = 0.1

export(NodePath) var eye_target

export(Color) var base_particle_color = Color.red;
export(Color) var marked_partice_color = Color.cyan;

onready var _eye_target: Spatial = get_node(eye_target)

var _eating: Cell = null

var damage: int = 0 setget _set_damage

func _ready():
	head_material.set_shader_param("marked", false)
	back_material.set_shader_param("marked", false)

	_particles.visible = true
	_particles.emitting = true
	_set_particles_enabled(false)
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
		_eating.set_eaten(true)

		var target_distance = (ray_target - ray_origin).length()
		_ray.global_transform.origin = ray_origin
		_ray.global_transform = _ray.global_transform.looking_at(ray_target, Vector3.UP);
		_ray.scale = Vector3(1.0, 1.0, target_distance);
		_ray.visible = true
		_ray.length = target_distance


func eat(cell: Cell):
	_eating = cell
	_eating.locked = true
	_ray.marked = cell.marked
	_eyes_animation_player.play("eat")
	
	var color = marked_partice_color if cell.marked else base_particle_color
	_particles.process_material.color = color
	
	var mouth_material: SpatialMaterial = _mouth.get_active_material(0);
	mouth_material.albedo_color = color
	mouth_material.emission = color

	_set_particles_enabled(true)


func make_angry():
	_eyes_animation_player.play("no")


func _compute_eye_position(eye: Spatial, sprite: Spatial, target: Vector3):
	var dir_to_target = target - eye.global_transform.origin
	sprite.global_transform.origin = eye.global_transform.origin + dir_to_target.normalized() * 0.1


func _on_animation_finished(_anim_name):
	if _eating != null:
		var item = _eating.item
		var last_damage = damage
		if _eating.marked:
			_set_damage(damage + 1)
		else:
			_set_damage(max(damage - 1, 0))

		_reset_animation()
		_set_particles_enabled(false)
		emit_signal("finished_eating", damage, last_damage)

		var word = Item.get_voice(item)
		if word != null:
			_audio.stream = word
			_audio.play()


func _reset_animation():
	_eating = null
	_ray.visible = false


func _set_particles_enabled(enabled: bool):
	_particles.emitting = enabled
	_particles.visible = enabled


func _set_damage(value):
	damage = value

	match value:
		0:
			head_material.set_shader_param("albedo", Color.white)
			head_material.set_shader_param("marked", false)

			back_material.set_shader_param("albedo", Color.white)
			back_material.set_shader_param("marked", false)
		1:
			var color = lerp(Color.white, damaged_color, 0.2)
			head_material.set_shader_param("albedo", color)
			head_material.set_shader_param("cracks_mask", damaged_textures[0])
			head_material.set_shader_param("marked", true)

			back_material.set_shader_param("albedo", color)
			back_material.set_shader_param("marked", false)
		2:
			var color = lerp(Color.white, damaged_color, 0.5)
			head_material.set_shader_param("albedo", color)
			head_material.set_shader_param("cracks_mask", damaged_textures[1])
			head_material.set_shader_param("marked", true)

			back_material.set_shader_param("albedo", color)
			back_material.set_shader_param("marked", false)
		_:
			head_material.set_shader_param("albedo", damaged_color)
			head_material.set_shader_param("marked", true)

			back_material.set_shader_param("albedo", damaged_color)
			back_material.set_shader_param("marked", true)
