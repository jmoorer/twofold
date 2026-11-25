# Twofold roadmap

Superpower roguelike, 3/4 view. Draft 2 of 3 offered power sets (from 12), fuse them on enemies, grow your sets as you clear rooms.

Milestones run in order; each ends with something playable on the web build. Sizes are rough: S = a session, M = a few sessions, L = a week or more.

## M0: Vertical slice (done)

- [x] Title, draft 2 of 3 sets, 3 rooms with waves and a boss, win and loss screens
- [x] 12 sets, each with a starter active, a passive and an advanced power unlocked by a room clear
- [x] Fusions: primer payload x finisher shape, 132 named combos, preview on the draft screen
- [x] Juice: trauma shake, hit-stop, zoom punch, lobbed casts, flashes, squash and stretch, debris
- [x] Shop with 3 skills, fusion challenge bonus
- [x] Smoke tests over every set and every fusion
- [x] CI: tests, web export, GitHub Pages deploy

## M1: Feel and readability (S to M)

Driven by playtests of the slice.

- [ ] Tune fusion numbers; check whether the Echo re-mark loop is too strong
- [ ] Clear status visuals on enemies: frozen, burning, stunned, armor cracked
- [ ] Enemy telegraphs readable during big fusions
- [ ] Settings: shake strength, reduce flashing, volume
- [ ] Cut the first-cast hitch (shader warm-up for every effect)
- [ ] Short in-game tutorial prompt for marking and fusing

## M2: The power list (M to L)

Starts with the [power-list spike](spikes/power-list.md).

- [ ] Close the spike: set size, unlock sources, one role per set
- [ ] Move set data from `powers.gd` into one Resource per set
- [ ] Room-clear reward: pick 1 of 2 powers from your sets
- [ ] Room challenges (one per room) that grant an extra pick
- [ ] Mutations: one per set, changes that set's payload or shape
- [ ] Content: 6 sets at full size first, the other 6 after

## M3: Run structure (L)

- [ ] Room map with choices: fight, elite, shop, event
- [ ] 8 to 10 rooms per run across 2 floors, each floor ending in a boss
- [ ] Arena layouts with cover and hazards, generated from a seed
- [ ] Enemy roster: 6 to 8 types, elite modifiers, 2 bosses with phases
- [ ] Difficulty curve across the run

## M4: Economy and progression (M)

- [ ] Shop: set-agnostic skills, rerolls, heals, a third active slot
- [ ] Meta-progression: unlock sets and starting options across runs
- [ ] Save system for settings, unlocks and run history

## M5: Presentation (L)

- [ ] Hero and enemy models and animation (replace primitive meshes)
- [ ] VFX pass per set so every power has its own look
- [ ] Music and a full sound pass
- [ ] Menus: settings, run summary, set collection
- [ ] Gamepad support and rebinding

## M6: Ship (M)

- [ ] Desktop builds (Windows, macOS, Linux) from CI
- [ ] itch.io page, then a Steam page and demo
- [ ] Accessibility pass and performance budget on low-end hardware
