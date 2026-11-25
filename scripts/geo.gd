extends RefCounted

static var materials := {}
static var shapes := {}

static func mat(c: Color, bright := false) -> StandardMaterial3D:
	var key := c.to_html() + str(bright)
	if materials.has(key):
		return materials[key]
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.roughness = 0.85
	if bright:
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	if c.a < 1.0:
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	materials[key] = m
	return m

static func shape(parent: Node3D, kind: String, p: Vector3, s: Vector3, c: Color, bright := false) -> MeshInstance3D:
	if not shapes.has(kind):
		var mesh: PrimitiveMesh
		match kind:
			"box": mesh = BoxMesh.new()
			"ball":
				mesh = SphereMesh.new()
				mesh.radial_segments = 10
				mesh.rings = 5
			"ring":
				mesh = TorusMesh.new()
				mesh.inner_radius = 0.46
				mesh.outer_radius = 0.5
				mesh.rings = 48
				mesh.ring_segments = 5
			_:
				mesh = CylinderMesh.new()
				mesh.radial_segments = 6 if kind == "hex" else 12
				mesh.top_radius = 0.0 if kind == "spike" else 0.5
				mesh.bottom_radius = 0.5
				mesh.height = 1
		shapes[kind] = mesh
	var node := MeshInstance3D.new()
	node.mesh = shapes[kind]
	node.material_override = mat(c, bright)
	node.position = p
	node.scale = s
	if bright or c.a < 1:
		node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(node)
	return node

static func link(parent: Node3D, a: Vector3, b: Vector3, width: float, c: Color, bright := false) -> MeshInstance3D:
	var v := b-a
	var n := shape(parent,"hex",(a+b)*0.5,Vector3.ONE,c,bright)
	if v.length_squared() > 0.00001:
		n.quaternion = Quaternion(Vector3.UP,v.normalized())
	n.scale = Vector3(width,maxf(v.length(),0.001),width)
	return n

static func pivot(parent: Node3D, p := Vector3.ZERO) -> Node3D:
	var n := Node3D.new()
	parent.add_child(n)
	n.position = p
	return n
