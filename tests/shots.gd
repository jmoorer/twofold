# godot --path . --script res://tests/shots.gd -- <out_dir> <setA> <setB>
extends SceneTree

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var out: String = args[0] if args.size() > 0 else "/tmp/twofold"
	var pair := [int(args[1]), int(args[2])] if args.size() > 2 else [0, 1]
	DirAccess.make_dir_recursive_absolute(out)
	await process_frame
	var game = load("res://Main.tscn").instantiate()
	root.add_child(game)
	await frames(10)
	await snap(out + "/1_title.png")
	game.draft()
	game.ui.toggle(0)
	game.ui.toggle(1)
	await frames(5)
	await snap(out + "/2_draft.png")
	game.ui.selection = pair
	game.begin_run()
	game.unlocked = [true, true]
	var t0 := Time.get_ticks_msec()
	for i in 40:
		var f0 := Time.get_ticks_msec()
		await process_frame
		if Time.get_ticks_msec() - f0 > 50: print("frame %d took %d ms" % [i, Time.get_ticks_msec() - f0])
	print("40 frames: %d ms, hp %d" % [Time.get_ticks_msec() - t0, game.hp])
	await snap(out + "/3_room.png")
	var n := 0
	for f in 400:
		game.hp = game.max_hp
		for slot in 4:
			if game.cool[slot] <= 0 and not game.enemies.is_empty():
				game.trigger(slot, game.enemies[0].position)
		var f1 := Time.get_ticks_msec()
		await process_frame
		if Time.get_ticks_msec() - f1 > 50: print("fight frame %d took %d ms" % [f, Time.get_ticks_msec() - f1])
		if f in [4, 9, 30, 75, 140, 230]:
			n += 1
			await snap(out + "/4_fight_%d.png" % n)
	quit()

func frames(count: int) -> void:
	for i in count: await process_frame

func snap(path: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_viewport().get_texture().get_image().save_png(path)
