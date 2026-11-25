# godot --always-on-top --path . --script res://tests/shop_shot.gd -- <out.png>
extends SceneTree

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var out: String = args[0] if args.size() > 0 else "/tmp/twofold/shop.png"
	await process_frame
	var game = load("res://Main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.draft()
	game.ui.selection = [0, 1]
	game.begin_run()
	for e in game.enemies: e.queue_free()
	game.enemies.clear()
	game.wave = game.wave_total - 1
	for i in 90: await process_frame
	await RenderingServer.frame_post_draw
	root.get_viewport().get_texture().get_image().save_png(out)
	quit()
