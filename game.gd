extends Spatial

const Item = preload("res://prefabs/item.gd").Item

const base_music_layer = preload("res://audio/base.mp3")
const first_music_layer = preload("res://audio/first_layer.mp3")
const second_music_layer = preload("res://audio/second_layer.mp3")

enum UiState {
	Menu,
	Paused,
	Game,
}

const LEVELS = [
	{
		solution = "living things",
		variants = [{
			sequence = [Item.Chicken, Item.Elephant, Item.Octopus, Item.Clown, Item.Cow],
			exclude = [Item.Cat, Item.Crab, Item.Ladybug, Item.Cockroach],
			hint = null,
			rows = 4,
			cols = 4,
			empty_cells = 0
		}]
	},
	{
		solution = "things you can theoretically fit\nin your mouth",
		variants = [{
			sequence = [Item.Cockroach, Item.Dice, Item.Lipstick, Item.Money, Item.Eye],
			exclude = [Item.Cat, Item.Crab, Item.Lamp, Item.Domino, Item.Paper, Item.Key, Item.Pill, Item.Lighter, Item.Compass, Item.Egg, Item.ChessPiece, Item.Nose, Item.Ladybug, Item.Strawberry, Item.AceOfSpades],
			hint = "You can't eat what I can.\nI can eat what you can.",
			rows = 5,
			cols = 5,
			empty_cells = 4,
		}, {
			sequence = [Item.Pill, Item.Lighter, Item.Compass, Item.Egg, Item.ChessPiece],
			exclude = [Item.Cat, Item.Crab, Item.Lamp, Item.Domino, Item.Paper, Item.Key, Item.Cockroach, Item.Dice, Item.Lipstick, Item.Money, Item.Eye, Item.Nose, Item.Ladybug, Item.Strawberry, Item.AceOfSpades],
			hint = "Big desires and small mouths.",
			rows = 5,
			cols = 5,
			empty_cells = 4,
		}, {
			sequence = [Item.Nose, Item.Ladybug, Item.Strawberry, Item.AceOfSpades],
			exclude = [Item.Cat, Item.Crab, Item.Lamp, Item.Domino, Item.Paper, Item.Key, Item.Cockroach, Item.Dice, Item.Lipstick, Item.Money, Item.Eye, Item.Pill, Item.Lighter, Item.Compass, Item.Egg, Item.ChessPiece],
			hint = null,
			rows = 5,
			cols = 5,
			empty_cells = 4,
		}]
	},
	{
		solution = "things you can open",
		variants = [{
			sequence = [Item.Eye, Item.Microwave, Item.Ambrella, Item.Chest, Item.BeerBottle, Item.Car],
			exclude = [Item.Cat, Item.Crab, Item.Lock, Item.CashMachine, Item.Helicopter, Item.WindMill, Item.Mouth, Item.Elevator, Item.Camera, Item.Safe, Item.Bag, Item.Refrigirator, Item.Door, Item.Prezent, Item.Car, Item.WashingMachine],
			hint = "You can't get out until you touch the knob.",
			rows = 5,
			cols = 5,
			empty_cells = 4,
		}, {
			sequence = [Item.Mouth, Item.Elevator, Item.Camera, Item.Safe, Item.Bag, Item.Refrigirator],
			exclude = [Item.Cat, Item.Crab, Item.Lock, Item.CashMachine, Item.Helicopter, Item.WindMill, Item.Eye, Item.Microwave, Item.Ambrella, Item.Chest, Item.BeerBottle, Item.Car, Item.Door, Item.Prezent, Item.Car, Item.WashingMachine],
			hint = "Don't close all the doors behind you.\nSometimes you have to come back.",
			rows = 5,
			cols = 5,
			empty_cells = 4,
		}, {
			sequence = [Item.Door, Item.Prezent, Item.Car, Item.WashingMachine],
			exclude = [Item.Cat, Item.Crab, Item.Lock, Item.CashMachine, Item.Helicopter, Item.WindMill, Item.Mouth, Item.Elevator, Item.Camera, Item.Safe, Item.Bag, Item.Refrigirator, Item.Eye, Item.Microwave, Item.Ambrella, Item.Chest, Item.BeerBottle, Item.Car],
			hint = null,
			rows = 5,
			cols = 5,
			empty_cells = 4,
		}]
	},
	{
		solution = "totating things",
		variants = [{
			sequence = [Item.MerryGoRound, Item.Planet, Item.Bike, Item.Clock, Item.WashingMachine, Item.Revolver],
			exclude = [Item.Cat, Item.Crab, Item.Lighter, Item.OfficeChair, Item.Lipstick, Item.Cannon, Item.Lighthouse, Item.Helicopter, Item.Drill, Item.Compass, Item.CorkScrew, Item.Wheel, Item.SpinningTop, Item.WheelChair, Item.WindMill, Item.ToiletPaper],
			hint = "I ate Jupiter for breakfast.\nAnd now my stomach is twisting.",
			rows = 6,
			cols = 6,
			empty_cells = 4,
		}, {
			sequence = [Item.Lighthouse, Item.Helicopter, Item.Drill, Item.Compass, Item.CorkScrew, Item.Wheel],
			exclude = [Item.Cat, Item.Crab, Item.Lighter, Item.OfficeChair, Item.Lipstick, Item.Cannon, Item.MerryGoRound, Item.Planet, Item.Bike, Item.Clock, Item.WashingMachine, Item.Revolver, Item.SpinningTop, Item.WheelChair, Item.WindMill, Item.ToiletPaper],
			hint = "Don't look too long before you eat it.\nIt can be hypnotizing.",
			rows = 6,
			cols = 6,
			empty_cells = 4,
		}, {
			sequence = [Item.SpinningTop, Item.WheelChair, Item.WindMill, Item.ToiletPaper],
			exclude = [Item.Cat, Item.Crab, Item.Lighter, Item.OfficeChair, Item.Lipstick, Item.Cannon, Item.MerryGoRound, Item.Planet, Item.Bike, Item.Clock, Item.WashingMachine, Item.Revolver, Item.Lighthouse, Item.Helicopter, Item.Drill, Item.Compass, Item.CorkScrew, Item.Wheel],
			hint = null,
			rows = 6,
			cols = 6,
			empty_cells = 4,
		}]
	}
]

onready var _head = $Head
onready var _head_timer = $Timers/Head
onready var _items = $Items
onready var _camera = $Camera
onready var _camera_target = $CameraTarget
onready var _music = $Music
onready var _idle_music = $IdleMusic
onready var _main_menu = $CanvasLayer/MainMenu
onready var _pause_menu = $CanvasLayer/PauseMenu
onready var _animation: AnimationPlayer = $AnimationPlayer
onready var _hint: Label3D = $StaticBody/Hint
onready var _preview: Label3D = $StaticBody/Preview

export(float) var item_width = 1.0
export(float) var item_height = 1.0
export(int) var rows = 4
export(int) var cols = 4
export(int) var empty_cell_count = 4
export(Array, Item) var sequence = []

var _current_level = 0
var _current_variant = 0
var _ui_state = UiState.Menu
var _eaten_cell: Cell = null
var _last_marked_cell: Cell = null

func _ready():
	_head.connect("finished_eating", self, "_on_finished_eating")
	_head_timer.connect("timeout", self, "_on_time_to_eat")

	_main_menu.connect("game_started", self, "_on_game_started")
	_pause_menu.connect("game_resumed", self, "_on_game_resumed")

	_animation.connect("animation_finished", self, "_on_animation_finished")

	_ui_state = UiState.Menu
	_update_interface()

	# Reset camera
	_idle_music.play()
	_animation.play("fade_in")
	_animation.playback_speed = 0.0;


func _on_game_started():
	_ui_state = UiState.Game
	_update_interface()

	_animation.playback_speed = 1.0;


func _on_animation_finished(anim):
	if anim == "fade_in":
		_idle_music.stop()

	if anim == "fade_in" or anim == "show_hint" or anim == "win":
		_head_timer.start()
		_regenerate()


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


func _process(_delta):
	if _eaten_cell == null and Input.is_action_pressed("mark"):
		var mouse_position = get_viewport().get_mouse_position()
		var drop_plane = Plane(Vector3(0, 1, 0), 0.1)
		var mouse_origin = _camera.project_ray_origin(mouse_position)
		var mouse_target = drop_plane.intersects_ray(mouse_origin, _camera.project_ray_normal(mouse_position))

		var space_state = get_world().direct_space_state
		var intersection = space_state.intersect_ray(
			mouse_origin, 
			mouse_target + (mouse_target - mouse_origin).normalized() * 10.0,
			[],
			0xffffffff,
			false, # collide_with_bodies
			true # collide_with_areas
		)
		if not intersection.empty() and intersection.collider is Cell:
			var cell = intersection.collider
			if cell != _last_marked_cell and not cell.locked:
				_last_marked_cell = cell
				_focus_eyes(cell)

				if cell.marked:
					cell.set_marked(false)
				else:
					for n in _items.get_children():
						if n is Cell and not n.locked:
							n.set_marked(false)
					cell.set_marked(true)


func _regenerate():
	_clear_field()

	var group = LEVELS[_current_level]
	var variant = group.variants[_current_variant]

	sequence = variant.sequence
	rows = variant.rows
	cols = variant.cols
	empty_cell_count = variant.empty_cells
	var exclude = variant.exclude
	_hint.text = variant.hint if variant.hint != null else ""

	if rows == 0 or cols == 0:
		return

	var field_origin = _items.transform.origin - Vector3((rows - 1) * item_width, 0, (cols - 1) * item_height) * 0.5
	var field_x = Vector3(item_width, 0, 0)
	var field_z = Vector3(0, 0, item_height)

	var total_items = cols * rows

	var grid = []
	grid += sequence

	var other_cells: Array = []
	for i in range(Item.MAX):
		if sequence.find(i) < 0 and exclude.find(i) < 0:
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

			var child = preload("res://prefabs/cell.tscn").instance()
			child.item = item
			child.name = "cell_{0}".format([i])
			_items.add_child(child)
			child.transform.origin = field_origin + field_x * r + field_z * c


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
		_eaten_cell = cell_to_eat
		_focus_eyes(cell_to_eat)
		_head.eat(_eaten_cell)


func _on_finished_eating(damage: int, last_damage: int):
	_items.remove_child(_eaten_cell)
	_eaten_cell.queue_free()
	_eaten_cell = null

	var victory = damage >= 3
	if not victory and damage != last_damage:
		_update_stream(damage)

	if sequence.empty() or victory:
		_focus_eyes(_camera)
		_head.make_angry()

		var current_level = LEVELS[_current_level]
		var variant = current_level.variants[_current_variant]

		if victory:
			_current_variant = 1000

		var level = ""
		if _current_level + 1 < LEVELS.size():
			level = "Now. Level {0}".format([_current_level + 1])


		_preview.text = "{0}, I was thinking about\n{1}.\n\n{2}".format([
			"Yes" if victory else "Hehe",
			current_level.solution,
			level
		])

		if _current_level == 0:
			variant.hint = _preview.text
			_hint.text = variant.hint


		if _current_variant + 1 < current_level.variants.size():
			_current_variant += 1
		elif _current_level + 1 < LEVELS.size():
			_current_level += 1
			_current_variant = 0
		else:
			_clear_field()
			_animation.play("final")
			return

		_clear_field()

		if variant.hint != null and not victory:
			_head._set_damage(0)
			_animation.play("show_hint")
		else:
			var timer = get_tree().create_timer(2.5)
			timer.connect("timeout", self, "_on_restore_health")
			_animation.play("win")
	else:
		_head_timer.start()


func _on_restore_health():
	_head._set_damage(0)


func _focus_eyes(target: Spatial):
	_camera_target.global_transform.origin = target.global_transform.origin


func _update_interface():
	_main_menu.visible = _ui_state == UiState.Menu
	_pause_menu.visible = _ui_state == UiState.Paused


func _update_stream(level: int):
	match level:
		0:
			_music.stream = base_music_layer
		1:
			_music.stream = first_music_layer
		_:
			_music.stream = second_music_layer
	_music.play()
