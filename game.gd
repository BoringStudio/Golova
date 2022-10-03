extends Spatial

const Item = preload("res://prefabs/item.gd").Item
const cell = preload("res://prefabs/cell.tscn")

enum UiState {
	Menu,
	Paused,
	Game,
}

onready var _head = $Head
onready var _head_timer = $Timers/Head
onready var _items = $Items
onready var _camera = $Camera
onready var _camera_target = $CameraTarget
onready var _music = $Music
onready var _main_menu = $CanvasLayer/MainMenu
onready var _pause_menu = $CanvasLayer/PauseMenu
onready var _animation: AnimationPlayer = $AnimationPlayer

export(float) var item_width = 1.0
export(float) var item_height = 1.0
export(int) var rows = 4
export(int) var cols = 4
export(int) var empty_cell_count = 4
export(Array, Item) var sequence = []

var _current_level = 0
var _ui_state = UiState.Menu

const LEVELS = [
	{
		solution = "Rotating things",
		variants = [
			{
				sequence = [Item.MerryGoRound, Item.Planet, Item.Bike, Item.Clock, Item.WashingMachine, Item.Windmill],
				hint = "I ate Jupiter for breakfast. And now my stomach is twisting.",
				rows = 4,
				cols = 4,
				empty_cells = 4,
			}
		]
	}
]

var eaten_cell: Cell = null

func _ready():
	_head.connect("finished_eating", self, "_on_finished_eating")
	_head_timer.connect("timeout", self, "_on_time_to_eat")

	_main_menu.connect("game_started", self, "_on_game_started")
	_pause_menu.connect("game_resumed", self, "_on_game_resumed")

	_ui_state = UiState.Menu
	_update_interface()

	# Reset camera
	_animation.play("fade_in")
	_animation.playback_speed = 0.0;



func _on_game_started():
	_ui_state = UiState.Game
	_update_interface()

	_animation.playback_speed = 1.0;
	_head_timer.start()
	_regenerate(0, 0)


func _on_game_resumed():
	_ui_state = UiState.Game
	_update_interface()


func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		if _ui_state == UiState.Game:
			_ui_state = UiState.Paused
			_update_interface()

			var tree = get_tree()
			tree.paused = true
			tree.set_input_as_handled()


func _clear_field():
	for n in _items.get_children():
		_items.remove_child(n)
		n.queue_free()


func _regenerate(level_id: int, variant_id: int):
	if rows == 0 or cols == 0:
		return

	var group = LEVELS[level_id]
	var variant = group.variants[variant_id]

	sequence = variant.sequence
	rows = variant.rows
	cols = variant.cols
	empty_cell_count = variant.empty_cells

	var field_origin = _items.transform.origin - Vector3((rows - 1) * item_width, 0, (cols - 1) * item_height) * 0.5
	var field_x = Vector3(item_width, 0, 0)
	var field_z = Vector3(0, 0, item_height)

	var total_items = cols * rows

	var grid = []
	grid += sequence

	var other_cells: Array = []
	for i in range(Item.MAX):
		if sequence.find(i) < 0:
			other_cells.append(i)

	randomize()
	other_cells.shuffle()
	other_cells.resize(total_items - grid.size())
	for i in range(empty_cell_count + 1):
		other_cells[i] = null

	grid += other_cells
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

	if not _music.playing:
		_music.play();

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
		_head_timer.start()


func _on_item_marked(item):
	_focus_eyes(item)
	if _head_timer.time_left == 0.0:
		_head_timer.start()


func _focus_eyes(target: Spatial):
	_camera_target.global_transform.origin = target.global_transform.origin


func _update_interface():
	_main_menu.visible = _ui_state == UiState.Menu
	_pause_menu.visible = _ui_state == UiState.Paused
