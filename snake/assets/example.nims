import nicoscript
import std/random
const
  ScreenSize = 128
  TileCount = 16
  BlockSize = ScreenSize div TileCount
  MoveDelay = 0.1

type
  Direction = enum
    left, right, up, down
  Player = object
    blocks: seq[int]
    direction: Direction
    isDead: bool

proc init* = discard

proc input(player: var Player) =
  if btn(pcRight, 0):
    player.direction = right
  if btn(pcDown, 0):
    player.direction = down
  if btn(pcLeft, 0):
    player.direction = left
  if btn(pcUp, 0):
    player.direction = up

proc update(player: var Player, apple: int) =
  let lastBlock = player.blocks[^1]
  for x in countDown(player.blocks.high, 1):
    player.blocks[x] = player.blocks[x - 1]

  let offset =
    case player.direction
    of left:
      if player.blocks[0] mod TileCount == 0:
        player.isDead = true
      -1
    of right:
      if player.blocks[0] mod TileCount == TileCount - 1:
        player.isDead = true
      1
    of up:
      if player.blocks[0] div TileCount == 0:
        player.isDead = true
      -TileCount
    of down:
      if player.blocks[0] div TileCount == TileCount - 1:
        player.isDead = true
      TileCount

  player.blocks[0] += offset
  for i, x in player.blocks:
    if i > 0 and x == player.blocks[0]:
      player.isDead = true
      break

  if player.blocks[0] == apple:
    player.blocks.add lastBlock

proc draw(p: Player) =
  for blck in p.blocks:
    let
      x = blck mod TileCount * BlockSize
      y = blck div TileCount * BlockSize
    setColor(10)
    rectFill(x, y, x + BlockSize - 1, y + BlockSize - 1)

var
  player* = Player(isDead: true)
  apple* = -1
  moveTimer* = MoveDelay

proc spawnApple(player: Player): int =
  result = rand(0 ..< TileCount * TileCount)
  while result in player.blocks:
    result = rand(0 ..< TileCount * TileCount)

proc update*(dt: float32) =
  if player.isDead:
    player.blocks.setLen(1)
    player.blocks[0] = rand(0 ..< TileCount * TileCount)
    player.isDead = false
    apple = spawnApple(player)

  player.input()
  moveTimer -= dt
  if moveTimer <= 0:
    player.update(apple)
    moveTimer = MoveDelay
    if player.blocks.len == TileCount * TileCount - 1:
      player.isDead = true
    if player.blocks[0] == apple:
      apple = spawnApple(player)

proc drawApple() =
  let
    x = apple mod TileCount * BlockSize
    y = apple div TileCount * BlockSize
  setColor(3)
  rectFill(x, y, x + BlockSize - 1, y + BlockSize - 1)

proc draw*() =
  cls()
  player.draw()
  if apple >= 0:
    drawApple()

