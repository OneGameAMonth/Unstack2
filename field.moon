require 'block'

export class Field extends Block

  new: (shape, group, level, colors) =>
    @group = group
    @level = level
    @shape = shape
    @colors = colors
    @createRects()
    return @

  blockToRect: (x,y) ->
    return {
      (x - 1) * game.block_size + 1,
      (y - 1) * game.block_size + 1,
      game.block_size - 2,
      game.block_size - 2
    }


  removeSelf: =>
    for y, row in pairs(@shape)
      for x, block in pairs(row)
        if type(block) == 'table' and block.removeSelf
          block\removeSelf()

  createRects: =>
    for y, row in pairs(@shape)
      for x, block in pairs(row)
        if block
          @\createRect(x, y, block)

  createRect: (x, y, block) =>
    color_num = math.ceil(#@colors * math.random())
    color = @colors[color_num]
    @shape[y][x] = display.newRect(unpack(Field.blockToRect(x,y)))
    @shape[y][x]\setFillColor(color)
    @shape[y][x].blendMode = 'add'
    @shape[y][x].color_num = color_num
    trans_x = math.random() * x * 2 * game.block_size
    trans_y = math.random() * y * 2 * game.block_size
    transition.from(@shape[y][x], {
      time: 500, alpha: 0,
      width: game.block_size * 10,
      rotation: y - x,
      y: trans_y, x: trans_x})
    @group\insert(@shape[y][x])
    return @shape[y][x]

  random: (group, level, height, width) ->
    empty_tiles = math.min(math.max(level - 1, math.floor(level/(height + width))), (width + height) / 2)
    shape = {}
    for y=1, width do
      shape[y] = {}
      for x=1, height do
        -- TODO: Use simplex noise
        if empty_tiles > 0 and math.random() < 1/math.sqrt(x+x*y+level+empty_tiles+1)
          empty_tiles -= 1
        else
          shape[y][x] = 1

    return Field(shape, group, level)

  blocksLeft: () =>
    blocks_left = 0
    for y, row in pairs(@shape)
      for x, b in pairs(row)
        if b ~= nil and b ~= false
          blocks_left += 1
    return blocks_left
  substract: (block) =>
    field = @
    for y, row in pairs(block.shape)
      for x, b in pairs(row)
        if @shape[y] and @shape[y][x]
          transition.to(@shape[y][x], {
            time: 1000, alpha: 0,
            height: game.block_size * 2, width: game.block_size * 2,
            rotation: 20 - math.random() * 40,
            x: game.block_size * 5,
            y: 2 * -game.block_size,
            onComplete: ->
              timer.performWithDelay 1000, ->
                b = field\get(x,y)
                if b and b.removeSelf
                  b\removeSelf()
                field\set(x, y, nil)
          })

