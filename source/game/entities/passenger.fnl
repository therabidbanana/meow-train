(import-macros {: inspect : defns : div : clamp} :source.lib.macros)

(defns :passenger
  [gfx playdate.graphics
   scene-manager (require :source.lib.scene-manager)
   tile (require :source.lib.behaviors.tile-movement)
   $particles (require :source.game.particles)
   $ui (require :source.lib.ui)
   anim (require :source.lib.animation)]

  (fn react! [{: state : height : x : y : tile-w : tile-h : width &as self}]
    (let [(target-x target-y) (if state.following
                                  (state.following:follow-target))
          max-speed 4
          dx (if state.following
                 (- target-x x)
                 0)
          dy (if state.following
                 (- target-y y)
                 0)
          dx (clamp (- 0 max-speed) dx max-speed)
          dy (clamp (- 0 max-speed) dy max-speed)
          bubble-timer (- state.bubble-timer 1)
          ]
      (if (= bubble-timer 0)
          (do
            (tset self :state :bubble-timer 60)
            ($particles.quest-bubble! (+ x (div self.width 2)) y))
          (not state.following)
          (tset self :state :bubble-timer bubble-timer))
      (tset self :state :dx dx)
      (tset self :state :dy dy)
      (tset self :state :walking? (not (and (= 0 dx) (= 0 dy))))
      )
    self)

  (fn update [{:state {: animation : dx : dy : walking?} &as self}]
    (let [target-x (+ dx self.x)
          target-y (+ dy self.y)
          (x y collisions count) (self:moveWithCollisions target-x target-y)]
      (if walking?
          (animation:transition! :walking)
          (animation:transition! :standing {:if :walking}))
      (tset self :state :dx 0)
      (tset self :state :dy 0)
      (self:markDirty)
      (self:setImage (animation:getImage)))
    )

  (fn follow! [self player]
    ;; Help prevent bugs where npc pushes you back into a door
    (self:setGroups [5])
    (tset self :state :following player)
    )

  (fn unfollow! [self player]
    (tset self :state :following nil)
    )

  (fn interact! [self player]
    ($ui:open-textbox! {:text (.. "I need to get to platform " self.state.platform " in 90 seconds!")
                        :action #(do (player:pickup! self)
                                     (self:follow! player))})
    )

  ;; (fn draw [{:state {: animation : dx : dy : visible : walking?} &as self} x y w h]
  ;;   (animation:draw x y))

  ;; (fn collisionResponse [self other]
  ;;   (other:collisionResponse))

  (local platforms [:2 :3])

  (fn new! [x y]
    (let [image (gfx.imagetable.new :assets/images/pineapple-walk)
          animation (anim.new {: image :states [{:state :standing :start 1 :end 1 :delay 2300 :transition-to :blinking}
                                                {:state :blinking :start 2 :end 3 :delay 300 :transition-to :pace}
                                                {:state :pace :start 4 :end 5 :delay 500 :transition-to :standing}
                                                {:state :walking :start 4 :end 5}]})
          player (gfx.sprite.new)
          ;; TODO - extract "sample" helper
          target (inspect (?. platforms (math.random (length platforms))))
          ]
      (player:setCenter 0 0)
      (player:setBounds x y 32 32)
      ;; (player:setCollideRect 6 1 18 30)
      (player:setCollideRect 0 0 32 32)
      (player:setGroups [3])
      (player:setCollidesWithGroups [1 4])
      (tset player :draw draw)
      (tset player :update update)
      (tset player :react! react!)
      (tset player :follow! follow!)
      (tset player :unfollow! unfollow!)
      (tset player :interact! interact!)
      (tset player :state {: animation :platform target
                           :speed 2 :dx 0 :dy 0 :visible true :bubble-timer 30})
      player)))

