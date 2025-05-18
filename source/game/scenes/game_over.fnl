(import-macros {: inspect : defns} :source.lib.macros)

(defns game-over
  [{:player player-ent} (require :source.game.entities.core)
      scene-manager (require :source.lib.scene-manager)
      $ui (require :source.lib.ui)
      pd playdate
      gfx pd.graphics]

  (local state {})

  (fn enter! [$ game-state]
    ($ui:open-textbox! {:text (.. "Your score was " game-state.player.state.score)})
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
          (if (pressed? playdate.kButtonA) (scene-manager:select! :menu)))
        ))
  (fn draw! [{:state {: listview} &as $}]
    ($ui:render!)
    ;; (listview:drawInRect 180 20 200 200)
    )
  )

