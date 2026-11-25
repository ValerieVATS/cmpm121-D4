extends "res://tests/test_case.gd"


func test_a_tick_moves_the_dragon_head() -> void:
	var session := Session.new(Vector2i(10, 10))
	session.turn(Vector2i.RIGHT)
	session.tick()
	assert_eq(session.dragon.body[0], Vector2i(6, 5))


func test_the_dragon_starts_on_open_floor_inside_a_wall() -> void:
	var session := Session.new(Vector2i(10, 10))
	assert_true(session.board.is_solid(Vector2i(0, 0)))
	assert_true(not session.board.is_solid(session.dragon.body[0]))


func test_waits_for_the_first_arrow_key() -> void:
	var session := Session.new(Vector2i(10, 10))
	var head := session.dragon.body[0]
	session.tick()
	assert_eq(session.dragon.body[0], head)
	assert_true(not session.started)


func test_seeded_food_starts_on_free_floor() -> void:
	var first := Session.new(Vector2i(10, 10), 42)
	var second := Session.new(Vector2i(10, 10), 42)
	assert_eq(first.food, second.food)
	assert_true(not first.board.is_solid(first.food))
	assert_true(first.food not in first.dragon.body)


func test_eating_grows_scores_and_respawns_off_the_body() -> void:
	var session := Session.new(Vector2i(10, 10))
	session.food = Vector2i(6, 5)
	session.turn(Vector2i.RIGHT)
	session.tick()
	assert_eq(session.dragon.body.size(), 5)
	assert_eq(session.score, 1)
	assert_true(session.food not in session.dragon.body)
	assert_true(not session.board.is_solid(session.food))


func test_hitting_a_wall_ends_the_run() -> void:
	var session := Session.new(Vector2i(10, 10))
	session.food = Vector2i(1, 1)
	session.turn(Vector2i.RIGHT)
	for i in 4:
		session.tick()
	assert_true(session.over)
	assert_eq(session.dragon.body[0], Vector2i(8, 5))
	session.tick()
	assert_eq(session.dragon.body[0], Vector2i(8, 5))


func test_biting_the_body_ends_the_run() -> void:
	var session := Session.new(Vector2i(10, 10))
	session.food = Vector2i(1, 1)
	session.dragon.body = [
		Vector2i(5, 5), Vector2i(5, 6), Vector2i(6, 6), Vector2i(6, 5), Vector2i(7, 5)
	]
	session.turn(Vector2i.RIGHT)
	session.tick()
	assert_true(session.over)
	assert_eq(session.dragon.body[0], Vector2i(5, 5))


func test_moving_into_the_tail_cell_is_safe() -> void:
	var session := Session.new(Vector2i(10, 10))
	session.food = Vector2i(1, 1)
	session.dragon.body = [Vector2i(5, 5), Vector2i(5, 6), Vector2i(6, 6), Vector2i(6, 5)]
	session.turn(Vector2i.RIGHT)
	session.tick()
	assert_true(not session.over)
	assert_eq(session.dragon.body[0], Vector2i(6, 5))
