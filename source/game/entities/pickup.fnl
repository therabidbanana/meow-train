(import-macros {: inspect : defns : div} :source.lib.macros)

(defns :pickup [gfx playdate.graphics
                passenger (require :source.game.entities.passenger)
                ]
  (fn react! [{: state &as self}]
    (let [will-spawn? (and (< state.spawn-timer 1)
                           (> (math.random 5 10) 5))
          new-timer (if (and (< state.spawn-timer 1) will-spawn?)
                        (* (math.random 30 45) 30)
                        (< state.spawn-timer 1)
                        (* (math.random 5 15) 30)
                        (- state.spawn-timer 1)
                        )]
      (tset state :spawn-timer new-timer)
      (if will-spawn?
          (doto (passenger.new! self.x self.y)
            (: :add)))
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
      (sprite:setGroups [3])
      (sprite:setCollideRect 0 0 width height)
      (tset sprite :entrance fields.entrance)
      (tset sprite :collisionResponse collisionResponse)
      (tset sprite :pickup? true)
      (tset sprite :state {:spawn-timer (* 3 30)})
      (tset sprite :draw draw)
      (tset sprite :update update)
      (tset sprite :react! react!)
      sprite))
  )
