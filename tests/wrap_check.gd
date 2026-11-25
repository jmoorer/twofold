# godot --headless --path . --script res://tests/wrap_check.gd
extends SceneTree

func _initialize() -> void:
	await process_frame
	var game = load("res://Main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.draft()
	game.ui.selection = [0, 1]
	game.begin_run()
	game.clear_room()
	await process_frame
	var failed := 0
	for n in game.ui.get_children():
		if n is Label and n.autowrap_mode != TextServer.AUTOWRAP_OFF:
			print("%4d wide, %d lines: %s" % [n.size.x, n.get_line_count(), n.text.left(50)])
			if n.size.x > 1150 or (n.size.x > 340 and n.text.length() < 60): failed += 1
	quit(1 if failed > 0 else 0)
