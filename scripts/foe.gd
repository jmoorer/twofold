extends Node3D
const G = preload("res://scripts/geo.gd")
var kind := 0
var hp := 42.0
var max_hp := 42.0
var cooldown := 1.0
var wind := 0.0
var goal := Vector3.ZERO
var knock := Vector3.ZERO
var slow := 0.0
var root_time := 0.0
var mark := -1
var mark_left := 0.0
var age := 0.0
var phase := 0.0
var hit := 0.0
var body: Node3D
var shell: MeshInstance3D
var marker: MeshInstance3D
var telegraph: MeshInstance3D
var hp_line: MeshInstance3D
var shell_mat: Material
var attack_number := 0
var armor := Color.WHITE
var base_scale := 1.0
var squash: Tween
var burn := 0.0
var burn_tick := 0.0
var vuln := 0.0

func dazzle() -> void:
	wind=0
	if is_instance_valid(telegraph): telegraph.queue_free()
	cooldown=maxf(cooldown,2.2)

func build(type: int, room: int) -> void:
	kind=type
	max_hp=[42.0,38.0,205.0][kind]+room*5.0
	hp=max_hp
	armor = Color(["d9604a","eab668","cb4759"][kind])
	var dark := Color("222b41")
	var light := Color("ffdd94")
	body=G.pivot(self)
	var size_factor := 1.65 if kind==2 else 1.0
	base_scale=size_factor
	body.scale=Vector3.ONE*size_factor
	G.shape(self,"cyl",Vector3(0,0.026,0),Vector3(1.45*size_factor,0.02,0.91*size_factor),Color(0.035,0.05,0.08,0.4),true)
	shell=G.shape(body,"hex",Vector3(0,1.0,0),Vector3(1.04,0.68,0.87),armor)
	shell_mat=shell.material_override
	G.shape(body,"hex",Vector3(0,1.36,0),Vector3(0.76,0.22,0.7),dark)
	G.shape(body,"box",Vector3(0,1.05,-0.43),Vector3(0.68,0.35,0.12),dark)
	G.shape(body,"box",Vector3(0,1.07,-0.505),Vector3(0.45,0.11,0.035),light,true)
	for s in [-1,1]:
		var limb:=G.shape(body,"box",Vector3(s*0.61,0.88,0),Vector3(0.35,0.61,0.58),dark)
		limb.rotation.z=s*0.28
		G.shape(body,"hex",Vector3(s*0.59,1.16,0),Vector3(0.42,0.28,0.56),armor)
		if kind!=1:
			G.link(body,Vector3(s*0.25,0.78,0),Vector3(s*0.47,0.27,0.12),0.25,dark)
			G.shape(body,"box",Vector3(s*0.46,0.22,-0.03),Vector3(0.33,0.26,0.51),armor)
		else:
			G.shape(body,"spike",Vector3(s*0.54,0.51,0),Vector3(0.25,0.45,0.25),light,true).rotation.x=PI
	if kind==2:
		for s in [-1,1]:
			G.shape(body,"spike",Vector3(s*0.36,1.67,0),Vector3(0.28,0.78,0.34),light)
	marker=G.shape(self,"ring",Vector3.UP*0.08,Vector3(1.85*size_factor,0.25,1.85*size_factor),light,true)
	marker.visible=false
	hp_line=G.shape(self,"box",Vector3(0,1.8*size_factor,0),Vector3(0.86,0.085,0.09),light,true)
	hp_line.visible=false
	phase=randf()*TAU
	cooldown=randf_range(0.8,1.4)

func marked(id: int,c: Color, duration: float) -> void:
	mark=id
	mark_left=duration
	marker.material_override=G.mat(c,true)
	marker.visible=true

func struck(damage: float, push: Vector3) -> void:
	hp-=damage
	knock+=push/(1.8 if kind==2 else 1.0)
	hit=0.11
	if squash: squash.kill()
	var k:=clampf(damage/40.0,0.12,0.35)
	body.scale=Vector3(1.0+k,1.0-k,1.0+k)*base_scale
	squash=create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	squash.tween_property(body,"scale",Vector3.ONE*base_scale,0.35)
	hp_line.visible=true
	hp_line.scale.x=maxf(0.015,0.86*hp/max_hp)

func advance(dt: float, game) -> void:
	age+=dt
	var dir: Vector3=game.hero.position-position
	var distance:=dir.length()
	dir=dir.normalized()
	hit=maxf(0,hit-dt)
	slow=maxf(0,slow-dt)
	root_time=maxf(0,root_time-dt)
	mark_left=maxf(0,mark_left-dt)
	vuln=maxf(0,vuln-dt)
	if burn>0:
		burn-=dt
		burn_tick-=dt
		if burn_tick<=0:
			burn_tick=0.4
			game.fx.burst(position+Vector3.UP*1.1,Color("ff7545"),3,0.6)
			game.damage_foe(self,5,Color("ff7545"),Vector3.ZERO)
			if not self in game.enemies: return
	if mark_left<=0:
		mark=-1
		marker.visible=false
	elif marker.visible:
		var pulse:=(1.85+0.22*sin(age*11.0))*base_scale
		marker.scale=Vector3(pulse,0.25+0.12*absf(sin(age*11.0)),pulse)
		marker.rotation.y+=dt*2.5
	shell.material_override=G.mat(Color("fff2ca"),true) if hit>0 else shell_mat
	position=game.bounded(position+knock*dt)
	knock=knock.move_toward(Vector3.ZERO,dt*22)
	body.position.y=absf(sin(age*6+phase))*0.12 + (0.21 if kind==1 else 0.0)
	if age<0.6: return
	if wind>0:
		wind-=dt
		if is_instance_valid(telegraph):
			telegraph.scale.y=0.12+0.25*absf(sin(wind*15))
		if wind<=0:
			if is_instance_valid(telegraph): telegraph.queue_free()
			if kind==1 or (kind==2 and attack_number%2==0):
				game.fire_enemy(self,goal,kind==2)
			else:
				var r:=3.15 if kind==2 else 1.85
				game.fx.ring(position,r,Color("ff8058"))
				game.fx.burst(position+Vector3.UP*0.4,Color("ffab69"),8,r*0.7)
				if game.hero.position.distance_to(position)<r+0.25:
					game.hurt(16 if kind==2 else 8)
			cooldown=[1.55,2.3,1.55][kind]
		return
	body.rotation.y=lerp_angle(body.rotation.y,atan2(-dir.x,-dir.z),minf(dt*8,1))
	cooldown-=dt
	var reach: float=[1.6,9.0,3.1][kind]
	if kind==2 and (attack_number+1)%2==0: reach=12.0
	if distance<reach and cooldown<=0 and root_time<=0 and hit<=0:
		attack_number+=1
		goal=game.hero.position
		wind=0.78 if kind==2 else 0.58
		var r:=3.15 if kind==2 else 1.85
		if kind==1 or (kind==2 and attack_number%2==0):
			telegraph=G.link(self,Vector3.UP*0.12,dir*distance+Vector3.UP*0.12,0.07,Color("ff8d72"),true)
		else:
			telegraph=G.shape(self,"ring",Vector3.UP*0.09,Vector3(r*2,0.16,r*2),Color("ff8964"),true)
		return
	if root_time>0: return
	var steer:=dir
	if kind==1 and distance<6.3: steer=-dir*0.7
	elif kind==1 and distance<8: steer=Vector3(dir.z,0,-dir.x)*sin(phase+age)*0.65
	for other in game.enemies:
		if other==self: continue
		var away: Vector3=position-other.position
		if away.length_squared()<1.95: steer+=away.normalized()*(1.45-away.length())*1.8
	var speed: float=[2.65,2.12,2.15][kind]
	position=game.bounded(position+steer.limit_length(1.25)*speed*(0.42 if slow>0 else 1.0)*dt)
