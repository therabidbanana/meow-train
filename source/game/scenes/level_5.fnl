(import-macros {: pd/import : defns : inspect} :source.lib.macros)
(import-macros {: deflevel} :source.lib.ldtk.macros)

(deflevel :level_5
  [entity-map (require :source.game.entities.core)
   {: build! : stage-exit! : stage-draw! : stage-tick!} (require :source.game.scenes.level_builder)
   $ui (require :source.lib.ui)
   pd playdate
   gfx pd.graphics]

  (fn enter! [$ game-state]
    (let [state (build! level_5 game-state)]
      (tset $ :state state)))

  (fn exit! [$ game-state]
    (stage-exit! $)
    (tset $ :state {})
    (playdate.graphics.setDrawOffset 0 0)
    )

  (fn draw! [$scene] (stage-draw! $scene))

  (fn tick! [{: state &as $scene}]
    (stage-tick! $scene))

  (fn debug-draw! [$]
    (gfx.sprite.performOnAllSprites
     (fn [ent]
       (if ent.collisionBox
           (gfx.drawRoundRect ent.collisionBox 1)
           ;; (gfx.drawCircleInRect ent.x ent.y ent.width ent.height 1)
           )))
    )
  )

