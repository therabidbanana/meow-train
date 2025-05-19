(import-macros {: inspect : defns} :source.lib.macros)

(defns game-over
  [{:player player-ent} (require :source.game.entities.core)
      scene-manager (require :source.lib.scene-manager)
      $ui (require :source.lib.ui)
      pd playdate
      gfx pd.graphics]

  (local state {})

  (fn enter! [$ game-state]
    (let [img (gfx.image.new :assets/images/game-over)
          ]
      (tset $ :state {})
      (tset $ :state :bg-anim (playdate.graphics.animator.new 2500 0 1 playdate.easingFunctions.inCubic))
      (tset $ :state :bg img)
      ($ui:open-textbox! {:text (.. "Your score was " (or (?. game-state :player :state :score) 0))})
      )
    ;; (tset $ :state :listview (testScroll pd gfx))
    )

  (fn exit! [$ game-state]
    (tset game-state :player nil)
    (tset game-state :spawned-count nil)
    (tset game-state :ready false)
    (tset $ :state {}))

  (fn tick! [{:state {: listview} &as $}]
    ;; (listview:drawInRect 180 20 200 200)
    (if ($ui:active?) ($ui:tick!)
        (let [pressed? playdate.buttonJustPressed]
          (if (pressed? playdate.kButtonA) (scene-manager:select! :title)))
        ))

  (fn draw! [$]
    (gfx.clear)
    ($.state.bg:drawFaded 0 0 ($.state.bg-anim:currentValue) gfx.image.kDitherTypeFloydSteinberg)
    ($ui:render!)
    ;; ($.layer.tilemap:draw 0 0)
    )
  )

