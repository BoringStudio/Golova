extends Spatial

export(ShaderMaterial) var ray_material;


func _ready():
	pass


func set_length(length: float):
	ray_material.set_shader_param("ray_length", length)
