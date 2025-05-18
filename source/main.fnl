(import-macros {: inspect : pd/import : pd/load : require/patch : love/patch} :source.lib.macros)
(require/patch)
(love/patch)

(pd/import :CoreLibs/object)
(pd/import :CoreLibs/easing)
(pd/import :CoreLibs/graphics)
(pd/import :CoreLibs/sprites)
(pd/import :CoreLibs/timer)
(pd/import :CoreLibs/crank)

(global $config {:debug false})

(pd/load
 [{: scene-manager} (require :source.lib.core)]
 (fn load-hook []
   (let [music-loop (playdate.sound.fileplayer.new :assets/sounds/meow-train-v1)]
     (doto music-loop
       (: :setVolume 0.2)
       (: :play 0))
     (scene-manager:load-scenes! (require :source.game.scenes))
     (scene-manager:select! :menu))
   )
 (fn update-hook []
   (scene-manager:tick!)
   )
 (fn draw-hook []
   (scene-manager:draw!)
   )
 (fn debug-draw []
   (scene-manager:debug-draw!))
 )

