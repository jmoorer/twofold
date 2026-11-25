extends Node3D
const G = preload("res://scripts/geo.gd")

func fade_scale(n: Node3D, end: Vector3, t: float) -> void:
	var tw := n.create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(n,"scale",end,t)
	tw.tween_callback(n.queue_free)

func ring(p: Vector3, radius: float, c: Color, t:=0.32) -> void:
	var n := G.shape(self,"ring",p+Vector3.UP*0.065,Vector3(0.2,0.14,0.2),c,true)
	var tw := n.create_tween().set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tw.tween_property(n,"scale",Vector3(radius*2,0.12,radius*2),t*0.78)
	tw.tween_property(n,"scale",Vector3(radius*2.07,0.005,radius*2.07),t*0.22)
	tw.tween_callback(n.queue_free)

func beam(a: Vector3,b: Vector3,c: Color,w:=0.18, t:=0.16) -> void:
	if a.distance_squared_to(b)<0.001: return
	var n := G.link(self,a,b,w,c,true)
	fade_scale(n,Vector3(0.002,n.scale.y,0.002),t)
	var line := G.link(self,a,b,w*0.36,Color("fff5da"),true)
	fade_scale(line,Vector3(0.002,line.scale.y,0.002),t*0.65)

func arc(a: Vector3,b: Vector3,c: Color) -> void:
	var last := a
	for i in range(1,7):
		var next := a.lerp(b,i/6.0)
		if i<6: next += Vector3(randf_range(-0.45,0.45),randf_range(-0.35,0.5),randf_range(-0.5,0.5))
		beam(last,next,c,0.18)
		last=next

func burst(p: Vector3,c: Color,count:=9,force:=1.5) -> void:
	for i in count:
		var dir := Vector3(cos(i*TAU/count),randf_range(0.15,0.9),sin(i*TAU/count)).normalized()
		var n := G.shape(self,"spike",p,Vector3.ONE,c if i%3 else Color("ffe9b6"),true)
		n.quaternion = Quaternion(Vector3.UP,dir)
		n.scale=Vector3(0.12,0.55,0.12)*minf(force,2.0)
		var t := n.create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		t.tween_property(n,"position",p+dir*randf_range(0.6,1.2)*force,0.25)
		t.tween_property(n,"scale",Vector3.ONE*0.012,0.34)
		t.chain().tween_callback(n.queue_free)

func spires(p: Vector3,c: Color,radius: float) -> void:
	for i in 8:
		var n := G.shape(self,"spike",p+Vector3(cos(i*2.4),0,sin(i*2.4))*radius*sqrt(i/9.0),Vector3(0.35,0.02,0.35),c)
		n.rotation.z=randf_range(-0.24,0.24)
		var tw := n.create_tween()
		tw.tween_property(n,"scale",Vector3(0.68,randf_range(1.5,3.3),0.68),0.1)
		tw.tween_property(n,"scale",Vector3.ONE*0.01,0.35)
		tw.tween_callback(n.queue_free)

func flash(p: Vector3, radius: float, c: Color, t:=0.24, light:=true) -> void:
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.albedo_color = Color(c.lerp(Color.WHITE,0.45),0.85)
	var n := G.shape(self,"ball",p,Vector3.ONE*radius*0.35,c,true)
	n.material_override = m
	var tw := n.create_tween().set_parallel(true).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tw.tween_property(n,"scale",Vector3.ONE*radius*2.0,t)
	tw.tween_property(m,"albedo_color:a",0.0,t)
	tw.chain().tween_callback(n.queue_free)
	if not light: return
	var o := OmniLight3D.new()
	o.light_color = c
	o.light_energy = 4.0
	o.omni_range = radius*3.0+1.5
	o.position = p+Vector3.UP*0.6
	add_child(o)
	var lt := o.create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	lt.tween_property(o,"light_energy",0.0,t*1.6)
	lt.tween_callback(o.queue_free)

func chunks(p: Vector3, c: Color, count:=8, force:=1.0) -> void:
	for i in count:
		var n := G.shape(self,"box",p+Vector3.UP*0.8,Vector3.ONE*randf_range(0.14,0.3),c if i%2 else c.darkened(0.45))
		var dir := Vector3(randf_range(-1,1),0,randf_range(-1,1)).normalized()*randf_range(1.2,3.2)*force
		var up := randf_range(1.0,2.4)*force
		var t := randf_range(0.45,0.7)
		var start := n.position
		var spin := Vector3(randf_range(-9,9),randf_range(-9,9),randf_range(-9,9))
		var tw := n.create_tween()
		tw.tween_method(func(k: float) -> void:
			n.position = start+dir*k+Vector3.UP*(up*4.0*k*(1.0-k)-0.75*k)
			n.rotation = spin*k, 0.0, 1.0, t).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
		tw.tween_property(n,"scale",Vector3.ONE*0.01,0.2)
		tw.tween_callback(n.queue_free)

func lob(a: Vector3, b: Vector3, c: Color, t: float, height: float, land: Callable) -> void:
	var n := G.shape(self,"ball",a,Vector3.ONE*0.6,c,true)
	G.shape(n,"ball",Vector3.ZERO,Vector3.ONE*0.55,Color("fff5da"),true)
	var tw := n.create_tween()
	tw.tween_method(func(k: float) -> void:
		n.position = a.lerp(b,k)+Vector3.UP*height*4.0*k*(1.0-k)
		trail(n.position,c), 0.0, 1.0, t)
	tw.tween_callback(func() -> void:
		land.call()
		n.queue_free())

func trail(p: Vector3, c: Color) -> void:
	var n := G.shape(self,"ball",p,Vector3.ONE*0.42,c,true)
	fade_scale(n,Vector3.ONE*0.02,0.22)

func word(p: Vector3, value: String, c: Color, big:=false) -> void:
	var n := Label3D.new()
	add_child(n)
	n.position = p+Vector3(randf_range(-0.18,0.18),1.75,0)
	n.text=value
	n.modulate=c
	n.billboard=BaseMaterial3D.BILLBOARD_ENABLED
	n.no_depth_test=true
	n.font_size=44 if big else 36
	n.pixel_size=0.013
	n.outline_size=8
	n.outline_modulate=Color("0a1525")
	n.scale=Vector3.ONE*(2.2 if big else 0.4)
	n.create_tween().tween_property(n,"scale",Vector3.ONE*(1.25 if big else 1.0),0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	var t:=n.create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.tween_property(n,"position",n.position+Vector3.UP*(1.2 if big else 0.8),0.58)
	t.tween_property(n,"modulate:a",0,0.25).set_delay(0.34)
	t.chain().tween_callback(n.queue_free)
