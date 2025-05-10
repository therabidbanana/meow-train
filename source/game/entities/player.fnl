(import-macros {: inspect : defns : div : clamp} :source.lib.macros)

(defns :player
  [pressed? playdate.buttonIsPressed
   justpressed? playdate.buttonJustPressed
   gfx playdate.graphics
   $ui (require :source.lib.ui)
   scene-manager (require :source.lib.scene-manager)
   anim (require :source.lib.animation)]

  (fn algo-1 [{: state} dir-x dir-y boost-factor]
    (let [meter (+ state.meter boost-factor)
          meter (* meter 0.95)
          meter (if (> meter 0.1) meter 0)
          extra-x (if (> meter 0) (* dir-x meter) 0)
          extra-y (if (> meter 0) (* dir-y meter) 0)]
      (tset state :meter meter)
      (values (/ (+ extra-x dir-x) 1.2) (/ (+ extra-y dir-y) 1.2)))
    )

  (fn algo-2 [{: state} dir-x dir-y boost-factor]
    (let [mx (if (> boost-factor 0) (+ state.mx (* dir-x boost-factor))
                 (* state.mx 0.9))
          my (if (> boost-factor 0) (+ state.my (* dir-y boost-factor))
                 (* state.my 0.9))
          mx (if (< -0.1 mx 0.1) 0 mx)
          my (if (< -0.1 my 0.1) 0 my)]
      (tset state :mx (clamp -4 mx 4))
      (tset state :my (clamp -4 my 4))
      (values (/ (+ mx dir-x) 1.2) (/ (+ my dir-y) 1.2)))
    )

  (fn algo-3 [{: state} dir-x dir-y boost-factor]
    (let []
      (tset state :mx (clamp -4 mx 4))
      (tset state :my (clamp -4 my 4))
      (values (/ (+ mx dir-x) 1.2) (/ (+ my dir-y) 1.2)))
    )

  (fn react! [{: state : height : x : y : width : run-algo &as self} $scene]
    (let [dir-x (if (pressed? playdate.kButtonLeft)
                     -1
                     (pressed? playdate.kButtonRight)
                     1
                     0)
          dir-y (if (pressed? playdate.kButtonUp)
                     -1
                     (pressed? playdate.kButtonDown)
                     1
                     0)

          (cranked accel) (playdate.getCrankChange)
          boost-factor (if (justpressed? playdate.kButtonB) 1
                           (> accel 1) 0.2
                           (< accel -1) 0.2
                           0
                       )
          (dx dy)  (run-algo self dir-x dir-y boost-factor)
          [facing-x facing-y] (case state.facing
                                :left [(- x 8) (+ y (div height 2))]
                                :right [(+ 40 x) (+ y (div height 2))]
                                :up [(+ x (div width 2)) (- y 8)]
                                _ [(+ x (div width 2)) (+ 8 height y)]) ;; 40 for height / width of sprite + 8
          [facing-sprite & _] (gfx.sprite.querySpritesAtPoint facing-x facing-y)
          ]
      ;; Figure out how to counteract accel with drag
      (tset self :state :dx dx)
      (tset self :state :dy dy)
      (tset self :state :walking? (not (and (= 0 dx) (= 0 dy))))

      (if (playdate.buttonJustPressed playdate.kButtonA)
          (scene-manager:select! :menu))
      (if (and (playdate.buttonJustPressed playdate.kButtonA)
               facing-sprite)
          ($ui:open-textbox! {:text (gfx.getLocalizedText "textbox.test2")}))
      )
    self)

  (fn boost! [{ : state &as self} dx dy]
    (let [meter (+ state.meter 10)
          boosted? (> meter 10)
          meter (if boosted?
                    (- meter 10)
                    meter)]
      (tset state :meter meter)
      (if boosted?
          (do
            (tset state :accel-x (clamp -4 (+ (/ dx 3) state.accel-x) 4))
            (tset state :accel-y (clamp -4 (+ (/ dy 3) state.accel-y) 4))
            )
          ))
    )

  (fn update [{:state {: animation : real-x : real-y : dx : dy : walking?} &as self}]
    (let [new-x (+ dx real-x)
          new-y (+ dy real-y)
          target-x (math.floor new-x)
          target-y (math.floor new-y)
          (x y collisions count) (self:moveWithCollisions target-x target-y)]
      (if (> count 0)
          (do
            (tset self :state :real-x x)
            (tset self :state :real-y y)
            (tset self :state :accel-x 0)
            (tset self :state :accel-y 0)
            )
          (do
            (tset self :state :real-x new-x)
            (tset self :state :real-y new-y)
            )
          )
      (if walking?
         (animation:transition! :walking)
         (animation:transition! :standing {:if :walking})))
    (self:setImage (animation:getImage))
    )

  ;; (fn draw [{:state {: animation : dx : dy : visible : walking?} &as self} x y w h]
  ;;   ;; (love.graphics.rectangle "fill" x y w h)
  ;;   ;; Playdate version weird here:
  ;;   (animation:draw x y)
  ;;   )

  (fn collisionResponse [self other]
    (other:collisionResponse))

  (fn new! [x y {: tile-w : tile-h : game-state &as extras}]
    (let [image (gfx.imagetable.new :assets/images/pineapple-walk)
          animation (anim.new {: image :states [{:state :standing :start 1 :end 1 :delay 2300 :transition-to :blinking}
                                                {:state :blinking :start 2 :end 3 :delay 300 :transition-to :pace}
                                                {:state :pace :start 4 :end 5 :delay 500 :transition-to :standing}
                                                {:state :walking :start 4 :end 5}]})
          player (gfx.sprite.new)]
      (player:setCenter 0 0)
      (player:setBounds x y 32 32)
      (player:setCollideRect 6 1 18 30)
      (player:setGroups [1])
      (player:setCollidesWithGroups [3 4])
      (tset player :player? true)
      (tset player :draw draw)
      (tset player :update update)
      (tset player :react! react!)
      (tset player :boost! boost!)
      (tset player :algo-1 algo-1)
      (tset player :algo-2 algo-2)
      (tset player :run-algo (?. player game-state.run-algo))
      (tset player :state {: animation :speed 2
                           :dx 0 :dy 0
                           :mx 0 :my 0 :meter 1
                           :real-x x :real-y y
                           :visible true})
      player)))

