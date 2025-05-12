(import-macros {: inspect : defns : div : clamp} :source.lib.macros)

(defns :player
  [pressed? playdate.buttonIsPressed
   justpressed? playdate.buttonJustPressed
   gfx playdate.graphics
   $ui (require :source.lib.ui)
   scene-manager (require :source.lib.scene-manager)
   anim (require :source.lib.animation)]

  (fn algo-1 [{: state} dir-x dir-y boost-factor]
    (let [mx state.mx
          my state.my
          boost-ticks (clamp 0 (- (+ state.boost-ticks (* boost-factor 20)) 1) 120)
          meter (+ (* boost-factor
                      (if (> state.meter 80) 1
                          (> state.meter 60) 2
                          (> state.meter 40) 3
                          (> state.meter 20) 5
                          6)
                      ) state.meter)
          meter (if (< boost-ticks 1)
                    (- meter 0.25)
                    meter)
          boost-ticks (if (< boost-ticks 1)
                          0
                          (- boost-ticks 1))
          meter (clamp 0 meter 100)
          boost (if (> meter 80) 2
                    (> meter 60) 1.8
                    (> meter 40) 1.3
                    (> meter 20) 1
                    0.8)
          drag (if (> meter 80) 0.95
                   (> meter 60) 0.90
                   (> meter 40) 0.85
                   (> meter 20) 0.8
                   0.5)
          mx (* (+ (* 0.2 dir-x) mx) drag)
          my (* (+ (* 0.2 dir-y) my) drag)
          mx (if (< -0.1 mx 0.1) 0 mx)
          my (if (< -0.1 my 0.1) 0 my)
          ]
      (tset state :meter meter)
      (tset state :boost-ticks boost-ticks)
      (tset state :mx (clamp -3 mx 3))
      (tset state :my (clamp -3 my 3))
      (values (/ (+ mx (* dir-x boost)) 1) (/ (+ my (* dir-y boost)) 1)))
    )

  (fn algo-2 [{: state} dir-x dir-y boost-factor]
    (let [mx state.mx
          my state.my
          boost-ticks (clamp 0 (- (+ state.boost-ticks (* boost-factor 20)) 1) 120)
          meter (+ (* boost-factor
                      (if (> state.meter 80) 1
                          (> state.meter 60) 2
                          (> state.meter 40) 3
                          (> state.meter 20) 5
                          6)
                      ) state.meter)
          meter (if (< boost-ticks 1)
                    (- meter 0.25)
                    meter)
          boost-ticks (if (< boost-ticks 1)
                          0
                          (- boost-ticks 1))
          meter (clamp 0 meter 100)
          boost (if (> meter 80) 2
                    (> meter 60) 1.8
                    (> meter 40) 1.3
                    (> meter 20) 1
                    0.8)
          drag (if (> meter 80) 0.95
                   (> meter 60) 0.90
                   (> meter 40) 0.85
                   (> meter 20) 0.8
                   0.5)
          mx (* (+ (/ (* boost dir-x) 5) mx) drag)
          my (* (+ (/ (* boost dir-y) 5) my) drag)
          mx (if (< -0.1 mx 0.1) 0 mx)
          my (if (< -0.1 my 0.1) 0 my)
          ]
      (tset state :meter meter)
      (tset state :boost-ticks boost-ticks)
      (tset state :mx (clamp -4 mx 4))
      (tset state :my (clamp -4 my 4))
      (values (/ (+ mx (* dir-x boost)) 1) (/ (+ my (* dir-y boost)) 1)))
    )

  (fn algo-3 [{: state} dir-x dir-y boost-factor]
    (let [mx state.mx
          my state.my
          meter (+ (* boost-factor 10) state.meter)
          meter (clamp 0 (- meter 1) 100)
          boost (if (> meter 80) 3
                    (> meter 60) 2.5
                    (> meter 40) 2
                    (> meter 20) 1.5
                    1)
          mx (* (+ (* 0.2 dir-x) mx) 0.9)
          my (* (+ (* 0.2 dir-y) my) 0.9)
          mx (if (< -0.1 mx 0.1) 0 mx)
          my (if (< -0.1 my 0.1) 0 my)
          ]
      (tset state :meter meter)
      (tset state :mx (clamp -4 mx 4))
      (tset state :my (clamp -4 my 4))
      (values (/ (+ mx (* dir-x boost)) 1) (/ (+ my (* dir-y boost)) 1)))
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
                           (> (math.abs accel) 10) 0.15
                           (> (math.abs accel) 5) 0.12
                           (> (math.abs accel) 1) 0.1
                           0
                       )
          (dx dy)  (run-algo self dir-x dir-y boost-factor)
          [facing-x facing-y] (case state.facing
                                :left [(- x 8) (+ y (div height 2))]
                                :right [(+ 40 x) (+ y (div height 2))]
                                :up [(+ x (div width 2)) (- y 8)]
                                _ [(+ x (div width 2)) (+ 8 height y)]) ;; 40 for height / width of sprite + 8
          [facing-sprite & _] (gfx.sprite.querySpritesAtPoint facing-x facing-y)
          pickup-time (if (?. state :picked-up) (- (?. state :pickup-time) 1)
                          0)
          ]
      ;; Figure out how to counteract accel with drag
      (tset self :state :dx dx)
      (tset self :state :dy dy)
      (tset self :state :pickup-time pickup-time)
      (tset self :state :walking? (not (and (= 0 dx) (= 0 dy))))

      ;; (if (playdate.buttonJustPressed playdate.kButtonA)
      ;;     (scene-manager:select! :menu))
      (if (and (playdate.buttonJustPressed playdate.kButtonA)
               facing-sprite)
          ($ui:open-textbox! {:text (gfx.getLocalizedText "textbox.test2")}))
      )
    self)

  (fn replace-at-exit [{: state &as self} {: x : y}]
    (self:add)
    (tset state :real-x x)
    (tset state :real-y y)
    (tset state :exit-from nil)
    (self:moveTo x y)
    self)

  (fn update [{:state {: animation : real-x : real-y : dx : dy : walking?} &as self}]
    (let [new-x (+ dx real-x)
          new-y (+ dy real-y)
          target-x (math.floor new-x)
          target-y (math.floor new-y)
          (x y collisions count) (self:moveWithCollisions target-x target-y)]
      (if
       (and (> count 0) (?. collisions 1 :other :door?))
       (let [door (?. collisions 1 :other)]
         (tset self :state :exit-from door.current)
         (scene-manager:select! door.level)
         )
       (and (> count 0) (?. collisions 1 :other :pickup?))
       (do
         (tset self :state :real-x new-x)
         (tset self :state :real-y new-y)
         (tset self :state :picked-up true)
         (tset self :state :pickup-time (* 30 90)))
       (and (> count 0) (?. collisions 1 :other :dropoff?))
       (do
         (tset self :state :real-x new-x)
         (tset self :state :real-y new-y)
         (tset self :state :picked-up false))
       (> count 0)
       (do
         (tset self :state :real-x x)
         (tset self :state :real-y y)
         (tset self :state :mx 0)
         (tset self :state :my 0)
         (tset self :state :meter (/ self.state.meter 2))
         )
       (do
         (tset self :state :real-x new-x)
         (tset self :state :real-y new-y)
            )
          )
      ;; (if walking?
      ;;    (animation:transition! :walking)
      ;;    (animation:transition! :standing {:if :walking}))
      )
    (self:setImage (animation:getImage))
    )

  ;; (fn draw [{:state {: animation : dx : dy : visible : walking?} &as self} x y w h]
  ;;   ;; (love.graphics.rectangle "fill" x y w h)
  ;;   ;; Playdate version weird here:
  ;;   (animation:draw x y)
  ;;   )

  (fn collisionResponse [self other]
    (if (or other.door? other.dropoff? other.pickup?)
        :overlap
        :bounce)
    )

  (fn new! [x y {: tile-w : tile-h : game-state &as extras}]
    (if (not (?. game-state :player))
        (let [image (gfx.imagetable.new :assets/images/player)
              animation (anim.new {: image :states [{:state :standing :start 1 :end 1}]})
              player (gfx.sprite.new)]
          (player:setCenter 0 0)
          (player:setBounds x y 48 48)
          (player:setCollideRect 0 0 48 48)
          (player:setGroups [1])
          (player:setCollidesWithGroups [3 4])
          (tset player :player? true)
          (tset player :draw draw)
          (tset player :replace-at-exit replace-at-exit)
          (tset player :collisionResponse collisionResponse)

          (tset player :update update)
          (tset player :react! react!)
          (tset player :boost! boost!)
          (tset player :algo-1 algo-1)
          (tset player :algo-2 algo-2)
          (tset player :algo-3 algo-3)
          (tset player :run-algo (?. player game-state.run-algo))
          (tset player :state {: animation :speed 2
                               :dx 0 :dy 0
                               :mx 0 :my 0 :meter 1 :boost-ticks 0
                               :real-x x :real-y y
                               :visible true})
          player))))

