extends RefCounted
const P = preload("res://scripts/powers.gd")
var game

func _init(owner_game) -> void:
	game=owner_game

func nearest(p: Vector3, limit: float, exclude: Array=[]):
	var best=null
	for enemy in game.enemies:
		if enemy in exclude: continue
		var d:=p.distance_to(enemy.position)
		if d<limit:
			limit=d
			best=enemy
	return best

func cast(slot: int, aim: Vector3) -> void:
	var hand:=slot%2
	var id: int=game.chosen[hand]
	var adv:=slot>=2
	var c:=Color(P.SETS[id][1])
	var start: Vector3=game.hero.position
	var target: Vector3=game.bounded(aim)
	var snap=nearest(target,2.35)
	if snap: target=snap.position
	var dir:=start.direction_to(target)
	if dir.is_zero_approx(): dir=Vector3.FORWARD
	var muzzle:=start+Vector3.UP*1.1 + dir*0.46
	game.hero.punch[hand]=1
	game.hero.pop(0.22 if adv else 0.12)
	game.look=dir
	game.aim_hold=0.35
	game.sound.play_note("heavy" if adv else "cast",0.83+id*0.045)
	game.fx.burst(muzzle,c,5,0.65)
	game.fx.flash(muzzle,0.55 if adv else 0.32,c,0.12,adv)
	var damage:=30.0 if adv else 16.0
	if id in [4,6,9]: damage+=4
	if 1 in game.chosen: damage*=1.15
	if adv and id in [1,5,7,10]:
		game.fields.append({"p":target,"id":id,"c":c,"t":0.32,"left":3,"damage":damage*0.43})
	if adv and id in [0,2,3,5,8,11]:
		game.fx.beam(target+Vector3.UP*7,target,c,0.62,0.4)
		game.fx.flash(target+Vector3.UP*0.5,2.3,c,0.3)
		game.add_trauma(0.35)
		area(target,4.25,damage,id,c)
	elif adv and id==9:
		area(start,3.55,damage,id,c)
		area(target,3.55,damage,id,c)
		game.fx.arc(muzzle,target+Vector3.UP*0.8,c)
	elif (adv and id in [4,6]) or (not adv and id in [2,4,7,8]):
		var rays:=3 if id==8 or (adv and id==4) else 1
		var victims: Array=[]
		game.add_trauma(0.25 if adv else 0.08)
		for i in rays:
			var v:=dir.rotated(Vector3.UP,(i-(rays-1)*0.5)*0.25)
			var end:=start+v*23
			game.fx.beam(muzzle,end+Vector3.UP*0.88,c,0.52 if adv else 0.28,0.24)
			if id==6: game.fx.spires(start+v*5,c,2.8)
			for enemy in game.enemies.duplicate():
				if enemy in victims: continue
				var offset: Vector3=enemy.position-start
				var t:=offset.dot(v)
				if t>=-0.6 and t<=23 and (offset-v*t).length()<(1.45 if adv else 1.0):
					victims.append(enemy)
					strike(enemy,damage,id,c,v*(8.0 if id==7 else 2.0))
	elif not adv and id in [0,11]:
		var last:=muzzle
		var picked: Array=[]
		var e=nearest(target,3.1)
		while e!=null and picked.size()<(4 if id==11 else 3):
			var at: Vector3=e.position
			if id==0: game.fx.arc(last,at+Vector3.UP,c)
			else:
				game.fx.beam(last,at+Vector3.UP,c,0.25,0.22)
				game.fx.ring(at,0.85,c)
			picked.append(e)
			strike(e,damage,id,c,dir*1.6)
			last=at+Vector3.UP
			e=nearest(at,5.2,picked)
		if picked.is_empty(): game.fx.arc(muzzle,target+Vector3.UP,c)
	elif not adv and id==5:
		for i in 7:
			game.fx.beam(muzzle,start+dir.rotated(Vector3.UP,(i-3)*0.15)*7.1+Vector3.UP*0.7,c,0.13,0.23)
		for e in game.enemies.duplicate():
			var v: Vector3=e.position-start
			if v.length()<8.2 and (v.length()<1.8 or dir.dot(v.normalized())>0.83):
				strike(e,damage,id,c,dir*5)
	elif id==9:
		target=game.bounded(start+(target-start).limit_length(7))
		game.fx.ring(start,1.7,c)
		game.fx.flash(start+Vector3.UP,0.9,c,0.18,false)
		game.hero.position=target
		game.hero.pop(-0.3)
		game.invul=maxf(game.invul,0.28)
		game.fx.beam(muzzle,target+Vector3.UP*0.68,c,0.17,0.18)
		land(target,3.85 if adv else 2.75,damage,id,c,adv)
	else:
		var radius:=3.85 if adv or id==3 else 2.75
		game.fx.lob(muzzle,target+Vector3.UP*0.3,c,0.22 if adv else 0.16,2.4 if adv else 1.1,land.bind(target,radius,damage,id,c,adv))

func land(at: Vector3, radius: float, damage: float, id: int, c: Color, heavy: bool) -> void:
	if game.state!=game.State.FIGHT: return
	game.fx.flash(at+Vector3.UP*0.4,radius*0.55,c)
	game.add_trauma(0.3 if heavy else 0.12)
	area(at,radius,damage,id,c)

func area(center: Vector3, radius: float, damage: float, id: int,c: Color) -> void:
	game.fx.ring(center,radius,c)
	game.fx.burst(center+Vector3.UP*0.6,c,11,radius*0.64)
	if id in [2,6,10]: game.fx.spires(center,c,radius*0.74)
	for enemy in game.enemies.duplicate():
		if enemy.position.distance_to(center)<radius+0.45:
			var push: Vector3=center.direction_to(enemy.position)*2
			if id in [3,7]: push=-push*3.0
			strike(enemy,damage,id,c,push)

func strike(enemy, damage: float, id: int,c: Color,push: Vector3) -> void:
	if not enemy in game.enemies: return
	var fusion: bool=enemy.mark>=0 and enemy.mark!=id and enemy.mark_left>0
	if id==2 or 2 in game.chosen: enemy.slow=maxf(enemy.slow,1.65)
	if id==10: enemy.root_time=1.0
	if fusion:
		fuse(enemy,enemy.mark,id,damage,push)
		return
	enemy.marked(id,c,mark_time())
	game.damage_foe(enemy,damage,c,push)

func mark_time() -> float:
	return 5.5 if 3 in game.chosen else 3.5

func fuse(enemy, primer: int, finisher: int, damage: float, push: Vector3) -> void:
	var at: Vector3=enemy.position
	var c:=Color(P.SETS[finisher][1])
	var first:=Color(P.SETS[primer][1])
	enemy.mark=-1
	enemy.mark_left=0
	enemy.marker.visible=false
	game.combos+=1
	game.room_combos+=1
	game.add_trauma(0.5)
	game.hit_stop(0.08)
	game.punch_zoom(1.1)
	game.fx.word(at,P.fusion_name(primer,finisher),c.lerp(first,0.35),true)
	game.fx.flash(at+Vector3.UP,2.2,c.lerp(first,0.5),0.32)
	game.fx.ring(at,4.2,first,0.5)
	game.fx.ring(at,2.5,c,0.28)
	game.fx.burst(at+Vector3.UP,c,12,2.4)
	game.fx.burst(at+Vector3.UP*1.3,first,9,2.0)
	game.sound.play_note("fusion",0.9+0.02*primer+0.025*finisher)
	if 5 in game.chosen: game.heal(4)
	var splash:=14.0+(12.0 if 1 in game.skills else 0.0)
	var hits:=blast(finisher,enemy,at,c)
	payload(primer,enemy,at,first,true)
	for other in hits:
		if not other in game.enemies: continue
		payload(primer,other,at,first,false)
		game.damage_foe(other,splash,c,Vector3.ZERO)
	game.damage_foe(enemy,damage+16.0,c,push,false)
	var remark: Array=[]
	if primer==5: remark=hits+[enemy]
	elif finisher==10: remark=hits
	for other in remark:
		if other in game.enemies: other.marked(primer,first,mark_time())

func within(p: Vector3, radius: float, skip) -> Array:
	return game.enemies.filter(func(o): return o!=skip and o.position.distance_to(p)<radius+0.45)

func line(a: Vector3, dir: Vector3, length: float, width: float, skip) -> Array:
	var out: Array=[]
	for o in game.enemies:
		if o==skip: continue
		var offset: Vector3=o.position-a
		var t:=offset.dot(dir)
		if t>=-0.5 and t<=length and (offset-dir*t).length()<width: out.append(o)
	return out

func rays(at: Vector3, dirs: Array, length: float, width: float, c: Color, skip) -> Array:
	var out: Array=[]
	for d: Vector3 in dirs:
		game.fx.beam(at+Vector3.UP*0.9,at+d*length+Vector3.UP*0.9,c,0.38,0.28)
		for o in line(at,d,length,width,skip):
			if not o in out: out.append(o)
	return out

# Finisher decides the shape: returns the other foes the fusion reaches.
func blast(shape: int, enemy, at: Vector3, c: Color) -> Array:
	var up:=Vector3.UP
	var hero: Vector3=game.hero.position
	var away:=hero.direction_to(at)
	if away.is_zero_approx(): away=Vector3.FORWARD
	var hit: Array=[]
	match shape:
		0:
			var last:=at
			var e=nearest(at,5.5,[enemy])
			while e!=null and hit.size()<4:
				game.fx.arc(last+up,e.position+up,c)
				hit.append(e)
				last=e.position
				e=nearest(last,5.5,hit+[enemy])
		1:
			game.fx.flash(at+up*0.6,3.4,c,0.4)
			game.fx.ring(at,5.0,c,0.45)
			game.fx.burst(at+up,c,18,3.2)
			game.add_trauma(0.25)
			hit=within(at,5.0,enemy)
		2:
			var dirs: Array=[]
			for i in 6: dirs.append(away.rotated(up,i*TAU/6))
			hit=rays(at,dirs,7.0,1.1,c,enemy)
		3:
			hit=within(at,6.5,enemy)
			for o in hit:
				game.fx.beam(o.position+up*0.8,at+up*0.8,c,0.22,0.3)
				o.knock+=o.position.direction_to(at)*11
			game.fx.ring(at,6.5,c,0.2)
		4:
			hit=rays(at-away*0.5,[away],20.0,1.3,c,enemy)
			game.fx.beam(at+up*0.9,at+away*20+up*0.9,Color("fff5da"),0.7,0.18)
		5:
			hit=within(at,3.8,enemy)
			game.fx.ring(at,3.8,c)
			var fx=game.fx
			var tw: Tween=fx.create_tween()
			tw.tween_interval(0.35)
			tw.tween_callback(func() -> void:
				if game.state!=game.State.FIGHT: return
				fx.ring(at,4.6,c,0.4)
				fx.flash(at+up,1.8,c,0.25,false)
				game.add_trauma(0.2)
				game.sound.play_note("heavy",1.3)
				for o in game.enemies.duplicate():
					if o.position.distance_to(at)<4.6: game.damage_foe(o,12,c,at.direction_to(o.position)*3))
		6:
			for i in 6: game.fx.spires(at+away*(i*1.6),c,0.9)
			hit=line(at-away,away,10.0,1.4,enemy)
		7:
			game.fx.ring(at,4.8,c,0.5)
			game.fx.ring(at,3.0,c,0.35)
			game.fx.burst(at+up*0.5,c,14,2.8)
			hit=within(at,4.8,enemy)
			for o in hit: o.knock+=at.direction_to(o.position)*10
		8:
			var base:=randf()*TAU
			hit=rays(at,[away.rotated(up,base),away.rotated(up,base+TAU/3),away.rotated(up,base-TAU/3)],12.0,1.1,c,enemy)
		9:
			var back:=at.direction_to(hero)
			game.fx.beam(at+up,hero+up,c,0.55,0.32)
			game.fx.ring(hero,3.0,c)
			hit=line(at,back,at.distance_to(hero),1.5,enemy)
			for o in within(hero,3.0,enemy):
				if not o in hit: hit.append(o)
		10:
			hit=within(at,5.0,enemy)
			for o in hit:
				game.fx.spires(o.position,c,0.8)
				o.root_time=maxf(o.root_time,0.8)
		11:
			var pool:=within(at,8.0,enemy)
			pool.sort_custom(func(a,b): return a.position.distance_to(at)<b.position.distance_to(at))
			for o in pool.slice(0,3):
				game.fx.beam(o.position+up*7,o.position,c,0.5,0.35)
				game.fx.flash(o.position+up*0.5,1.0,c,0.2,false)
				hit.append(o)
	return hit

# Primer decides the payload applied to every foe the blast reaches.
func payload(primer: int, e, at: Vector3, c: Color, main: bool) -> void:
	var up:=Vector3.UP
	match primer:
		0:
			e.root_time=maxf(e.root_time,0.9)
			game.fx.arc(e.position+up*1.8,e.position+up*0.4,c)
		1:
			e.burn=3.2
			e.burn_tick=0.2
		2:
			e.root_time=maxf(e.root_time,1.8)
			e.slow=maxf(e.slow,3.5)
			game.fx.spires(e.position,c,0.6)
		3:
			if not main: e.knock+=e.position.direction_to(at)*10
		4:
			e.knock+=game.hero.position.direction_to(e.position)*(16.0 if main else 10.0)
		6:
			e.vuln=4.0
			game.fx.spires(e.position,c,0.7)
		7:
			e.knock+=(game.hero.position.direction_to(e.position)*8.0) if main else (at.direction_to(e.position)*12.0)
			e.slow=maxf(e.slow,2.5)
		8:
			e.dazzle()
			game.fx.flash(e.position+up*1.2,0.6,c,0.18,false)
		9:
			if main:
				game.invul=maxf(game.invul,0.7)
				for i in 4: game.cool[i]=maxf(0,game.cool[i]-0.8)
				game.fx.ring(game.hero.position,1.6,c)
		10:
			e.root_time=maxf(e.root_time,1.4)
			game.heal(2)
		11:
			var t=nearest(e.position,7.0,[e])
			if t:
				game.fx.beam(e.position+up,t.position+up,c,0.25,0.25)
				game.damage_foe(t,8,c,Vector3.ZERO)
