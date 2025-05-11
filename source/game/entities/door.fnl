(import-macros {: inspect : defns : div} :source.lib.macros)

(defns :door [gfx playdate.graphics]
  (fn react! [{: state &as self}]
    )
  (fn draw [{: state &as self}]
    )
  (fn update [{: state &as self}]
    )

  (fn collisionResponse [self other]
    :overlap
    )

  (fn new! [x y {: width : height : fields : tile-w : tile-h : game-state &as extras}]
    (let [door (gfx.sprite.new)]
      (door:setCenter 0 0)
      (door:setSize width height)
      (door:moveTo x y)
      (door:setGroups [3])
      (door:setCollideRect 0 0 width height)
      (tset door :level fields.level)
      (tset door :current fields.current)
      (tset door :exit {:x (* tile-w fields.exit.cx)
                        :y (* tile-h fields.exit.cy)})
      (tset door :door? true)
      (tset door :state {})
      (tset door :draw draw)
      (tset door :update update)
      (tset door :react! react!)
      door))
  )
