# Design

Fill this in as you go. Your partner, future teammates, and the review bot read it
to learn where your project is headed. Replace each _italic prompt_.

## Target

A little garden snake collects berries in a grassy field. Each berry adds one body
segment; moving through the 20x20 garden should feel cozy until the growing snake
has to navigate around itself and the walls.

## Menu choices

Two items from two different groups (see the D4 guide's "The menu" tab).

| Item | Group | Done when (in your words) |
| --- | --- | --- |
| _item_ | _group_ | _what you will be able to show_ |
| _item_ | _group_ | _what you will be able to show_ |

## Words we use

Each word your project uses, what it means, and where it lives in code. A few are
already here from the starter; keep them accurate as you change things.

| Word | Meaning | In code |
| --- | --- | --- |
| cell | one square of the grid | `Vector2i` |
| session | one run at the game, from the first tick until it ends; owns the board and the dragon | `Session` in `core/session.gd` |
| tick | one step of the rules; the dragon moves one cell | `Session.tick()`, `Dragon.tick()` |
| tile kind | what a cell is made of, such as `floor` or `wall` | `Board.TILES`, `TILES` in `tools/build_art.py` |
| piece | one model in the kit: head, straight, turn, tail | `Kit.Piece`, `PIECES` in `tools/build_art.py` |
| berry | food on a free garden cell; eating it adds one segment and one point | `Session.food`, `build_berry()` in `tools/build_art.py` |
| score | number of berries eaten in this run | `Session.score`, shown by `app/main.gd` |
| started | the first arrow key has been pressed; ticks now advance the snake | `Session.started` |
| crash | the head would enter a wall or an occupied body cell | `Session.tick()`, reported by `crashed` |
| signal | an event from the rules that the adapter listens to | `Session.ate`, `Session.crashed` |

## Where things live

`core/` owns grid movement, food placement, growth, collisions, and score without
depending on scene nodes. `app/` owns input, the clock, the camera, meshes, and HUD:
arrow keys call `Session.turn()`, each clock tick calls `Session.tick()`, and its
`ate` / `crashed` signals update the display.

## Adding a tile kind

_The steps a teammate would follow, naming your actual files._

## Patterns, and what they bought us

_Each pattern you used on purpose, where it is, and what it made easier (or harder).
Where a SOLID principle explains why it helped (for example, open/closed: a new tile
kind or powerup is added, not edited in), say which one._

## One idea we carried over

_Pick one idea you used earlier this quarter in TypeScript (for example a Command queue,
a core kept apart from the framework, data-driven content, or a boundary gate) and
describe its transfer at three levels:_

- _**The problem:** what goes wrong without it, in any engine or language._
- _**The practice:** what we do about it, the same here as in our TypeScript Demos._
- _**The mechanism:** how Godot, GDScript, or Blender does it, and what changed from
  TypeScript (what got easier, what got harder, what we had to give up)._

## Sources we relied on

Claims about how Godot or Blender behaves, checked against the documentation for the
versions we run (Godot 4.7, Blender 5.2). Add a row when a decision depends on one.

| Claim | Source (link) | How we checked it |
| --- | --- | --- |
| _what the tool does_ | _manual page or source file_ | _what we ran or looked at_ |
