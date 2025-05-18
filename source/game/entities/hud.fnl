(import-macros {: inspect : defns : div} :source.lib.macros)

(defns :hud [gfx playdate.graphics]

  (fn react! [{:state {: player &as state} &as self}]
    (let [meter (math.floor (or player.state.meter 0))
          timer (math.floor (or (?. player.state.passenger :state :pickup-time) 0))
          score (math.floor (or player.state.score 0))
          misses (math.floor (or player.state.misses 0))
          active-timer? (or player.state.passenger false)
          ]
      (tset state :meter meter)
      (tset state :timer timer)
      (tset state :score score)
      (tset state :misses misses)
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
          rect (playdate.geometry.rect.new 300 2 100 20)]
      (gfx.setColor gfx.kColorWhite)
      (gfx.fillRoundRect rect 3)
      (gfx.setColor gfx.kColorBlack)
      (gfx.setLineWidth 1)
      (gfx.drawRoundRect rect 3)
      (gfx.drawText (.. seconds "s left") ;;(rect:insetBy 6 2)
                    306 4
                    )
      ))

  (fn draw-score [score-font score]
    (let [rect (playdate.geometry.rect.new 300 20 100 20)]
      (gfx.setColor gfx.kColorWhite)
      (gfx.fillRoundRect rect 3)
      (gfx.setColor gfx.kColorBlack)
      (gfx.setLineWidth 1)
      (gfx.drawRoundRect rect 3)
      (score-font:drawText (.. score) ;;(rect:insetBy 6 2)
                           306 24
                           )
      ))

  (fn draw-misses [score-font frown-image misses]
    (let [rect (playdate.geometry.rect.new 365 32 35 20)]
      (gfx.setColor gfx.kColorWhite)
      (gfx.fillRoundRect rect 3)
      (gfx.setColor gfx.kColorBlack)
      (gfx.setLineWidth 1)
      (gfx.drawRoundRect rect 3)
      (frown-image:drawImage 1 380 33)
      (score-font:drawText (.. misses) ;;(rect:insetBy 6 2)
                           370 36
                           )
      ))


  (fn draw [{:state {: player : score-font : score
                     : frown-image
                     : misses : meter : timer : active-timer?} &as self}]
    (draw-meter meter)
    (draw-score score-font score)
    (draw-misses score-font frown-image misses)
    (if active-timer?
        (draw-timer timer))
    )

  (fn update [{:state {: player} &as self}]
    (self:markDirty))
  (fn new! [player]
    (let [hud (gfx.sprite.new)
          frown-image (gfx.imagetable.new :assets/images/frown)
          score-font (gfx.font.new :assets/fonts/Nontendo-Bold)]
      (hud:setIgnoresDrawOffset true)
      (hud:setCenter 0 0)
      (hud:setSize 400 240)
      (hud:moveTo 0 0)
      (hud:setZIndex 100)
      (tset hud :state {: player : score-font :score 0 :misses 0 : frown-image})
      (tset hud :draw draw)
      (tset hud :update update)
      (tset hud :react! react!)
      hud))
  )
