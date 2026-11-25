extends Node3D
const G = preload("res://scripts/geo.gd")
var body: Node3D
var arms: Array[Node3D] = []
var legs: Array[Node3D] = []
var cape: Node3D
var phase := 0.0
var punch := [0.0,0.0]
var squash: Tween

func pop(amount := 0.18) -> void:
	if squash: squash.kill()
	body.scale = Vector3(1.0+amount,1.0-amount,1.0+amount)
	squash = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	squash.tween_property(body,"scale",Vector3.ONE,0.2)

func flinch() -> void:
	pop(-0.2)

func build(colors: Array) -> void:
	var ink := Color("152740")
	var cream := Color("fff0cc")
	var orange := Color("ff6229")
	G.shape(self,"cyl",Vector3(0,0.025,0),Vector3(1.24,0.015,0.75),Color(0.04,0.08,0.14,0.34),true)
	body = G.pivot(self)
	G.shape(body,"hex",Vector3(0,1.09,0),Vector3(0.63,0.52,0.49),ink)
	G.shape(body,"box",Vector3(0,1.38,-0.02),Vector3(0.72,0.43,0.46),cream)
	var sash := G.shape(body,"box",Vector3(0,1.38,-0.25),Vector3(0.12,0.52,0.05),ink)
	sash.rotation.z=-0.52
	G.shape(body,"hex",Vector3(0,1.61,0),Vector3(0.65,0.18,0.58),orange)
	G.shape(body,"ball",Vector3(0,1.91,-0.03),Vector3(0.69,0.72,0.65),cream)
	G.shape(body,"box",Vector3(0,1.92,-0.293),Vector3(0.53,0.19,0.13),ink)
	G.shape(body,"box",Vector3(0,1.93,-0.365),Vector3(0.45,0.055,0.025),Color("4ff9d2"),true)
	G.shape(body,"hex",Vector3(0,0.9,0),Vector3(0.66,0.13,0.52),orange)
	cape = G.pivot(body,Vector3(0.13,1.63,0.21))
	var scarf := G.shape(cape,"box",Vector3(0.05,-0.15,0.44),Vector3(0.32,0.08,1),orange)
	scarf.rotation.x=0.3
	for i in 2:
		var sign_x := -1 if i==0 else 1
		var arm := G.pivot(body,Vector3(sign_x*0.42,1.48,0))
		arm.rotation.z = sign_x*0.14
		arms.append(arm)
		G.shape(arm,"ball",Vector3.ZERO,Vector3(0.37,0.39,0.44),cream)
		G.shape(arm,"hex",Vector3(0,-0.23,-0.05),Vector3(0.24,0.42,0.28),ink)
		G.shape(arm,"hex",Vector3(0,-0.4,-0.17),Vector3(0.39,0.34,0.43),colors[i])
		G.shape(arm,"box",Vector3(0,-0.4,-0.385),Vector3(0.22,0.1,0.03),colors[i].lightened(0.4),true)
		var leg := G.pivot(body,Vector3(sign_x*0.205,0.88,0))
		legs.append(leg)
		G.shape(leg,"hex",Vector3(0,-0.22,0),Vector3(0.3,0.48,0.34),ink)
		G.shape(leg,"hex",Vector3(0,-0.56,0),Vector3(0.27,0.36,0.32),cream)
		G.shape(leg,"box",Vector3(0,-0.76,-0.06),Vector3(0.32,0.21,0.49),ink)

func pose(dt: float, move: float, direction: Vector3, dashing: bool) -> void:
	phase += dt*(4.0+move*9.0)
	body.position.y = (0.04+move*0.095)*absf(sin(phase))
	body.rotation.x = lerpf(body.rotation.x,-0.34 if dashing else -0.09*move, minf(1,dt*16))
	if direction.length_squared()>0.01:
		rotation.y = lerp_angle(rotation.y,atan2(-direction.x,-direction.z),minf(1,dt*17))
	cape.rotation.x = -0.25*move+sin(phase*1.2)*0.13
	cape.rotation.y = sin(phase*0.7)*0.2
	for i in 2:
		punch[i] = maxf(0,punch[i]-dt*4.8)
		var swing := sin(phase + i*PI)*move
		legs[i].rotation.x = swing*0.65
		arms[i].rotation.x = -swing*0.4+1.3*sin(float(punch[i])*PI*0.60)
