extends Node3D
const P=preload("res://scripts/powers.gd")
const G=preload("res://scripts/geo.gd")
const Arena=preload("res://scripts/arena.gd")
const Runner=preload("res://scripts/runner.gd")
const Foe=preload("res://scripts/foe.gd")
const Effects=preload("res://scripts/fx.gd")
const Combat=preload("res://scripts/combat.gd")
const Overlay=preload("res://scripts/ui.gd")
const Sound=preload("res://scripts/audio.gd")
enum State {TITLE,DRAFT,FIGHT,SHOP,PAUSED,WIN,LOSS}
var state:=State.TITLE
var ui: Overlay
var sound: Sound
var arena: Arena
var hero: Runner
var fx: Effects
var camera: Camera3D
var reticle: MeshInstance3D
var combat: Combat
var offer:Array=[]
var chosen:Array=[]
var enemies:Array=[]
var shots:Array=[]
var fields:Array=[]
var skills:Array=[]
var unlocked:=[false,false]
var cool:=[0.0,0.0,0.0,0.0]
var hp:=100.0
var max_hp:=100.0
var coins:=0
var kills:=0
var combos:=0
var room_combos:=0
var room:=0
var wave:=0
var wave_total:=2
var wave_wait:=-1.0
var dash_cd:=0.0
var dash_left:=0.0
var dash_dir:=Vector3.FORWARD
var invul:=0.0
var trauma:=0.0
var shake_t:=0.0
var stop_id:=0
var zoom_tween: Tween
const CAM_SIZE:=19.4
var look:=Vector3.FORWARD
var aim_hold:=0.0
var aim:=Vector3.ZERO
var notice:=""
var notice_time:=0.0
var ui_tick:=0.0
var wait_mouse_release:=true
var cam_anchor:=Vector3(0,22,19)
var random:=RandomNumberGenerator.new()
const SPAWNS=[Vector3(-8,0,-4),Vector3(7,0,-5),Vector3(-10,0,2),Vector3(9,0,3),Vector3(1,0,-6),Vector3(-6,0,6),Vector3(6,0,6)]

func _ready() -> void:
	process_mode=Node.PROCESS_MODE_ALWAYS
	random.randomize()
	for pair in [["left",KEY_A,KEY_LEFT],["right",KEY_D,KEY_RIGHT],["up",KEY_W,KEY_UP],["down",KEY_S,KEY_DOWN],["dash",KEY_SPACE],["first",KEY_J],["second",KEY_K],["extra_left",KEY_Q],["extra_right",KEY_E]]:
		InputMap.add_action(pair[0])
		for code in pair.slice(1):
			var event:=InputEventKey.new()
			event.physical_keycode=code
			InputMap.action_add_event(pair[0],event)
	sound=Sound.new()
	add_child(sound)
	var layer:=CanvasLayer.new()
	add_child(layer)
	ui=Overlay.new()
	layer.add_child(ui)
	ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui.game=self
	combat=Combat.new(self)
	title()

func reset_world() -> void:
	release_time()
	enemies.clear()
	shots.clear()
	fields.clear()
	if is_instance_valid(arena):
		remove_child(arena)
		arena.queue_free()
	arena=null

func title() -> void:
	get_tree().paused=false
	state=State.TITLE
	reset_world()
	ui.intro()

func draft() -> void:
	get_tree().paused=false
	state=State.DRAFT
	reset_world()
	sound.play_note("select")
	var pool:=range(P.SETS.size())
	offer.clear()
	for i in 3: offer.append(pool.pop_at(random.randi_range(0,pool.size()-1)))
	ui.selection.clear()
	ui.draft_screen()

func begin_run() -> void:
	if state!=State.DRAFT or ui.selection.size()!=2: return
	chosen=ui.selection.duplicate()
	room=0
	coins=0
	kills=0
	combos=0
	skills.clear()
	unlocked=[false,false]
	max_hp=125.0 if 6 in chosen else 100.0
	hp=max_hp
	start_room()

func start_room() -> void:
	reset_world()
	state=State.FIGHT
	wave=0
	wave_total=2
	wave_wait=-1
	room_combos=0
	cool=[0.0,0.0,0.0,0.0]
	dash_left=0
	dash_cd=0
	invul=0.9
	trauma=0
	aim_hold=0
	look=Vector3.FORWARD
	wait_mouse_release=true
	arena=Arena.new()
	arena.process_mode=Node.PROCESS_MODE_PAUSABLE
	add_child(arena)
	arena.build(room)
	hero=Runner.new()
	arena.add_child(hero)
	hero.build([Color(P.SETS[chosen[0]][1]),Color(P.SETS[chosen[1]][1])])
	hero.position=Vector3(0,0,3.5)
	camera=Camera3D.new()
	arena.add_child(camera)
	camera.projection=Camera3D.PROJECTION_ORTHOGONAL
	camera.size=CAM_SIZE
	camera.position=cam_anchor
	camera.look_at(Vector3(0,0.52,0))
	camera.current=true
	fx=Effects.new()
	arena.add_child(fx)
	fx.flash(hero.position+Vector3.UP,1.4,Color("bdfbe8"),0.35)
	reticle=G.shape(arena,"ring",Vector3(0,0.045,0),Vector3(1.15,0.18,1.15),Color("fff0c7"),true)
	spawn_wave()
	ui.hud()
	ui.update_hud()
	say(["Hit a marked foe with your other gauntlet to fuse.","Q is live. Cast your new power at the cursor.","Both advanced powers are live. Defeat the Warden."][room],4.5)
	sound.play_note("clear",0.78+room*0.12)

func spawn_wave() -> void:
	var types: Array
	if room==0: types=[0,0,0] if wave==0 else [0,0,1]
	elif room==1: types=[0,1,0,1] if wave==0 else [1,0,1,0,0]
	else: types=[0,1,0,1] if wave==0 else [2,1,0]
	var spots:=SPAWNS.duplicate()
	for type in types:
		var index:=random.randi_range(0,spots.size()-1)
		var p: Vector3=spots.pop_at(index)
		if hero.position.distance_to(p)<4.5: p=bounded(-p)
		var e:=Foe.new()
		arena.add_child(e)
		e.position=p
		e.build(type,room)
		enemies.append(e)
		fx.ring(p,1.4,Color("ffaa75"),0.55)

func bounded(p: Vector3) -> Vector3:
	return Vector3(clampf(p.x,-12.5,12.5),0,clampf(p.z,-8.25,8.25))

func cursor() -> Vector3:
	var mouse:=get_viewport().get_mouse_position()
	var origin:=camera.project_ray_origin(mouse)
	var dir:=camera.project_ray_normal(mouse)
	return bounded(origin-dir*(origin.y/dir.y))

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode==KEY_ESCAPE:
		if state==State.FIGHT:
			release_time()
			state=State.PAUSED
			get_tree().paused=true
			ui.pause_screen()
		elif state==State.PAUSED: resume()
		elif state==State.DRAFT: title()
		get_viewport().set_input_as_handled()

func resume() -> void:
	get_tree().paused=false
	state=State.FIGHT
	wait_mouse_release=true
	ui.hud()
	ui.update_hud()

func _physics_process(dt: float) -> void:
	if state!=State.FIGHT: return
	aim=cursor()
	reticle.position=aim+Vector3.UP*0.049
	invul=maxf(0,invul-dt)
	dash_cd=maxf(0,dash_cd-dt)
	dash_left=maxf(0,dash_left-dt)
	aim_hold=maxf(0,aim_hold-dt)
	notice_time=maxf(0,notice_time-dt)
	for i in 4: cool[i]=maxf(0,cool[i]-dt)
	var input:=Input.get_vector("left","right","up","down")
	var move:=Vector3(input.x,0,input.y)
	if Input.is_action_just_pressed("dash") and dash_cd<=0:
		dash_dir=move if move.length_squared()>0.01 else hero.position.direction_to(aim)
		if dash_dir.is_zero_approx(): dash_dir=look
		dash_left=0.175
		dash_cd=1.15 if 7 in chosen else 1.65
		invul=0.48 if 9 in chosen else 0.25
		if 0 in skills:
			for i in 2: cool[i]=maxf(0,cool[i]-0.7)
		fx.burst(hero.position+Vector3.UP*0.5,Color("bdfbe8"),8,1.3)
		hero.pop(-0.25)
		sound.play_note("dash")
	if dash_left>0:
		var from:=hero.position
		hero.position=bounded(from+dash_dir*23*dt)
		fx.beam(from+Vector3.UP*0.78-dash_dir*0.7,hero.position+Vector3.UP*0.78,Color("bdfbe8"),0.21,0.17)
	else: hero.position=bounded(hero.position+move*(7.6 if 4 in chosen else 6.45)*dt)
	if aim_hold<=0:
		look=move if move.length_squared()>0.01 else hero.position.direction_to(aim)
	hero.pose(dt,move.length(),look,dash_left>0)
	var left:=Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	var right:=Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)
	if not left and not right: wait_mouse_release=false
	for i in 4:
		var key:=Input.is_action_pressed(["first","second","extra_left","extra_right"][i])
		var mouse_down:=not wait_mouse_release and ((i==0 and left) or (i==1 and right))
		if (key or mouse_down) and cool[i]<=0 and (i<2 or unlocked[i-2]):
			var target:=aim
			if key and i<2:
				var nearest=combat.nearest(hero.position,100)
				if nearest: target=nearest.position
			trigger(i,target)
	for e in enemies.duplicate():
		e.advance(dt,self)
		if state!=State.FIGHT: return
	update_shots(dt)
	if state!=State.FIGHT: return
	for field in fields.duplicate():
		field.t-=dt
		if field.t<=0:
			field.t=0.55
			combat.area(field.p,3.5,field.damage,field.id,field.c)
			field.left-=1
			if field.left<=0: fields.erase(field)
	if enemies.is_empty():
		if wave_wait<0: wave_wait=0.85
		wave_wait-=dt
		if wave_wait<=0:
			if wave+1<wave_total:
				wave+=1
				wave_wait=-1
				spawn_wave()
				say("Warden incoming" if room==2 else "Reinforcements incoming",1.6)
			else:
				clear_room()
				return
	var real_dt:=dt/maxf(Engine.time_scale,0.0001)
	trauma=maxf(0,trauma-real_dt*1.5)
	shake_t+=real_dt*30
	var s:=trauma*trauma
	camera.h_offset=0.7*s*sin(shake_t*1.7)
	camera.v_offset=0.5*s*sin(shake_t*2.3)
	ui_tick-=dt
	if ui_tick<=0:
		ui_tick=0.07
		ui.update_hud()

func add_trauma(amount: float) -> void:
	trauma=clampf(trauma+amount,0,1)

func hit_stop(duration: float, slow:=0.05) -> void:
	if Engine.time_scale<1.0: return
	stop_id+=1
	var mine:=stop_id
	Engine.time_scale=slow
	await get_tree().create_timer(duration,true,false,true).timeout
	if mine==stop_id: Engine.time_scale=1.0

func release_time() -> void:
	stop_id+=1
	Engine.time_scale=1.0

func punch_zoom(amount: float) -> void:
	if not is_instance_valid(camera): return
	if zoom_tween: zoom_tween.kill()
	camera.size=CAM_SIZE-amount
	zoom_tween=camera.create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	zoom_tween.tween_property(camera,"size",CAM_SIZE,0.4)

func trigger(slot: int,target: Vector3) -> void:
	var id: int=chosen[slot%2]
	cool[slot]=6.0*(0.8 if 8 in chosen else 1.0) if slot>=2 else float(P.BASE_CD[id])*(0.88 if 0 in chosen else 1.0)
	combat.cast(slot,target)

func damage_foe(e,amount: float,c: Color,push: Vector3,number:=true) -> void:
	if not e in enemies: return
	if e.vuln>0: amount*=1.35
	e.struck(amount,push)
	var at: Vector3=e.position
	fx.burst(at+Vector3.UP*0.9,c,5,1.0)
	if number: fx.word(at,str(roundi(amount)),Color("fff3d6"))
	if e.hp<=0:
		enemies.erase(e)
		e.queue_free()
		kills+=1
		coins+=2 if e.kind==2 else 1
		if 10 in chosen: heal(2)
		var boss: bool=e.kind==2
		fx.burst(at+Vector3.UP*0.65,Color("ffad70"),14 if boss else 10,2.1)
		fx.chunks(at,e.armor,22 if boss else 9,1.6 if boss else 1.0)
		fx.flash(at+Vector3.UP*0.8,2.6 if boss else 1.3,c)
		add_trauma(0.8 if boss else 0.22)
		hit_stop(0.22 if boss else 0.035)
		if boss: punch_zoom(2.2)
		sound.play_note("fall",0.7 if boss else 1.0)

func heal(amount: float) -> void:
	hp=minf(max_hp,hp+amount)

func hurt(amount: float) -> void:
	if invul>0 or state!=State.FIGHT: return
	hp=maxf(0,hp-amount*(0.82 if 11 in chosen else 1.0))
	invul=0.64
	add_trauma(0.45)
	hit_stop(0.06)
	hero.flinch()
	fx.flash(hero.position+Vector3.UP,1.0,Color("ff5a52"),0.2)
	fx.ring(hero.position,1.1,Color("ff7771"))
	fx.word(hero.position,"-"+str(roundi(amount*(0.82 if 11 in chosen else 1.0))),Color("ff9676"))
	sound.play_note("hurt")
	if hp<=0:
		state=State.LOSS
		ui.end_screen(false)

func fire_enemy(e,target: Vector3,fan: bool) -> void:
	var direction: Vector3=e.position.direction_to(target)
	if direction.is_zero_approx(): direction=Vector3.FORWARD
	var count:=3 if fan else 1
	for i in count:
		var v:=direction.rotated(Vector3.UP,(i-(count-1)*0.5)*0.23)
		var n:=G.shape(arena,"ball",e.position+Vector3.UP*0.65,Vector3(0.45,0.45,0.45),Color("ff8b52"),true)
		G.shape(n,"ring",Vector3.ZERO,Vector3(1.55,1,1.55),Color("ffe5a8"),true)
		shots.append({"node":n,"v":v*7.4,"ttl":3.8,"damage":11 if fan else 8})

func update_shots(dt: float) -> void:
	for s in shots.duplicate():
		var n: Node3D=s.node
		n.position+=s.v*dt
		s.ttl-=dt
		var hit:=Vector2(n.position.x-hero.position.x,n.position.z-hero.position.z).length()<0.67
		if hit: hurt(s.damage)
		if hit or s.ttl<=0 or absf(n.position.x)>15 or absf(n.position.z)>11:
			shots.erase(s)
			n.queue_free()

func say(message: String, duration: float) -> void:
	notice=message
	notice_time=duration

func clear_room() -> void:
	sound.play_note("clear")
	if room==2:
		state=State.WIN
		ui.end_screen(true)
		return
	state=State.SHOP
	unlocked[room]=true
	coins+=2
	ui.shop_note="Clear bonus   +2 shards"
	if room_combos>=2:
		coins+=3
		ui.shop_note+="      •      Fusion challenge   +3 shards (2+ fusions)"
	else: ui.shop_note+="      •      Land 2 fusions in a deck for 3 bonus shards."
	ui.shop()

func buy(index: int) -> void:
	if state!=State.SHOP or index<0 or index>=P.SHOP.size() or index in skills: return
	var cost: int=P.SHOP[index][2]
	if coins<cost: return
	coins-=cost
	skills.append(index)
	if index==2:
		max_hp+=10
		heal(24)
	sound.play_note("buy")
	ui.shop_note=P.SHOP[index][0]+" acquired."
	ui.shop()

func next_room() -> void:
	if state!=State.SHOP: return
	room+=1
	start_room()
