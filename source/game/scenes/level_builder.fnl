(import-macros {: inspect : defns : div : clamp} :source.lib.macros)

(defns :level_builder
  [gfx playdate.graphics

   entity-map (require :source.game.entities.core)
   {: prepare-level!} (require :source.lib.level)
   libgraph (require :source.lib.graph)
   $ui (require :source.lib.ui)
   scene-manager (require :source.lib.scene-manager)
   ]

  (fn stage-tick! [{: state &as $scene}]
    (if ($ui:active?) ($ui:tick!) ;; tick if open
        (let [player-x state.player.x
              player-y state.player.y
              center-x (clamp 0 (- player-x 200) (- state.stage-width 400))
              center-y (clamp 0 (- player-y 120) (- state.stage-height 240))]
          (gfx.setDrawOffset (- 0 center-x) (- 0 center-y))
          (gfx.sprite.performOnAllSprites (fn react-each [ent]
                                            (if (?. ent :react!) (ent:react! $scene))))
          )
        ))

  (fn stage-exit! [$scene]
    )

  (fn stage-draw! [$scene]
    ($ui:render!)
    )

  (fn build! [level]
    (let [tile-size 32
          grid-w (div level.w tile-size)
          grid-h (div level.h tile-size)
          locations {}

          {: stage-width : stage-height
           &as loaded} (prepare-level! level
                                       entity-map
                                       {:tiles   {:z-index -10}})
          wall-sprites (icollect [_ v (ipairs (playdate.graphics.sprite.getAllSprites))]
                         (if (?. v :wall?) v))

          player (?. (icollect [_ v (ipairs loaded.entities)]
                       (if (?. v :player?) v)) 1)
          ]
      {: player : stage-width : stage-height : grid-w}
     )))
