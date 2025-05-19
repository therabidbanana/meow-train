(import-macros {: inspect : defns : div} :source.lib.macros)

(defns :pickup [gfx playdate.graphics
                passenger (require :source.game.entities.passenger)
                ]
  (fn react! [{: state &as self} $scene game-state]
    (let [will-spawn? (and (< state.spawn-timer 1)
                           (> (math.random 5 10) 5))
          new-timer (if (and (< state.spawn-timer 1) will-spawn?)
                        (* (math.random 30 45) 30)
                        (< state.spawn-timer 1)
                        (* (math.random 3 5) 30)
                        (- state.spawn-timer 1)
                        )
          sprites (icollect [_ x (ipairs (gfx.sprite.querySpritesInRect self.x self.y 16 16))]
                    (if (?. x :interact!) x))
          spawned-count (or (?. game-state :spawned-count) 0)
          ready? (?. game-state :ready)]
      (tset state :spawn-timer new-timer)
      (if (and will-spawn? (= (length sprites) 0) ready?)
          (let [passenger (passenger.new! self.x self.y spawned-count)
                spawned (+ 1 spawned-count)]
            (tset game-state :spawned-count spawned)
            (passenger:add)
            )
          )
      ))

  (fn draw [{: state &as self}]
    )

  (fn update [{: state &as self}]
    )

  (fn collisionResponse [self other]
    :overlap
    )

  (fn new! [x y {: width : height : fields : tile-w : tile-h : game-state &as extras}]
    (let [sprite (gfx.sprite.new)]
      (sprite:setCenter 0 0)
      (sprite:setSize width height)
      (sprite:moveTo x y)
      (sprite:setGroups [5])
      (sprite:setCollidesWithGroups [3])
      (sprite:setCollideRect 0 0 width height)
      (tset sprite :entrance fields.entrance)
      (tset sprite :collisionResponse collisionResponse)
      (tset sprite :pickup? true)
      (tset sprite :state {:spawn-timer (* 3 30) :spawned-count 0})
      (tset sprite :draw draw)
      (tset sprite :update update)
      (tset sprite :react! react!)
      sprite))
  )
