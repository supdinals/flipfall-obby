# FLIPFALL — Gravity Flip Obby

[![make.fun bounty](https://make.fun/api/competitions/roblox-game-01/badge.svg)](https://make.fun/bounty/roblox-game-01)
[![built for make.fun](https://make.fun/api/competitions/roblox-game-01/badge-earned.svg)](https://make.fun/bounty/roblox-game-01)

**FLIPFALL** is a Roblox obby with one twist that changes everything: **gravity is yours to flip.**

Press **F** (or tap the **FLIP!** button) and your character's gravity reverses — you fall *up*, land on the ceiling, and walk on the underside of the world. And you are not the only thing that flips: every loose crate in the course carries the same force field, so flipping throws the crates to the ceiling with you. Use them to clear the Crate Gate.

## Why it's different

Most Roblox obbies are static jump courses, and most make.fun entries are neon arcade games. FLIPFALL's course is built around a physics mechanic:

- **Per-player gravity** via a `VectorForce` on each character (mass × 2g), with the character model rolled 180° so feet meet the ceiling.
- **Physics props flip too** — crates are unanchored parts with the same force applied.
- **The entire course is generated from Luau code** (`CourseBuilder.lua`) — no hand-placed parts, so the level design is readable, reviewable source.

## The course (9 stages)

0. **Spawn Plaza** — learn the flip.
1. **First Steps** — warm-up jumps.
2. **Ceiling Walk** — no floor: flip and walk the slab's underside.
3. **Lava Floor** — alternate between floor islands and ceiling ledges over lava.
4. **Moving Platform** — ride a sliding platform across a lava pit.
5. **Crate Gate** — crates jam the doorway; flip them to the ceiling to pass.
6. **Flip Pad Alley** — pads force your gravity up or down.
7. **The Shaft** — fall *up* a vertical shaft, ledge to ledge.
8. **The Gauntlet** — kill bars above and below; pick your surface.
9. **Finish** — stop the timer; best time goes on your leaderstats.

Checkpoints save per stage, lava and kill bricks respawn you at your last checkpoint, and the HUD timer starts at checkpoint 1.

## Play it

See **PLAY.json** for the live Roblox experience link (place + universe id).

## Build it yourself

Prerequisites: [Rojo](https://rojo.space/) 7.x and Roblox Studio.

```sh
rojo build default.project.json -o game.rbxl
```

Open `game.rbxl` in Roblox Studio, press Play to test, then **Publish to Roblox** as a **Public** experience.

## Source layout

| File | What it does |
|---|---|
| `src/server/Main.server.lua` | Entry point: builds the course, creates remotes, starts services |
| `src/server/CourseBuilder.lua` | Generates all 9 stages procedurally |
| `src/server/FlipService.lua` | The gravity-flip mechanic (characters + crates) |
| `src/server/GameService.lua` | Checkpoints, kill bricks, flip pads, movers, timer, finish |
| `src/client/FlipClient.client.lua` | F key + FLIP button, HUD timer, win banner |
| `src/shared/Config.lua` | Palette + physics constants |
| `main.ts` | make.fun grader entrypoint (node22) |

## License

MIT — see `LICENSE`.

*Built by an AI agent for the [make.fun](https://make.fun/bounty/roblox-game-01) roblox-game-01 bounty, for @mellow-finch-24.*
