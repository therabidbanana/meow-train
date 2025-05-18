(import-macros {: inspect : defns : div} :source.lib.macros)

(defns :npc
  [gfx playdate.graphics
   scene-manager (require :source.lib.scene-manager)
   tile (require :source.lib.behaviors.tile-movement)
   $ui (require :source.lib.ui)
   anim (require :source.lib.animation)]

  (fn react! [{: state : height : x : y : tile-w : tile-h : width &as self}]
    (let [(dx dy) (self:tile-movement-react! state.speed)]
      (if (and (= dx 0) (= dy 0))
          (case (math.random 0 100)
            1 (self:->left!)
            2 (self:->right!)
            3 (self:->up!)
            4 (self:->down!)
            _ nil))
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
      (if (> count 0) (self:->stop!))
      (self:markDirty)
      (self:setImage (animation:getImage)))
    )

  ;; (fn draw [{:state {: animation : dx : dy : visible : walking?} &as self} x y w h]
  ;;   (animation:draw x y))

  ;; (fn collisionResponse [self other]
  ;;   (other:collisionResponse))

  (fn interact! [{: state &as self}]
    (if (?. state :text) ($ui:open-textbox! {:text state.text })))

  (fn new! [x y {: tile-h : tile-w : fields}]
    (let [roll (math.random 1 100)
          image (if (> roll 95)
                    (gfx.imagetable.new :assets/images/pineapple-walk)
                    (> roll 80)
                    (gfx.imagetable.new :assets/images/bear)
                    (> roll 60)
                    (gfx.imagetable.new :assets/images/rabbit)
                    (> roll 40)
                    (gfx.imagetable.new :assets/images/frog-woman)
                    ;; else
                    (gfx.imagetable.new :assets/images/cat-woman)
                    )
          animation (anim.new {: image :states [{:state :standing :start 1 :end 1 :delay 2300}
                                                {:state :walking :start 1 :end 3}]})
          player (gfx.sprite.new)]
      (player:setCenter 0 0)
      (player:setBounds x y 48 48)
      ;; (player:setCollideRect 6 1 18 30)
      (player:setCollideRect 8 8 30 30)
      (player:setGroups [3])
      (player:setCollidesWithGroups [1 4])
      (tset player :draw draw)
      (tset player :update update)
      (tset player :react! react!)
      (if (?. fields :text)
          (tset player :interact! interact!))
      (tset player :tile-h tile-h)
      (tset player :tile-w tile-w)
      (tset player :state {: animation :speed 2 :dx 0 :dy 0 :visible true
                           :text (?. fields :text)
                           :tile-x (div x tile-w) :tile-y (div y tile-h)})
      (tile.add! player {: tile-h : tile-w})
      player)))

