(import-macros {: inspect : defns : div} :source.lib.macros)

(defns :hud [gfx playdate.graphics]
  (fn react! [{:state {: player &as state} &as self}]
    (let [meter (math.floor (or player.state.meter 0))]
      (tset state :meter meter)))
  (fn draw [{:state {: player : meter} &as self}]
    (let [fill (* (/ meter 100) 220)
          rect (playdate.geometry.rect.new 0 0 8 220)
          bar (playdate.geometry.rect.new 2 3 4 fill)
          ]
      (gfx.setColor gfx.kColorWhite)
      (gfx.fillRoundRect rect 3)
      (gfx.setColor gfx.kColorBlack)
      (gfx.setLineWidth 1)
      (gfx.drawRoundRect rect 3)
      (gfx.fillRoundRect bar 3)
      ))
  (fn update [{:state {: player} &as self}]
    (self:markDirty))
  (fn new! [player]
    (let [hud (gfx.sprite.new)]
      (hud:setIgnoresDrawOffset true)
      (hud:setCenter 0 0)
      (hud:setSize 8 220)
      (hud:moveTo 380 10)
      (tset hud :state {: player})
      (tset hud :draw draw)
      (tset hud :update update)
      (tset hud :react! react!)
      hud))
  )
