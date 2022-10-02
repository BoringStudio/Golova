extends Spatial

const Item = preload("res://prefabs/item.gd").Item
const cell = preload("res://prefabs/cell.tscn")

onready var _head = $Head
onready var _timer = $Timer
onready var _items = $Items
onready var _camera = $Camera
onready var _camera_target = $CameraTarget

export(float) var item_width = 1.0
export(float) var item_height = 1.0
export(int) var rows = 4
export(int) var cols = 4
export(Array, Item) var sequence = []

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

	if rows == 0 or cols == 0:
		return

	var field_origin = _items.transform.origin - Vector3((rows - 1) * item_width, 0, (cols - 1) * item_height) * 0.5
	var field_x = Vector3(item_width, 0, 0)
	var field_z = Vector3(0, 0, item_height)

	var total_items = cols * rows

	var grid = []
	grid += sequence
	
	while grid.size() < total_items:
		var variant = randi() % (Item.MAX + 10)
		if variant >= Item.MAX:
			grid.append(null)
		else:
			grid.append(variant)

	randomize()
	grid.shuffle()

	for r in range(0, rows):
		for c in range(0, cols):
			var i = r * cols + c
			var item = grid[i]
			if item == null:
				continue

			var child = cell.instance()
			child.item = item
			child.name = "cell_{0}".format([i])
			_items.add_child(child)
			child.transform.origin = field_origin + field_x * r + field_z * c
			child.connect("marked", self, "_on_item_marked")


func _on_time_to_eat():
	if sequence.empty():
		_focus_eyes(_camera)
		return

	var next_seq_idx = 0
	var cell_to_eat = null
	var remaining_cells = []
	for n in _items.get_children():
		if n is Cell:
			remaining_cells.append(n)
			if n.marked:
				var seq_idx = sequence.find(n.item)
				if seq_idx >= 0:
					next_seq_idx = seq_idx
					cell_to_eat = n
					break

	if cell_to_eat == null:
		remaining_cells.shuffle()
		for n in remaining_cells:
			if n.item == sequence[next_seq_idx]:
				cell_to_eat = n
				break

	if cell_to_eat != null:
		sequence.remove(next_seq_idx)
		eaten_cell = cell_to_eat
		_focus_eyes(cell_to_eat)
		_head.eat(eaten_cell)


func _on_finished_eating():
	_items.remove_child(eaten_cell)
	eaten_cell.queue_free()
	eaten_cell = null
	if sequence.empty():
		_focus_eyes(_camera)
		_head.make_angry()
	else:
		_timer.start()


func _on_item_marked(item):
	_focus_eyes(item)
	if _timer.time_left == 0.0:
		_timer.start()


func _focus_eyes(target: Spatial):
	_camera_target.global_transform.origin = target.global_transform.origin
