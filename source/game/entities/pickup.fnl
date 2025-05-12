(import-macros {: inspect : defns : div} :source.lib.macros)

(defns :pickup [gfx playdate.graphics]
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
    (let [sprite (gfx.sprite.new)]
      (sprite:setCenter 0 0)
      (sprite:setSize width height)
      (sprite:moveTo x y)
      (sprite:setGroups [3])
      (sprite:setCollideRect 0 0 width height)
      (tset sprite :entrance fields.entrance)
      (tset sprite :collisionResponse collisionResponse)
      (tset sprite :pickup? true)
      (tset sprite :state {})
      (tset sprite :draw draw)
      (tset sprite :update update)
      (tset sprite :react! react!)
      sprite))
  )
