(import-macros {: inspect : defns : div} :source.lib.macros)

(defns :track [gfx playdate.graphics
               anim (require :source.lib.animation)
               ]
  (fn react! [{: state &as self}]
    )

  (fn update-car [{:state {: track : animation} &as self}]
    (self:setImage (animation:getImage))
    )

  (fn collisionResponse [self other]
    :slide
    )

  (fn add [{:state {: cars} &as self}]
    (icollect [_ x (ipairs cars)]
      (x:add)))

  (fn remove [{:state {: cars} &as self}]
    (icollect [_ x (ipairs cars)]
      (x:remove)))

  (fn build-car [{: track : car-num : x : y : image}]
    (let [sprite (gfx.sprite.new)
          anim (anim.new {: image :states [{:state :standing :start 1 :end 1}
                                           {:state :moving :start 1 :end 6 :delay (+ 250 (math.random 30 120))}]})
          ]
      (sprite:setCenter 0 0)
      (sprite:setSize 128 64)
      (sprite:moveTo (+ x (* 128 car-num)) y)
      (tset sprite :update update-car)
      (tset sprite :state {:animation anim : track })
      sprite
      ))

  (fn new! [x y {: width : height : fields : tile-w : tile-h : game-state &as extras}]
    (let [image (gfx.imagetable.new :assets/images/train-car)
          sprite (gfx.sprite.new)
          cars (fcollect [i 0 (div width 128)]
                 (build-car {:track sprite :car-num i : x : y : image})
                 )]
      (sprite:setCenter 0 0)
      (sprite:setSize width height)
      (sprite:moveTo x y)
      (sprite:setGroups [4])
      (sprite:setCollideRect 0 0 width height)
      (tset sprite :platform fields.platform)
      (tset sprite :train? true)
      (tset sprite :state {:state :present : cars})
      (tset sprite :real-add sprite.add)
      (tset sprite :add add)
      (tset sprite :real-remove sprite.remove)
      (tset sprite :remove remove)
      ;; (tset sprite :update update)
      (tset sprite :react! react!)
      sprite))
  )
