extends Spatial

const Item = preload("res://prefabs/item.gd").Item
const cell = preload("res://prefabs/cell.tscn")

onready var _head = $Head
onready var _timer = $Timer
onready var _items = $Items

export(float) var item_width = 1.0
export(float) var item_height = 1.0
export(Array, Array, Item) var grid = [[Item.None]]

onready var _rows = len(grid)
onready var _cols = len(grid[0])

var eaten_cell: Cell = null

func _ready():
	_regenerate()
	_timer.connect("timeout", self, "_on_time_to_eat")
	_timer.start()
	_head.connect("finished_eating", self, "_on_finished_eating")


func _regenerate():
	for n in _items.get_children():
		_items.remove_child(n)
		n.queue_free()

	var field_origin = _items.transform.origin - Vector3((_rows - 1) * item_width, 0, (_cols - 1) * item_height) * 0.5
	var field_x = Vector3(item_width, 0, 0)
	var field_z = Vector3(0, 0, item_height)

	for r in range(0, _rows):
		var row = grid[r]
		for c in range(0, _cols):
			var item = row[c]

			var child = cell.instance()
			child.set_item(item)
			child.name = "cell_{0}".format([r * _cols + c])
			_items.add_child(child)
			child.transform.origin = field_origin + field_x * r + field_z * c
			child.connect("marked", self, "_on_item_marked")


func _on_time_to_eat():
	var possible_children = []
	for n in _items.get_children():
		if n is Cell and n.marked:
			possible_children.append(n)

	var child_count = len(possible_children)
	if child_count == 0:
		return

	var cell_to_eat = randi() % child_count
	eaten_cell = possible_children[cell_to_eat]
	_head.eat(eaten_cell)


func _on_finished_eating():
	_items.remove_child(eaten_cell)
	eaten_cell.queue_free()
	eaten_cell = null
	_timer.start()


func _on_item_marked(_item):
	print("MARKED")
	if _timer.time_left == 0.0:
		_timer.start()
