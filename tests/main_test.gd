extends "res://tests/test_case.gd"


func test_scene_shows_score_crash_and_restart_after_input() -> void:
	var game: Node3D = load("res://main.tscn").instantiate()
	Engine.get_main_loop().root.add_child(game)
	assert_eq(game.score_label.text, "Berries: 0")
	assert_true("Press an arrow key" in game.message_label.text)
	game._process(0.11)
	assert_eq(game.session.dragon.body[0], Vector2i(10, 10))

	game.session.food = Vector2i(11, 10)
	game._unhandled_input(_key(KEY_RIGHT))
	game._process(0.11)
	assert_eq(game.session.score, 1)
	assert_eq(game.score_label.text, "Berries: 1")
	assert_eq(game.session.dragon.body.size(), 5)

	for i in 8:
		game._process(0.11)
	assert_true(game.session.over)
	assert_true("Game over! Score: 1" in game.message_label.text)
	assert_eq(game.session.dragon.body[0], Vector2i(18, 10))

	game._unhandled_input(_key(KEY_SPACE))
	assert_true(not game.session.over)
	assert_true(not game.session.started)
	assert_eq(game.score_label.text, "Berries: 0")
	assert_true("Press an arrow key" in game.message_label.text)
	game._process(0.11)
	assert_eq(game.session.dragon.body[0], Vector2i(10, 10))
	game.free()


func _key(code: Key) -> InputEventKey:
	var event := InputEventKey.new()
	event.keycode = code
	event.pressed = true
	return event
