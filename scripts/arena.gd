extends Node3D
const G = preload("res://scripts/geo.gd")
const PALETTES = [
	["2f626c","437982","72d6cd","152e42","ff9251"],
	["535377","66668a","bba6eb","252d48","ffab67"],
	["715147","8b6859","ffc484","3d323e","79ead7"],
]
var rng := RandomNumberGenerator.new()

func build(room: int) -> void:
	rng.seed = 7711 + room
	var colors = PALETTES[room]
	var slab := Color(colors[0])
	var tile := Color(colors[1])
	var edge := Color(colors[2])
	var iron := Color(colors[3])
	var signal_color := Color(colors[4])
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = iron.lightened(0.09)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("c6dded")
	env.ambient_light_energy = 0.85
	var world := WorldEnvironment.new()
	world.environment = env
	add_child(world)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-57,-28,-12)
	sun.light_energy = 1.0
	sun.light_color = Color("ffe6bd")
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 65
	add_child(sun)
	var side := DirectionalLight3D.new()
	side.rotation_degrees = Vector3(-22,144,0)
	side.light_color = Color("88dcff")
	side.light_energy = 0.38
	add_child(side)
	G.shape(self,"box",Vector3(0,-2.55,0),Vector3(28,4.5,19.4),iron)
	G.shape(self,"box",Vector3(0,-0.38,0),Vector3(28.3,0.28,19.7),edge)
	G.shape(self,"box",Vector3(0,-0.16,0),Vector3(28.5,0.28,20),slab)
	for x in range(-4,5):
		for z in range(-3,4):
			G.shape(self,"box",Vector3(x*3.12,-0.03,z*2.8),Vector3(3.09,0.06,2.77),tile.darkened(rng.randf_range(0.0,0.085)))
	for x in [-1,1]:
		G.shape(self,"box",Vector3(x*12.8,0.012,0),Vector3(0.05,0.015,16.8),edge)
		for z in range(-8,9,2):
			G.shape(self,"box",Vector3(x*13.35,0.018,z),Vector3(0.65,0.022,0.09),edge)
		for z in [-8.95,-4.5,4.5,8.95]:
			var post := Vector3(x*13.72,0,z)
			G.shape(self,"box",post+Vector3.UP*0.34,Vector3(0.86,0.67,1.16),iron)
			G.shape(self,"box",post+Vector3.UP*0.72,Vector3(0.74,0.09,0.9),slab)
			G.shape(self,"box",post+Vector3.UP*0.8,Vector3(0.18,0.09,0.7),signal_color,true)
	for z in [-1,1]:
		for x in [-9.8,0,9.8]:
			G.shape(self,"box",Vector3(x,0.012,z*8.6),Vector3(4.2,0.015,0.05),edge)
			for k in 7:
				var stripe := G.shape(self,"box",Vector3(x+(k-3)*0.26,0.025,z*9.25),Vector3(0.13,0.018,0.58),signal_color)
				stripe.rotation.y = -0.55
	G.shape(self,"ring",Vector3(0,0.016,0),Vector3(5.8,0.16,5.8),tile.lightened(0.12))
	for i in 2:
		var slash := G.shape(self,"box",Vector3((i-0.5)*0.64,0.025,0),Vector3(0.4,0.02,2.6),tile.lightened(0.14))
		slash.rotation.y = -0.46
	var label := Label3D.new()
	label.text="0%d" % (room+1)
	label.font_size=64
	label.pixel_size=0.038
	label.outline_size=0
	label.modulate=tile.lightened(0.3)
	label.rotation.x=-PI/2
	label.position=Vector3(-10.9,0.025,6.85)
	add_child(label)
	for i in 9:
		G.shape(self,"box",Vector3((i-4)*3.12,-1.4,9.8),Vector3(0.26,2.35,0.35),slab)
	for row in 3:
		for col in 17:
			var x := float(col-8)*4.2 + rng.randf_range(-1,1)
			var z := -15.0-row*8 + rng.randf_range(-1.5,1.5)
			building(Vector3(x,rng.randf_range(-8.5,-3.3)+row*0.55,z),iron,slab,edge)
	for side_sign in [-1,1]:
		for i in 11:
			building(Vector3(side_sign*rng.randf_range(17.5,24.0),rng.randf_range(-9,-4.8),-9+i*3.6),iron,slab,edge)
	for i in room+2:
		var at := Vector3(-7+i*(14.0/(room+1)),0,-10.4)
		G.shape(self,"hex",at+Vector3.UP*0.7,Vector3(1.35,1.5,1.35),iron)
		G.shape(self,"hex",at+Vector3.UP*1.55,Vector3(0.95,0.45,0.95),edge,true)
		G.shape(self,"hex",at+Vector3.UP*2.0,Vector3(1.04,0.5,1.04),iron)
		G.shape(self,"box",at+Vector3.UP*2.85,Vector3(0.1,1.4,0.1),slab)

func building(rooftop: Vector3, iron: Color, slab: Color, edge: Color) -> void:
	var w := rng.randf_range(2.1,3.9)
	var depth := rng.randf_range(2.1,3.8)
	var wall := iron.lerp(slab,rng.randf_range(0.16,0.45))
	G.shape(self,"box",rooftop-Vector3.UP*6,Vector3(w,12,depth),wall)
	G.shape(self,"box",rooftop,Vector3(w+0.23,0.18,depth+0.23),wall.lightened(0.09))
	G.shape(self,"box",rooftop+Vector3.UP*0.36,Vector3(w*0.52,0.76,depth*0.48),wall)
	for i in 3:
		G.shape(self,"box",rooftop+Vector3(0,-0.9-i*1.0,depth*0.5+0.018),Vector3(w*0.62,0.1,0.025),edge.darkened(0.4))
