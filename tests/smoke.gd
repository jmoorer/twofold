# godot --headless --path . --script res://tests/smoke.gd
extends SceneTree

var failed := 0

func _initialize() -> void:
	await process_frame
	var game = load("res://Main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	if not await all_fusions(game):
		failed += 1
	for pair in [[0,1],[2,3],[4,5],[6,7],[8,9],[10,11]]:
		if not await run_pair(game, pair):
			failed += 1
	game.title()
	print("Results: %d failed" % failed)
	quit(1 if failed > 0 else 0)

func check(ok: bool, label: String) -> void:
	if not ok:
		failed += 1
		push_error("FAIL " + label)

func all_fusions(game) -> bool:
	game.draft()
	game.ui.selection = [0, 1]
	game.begin_run()
	var fired := 0
	for primer in 12:
		for finisher in 12:
			if primer == finisher: continue
			game.hp = game.max_hp
			if game.enemies.size() < 3: game.spawn_wave()
			game.combat.fuse(game.enemies[0], primer, finisher, 10.0, Vector3.ZERO)
			fired += 1
			for i in 3: await physics_frame
	for i in 40: await physics_frame
	check(fired == 132, "all 132 fusions fired")
	check(game.state == game.State.FIGHT or game.state == game.State.SHOP, "fight survived fusions")
	return true

func run_pair(game, pair: Array) -> bool:
	game.draft()
	game.ui.selection = pair.duplicate()
	game.begin_run()
	check(game.state == game.State.FIGHT, "fight starts %s" % [pair])
	game.unlocked = [true, true]
	for room in 3:
		for frame in 2400:
			if game.state != game.State.FIGHT: break
			game.hp = game.max_hp
			for slot in 4:
				if game.cool[slot] <= 0 and not game.enemies.is_empty():
					game.trigger(slot, game.enemies[0].position)
			await physics_frame
		check(game.state in [game.State.SHOP, game.State.WIN], "room %d cleared %s (state %d)" % [room, pair, game.state])
		if game.state == game.State.SHOP:
			game.coins = 99
			for i in 3: game.buy(i)
			game.next_room()
			game.unlocked = [true, true]
	check(game.state == game.State.WIN, "run won %s" % [pair])
	check(game.combos > 0, "fusions fired %s" % [pair])
	await create_timer(0.3, true, false, true).timeout
	check(Engine.time_scale == 1.0, "time scale restored %s" % [pair])
	print("pair %s: kills %d fusions %d" % [pair, game.kills, game.combos])
	return true
