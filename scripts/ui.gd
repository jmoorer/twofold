extends Control
const P = preload("res://scripts/powers.gd")
const Glyph = preload("res://scripts/glyph.gd")
const COVER = preload("res://art/title.png")
const INK=Color("#091422")
const PANEL=Color("#132538")
const LINE=Color("#365061")
const PAPER=Color("#fff1ce")
const MUTED=Color("#a9bec8")
const MINT=Color("#61f5cf")
const ORANGE=Color("#ff7945")
var game
const ARCHIVO = preload("res://art/fonts/Archivo.ttf")
const ARCHIVO_BLACK = preload("res://art/fonts/ArchivoBlack-Regular.ttf")
const JETBRAINS = preload("res://art/fonts/JetBrainsMono.ttf")
var regular:=FontVariation.new()
var heavy:=FontVariation.new()
var mono:=FontVariation.new()
var display:=FontVariation.new()
var hp_label: Label
var life: ColorRect
var enemies_label: Label
var currency: Label
var slot_status: Array[Label]=[]
var dash_status: Label
var hint: Label
var shop_note:=""
var selection:Array=[]
var launch: Button
var fusion_hint: Label
var cards:Array[Button]=[]
var card_tags:Array[Label]=[]
var card_panels:Array[ColorRect]=[]

func _ready() -> void:
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	regular.base_font=ARCHIVO
	regular.variation_opentype={"wght":540}
	heavy.base_font=ARCHIVO_BLACK
	mono.base_font=JETBRAINS
	mono.variation_opentype={"wght":650}
	for f: Font in [regular,heavy]: f.fallbacks=[mono]
	display.base_font=heavy
	display.variation_transform=Transform2D(Vector2(0.93,0),Vector2(-0.15,1),Vector2.ZERO)

func clear() -> void:
	for n in get_children():
		remove_child(n)
		n.queue_free()
	slot_status.clear()
	cards.clear()
	card_tags.clear()
	card_panels.clear()

func place(n: Control,x: float,y: float,w: float,h: float) -> void:
	n.position=Vector2(x,y)
	n.size=Vector2(w,h)
	n.mouse_filter=Control.MOUSE_FILTER_IGNORE

func rect(x: float,y: float,w: float,h: float,c: Color) -> ColorRect:
	var n:=ColorRect.new()
	n.color=c
	add_child(n)
	place(n,x,y,w,h)
	return n

func label(t: String,x: float,y: float,w: float,h: float,sz: int,c:=PAPER,f: Font=null,wrap:=false) -> Label:
	var n:=Label.new()
	if wrap: n.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	n.text=t
	n.add_theme_font_override("font",f if f else regular)
	n.add_theme_font_size_override("font_size",sz)
	n.add_theme_color_override("font_color",c)
	n.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
	add_child(n)
	place(n,x,y,w,h)
	return n

func body(t: String,x: float,y: float,w: float,h: float,sz:=18,c:=MUTED) -> Label:
	var n:=label(t,x,y,w,h,sz,c,null,true)
	n.vertical_alignment=VERTICAL_ALIGNMENT_TOP
	return n

func style(bg: Color, border: Color, width:=1) -> StyleBoxFlat:
	var b:=StyleBoxFlat.new()
	b.bg_color=bg
	b.border_color=border
	b.set_border_width_all(width)
	b.content_margin_left=16
	b.content_margin_right=16
	return b

func button(t: String,x: float,y: float,w: float,h: float, cb: Callable, accent:=false) -> Button:
	var b:=Button.new()
	add_child(b)
	place(b,x,y,w,h)
	b.mouse_filter=Control.MOUSE_FILTER_STOP
	b.mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
	b.text=t
	b.add_theme_font_override("font",heavy)
	b.add_theme_font_size_override("font_size",18)
	b.add_theme_color_override("font_color",INK if accent else PAPER)
	b.add_theme_color_override("font_hover_color",INK if accent else Color.WHITE)
	b.add_theme_color_override("font_pressed_color",INK if accent else PAPER)
	b.add_theme_color_override("font_focus_color",INK if accent else PAPER)
	b.add_theme_stylebox_override("normal",style(MINT if accent else PANEL,MINT if accent else LINE))
	b.add_theme_stylebox_override("hover",style(PAPER if accent else Color("#233e50"),PAPER if accent else MINT))
	b.add_theme_stylebox_override("pressed",style(ORANGE if accent else INK,ORANGE))
	b.add_theme_stylebox_override("disabled",style(Color("#23363f"),LINE))
	var focus:=style(Color.TRANSPARENT,PAPER,2)
	b.add_theme_stylebox_override("focus",focus)
	b.pressed.connect(cb)
	return b

func art(shade: float) -> void:
	var bg:=TextureRect.new()
	bg.texture=COVER
	bg.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED
	add_child(bg)
	place(bg,0,0,1280,720)
	if shade>0: rect(0,0,1280,720,Color(0.026,0.055,0.095,shade))

func header(kicker: String, title: String, sub: String) -> void:
	rect(66,55,29,4,MINT)
	label(kicker,106,36,840,42,14,MINT,mono)
	label(title,61,71,1140,86,58,PAPER,display)
	label(sub,66,159,1150,32,21,MUTED)

func intro() -> void:
	clear()
	art(0)
	rect(67,100,32,4,MINT)
	label("THREE-ROOM ROGUELIKE",111,82,385,40,15,MINT,mono)
	label("TWO",47,105,450,151,134,PAPER,display)
	label("FOLD",43,213,510,166,138,PAPER,display)
	rect(70,392,60,5,ORANGE)
	body("Draft two powers. Chain them together.\nFight your way to the Crown Reactor.",70,422,520,76,22,PAPER)
	var play:=button("PLAY    →",70,528,236,60,game.draft,true)
	play.grab_focus()
	label("WASD   MOVE       MOUSE   AIM       SPACE   DASH",70,650,650,32,13,MUTED,mono)

func glyph(id: int, x: float,y: float, extent: float) -> void:
	var g:=Glyph.new()
	g.id=id
	g.tint=Color(P.SETS[id][1])
	add_child(g)
	place(g,x,y,extent,extent)

func draft_screen() -> void:
	clear()
	art(0.94)
	header("POWER DRAFT","Choose your two.","The first pick goes on your left gauntlet. The second goes on your right.")
	for i in 3:
		var id: int=game.offer[i]
		var item: Array=P.SETS[id]
		var c:=Color(item[1])
		var x:=66+i*389
		cards.append(button("",x,218,370,351,toggle.bind(i)))
		rect(x+1,219,368,5,c)
		glyph(id,x+16,231,92)
		card_tags.append(label("",x+152,248,195,29,14,c,mono))
		card_tags[i].horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT
		label(item[0].to_upper(),x+21,321,333,41,32,PAPER,display)
		rect(x+22,378,324,1,LINE)
		label("ACTIVE  /  "+item[2],x+22,390,331,28,16,c,mono)
		body(item[3],x+22,424,323,46,17,PAPER)
		label("PASSIVE  /  "+item[4],x+22,484,331,27,16,c,mono)
		body(item[5],x+22,515,325,48,16,MUTED)
	launch=button("ENTER SWITCHYARD    →",846,604,368,58,game.begin_run,true)
	fusion_hint=label("",66,590,760,80,16,PAPER)
	update_draft()
	cards[0].grab_focus()

func toggle(i: int) -> void:
	var id: int=game.offer[i]
	if id in selection: selection.erase(id)
	elif selection.size()<2: selection.append(id)
	else: selection[1]=id
	game.sound.play_note("select")
	update_draft()

func update_draft() -> void:
	for i in 3:
		var idx:=selection.find(game.offer[i])
		var c:=Color(P.SETS[game.offer[i]][1])
		card_tags[i].text=["LEFT  /  01","RIGHT  /  02"][idx] if idx>=0 else "+  SELECT"
		var bg:=PANEL if idx<0 else PANEL.lerp(c,0.17)
		cards[i].add_theme_stylebox_override("normal",style(bg,c if idx>=0 else LINE,2))
		cards[i].add_theme_stylebox_override("hover",style(bg.lightened(0.07),c,2))
	if selection.size()==2:
		var a: int=selection[0]
		var b: int=selection[1]
		fusion_hint.text="FUSIONS    mark with one set, hit with the other\nL → R   %s:  %s\nR → L   %s:  %s" % [P.fusion_name(a,b),P.fusion_text(a,b),P.fusion_name(b,a),P.fusion_text(b,a)]
	else: fusion_hint.text="Land both sets on one foe to trigger a fusion.\nWhich set marks first changes what the fusion does."
	launch.disabled=selection.size()!=2
	launch.text="ENTER SWITCHYARD    →" if not launch.disabled else "PICK %d MORE" % (2-selection.size())

func hud() -> void:
	clear()
	rect(26,23,268,67,Color(0.035,0.07,0.12,0.94))
	rect(26,23,4,67,MINT)
	label("VITALITY",43,28,107,27,14,MUTED,mono)
	hp_label=label("",148,27,125,27,17,PAPER,heavy)
	hp_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT
	rect(44,62,230,9,LINE)
	life=rect(44,62,230,9,MINT)
	rect(461,22,358,58,Color(0.035,0.07,0.12,0.94))
	var room_text:=label("0%d  /  %s" % [game.room+1,P.ROOMS[game.room].to_upper()],470,24,340,31,20,PAPER,display)
	room_text.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	enemies_label=label("",467,53,346,22,13,MUTED,mono)
	enemies_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	rect(1079,23,174,43,Color(0.035,0.07,0.12,0.94))
	currency=label("",1091,26,151,35,16,PAPER,mono)
	currency.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	var keys:=["LMB","RMB","Q","E"]
	for i in 4:
		var id: int=game.chosen[i%2]
		var c:=Color(P.SETS[id][1])
		var x:=26+i*231
		var locked: bool=i>=2 and not game.unlocked[i-2]
		rect(x,633,221,65,Color(0.035,0.07,0.12,0.96))
		rect(x,633,221,3,LINE if locked else c)
		label(keys[i],x+12,641,50,20,13,MUTED if locked else c,mono)
		var status:=label("",x+59,641,149,20,13,MUTED,mono)
		status.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT
		slot_status.append(status)
		label(P.SETS[id][6 if i>=2 else 2],x+11,661,205,28,19,MUTED if locked else PAPER,heavy)
	dash_status=label("",977,633,274,29,16,PAPER,mono)
	dash_status.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT
	var pause_hint:=label("ESC   PAUSE",1032,672,218,20,13,MUTED,mono)
	pause_hint.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT
	hint=label("",235,89,810,40,17,PAPER,heavy)
	hint.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_constant_override("outline_size",5)
	hint.add_theme_color_override("font_outline_color",INK)

func update_hud() -> void:
	hp_label.text="%d / %d" % [ceili(game.hp),int(game.max_hp)]
	life.size.x=230.0*maxf(0,game.hp/game.max_hp)
	currency.text="%d  SHARDS" % game.coins
	enemies_label.text="WAVE %d / %d    •    %d FOES" % [game.wave+1,game.wave_total,game.enemies.size()]
	for i in 4:
		if i>=2 and not game.unlocked[i-2]:
			slot_status[i].text="CLEAR ROOM %d" % (i-1)
		else: slot_status[i].text="READY" if game.cool[i]<=0 else "%.1fs" % game.cool[i]
	dash_status.text="SPACE  /  DASH" if game.dash_cd<=0 else "DASH  /  %.1fs" % game.dash_cd
	hint.text=game.notice if game.notice_time>0 else ""

func shop() -> void:
	clear()
	art(0.94)
	var id: int=game.chosen[game.room]
	header("ROOM 0%d CLEARED    /    SKILL EXCHANGE" % (game.room+1),"Power unlocked.",P.SETS[id][6]+"   ·   "+P.SETS[id][7]+"   ["+["Q","E"][game.room]+"]")
	rect(66,216,1148,1,LINE)
	label("BUY A SKILL",66,232,480,41,22,PAPER,heavy)
	var balance:=label("%d  SHARDS" % game.coins,943,232,271,41,18,MINT,mono)
	balance.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT
	for i in 3:
		var x:=66+i*389
		var item: Array=P.SHOP[i]
		rect(x,298,370,192,PANEL)
		rect(x,298,370,3,MINT if i==game.room else LINE)
		label(item[0],x+18,313,334,44,27,PAPER,heavy)
		body(item[1],x+18,373,331,73,19)
		var owned: bool=i in game.skills
		var action:=button("ACQUIRED" if owned else "BUY   /   %d SHARDS" % item[2],x,451,370,46,game.buy.bind(i))
		action.disabled=owned or game.coins<item[2]
	body(shop_note,67,529,1120,55,18,MINT)
	var next:=button("ENTER "+P.ROOMS[game.room+1].to_upper()+"    →",803,606,411,56,game.next_room,true)
	next.grab_focus()

func end_screen(win: bool) -> void:
	clear()
	art(0.78)
	header("RUN COMPLETE" if win else "RUN ENDED","Reactor secured." if win else "Runner down.","%s  +  %s" % [P.SETS[game.chosen[0]][0],P.SETS[game.chosen[1]][0]])
	var stats:=["ROOMS CLEARED","FOES DEFEATED","FUSIONS"]
	var vals: Array=[3 if win else game.room,game.kills,game.combos]
	for i in 3:
		var x:=66+i*260
		rect(x,270,235,119,PANEL)
		label(str(vals[i]),x+17,277,198,65,47,PAPER,display)
		label(stats[i],x+18,347,200,25,14,MINT,mono)
	var again:=button("DRAFT AGAIN    →",66,471,290,57,game.draft,true)
	button("TITLE SCREEN",380,471,243,57,game.title)
	again.grab_focus()

func pause_screen() -> void:
	clear()
	rect(0,0,1280,720,Color(0.025,0.055,0.095,0.9))
	header("RUN PAUSED","Take a breath.","WASD or arrows to move. Aim with the mouse and hold either mouse button to cast.")
	body("J / K   Cast at the nearest foe\nQ / E   Use unlocked powers\nSpace   Dash through danger\nEsc       Resume",69,256,860,160,23,PAPER)
	var resume:=button("RESUME    →",68,494,250,57,game.resume,true)
	resume.grab_focus()
