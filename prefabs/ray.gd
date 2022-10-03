extends Spatial

export(ShaderMaterial) var ray_material;

var length: float = 1.0 setget _set_length
var marked: bool = false setget _set_marked

func _ready():
	pass

func _set_length(value: float):
	ray_material.set_shader_param("ray_length", value)


func _set_marked(value: bool):
	ray_material.set_shader_param("marked", value)
