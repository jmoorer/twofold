# Spike: the power list

**Status:** open
**Timebox:** 2 sessions (paper pass, then an in-game test of 2 sets)
**Source of truth for what ships today:** `scripts/powers.gd`

## Question

What is the full list of powers in each of the 12 sets, and how does a set grow during a run?

The spike is done when we can answer:

1. How many powers does a set hold, and how many does a run see?
2. What unlocks them: room clears, challenges, the shop, or a mix?
3. Does each set have a clear role, so picking 2 of 3 is a real choice?
4. Does every new power touch fusions, or are some plain stat bumps?
5. Is the list small enough to build and balance for the next slice?

## What exists today

Each set has 3 powers plus 2 fusion roles. Names only; numbers live in `powers.gd` and `combat.gd`.

| Set | Starter active | Starter passive | Advanced (unlocked by room clear) | As primer (marks) | As finisher (shape) |
|---|---|---|---|---|---|
| Volt | Arc lash | Live wire | Thunderhead | STATIC: stuns | CHAIN |
| Cinder | Firebrand | Hot hands | Firestorm | MOLTEN: burns | NOVA |
| Glacier | Ice lance | Cold front | Whiteout | FROZEN: freezes | SHATTER |
| Gravity | Gravity well | Event horizon | Collapse | HEAVY: drags in | COLLAPSE |
| Vector | Rail shot | Momentum | Rail fan | KINETIC: knockback | RAIL |
| Echo | Soundwave | Feedback | Aftershock | RESONANT: re-marks | ECHO |
| Fault | Stone fist | Bedrock | Earthsplitter | SEISMIC: armor crack | FISSURE |
| Gale | Gust blade | Tailwind | Cyclone | HOWLING: hurl + slow | CYCLONE |
| Prism | Light fan | Refraction | Sun pillar | RADIANT: cancels attacks | PRISM |
| Rift | Fold step | Phase skin | Twin gates | PHASED: refunds cooldowns | GATE |
| Thorn | Briar trap | Regrowth | Wild garden | THORNED: root + heal | BLOOM |
| Orbit | Satellite | Satellite shield | Starfall | STELLAR: seeking stars | STARFALL |

Unlocks today are fixed: room 1 clear gives the left set's advanced power, room 2 the right set's. The shop sells 3 set-agnostic skills.

## Proposal to test

[ASSUMPTION] numbers below are starting points to argue with, not decisions.

**Set size: 6 powers.** 1 starter active, 1 starter passive, then an unlock pool of 4:

- 2 actives (the current advanced power plus one alternative)
- 1 passive
- 1 **mutation**: changes that set's fusion payload or shape (the build-defining pick)

A run sees both starters of 2 sets (4 powers) and unlocks about 4 to 6 more, so it never sees everything.

**Unlock sources:**

| Source | Gives | Notes |
|---|---|---|
| Room clear | Choose 1 of 2 from your sets' unlock pools | The main growth path |
| Room challenge (one per room, shown at start) | 1 extra pick, or upgrades a power | e.g. 3 fusions, no hits taken, clear under 40 s |
| Shop (shards) | Set-agnostic skills, rerolls, a third active slot | Keeps shards useful when the pool is thin |

**Slots:** 2 starter actives (LMB, RMB) + 2 unlocked actives (Q, E). Unlocking a third active means replacing one. Passives are unlimited.

## Set roles (to keep the draft meaningful)

| Set | Role | Fantasy in one verb |
|---|---|---|
| Volt | Chain damage | jump |
| Cinder | Area burst, damage over time | ignite |
| Glacier | Hard control | freeze |
| Gravity | Grouping | pull |
| Vector | Long-range pierce | skewer |
| Echo | Repeat hits, fusion engine | resonate |
| Fault | Ground zones, armor break | crack |
| Gale | Spacing, mobility | shove |
| Prism | Precision multi-ray | split |
| Rift | Mobility, cooldown tempo | blink |
| Thorn | Sustain, root | entangle |
| Orbit | Auto-damage, defense | circle |

Check during the spike: no two sets share a role. Today Glacier and Thorn both root; Gravity and Gale both move foes. Decide whether that overlap is fine or one gets moved.

## Candidate unlocks (first pass)

One line each. Mark keep / cut / merge during the paper pass.

| Set | Alt active | Passive | Mutation |
|---|---|---|---|
| Volt | Ball lightning: slow orb that zaps foes it passes | Overcharge: every 4th cast chains twice as far | CHAIN shape arcs 7 foes |
| Cinder | Fire dash: dash leaves a burning trail | Kindling: burning foes take +20% from Volt and Gale | MOLTEN burns spread on death |
| Glacier | Ice wall: blocks shots for 4 s | Brittle: frozen foes shatter for bonus damage | FROZEN freeze lasts 2x, foes take +25% while frozen |
| Gravity | Singularity: hold-to-charge black hole | Mass: pulled foes collide for damage | COLLAPSE crushes foes into each other |
| Vector | Ricochet: rail bounces off arena walls | Focus: standing still charges the next shot | RAIL fires both ways |
| Echo | Sonic boom: cone that knocks back and marks | Encore: 15% chance any cast repeats | RESONANT marks last forever until fused |
| Fault | Pillar: raise a pillar enemies path around | Aftershock: dash end makes a small quake | FISSURE line leaves a hazard zone |
| Gale | Updraft: lift foes (stun), slam on landing | Second wind: extra dash charge | CYCLONE pulls in first, then hurls |
| Prism | Mirror: decoy that copies your next cast | Focal point: rays converging on one foe crit | PRISM splits into 5 rays |
| Rift | Recall: snap back to where you were 2 s ago | Phase strike: casts after a blink deal +30% | GATE leaves a portal that repeats fusions |
| Thorn | Vine lash: pull yourself to a foe | Bloom: kills drop healing seeds | BLOOM chains to a second wave of spread |
| Orbit | Moon shield: 3 orbiting blockers | Gravity well: stars curve to marked foes | STARFALL drops 6 stars |

## How to run the spike

1. **Paper pass (session 1):** go through the candidate table. Every kept power must pass all four:
   - it changes how you move or aim, not just a number
   - it hooks into fusions (makes marks, uses marks, or changes a fusion)
   - it fits in one sentence on a card
   - it has a different look from every other power in its set
2. **In-game test (session 2):** build Volt and Cinder to 6 powers each, with room-clear picks of 1 of 2. Play 5 runs and note which picks you always take, never take, or can't tell apart.
3. **Write down the answers** to the 5 questions above in this file, then set Status to closed.

## Risks

- **Content cost:** 12 sets x 6 powers = 72 powers, each with VFX. If too much, ship 6 sets for the next slice.
- **Balance:** 132 ordered fusions plus mutations. Keep fusion math shared (payload x shape) so balance happens on 24 behaviours, not 132.
- **Readability:** more powers means more on-screen noise. The mark ring and fusion name must stay readable.

## Follow-up once decided

Move set data out of the arrays in `powers.gd` into one Godot Resource per set (`PowerSet.tres` with `PowerDef` entries), so adding a power is a data edit.
