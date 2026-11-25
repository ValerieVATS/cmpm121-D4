## One run at the game: the board and the dragon on it, from the first tick until the
## run ends. Rules that involve more than the dragon (food, score, what the dragon can
## run into) belong here, so Dragon stays about movement and app/ only draws.
class_name Session
extends RefCounted

signal ate(score: int)
signal crashed(score: int)

var board: Board
var dragon: Dragon
var food := Vector2i(-1, -1)
var score := 0
var started := false
var over := false
var rng := RandomNumberGenerator.new()


func _init(grid_size: Vector2i, seed := 121) -> void:
	board = Board.bordered(grid_size)
	dragon = Dragon.new(grid_size)
	rng.seed = seed
	_spawn_food()


func turn(direction: Vector2i) -> void:
	if over:
		return
	started = true
	dragon.turn(direction)


## A vacating tail is safe unless the head is eating and the tail stays put.
func tick() -> void:
	if not started or over:
		return
	var next := dragon.next_head()
	var eating := next == food
	var occupied := dragon.body.size() if eating else dragon.body.size() - 1
	if board.is_solid(next) or next in dragon.body.slice(0, occupied):
		over = true
		crashed.emit(score)
		return
	dragon.tick(eating)
	if eating:
		score += 1
		_spawn_food()
		ate.emit(score)


func _spawn_food() -> void:
	var free: Array[Vector2i] = []
	for cell in board.tiles:
		if not board.is_solid(cell) and cell not in dragon.body:
			free.append(cell)
	if free.is_empty():
		food = Vector2i(-1, -1)
		return
	food = free[rng.randi_range(0, free.size() - 1)]
