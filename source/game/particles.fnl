(import-macros {: inspect : defns : pd/import} :source.lib.macros)

(pd/import :CoreLibs/animation)
(pd/import :CoreLibs/easing)
(pd/import :CoreLibs/animator)

(let [gfx playdate.graphics
      animation  gfx.animation
      sprite gfx.sprite]

  (local state {:particles []})

  (fn draw-all []
    (let [transitioned (icollect [i particle (ipairs state.particles)]
                         (let [{: anim : x : y : ignore-offset} particle]
                           (if ignore-offset
                               (do
                                 (gfx.pushContext)
                                 (gfx.setDrawOffset 0 0)))
                           (particle.anim:draw x y)
                           (if ignore-offset (gfx.popContext))
                           (if (particle.anim:isValid) particle)))]
      (tset state :particles transitioned)))

  (fn clear-all []
    (tset state :particles []))

  (fn plus! []
    (let [image (gfx.imagetable.new :assets/images/plus)
          anim (gfx.animation.loop.new 150 image false)]
      (table.insert state.particles {:ignore-offset true : anim :x 280 :y 25})))

  (fn frown! []
    (let [image (gfx.imagetable.new :assets/images/frown)
          anim (gfx.animation.loop.new 150 image false)]
      (table.insert state.particles {:ignore-offset true : anim :x 348 :y 40})))

  (fn frustration! [x y]
    (let [image (gfx.imagetable.new :assets/images/frustration)
          anim (gfx.animation.loop.new 80 image false)]
      (table.insert state.particles {: anim :x (- x 8) :y (- y 16)})))

  (fn quest-bubble! [x y]
    (let [image (gfx.imagetable.new :assets/images/quest-bubble)
          anim (gfx.animation.loop.new 300 image false)]
      (table.insert state.particles {: anim :x (- x 12) :y (- y 24)})))

  {: draw-all : clear-all
   : frown! : plus!
   : frustration! : quest-bubble!
   })
