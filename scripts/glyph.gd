extends Control
var id:=0
var tint:=Color.WHITE
const ICONS = [
	[[-0.02,-0.95],[-0.78,0.13],[-0.18,0.13],[-0.37,0.92],[0.82,-0.32],[0.17,-0.32],[0.48,-0.95]],
	[[-0.64,0.25],[-0.44,-0.47],[-0.12,-0.12],[0.22,-0.95],[0.7,-0.17],[0.77,0.38],[0.34,0.83],[-0.26,0.8]],
	[[0,-0.98],[0.64,-0.19],[0.42,0.51],[0,0.96],[-0.48,0.48],[-0.65,-0.23]],
	[], [[-0.87,0.73],[-0.28,-0.19],[0.87,-0.84],[0.37,0.22]],
	[], [[-0.8,0.49],[-0.73,-0.34],[-0.15,-0.75],[0.52,-0.63],[0.88,-0.03],[0.34,0.65],[-0.39,0.79]],
	[], [[0,-0.85],[0.87,0.67],[-0.87,0.67]], [],
	[[-0.39,0.89],[-0.11,0.05],[-0.74,-0.28],[-0.28,-0.39],[0.51,-0.88],[0.26,-0.22],[0.81,-0.3],[0.26,0.27]],
	[]
]
func _draw() -> void:
	var r:=minf(size.x,size.y)*0.34
	var center:=size*0.5
	draw_circle(center,r*1.36,Color(tint,0.06),true,-1,true)
	draw_arc(center,r*1.33,-1.38,3.93,54,Color(tint,0.33),1.5,true)
	for i in 12:
		var v:=Vector2.RIGHT.rotated(i*TAU/12)
		draw_line(center+v*r*1.29,center+v*r*1.39,Color(tint,0.58),1.5,true)
	if not ICONS[id].is_empty():
		var pts:=PackedVector2Array()
		for p in ICONS[id]: pts.append(center+Vector2(p[0],p[1])*r)
		draw_colored_polygon(pts,tint)
		if id in [2,6,8]: draw_line(center+Vector2(-0.27,0.48)*r,center+Vector2(0.03,-0.45)*r,Color("17223a"),r*0.1,true)
	elif id in [3,11]:
		draw_circle(center,r*0.37,tint,true,-1,true)
		for j in 2:
			var pts:=PackedVector2Array()
			for i in 49:
				var a:=i*TAU/48
				pts.append(center+Vector2(cos(a)*r,sin(a)*r*0.38).rotated(-0.58+j*1.2))
			draw_polyline(pts,tint,r*0.11,true)
	elif id==5:
		for i in 5:
			var h:float=[0.25,0.66,0.95,0.61,0.29][i]
			draw_line(center+Vector2((i-2)*0.34,-h)*r,center+Vector2((i-2)*0.34,h)*r,tint,r*0.16,true)
	else:
		for i in 3:
			if id==9:
				draw_polyline(PackedVector2Array([center+Vector2(-0.7+i*0.39,-0.63)*r,center+Vector2(-0.21+i*0.39,0)*r,center+Vector2(-0.7+i*0.39,0.63)*r]),tint,r*0.12,true)
			else:
				draw_arc(center+Vector2((i-1)*0.2,(i-1)*0.38)*r,r*0.54,-1.8,2.9,25,tint,r*0.13,true)
