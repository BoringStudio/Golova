extends Spatial

export(int) var _rows = 4
export(int) var _cols = 4
export(float) var width = 1.0
export(float) var height = 1.0
export(PackedScene) var cell

var cells: Array

func _ready():
	regenerate(_rows, _cols)


func regenerate(rows: int, cols: int):
	_rows = rows
	_cols = cols

	var field_origin = transform.origin - Vector3(rows * width, 0, cols * height) * 0.5
	var field_x = Vector3(width, 0, 0)
	var field_z = Vector3(0, 0, height)

	for n in get_children():
		remove_child(n)
		n.queue_free()

	for r in range(0, rows):
		for c in range(0, cols):
			var child = cell.instance()
			child.name = "cell_{0}_{1}".format([r, c])
			add_child(child)
			child.transform.origin = field_origin + field_x * r + field_z * c


func get_item(r: int, c: int):
	if r >= _rows or c >= _cols:
		printerr("Get item out of field bounds", r, c)


func add_item(r: int, c: int):
	if r >= _rows or c >= _cols:
		printerr("Add item out of field bounds")
