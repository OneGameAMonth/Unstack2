--  Unstack2 Menu
--
--  Copyright 2011-2013 Ananasblau.com. All rights reserved.

scene = storyboard.newScene('Menu')
widget = require "widget"
require 'field'

doBackgroundBlocks = true
last_background_blocks = 0

backgroundBlocks = (group) ->
  if not doBackgroundBlocks or (last_background_blocks and last_background_blocks + 2 > os.time())
    return false
  last_background_blocks = os.time()
  w = math.floor(display.contentWidth / game.block_size)
  h = math.floor(display.contentHeight / game.block_size)
  if group.field
    group.field\removeSelf()
  group.field = Field.random(group, 50, w, h)
  timer.performWithDelay 3000, -> backgroundBlocks(group)

-- Called when the scene's view does not exist:

scene.enterScene = (event) =>
  scene.background_group = display.newGroup()
  doBackgroundBlocks = true
  backgroundBlocks(scene.background_group)

  @view\insert(scene.background_group)
  y = display.contentHeight * 0.4
  play_button = widget.newButton({
    label: "Play Now",
    labelColor: { default: {0}, over: {0} },
    top: y,
    onRelease: ->
      storyboard.gotoScene("scenes.field", "fade", 50)
      analytics.newEvent("design", {event_id: "menu:play"})
      return true
  })

  play_button\setReferencePoint(display.CenterReferencePoint)
  play_button.x = display.contentWidth * 0.5
  y += play_button.height * 1.2

  games_button = widget.newButton({
    label: 'More games',
    top: y,
    onRelease: ->
      analytics.newEvent("design", {event_id: "menu:visit_more_games"})
      system.openURL( 'http://ananasblau.com/games?utm_source=unstack2&utm_medium=android&utm_term=main+menu&utm_campaign=games' )
  })
  games_button.x = play_button.x
  y += games_button.height * 1.2

  highscores_button = widget.newButton({
    label: 'Highscores',
    top: y,
    onRelease: ->
      storyboard.gotoScene("scenes.highscores", "fade", 50)
      analytics.newEvent("design", {event_id: "menu:highscores"})
      return true
  })
  highscores_button.x = play_button.x
  y += highscores_button.height * 1.2

  howto_button = widget.newButton({
    label: 'Howto play',
    top: y,
    onRelease: ->
      storyboard.gotoScene("scenes.howto", "fade", "50")
      analytics.newEvent("design", { event_id: "menu:howto"})
      return true
  })
  howto_button.x = play_button.x

  @view\insert(howto_button)
  @view\insert(highscores_button)
  @view\insert(games_button)
  @view\insert(play_button)

scene.exitScene = (event) ->
  doBackgroundBlocks = false

scene\addEventListener( "createScene", scene )
scene\addEventListener( "enterScene", scene )
scene\addEventListener( "exitScene", scene )

return scene

