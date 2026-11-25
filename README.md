# Twofold

Superpower roguelike in Godot 4.7. Draft two of three offered power sets, mark enemies with one and hit them with the other to trigger fusions, and fight through three rooms to the Crown Reactor.

**Play in the browser:** https://jmoorer.github.io/twofold/

Controls: WASD to move, mouse to aim, left and right click to cast, Q and E for unlocked powers, Space to dash, Esc to pause.

## Develop

```bash
godot --path .                                                         # run
godot --headless --fixed-fps 60 --path . --script res://tests/smoke.gd # tests
godot --headless --path . --export-release "Web" build/web/index.html  # web build
```

CI runs the smoke tests and the web export on every pull request; merges to `main` deploy to GitHub Pages.

- [Roadmap](docs/ROADMAP.md)
- [Power list spike](docs/spikes/power-list.md)

Fonts: Archivo, Archivo Black and JetBrains Mono, under the SIL Open Font License (`art/fonts/`).
