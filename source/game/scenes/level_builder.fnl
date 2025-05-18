(import-macros {: inspect : defns : div : clamp} :source.lib.macros)

(defns :level_builder
  [gfx playdate.graphics

   entity-map (require :source.game.entities.core)
   {: prepare-level!} (require :source.lib.level)
   libgraph (require :source.lib.graph)
   $ui (require :source.lib.ui)
   $particles (require :source.game.particles)
   scene-manager (require :source.lib.scene-manager)
   ]

  (fn stage-tick! [{: state &as $scene}]
    (if ($ui:active?) ($ui:tick!) ;; tick if open
        (let [player-x state.player.x
              player-y state.player.y

              game-over-misses 3

              center-x (clamp 0 (- player-x 200) (- state.stage-width 400))
              center-y (clamp 0 (- player-y 120) (- state.stage-height 240))]
          (if (>= (or (?. state.player :state :misses) 0) game-over-misses)
              (scene-manager:select! :game-over))
          (gfx.setDrawOffset (- 0 center-x) (- 0 center-y))
          (gfx.sprite.performOnAllSprites (fn react-each [ent]
                                            (if (?. ent :react!) (ent:react! $scene))))
          )
        ))

  (fn stage-exit! [$scene]
    ($particles:clear-all)
    )

  (fn stage-draw! [$scene]
    ($particles:draw-all)
    ($ui:render!)
    )

  (fn build! [level game-state]
    (let [tile-size 32
          grid-w (div level.w tile-size)
          grid-h (div level.h tile-size)
          locations {}

          {: stage-width : stage-height
           &as loaded} (prepare-level! level
                                       entity-map
                                       {:game-state game-state
                                        :floor {:z-index -100}
                                        :walls {:z-index -90}
                                        :tiles      {:z-index -10}
                                        :foreground {:z-index 10}
                                        })
          wall-sprites (icollect [_ v (ipairs (playdate.graphics.sprite.getAllSprites))]
                         (if (?. v :wall?) v))

          doors (icollect [_ v (ipairs (playdate.graphics.sprite.getAllSprites))]
                  (if (?. v :door?) v))
          player (if (?. game-state :player) (let [door (?. (icollect [_ v (ipairs doors)]
                                                              (if (= v.level game-state.player.state.exit-from) v)) 1)
                                                   door (or door (?. doors 1))]
                                               (game-state.player:replace-at-exit door.exit)
                                               game-state.player)
                     (?. (icollect [_ v (ipairs loaded.entities)]
                           (if (?. v :player?) v)) 1))
          hud (-> (entity-map.hud.new! player) (: :add))
          ]
      (tset game-state :player player)
      {: player : hud : stage-width : stage-height : grid-w}
      )))
