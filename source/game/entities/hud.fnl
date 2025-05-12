(import-macros {: inspect : defns : div} :source.lib.macros)

(defns :hud [gfx playdate.graphics]

  (fn react! [{:state {: player &as state} &as self}]
    (let [meter (math.floor (or player.state.meter 0))
          timer (math.floor (or player.state.pickup-time 0))
          active-timer? (or player.state.picked-up false)
          ]
      (tset state :meter meter)
      (tset state :timer timer)
      (tset state :active-timer? active-timer?)
      ))

  (fn draw-meter [meter]
    (let [fill (* (/ meter 100) 220)
          rect (playdate.geometry.rect.new 0 10 8 220)
          bar (playdate.geometry.rect.new 2 13 4 fill)
          ]
      (gfx.setColor gfx.kColorWhite)
      (gfx.fillRoundRect rect 3)
      (gfx.setColor gfx.kColorBlack)
      (gfx.setLineWidth 1)
      (gfx.drawRoundRect rect 3)
      (gfx.fillRoundRect bar 3)
      ))

  (fn draw-timer [timer]
    (let [seconds (div timer 30)
          rect (playdate.geometry.rect.new 300 10 100 20)]
      (gfx.setColor gfx.kColorWhite)
      (gfx.fillRoundRect rect 3)
      (gfx.setColor gfx.kColorBlack)
      (gfx.setLineWidth 1)
      (gfx.drawRoundRect rect 3)
      (gfx.drawText (.. seconds "s left") ;;(rect:insetBy 6 2)
                    306 12
                    )
      ))

  (fn draw [{:state {: player : meter : timer : active-timer?} &as self}]
    (draw-meter meter)
    (if active-timer?
        (draw-timer timer))
    )

  (fn update [{:state {: player} &as self}]
    (self:markDirty))
  (fn new! [player]
    (let [hud (gfx.sprite.new)]
      (hud:setIgnoresDrawOffset true)
      (hud:setCenter 0 0)
      (hud:setSize 400 240)
      (hud:moveTo 0 0)
      (tset hud :state {: player})
      (tset hud :draw draw)
      (tset hud :update update)
      (tset hud :react! react!)
      hud))
  )
