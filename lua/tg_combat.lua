-- ********************************************************************** Card
Card = {}
Card.mt = {} -- metatable that will be shared
function Card.tostring( card )
   local s = "C: " .. card.title .. " (" .. card.id .. ")"
   return s
end
Card.mt.__tostring = Card.tostring

c1 = {
   id = 1,
   title = "One",
   closed_keys = {
      agression = { effect=3 },
      courage = { effect=2 },
   },
   free_key = 1
}
setmetatable( c1, Card.mt )

-- ********************************************************************* Perso
Perso = {}
Perso.mt = {} -- metatable that will be shared
function Perso.tostring( perso )
   local s = "P: " .. perso.name
   return s
end
Perso.mt.__tostring = Perso.tostring

p_bidule = {
   name = "Bidule",
   agression = 1,
   courage = 1,
   pragmatisme = 0,
}
setmetatable( p_bidule, Perso.mt )

-- ******************************************************************* Monster
Monster = {}
Monster.mt = {} -- metatable that will be shared
function Monster.tostring( monster )
   local s = "M: " .. monster.name
   s = s .. " dmg=" .. monster.damage .. "/" .. monster.max_damage
   return s
end
Monster.mt.__tostring = Monster.tostring

monster = {
   name = "Monster",
   open_keys = {
      agression = 1,
      courage = 2,
   },
   free_key = 1,
   attack = {
      { limup = 2, effect=-1 },
      { limup = 4, effect=-2 },
   },
   damage = 0,
   max_damage = 7,
}
setmetatable( monster, Monster.mt )

-- ***************************************************************************
-- ********************************************************************** MCTS
-- ***************************************************************************
State = {}
State.mt = {} -- metatable that will be shared
-- state = {
--    card_seq = {},
--    monster = {},
--    still_to_play = {},
--    active_perso = nil,
-- }
function State.tostring( state )
   local s = "STATE"
   s = s .. "\n  len=" .. #state.card_seq
   s = s .. "\n  seq={"
   for name, val in pairs(state.card_seq) do
      s = s .. tostring( val ) .. ", "
   end
   s = s .. "}"
   s = s .. "\n  monster=" .. tostring( state.monster )
   s = s .. "\n  to_play={"
   for name, val in pairs(state.still_to_play) do
      s = s .. tostring( val ) .. ", "
   end
   s = s .. "}"
   s = s .. "\n  active=" .. tostring( state.active_perso )
   return s
end
State.mt.__tostring = State.tostring

function init_fight( monster )
   local state = {
      card_seq = {monster},
      monster = monster,
      still_to_play = {p_bidule},
      active_perso = nil,
      level = 0
   }
   setmetatable( state, State.mt ) -- make sur all share same metatable
   return state
end
      

-- WARNING : assume action are VALID -----------------------------------------
function action_play_card( state, card, perso )
   -- update active perso
   state.active_perso = perso
   -- remove from to_play
   for idx, val in ipairs(state.still_to_play) do
      if val == perso then
         table.remove( state.still_to_play, idx )
         break
      end
   end
   -- insert at end of pile
   table.insert( state.card_seq, card )

   -- apply card
   apply_card( state.card_seq[#state.card_seq - 1], card,
               state.monster, state.active_perso )
   return state
end
function action_monster_atk( state )
   -- apply attack on active player
   apply_attack( state.monster, state.active_perso )

   return state
end
function action_finish_round( state )
end

-- ***************************************************************************
-- **************************************************************** Mechanisms
-- ***************************************************************************
function resolve_effect( effect, monster, perso )
   -- number => add to monster.damage
   if type(effect) == 'number' then
      monster.damage = monster.damage + effect
   else
      error( "invalid effect" )
   end
end

function apply_card (prev_card, card, monster, perso)
   
   -- Effect of closed keys
   for kname in pairs( prev_card.open_keys ) do
      if card.closed_keys[kname] then
         if perso[kname] >= prev_card.open_keys[kname] then
            print( "  "..kname.." effect can be resolved" )
            resolve_effect( card.closed_keys[kname].effect, monster, perso)
         else
            print( "  "..kname.." effect CANNOT be resolved" )
         end
      end
   end
end

function apply_attack( monster, perso )
   local limin = 0
   local limup = 0
   for i,atk in ipairs(monster.attack) do
      limup = atk.limup
      print( "  atk in ["..limin..", "..limup.."[")
      if monster.damage >= limin and monster.damage < limup then
         print( "  resolve_effect" )
         resolve_effect( atk.effect, monster, perso )
         break
      end
      limin = limup
   end
end
   
-- ****************************** MAIN
-- print( "__Apply c1 on monster" )
-- apply_card( monster, c1, monster, p_bidule )
-- print( "=> Monster dmg="..monster.damage )

-- print( "__Apply attack of Monster" )
-- apply_attack( monster, p_bidule )
-- print( "=> Monster dmg="..monster.damage )

-- ***************************************************************** MAIN MCTS
print( "__INIT fight" )
mcts_state = init_fight( monster )
print( tostring(mcts_state) )

print( "__PLAY CARD c1" )
mcts_state = action_play_card( mcts_state, c1, p_bidule )
print( tostring(mcts_state) )

print( "__Monster Attack" )
mcts_state = action_monster_atk( mcts_state )
print( tostring(mcts_state) )

   
