extends RefCounted

# Each set has a starter cast, a trait and an advanced cast.
const SETS = [
	["Volt", "57fbe2", "Arc lash", "Lightning jumps between three targets.", "Live wire", "Both starter powers recharge 12% faster.", "Thunderhead", "Call down a wide lightning strike."],
	["Cinder", "ff7545", "Firebrand", "Burst a fireball around the aim point.", "Hot hands", "Deal 15% more damage with both sets.", "Firestorm", "Ignite a field that burns in pulses."],
	["Glacier", "9edfff", "Ice lance", "Pierce a line of foes and slow them.", "Cold front", "All your power hits briefly slow foes.", "Whiteout", "Freeze enemies across a wide field."],
	["Gravity", "bf9cff", "Gravity well", "Pull nearby foes into one tight cluster.", "Event horizon", "Power marks last two seconds longer.", "Collapse", "Crush a cluster and drag survivors inward."],
	["Vector", "ffe17c", "Rail shot", "Fire a heavy, piercing kinetic beam.", "Momentum", "Run 18% faster.", "Rail fan", "Sweep three piercing rails in a fan."],
	["Echo", "ffa4ce", "Soundwave", "Strike a broad cone with a sonic wave.", "Feedback", "Each fusion restores 4 health.", "Aftershock", "Send a second wave through a resonant field."],
	["Fault", "eeb783", "Stone fist", "Raise jagged stone fists under a group.", "Bedrock", "Gain 25 maximum health.", "Earthsplitter", "Rip a long fault through the arena."],
	["Gale", "b4f4c0", "Gust blade", "Hurl a slicing gust that pushes foes back.", "Tailwind", "Dash recovers 30% faster.", "Cyclone", "Sweep a spiraling field around your target."],
	["Prism", "fff2a4", "Light fan", "Split light into three piercing rays.", "Refraction", "Both advanced casts recharge 20% faster.", "Sun pillar", "Focus a column of light onto the target."],
	["Rift", "de99ff", "Fold step", "Blink to the aim point and burst on arrival.", "Phase skin", "Remain invulnerable longer after a dash.", "Twin gates", "Blast enemies around you and your target."],
	["Thorn", "a2e16f", "Briar trap", "Root a cluster with a burst of thorns.", "Regrowth", "Recover 2 health when a foe falls.", "Wild garden", "Grow a rooting field with repeated strikes."],
	["Orbit", "89aeff", "Satellite", "Launch a ricocheting star at nearby foes.", "Satellite shield", "Take 18% less incoming damage.", "Starfall", "Drop a cluster of stars over a wide area."],
]
# A fusion pairs the primer (the set that marked the foe) with the finisher (the set that hit it).
# The primer picks the payload, the finisher picks the blast shape: name = PAYLOAD + SHAPE.
const PAYLOAD = [
	["STATIC", "stuns"],
	["MOLTEN", "sets foes burning"],
	["FROZEN", "freezes solid"],
	["HEAVY", "drags foes inward"],
	["KINETIC", "blasts foes away"],
	["RESONANT", "re-marks for another fusion"],
	["SEISMIC", "cracks armor (+35% damage taken)"],
	["HOWLING", "hurls foes outward and slows"],
	["RADIANT", "dazzles, cancelling attacks"],
	["PHASED", "refunds cooldowns and phases you"],
	["THORNED", "roots and heals you per foe"],
	["STELLAR", "spawns a seeking star per foe"],
]
const SHAPE = [
	["CHAIN", "Arcs through 4 foes"],
	["NOVA", "Huge explosion"],
	["SHATTER", "Six shards burst outward"],
	["COLLAPSE", "Implodes everything nearby"],
	["RAIL", "Pierces a line behind the target"],
	["ECHO", "Bursts twice"],
	["FISSURE", "Splits the ground in a line"],
	["CYCLONE", "Spins a wide gale ring"],
	["PRISM", "Splits into three rays"],
	["GATE", "Rips a rift back to you"],
	["BLOOM", "Spreads the mark to nearby foes"],
	["STARFALL", "Drops stars on the 3 nearest foes"],
]

static func fusion_name(primer: int, finisher: int) -> String:
	return PAYLOAD[primer][0] + " " + SHAPE[finisher][0]

static func fusion_text(primer: int, finisher: int) -> String:
	return SHAPE[finisher][1] + " and " + PAYLOAD[primer][1] + "."

const BASE_CD = [1.35,1.55,1.15,1.95,1.1,1.1,1.65,1.15,1.35,2.1,1.65,1.35]
const ROOMS = ["Switchyard", "Relay Deck", "Crown Reactor"]
const SHOP = [
	["Slipstream", "Dashing trims 0.7s off both starter cooldowns.", 6],
	["Shock relay", "Fusion blasts deal 12 extra damage to nearby foes.", 8],
	["Second wind", "Recover 24 health and gain 10 maximum health.", 5],
]
