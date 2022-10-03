tool
extends Spatial

export(bool) var mirror = false

onready var sprite = $Sprite

func _ready():
	pass


func _process(_delta):
	sprite.scale.x = -1.0 if mirror else 1.0
