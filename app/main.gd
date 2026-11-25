## Engine adapter: keeps the clock, passes keys to the Session, and draws what it holds.
## It never decides rules: those live in core/session.gd.
extends Node3D

const GRID := Vector2i(20, 20)
const TICK_SECONDS := 0.1
const CAMERA_OFFSET := Vector3(0, 11, 7.5)  # above and behind the head
const DIRECTIONS := {
	"ui_up": Vector2i.UP,
	"ui_down": Vector2i.DOWN,
	"ui_left": Vector2i.LEFT,
	"ui_right": Vector2i.RIGHT,
}

var session := Session.new(GRID)
var meshes := {}  # kit piece name -> Mesh, shared by everything that shows it (Flyweight)
var segments: Array[MeshInstance3D] = []
var food_view := MeshInstance3D.new()
var camera := Camera3D.new()
var score_label := Label.new()
var message_label := Label.new()
var _clock := 0.0


func _ready() -> void:
	meshes = Stage.load_kit()
	_build_stage()
	add_child(food_view)
	food_view.mesh = meshes["berry"]
	_setup_hud()
	_connect_session()
	_draw_dragon()
	_draw_food()
	_update_hud()


## Input arrives as events, so even a tap shorter than one frame is never missed.
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and session.over:
		if event.keycode == KEY_R or event.keycode == KEY_SPACE:
			session = Session.new(GRID)
			_clock = 0.0
			_connect_session()
			_draw_dragon()
			_draw_food()
			_update_hud()
			return
	for action in DIRECTIONS:
		if event.is_action_pressed(action):
			session.turn(DIRECTIONS[action])
			_update_hud()


func _process(delta: float) -> void:
	_clock += delta
	while _clock >= TICK_SECONDS:
		_clock -= TICK_SECONDS
		session.tick()
		_draw_dragon()
		_draw_food()
	_follow(delta)


func _connect_session() -> void:
	session.ate.connect(_on_ate)
	session.crashed.connect(_on_crashed)


func _setup_hud() -> void:
	var hud := CanvasLayer.new()
	add_child(hud)
	for label in [score_label, message_label]:
		label.add_theme_font_size_override("font_size", 24)
		label.add_theme_color_override("font_color", Color.WHITE)
		label.add_theme_color_override("font_outline_color", Color.BLACK)
		label.add_theme_constant_override("outline_size", 5)
		hud.add_child(label)
	score_label.position = Vector2(18, 14)
	message_label.position = Vector2(18, 46)


func _update_hud() -> void:
	score_label.text = "Berries: %d" % session.score
	if session.over:
		message_label.text = "Game over! Score: %d  -  R or Space to restart" % session.score
	elif session.started:
		message_label.text = "Collect berries. Avoid walls and your body."
	else:
		message_label.text = "Press an arrow key to begin."


func _on_ate(_score: int) -> void:
	_update_hud()
	_draw_food()


func _on_crashed(_score: int) -> void:
	_update_hud()


func _draw_food() -> void:
	food_view.visible = session.food != Vector2i(-1, -1)
	if food_view.visible:
		food_view.position = _center(session.food)


## Sky, light, and tiles live in app/stage.gd; the camera follows the head.
func _build_stage() -> void:
	add_child(Stage.new(session.board.tiles, meshes))
	add_child(camera)
	camera.position = _center(session.dragon.body[0]) + CAMERA_OFFSET


## Ease toward the head each frame, so the camera glides while the dragon steps.
func _follow(delta: float) -> void:
	var target := _center(session.dragon.body[0]) + CAMERA_OFFSET
	camera.position = camera.position.lerp(target, 1 - exp(-3 * delta))
	camera.look_at(camera.position - CAMERA_OFFSET)


func _draw_dragon() -> void:
	var body := session.dragon.body
	while segments.size() < body.size():
		var segment := MeshInstance3D.new()
		add_child(segment)
		segments.append(segment)
	var placed := Kit.layout(body)
	for i in segments.size():
		var segment := segments[i]
		segment.visible = i < body.size()
		if not segment.visible:
			continue
		var cell := body[i]
		segment.mesh = meshes[Kit.Piece.keys()[placed[i][0]].to_lower()]
		segment.position = _center(cell)
		segment.rotation.y = placed[i][1] * PI / 2


func _center(cell: Vector2i) -> Vector3:
	return Vector3(cell.x + 0.5, 0, cell.y + 0.5)
