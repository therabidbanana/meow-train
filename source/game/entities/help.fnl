(import-macros {: inspect : defns : div} :source.lib.macros)

(defns :npc
  [gfx playdate.graphics
   scene-manager (require :source.lib.scene-manager)
   tile (require :source.lib.behaviors.tile-movement)
   $particles (require :source.game.particles)
   $ui (require :source.lib.ui)
   anim (require :source.lib.animation)]

  (fn react! [{: state : height : x : y : tile-w : tile-h : width &as self} $scene game-state]
    (let [(dx dy) (self:tile-movement-react! state.speed)
          ready-state (or self.state.ready game-state.ready)
          bubble-timer (- state.bubble-timer 1)]
      (if (= bubble-timer 0)
          (do
            (tset self :state :bubble-timer 60)
            ($particles.quest-bubble! (+ x (div self.width 2)) y))
          (not ready-state)
          (tset self :state :bubble-timer bubble-timer))
      (tset self :state :ready ready-state)
      (tset self :state :dx dx)
      (tset self :state :dy dy)
      (tset self :state :walking? (not (and (= 0 dx) (= 0 dy))))
      (tset game-state :ready ready-state)
      )
    self)

  (fn update [{:state {: animation : dx : dy : walking?} &as self}]
    (let [target-x (+ dx self.x)
          target-y (+ dy self.y)
          (x y collisions count) (self:moveWithCollisions target-x target-y)]
      (tset self :state :dx 0)
      (tset self :state :dy 0)
      (if (> count 0) (self:->stop!))
      (self:markDirty)
      (self:setImage (animation:getImage)))
    )

  ;; (fn draw [{:state {: animation : dx : dy : visible : walking?} &as self} x y w h]
  ;;   (animation:draw x y))

  ;; (fn collisionResponse [self other]
  ;;   (other:collisionResponse))

  (fn interact! [self]
    (if self.state.ready
        ($ui:open-textbox! {:text "Listen, you don't have time to talk to me - if someone is late they'll complain and you'll get fired on your first day. These people think they can show up with less than a minute to get to their train!"})
        ($ui:open-textbox! {:text "Oh, you're here. I know it's your first day, but I don't have time to help you and your boss called out sick. Just help the people get to their trains. Maybe hit a button or spin something to pick up the pace?"
                         :action #(do (tset self :state :ready true))})))

  (fn new! [x y {: tile-h : tile-w}]
    (let [image (gfx.imagetable.new :assets/images/rabbit-help)
          animation (anim.new {: image :states [{:state :standing :start 1 :end 1 :transition-to :blinking :delay 1500}
                                                {:state :blinking :start 1 :end 3 :transition-to :standing :delay 300}]})
          player (gfx.sprite.new)]
      (player:setCenter 0 0)
      (player:setBounds x y 48 48)
      ;; (player:setCollideRect 6 1 18 30)
      (player:setCollideRect 12 12 24 24)
      (player:setGroups [3])
      (player:setCollidesWithGroups [1 ])
      (tset player :draw draw)
      (tset player :update update)
      (tset player :react! react!)
      (tset player :interact! interact!)
      (tset player :tile-h tile-h)
      (tset player :tile-w tile-w)
      (tset player :state {: animation :speed 2 :dx 0 :dy 0 :visible true
                           :ready false
                           :bubble-timer 30
                           :tile-x (div x tile-w) :tile-y (div y tile-h)})
      (tile.add! player {: tile-h : tile-w})
      player)))

