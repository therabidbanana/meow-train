(let [player (require :source.game.entities.player)
      npc    (require :source.game.entities.npc)
      cat    (require :source.game.entities.cat)
      frog    (require :source.game.entities.frog)
      door    (require :source.game.entities.door)
      help    (require :source.game.entities.help)
      dropoff    (require :source.game.entities.dropoff)
      pickup    (require :source.game.entities.pickup)
      track    (require :source.game.entities.track)
      hud    (require :source.game.entities.hud)]
  {: player : npc : hud : door : pickup : dropoff
   : cat : frog : track : help})
