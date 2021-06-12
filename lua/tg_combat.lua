-- Cards definition
require( "cards" )

-- ********************************************************************** Card
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
   s = s .. " l= " .. perso.life .. "/" .. perso.life_max
   return s
end
Perso.mt.__tostring = Perso.tostring

p_bidule = {
   name = "Bidule",
   agression = 1,
   courage = 1,
   pragmatisme = 0,
   life = 6, life_max = 6,
   cards={},
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
      { limup = 2, effects={-1, "wound_1"} },
      { limup = 4, effects={-2, "wound_2"} },
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
function is_valid_sequel( prev_card, card, perso )
   -- is there a NON-negated "sequence" label somewhere ?
   local nb_sequence = 0
   -- first in keys
   for kname, val in pairs(card.closed_keys) do
      if val == "sequence" and prev_card.open_keys[kname] then
         if perso[kname] >= prev_card.open_keys[kname] then
            nb_sequence = nb_sequence + 1
         end
      end
   end
   -- then magic TODO DECISION
   -- and free
   if card.closed_free == "sequence" then
      if prev_card.open_free > 0 then
         nb_sequence = nb_sequence + 1
      end
   end
   return (nb_sequence > 0)
end


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
         local effects = atk.effects
         for name, val in pairs(effects) do
            if type(val) == 'number' then             -- number => dmg
               print( "  will change damage by " .. val )
               resolve_effect( val, monster, perso )
            elseif string.find( val, "wound_" ) then
               -- get number of wounds
               nb_wnd = tonumber( val.sub( val, 7))
               print( "  will apply" .. nb_wnd+10 .. " wounds" )
               perso.life = math.max( 0, perso.life - nb_wnd )
            end
         end

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

-- ************************************************************* TEST Sequence
function test_sequence()
   --for name, card1 in pairs(cards_larve) do
   card1 = cards_larve[2]
   for name, card2 in pairs(cards_larve) do
      print( "\n" )
      print( Card.display( card1 ) )
      print( Card.display( card2 ) )
      print( "==> Valid = ", is_valid_sequel(card1, card2, p_bidule))
   end
--end
end

-- ***************************************************************** MAIN MCTS
-- print( "__INIT fight" )
-- mcts_state = init_fight( monster )
-- print( tostring(mcts_state) )

-- print( "__PLAY CARD c1" )
-- mcts_state = action_play_card( mcts_state, c1, p_bidule )
-- print( tostring(mcts_state) )

-- print( "__Monster Attack" )
-- mcts_state = action_monster_atk( mcts_state )
-- print( tostring(mcts_state) )

-- ****************************************************************** TEST_SEQ
test_sequence()


-- print( "__101 " )
-- print( cards_larve[1] )
-- print( Card.display( cards_larve[1] ))

-- ********************************************************************** DECK
function make_deck()
   local deck = {}
   for name, val in pairs(cards_larve) do
      table.insert( deck, val )
   end
   return deck
end
math.randomseed(os.time()) 
function shuffle_deck( deck )
   for i = #deck, 2, -1 do
      local j = math.random(i)
      deck[i], deck[j] = deck[j], deck[i]
   end
   return deck
end
function take_card( perso, deck, nb_card )
   nb_card = nb_card or 1 -- default value for nb
   for v=1,nb_card do
      table.insert( perso.cards, table.remove(deck) )
   end
end

-- print( "__CREATE DECK" )
-- deck = make_deck()
-- for idx, val in ipairs(deck) do
--    print( idx .. " : " .. Card.tostring(val) )
-- end
-- print( "__SHUFFLE" )
-- deck = shuffle_deck( deck )
-- for idx, val in ipairs(deck) do
--    print( idx .. " : " .. Card.tostring(val) )
-- end
-- print( "__DEAL" )
-- nc = table.remove( deck, 5)
-- print( Card.tostring(nc) )
-- for idx, val in ipairs(deck) do
--    print( idx .. " : " .. Card.tostring(val) )
-- end
-- print( "cards for " .. Perso.tostring(p_bidule) )
-- for idx, val in ipairs(p_bidule.cards) do
--    print( idx .. " : " .. Card.tostring(val) )
-- end
-- take_card( p_bidule, deck )
-- for idx, val in ipairs(deck) do
--    print( idx .. " : " .. Card.tostring(val) )
-- end
-- print( "cards for " .. Perso.tostring(p_bidule) )
-- for idx, val in ipairs(p_bidule.cards) do
--    print( idx .. " : " .. Card.tostring(val) )
-- end
-- take_card( p_bidule, deck, 2 )
-- for idx, val in ipairs(deck) do
--    print( idx .. " : " .. Card.tostring(val) )
-- end
-- print( "cards for " .. Perso.tostring(p_bidule) )
-- for idx, val in ipairs(p_bidule.cards) do
--    print( idx .. " : " .. Card.tostring(val) )
-- end
-- print( "__SHUFFLE" )
-- deck = shuffle_deck( deck )
-- for idx, val in ipairs(deck) do
--    print( idx .. " : " .. Card.tostring(val) )
-- end

-- ***************************************************************** ALL CARDS
-- print( "__***********************************************" )
-- for idx, val in ipairs(cards_larve) do
--    print( "\n" .. Card.display(val) )
-- end

