(import-macros {: inspect : defns : div : clamp} :source.lib.macros)

(defns :player
  [pressed? playdate.buttonIsPressed
   justpressed? playdate.buttonJustPressed
   gfx playdate.graphics
   $particles (require :source.game.particles)
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
          meter (if (and (< boost-ticks 1) (= 0 (+ (* dir-x dir-x) (* dir-y dir-y))))
                    (- meter 2)
                    (< boost-ticks 1)
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
          boost (if (> meter 80) 0.8
                    (> meter 60) 0.6
                    (> meter 40) 0.5
                    (> meter 20) 0.4
                    0.3)
          drag (if (> meter 80) 0.95
                   (> meter 60) 0.90
                   (> meter 40) 0.85
                   (> meter 20) 0.8
                   0.8)
          mx (* (+ (* boost dir-x) mx) drag)
          my (* (+ (* boost dir-y) my) drag)
          mx (if (< -0.1 mx 0.1) 0 (clamp -5 mx 5))
          my (if (< -0.1 my 0.1) 0 (clamp -5 my 5))
          ]
      (tset state :meter meter)
      (tset state :boost-ticks boost-ticks)
      (tset state :mx (clamp -5 mx 5))
      (tset state :my (clamp -5 my 5))
      (values mx my))
    )

  (fn algo-3 [{: state} dir-x dir-y boost-factor]
    (let [mx state.mx
          my state.my
          boost-ticks (clamp 0 (- (+ state.boost-ticks (* boost-factor 20)) 1) 120)
          meter (+ (* boost-factor
                      (if (> state.meter 80) 1
                          (> state.meter 60) 2
                          (> state.meter 40) 3
                          (> state.meter 20) 5
                          10)
                      ) state.meter)
          meter (if (and (< boost-ticks 1) (= 0 (+ (* dir-x dir-x) (* dir-y dir-y))))
                    (- meter 2)
                    (< boost-ticks 1)
                    (- meter 0.25)
                    meter)
          boost-ticks (if (< boost-ticks 1)
                          0
                          (- boost-ticks 1))
          meter (clamp 0 meter 100)
          speed (if (> meter 80) 6
                    (> meter 60) 3
                    (> meter 40) 2
                    (> meter 20) 1.2
                    1)

          vx (* speed (+ mx dir-x))
          vy (* speed (+ my dir-y))
          ]
      (tset state :meter meter)
      (tset state :boost-ticks boost-ticks)
      ;; (tset state :degrees new-degrees)
      (tset state :mx vx)
      (tset state :my vy)
      (values vx vy))
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
          magx (math.abs dx)
          magy (math.abs dy)
          new-facing (if (and (>= magy magx) (> dy 0)) :down
                         (and (>= magy magx) (> 0 dy)) :up
                         (and (>= magx magy) (> dx 0)) :right
                         (and (>= magx magy) (> 0 dx)) :left
                         state.facing)
          [facing-x facing-y] (case state.facing
                                :left [(- x 24) (+ y (div height 2))]
                                :right [(+ width x) (+ y (div height 2))]
                                :up [(+ x (div width 2)) (- y 24)]
                                _ [(+ x (div width 2)) (+ 8 height y)])
          [facing-sprite & _] (icollect [_ x (ipairs (gfx.sprite.querySpritesInRect facing-x facing-y 16 16))]
                                (if (?. x :interact!) x))
          pickup-time (if (?. state :picked-up) (- (?. state :pickup-time) 1)
                          0)
          ]
      ;; Figure out how to counteract accel with drag
      (tset self :state :dx dx)
      (tset self :state :dy dy)
      (tset self :state :facing new-facing)
      (tset self :state :pickup-time pickup-time)
      (tset self :state :walking? (not (and (= 0 dx) (= 0 dy))))

      ;; (if (playdate.buttonJustPressed playdate.kButtonA)
      ;;     (scene-manager:select! :menu))
      (if (and (playdate.buttonJustPressed playdate.kButtonA)
               (?. facing-sprite :interact!))
          (let [response (facing-sprite:interact! self)]
            (print response)))
      )
    self)

  (fn pickup! [self passenger]
    (do
      (tset self :state :picked-up true)
      (tset self :state :passenger passenger)
      (tset self :state :pickup-time (* 30 90)))
    )

  ;; Returns the target x y for a following passenger based on
  ;; current x y (and eventually facing, so they stay behind)
  (fn follow-target [self]
    (case self.state.facing
      :down
      (values (+ self.x (/ self.width 2)) (- self.y (* self.height 0.5)))
      :up
      (values (+ self.x (/ self.width 2)) (+ self.y (* self.height 1.5)))
      :right
      (values (- self.x (* self.width 1)) (+ self.y (/ self.height 2)))
      :left
      (values (+ self.x (* self.width 1.5)) (+ self.y (/ self.height 2)))
      ))

  (fn replace-at-exit [{: state &as self} {: x : y}]
    (self:add)
    (tset state :real-x x)
    (tset state :real-y y)
    (tset state :exit-from nil)
    (self:moveTo x y)
    (if state.passenger
        (let [(new-x new-y) (self:follow-target)]
          (state.passenger:add)
          (state.passenger:moveTo new-x new-y))
        )
    self)

  (fn update [{:state {: passenger : animation : real-x : real-y : dx : dy : walking?} &as self}]
    (let [new-x (+ dx real-x)
          new-y (+ dy real-y)
          target-x (math.floor new-x)
          target-y (math.floor new-y)
          (x y collisions count) (self:moveWithCollisions target-x target-y)
          first-collision (?. collisions 1 :other)]
      ;; TODO: collisions relying on 1 being the special other is going to cause issues
      ;; (if (> count 0) (inspect (icollect [_ x (ipairs collisions)] x.other)))
      (tset self :state :dx 0)
      (tset self :state :dy 0)
      (if
       (and (> count 0) (?. collisions 1 :other :door?))
       (let [door (?. collisions 1 :other)]
         (tset self :state :exit-from door.current)
         (scene-manager:select! (inspect door.level))
         )
       ;; TODO: bug if you collide with dropoff _and_ wall in same move (start moving inverse because bounces get larger and larger as real-x grows)
       (and (> count 0) (?. collisions 1 :other :dropoff?))
       (do
         (tset self :state :real-x new-x)
         (tset self :state :real-y new-y)
         (tset self :state :picked-up false)
         (if passenger
             (do (passenger:transfer! first-collision)
                 (tset self :state :passenger nil)))
         )
       (> count 0)
       (do
         ($particles.frustration! (+ x (div self.width 2)) (- y 2))
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
      (if walking?
          (animation:transition! (case self.state.facing
                                   :left :walking-left
                                   :right :walking-right
                                   :up :walking-up
                                   _ :walking-down))
          (animation:transition! (case self.state.facing
                                   :left :standing-left
                                   :right :standing-right
                                   :up :standing-up
                                   _ :standing)))
      (self:setImage (animation:getImage)))
    )

  ;; (fn draw [{:state {: animation : dx : dy : visible : walking?} &as self} x y w h]
  ;;   ;; (love.graphics.rectangle "fill" x y w h)
  ;;   ;; Playdate version weird here:
  ;;   (animation:draw x y)
  ;;   )

  (fn collisionResponse [self other]
    (if (or other.door? other.dropoff? other.pickup?)
        :overlap
        :slide)
    )

  (fn new! [x y {: tile-w : tile-h : game-state &as extras}]
    (if (not (?. game-state :player))
        (let [image (gfx.imagetable.new :assets/images/player)
              animation (anim.new {: image :states [{:state :standing :start 1 :end 1 :transition-to :blink :delay 1700}
                                                    {:state :blink :start 6 :end 6 :transition-to :standing :delay 150}
                                                    {:state :walking-down :start 1 :end 6}
                                                    {:state :walking-up :start 19 :end 24}
                                                    {:state :walking-left :start 7 :end 12}
                                                    {:state :walking-right :start 13 :end 18}
                                                    {:state :standing-down :start 1 :end 1}
                                                    {:state :standing-up :start 19 :end 19}
                                                    {:state :standing-left :start 7 :end 7}
                                                    {:state :standing-right :start 13 :end 13}
                                                    ]})
              player (gfx.sprite.new)]
          (player:setCenter 0 0)
          (player:setBounds x y 48 48)
          (player:setCollideRect 8 18 30 30)
          (player:setGroups [1])
          (player:setCollidesWithGroups [3 4])
          (tset player :player? true)
          ;; (tset player :draw draw)
          (tset player :replace-at-exit replace-at-exit)
          (tset player :collisionResponse collisionResponse)

          (tset player :update update)
          (tset player :follow-target follow-target)
          (tset player :react! react!)
          (tset player :boost! boost!)
          (tset player :pickup! pickup!)
          (tset player :algo-1 algo-1)
          (tset player :algo-2 algo-2)
          (tset player :algo-3 algo-3)
          (tset player :run-algo (?. player game-state.run-algo))
          (tset player :state {: animation :speed 2
                               :dx 0 :dy 0 :degrees 180
                               :mx 0 :my 0 :meter 1 :boost-ticks 0
                               :real-x x :real-y y
                               :visible true})
          player))))

