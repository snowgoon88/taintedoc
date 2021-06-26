-- Cards definition
require( "cards" )

-- ********************************************************************* Utils
-- WARNING -- not tested !!!
function deepcopy( orig )
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

-- ********************************************************************** Card
-- c1 = {
--    id = 1,
--    title = "One",
--    closed_keys = {
--       agression = { effect=3 },
--       courage = { effect=2 },
--    },
--    free_key = 1
-- }
-- setmetatable( c1, Card.mt )

-- ********************************************************************* Perso
Perso = {}
Perso.mt = {} -- metatable that will be shared
function Perso.tostring( perso )
   if perso == nil then
      return "nil"
   end

   local s = "P: " .. perso.name
   s = s .. " l= " .. perso.state.life .. "/" .. perso.life_max
   s = s .. " c="
   for name, val in pairs(perso.state.cards) do
      s = s .. val.id .. ", "
   end

   return s
end
Perso.mt.__tostring = Perso.tostring

function Perso.clone_state( orig )
   -- state is a copy, everything else is same reference
   local clone = {}
   -- get ref to everything except state
   for name, val in pairs(orig) do
      if name ~= "state" then
         clone[name] = val
      end
   end
   -- copy state
   clone.state = {}
   clone.state.life = orig.state.life
   clone.state.cards = {}
   for name, val in pairs(orig.state.cards) do
      table.insert( clone.state.cards, val )
   end
   clone.state.deck = {}
   for name, val in pairs(orig.state.deck) do
      table.insert( clone.state.deck, val )
   end
   setmetatable( clone, Perso.mt ) -- make sur all share same metatable
   return clone
end
function Perso.equal( p1, p2 )
   if p1 == nil and p2 == nil then return true end
   -- same name
   if p1.name ~= p2.name then
      return false
   end
   -- same state
   s1 = p1.state
   s2 = p2.state
   if s1.life ~= s2.life then
      return false
   end
   if not Card.equal_list( s1.cards, s2.cards ) then return false end
   if not Card.equal_list( s1.deck, s2.deck ) then return false end

   return true
end

p_bidule = {
   name = "Bidule",
   agression = 1,
   courage = 1,
   pragmatisme = 0,
   life_max = 6,
   state = {
      life = 6,
      cards = {},
      deck = {}
   }
}
setmetatable( p_bidule, Perso.mt )

-- ******************************************************************* Monster
Monster = {}
Monster.mt = {} -- metatable that will be shared
function Monster.tostring( monster )
   local s = "M: " .. monster.name
   s = s .. " dmg=" .. monster.state.damage .. "/" .. monster.max_damage
   return s
end
Monster.mt.__tostring = Monster.tostring

function Monster.clone_state( orig )
   local clone = {}
    -- get ref to everything except state
   for name, val in pairs(orig) do
      if name ~= "state" then
         clone[name] = val
      end
   end
   -- copy state
   clone.state = {}
   clone.state.damage = orig.state.damage

   setmetatable( clone, Monster.mt ) -- make sur all share same metatable
   return clone
end
function Monster.equal( m1, m2 )
   -- same name
   if m1.name ~= m2.name then
      return false
   end
   -- same state
   if m1.state.damage ~= m2.state.damage then
      return false
   end
   
   return true
end

monster = {
   name = "Monster",
   open_keys = {
      agression = 1,
      courage = 2,
   },
   open_free = 1,
   attack = {
      { limup = 2, effects={-1, "wound_1"} },
      { limup = 4, effects={-2, "wound_2"} },
   },
   max_damage = 7,
   state = {
      damage = 0,
   }
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
      s = s .. Perso.tostring( val ) .. " || "
   end
   s = s .. "}"
   s = s .. "\n  active=" .. Perso.tostring( state.active_perso )
   return s
end
State.mt.__tostring = State.tostring

function init_fight( monster, all_perso )
   local state = {
      -- card_sequence is a list of {carid,state} ?
      card_seq = {monster},
      monster = monster,
      -- still to play is a list of {p_id, state} ?
      still_to_play = {},
      active_perso = nil,
   }
   -- add perso
   for name, p in pairs(all_perso) do
      perso = Perso.clone_state(p)
      perso.state.deck = shuffle_deck(make_deck())
      take_card( perso, perso.state.deck, 3)
      table.insert( state.still_to_play, perso )
   end

   setmetatable( state, State.mt ) -- make sur all share same metatable
   return state
end
function State.clone_state( orig )
   local clone = {
      card_seq = {},
      monster = nil,
      still_to_play = {},
      active_perso = nil,
   }
   for name, val in pairs(orig.card_seq) do
      table.insert( clone.card_seq, val )
   end
   if orig.monster then
      clone.monster = Monster.clone_state( orig.monster )
   end
   for name, val in pairs(orig.still_to_play) do
      table.insert( clone.still_to_play, Perso.clone_state(val) )
   end
   if orig.active_perso then
      clone.active_perso = Perso.clone_state( orig.active_perso )
   end
    setmetatable( clone, State.mt ) -- make sur all share same metatable
   return clone
end
function State.equal( s1, s2)
   -- same card sequence
   if not Card.equal_sequence( s1.card_seq, s2.card_seq ) then
      return false
   end
   -- same monster
   if not Monster.equal( s1.monster, s2.monster ) then
      return false
   end
   -- same perso, active and still to play
   if not Perso.equal( s1.active_perso, s2.active_perso ) then return false end
   if #s1.still_to_play ~= #s2.still_to_play then
      return false
   end
   for idx, p1 in ipairs(s1.still_to_play) do
      -- also in s2 ?
      found = false
      for idx2, p2 in ipairs(s2.still_to_play) do
         if Perso.equal(p1, p2) then
            found = true
            break
         end
      end
      if not found then return false end
   end
   return true
end
   

-- ********************************************************************* Model
function env_transition( state, action )
   new_state = apply_action( state, action.action, action.args )
   -- TODO Reward
   reward = state.monster.state.damage
   return new_state, reward
end

-- WARNING : assume action are VALID -----------------------------------------
function apply_action( state, action, args )
   local new_state = State.clone_state( state )
   new_state = action( new_state, args )
   return new_state
end
function action_play_card( state, args )
   local card = args.card
   local perso = args.perso
   -- update active perso
   if state.active_perso == nil or state.active_perso.name ~= perso.name then
      print( "*** set new clone in state ***" )
      state.active_perso = Perso.clone_state(perso)      
   end
   -- remove card played
   for idx, val in ipairs(state.active_perso.state.cards) do
      if card == val then
         table.remove( state.active_perso.state.cards, idx )
         break
      end
   end
   -- remove from still_to_play
   for idx, val in ipairs(state.still_to_play) do
      if val.name == perso.name then
         table.remove( state.still_to_play, idx )
         break
      end
   end
   -- insert at end of pile
   table.insert( state.card_seq, card )

   -- apply card
   print( Card.disp_open( state.card_seq[#state.card_seq - 1] ))
   print( Card.display( card ))
          
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
   print( "resolve_effect for " .. effect )
   -- number => add to monster.damage
   if type(effect) == 'number' then
      monster.state.damage = monster.state.damage + effect
   elseif effect == "sequence" then
      -- nothing for this effect
   else
      print( "effect " .. effect .. " TODO" )
   end
end


function apply_card (prev_card, card, monster, perso)
   -- Effect of closed keys
   for kname in pairs( prev_card.open_keys ) do
      if card.closed_keys[kname] then
         if perso[kname] >= prev_card.open_keys[kname] then
            print( "  "..kname.." effect can be resolved: " )
            resolve_effect( card.closed_keys[kname], monster, perso)
         else
            print( "  "..kname.." effect CANNOT be resolved" )
         end
      end
   end
   -- magic TODO
   -- free effect
   for i=1,prev_card.open_free do
      resolve_effect( card.closed_free, monster, perso )
   end
end

function apply_attack( monster, perso )
   local limin = 0
   local limup = 0
   for i,atk in ipairs(monster.attack) do
      limup = atk.limup
      print( "  atk in ["..limin..", "..limup.."[")
      if monster.state.damage >= limin and monster.state.damage < limup then
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
               perso.state.life = math.max( 0, perso.state.life - nb_wnd )
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
      table.insert( perso.state.cards, table.remove(deck) )
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

-- ***************************************************************************
-- ******************************************************************* ACTIONS
-- ***************************************************************************
function is_final( s )
   -- is this a final state ?
   -- Either monster is dead or perso out
   if s.monster.state.damage >= s.monster.max_damage then
      return true
   end
   if s.active_perso then
      if s.active_perso.state.life == 0 then
         return true
      end
   end
   -- TODO temporary, final if active_perso out of cards
   if s.active_perso then
      if #s.active_perso.state.cards == 0 then
         return true
      end
   end
   return false
end
function possible_actions( s )
   print( "__POSSIBLE ACTIONS " )
   print( s )
   actions = {}
   -- active perso can play cards
   if s.active_perso then
      -- can pass : monster attack
      table.insert( actions,
                    {
                       action = action_monster_atk,
                       args = {},
                       name = "monster_atk",
      })
      -- or play cards
      local perso = s.active_perso
      for idx, card in ipairs(perso.state.cards) do
         table.insert( actions,
                       {
                          action = action_play_card,
                          args = {
                             perso = perso,
                             card = card },
                          name = "active_play_"..card.title,
         })
      end         
   else
      
      -- others perso can play
      for idp, perso in ipairs(s.still_to_play) do
         for idc, card in ipairs(perso.state.cards) do
            table.insert( actions,
                          {
                             action = action_play_card,
                             args = {
                                perso = perso,
                                card = card },
                             name = perso.name .."_play_"..card.title,
            })
         end
      end
   end

   msg = "  poss. actions : "
   for idx, act in ipairs(actions) do
      msg = msg .. act.name .. ", "
   end
   print( msg )
   return actions
end
function policy_uniform( s )
   print( "__POLICY on ")
   print( s )
   -- must return an action
   -- choose uniformly among possible actions
   actions = possible_actions( s )

   return actions[math.random(#actions)]
end

-- ****************************************************************** TEST_SEQ
--test_sequence()

-- apply_card( monster, cards_larve[4], monster, p_bidule )

-- STATE
-- monster : dammage
-- perso : cards, wounds, deck
-- active perso

-- NODE = {state, {action = next}}

function best_sequence( monster, perso )
   -- make random deck
   local deck = make_deck()
   deck = shuffle_deck( deck )
   -- perso takes 3 cards
   take_card( perso, deck, 3 )
   for idx, val in ipairs(perso.state.cards) do
      print( idx .. " : " .. Card.tostring(val) )
   end
   
   -- check all combination to "greater" results
   best_sequence = {}
   max_damage = 0
   for name, card1 in pairs(perso.state.cards) do
      for name, card2 in pairs(perso.state.cards) do
         if card2 ~= card1 then
            for name, card3 in pairs(perso.state.cards) do
               if card3 ~= card1 and card3 ~= card2 then
                  monster.state.damage = 0
                  print( "__APPLY ")
                  print( Card.disp_open( monster ))
                  print( Card.display( card1 ))

                  apply_card( monster, card1, monster, perso )
                  if is_valid_sequel(card1, card2, perso) then
                     print( Card.display( card2 ))
                     apply_card( card1, card2, monster, perso )
                     if is_valid_sequel(card2, card3, perso) then
                        print( Card.display( card3 ))
                        apply_card( card2, card3, monster, perso )
                     end
                  end
                  print( "==> DMG = " .. monster.state.damage .. "\n" )

                  if monster.state.damage > max_damage then
                     max_damage = monster.state.damage
                     best_sequence = {card1, card2, card3}
                  end
               end
            end
         end
      end
   end
   print( "__BEST SEQUENCE ="..max_damage )
   for name, card in pairs(best_sequence) do
      print( Card.display( card ))
   end
end
--best_sequence( monster, p_bidule )


function try_all_action( state, lvl )
   print( "\n__TRY ALL ".. lvl .. " **********************************************" )
   print("OLD STATE\n" .. State.tostring( state))
   -- if lvl > 1 then
   --    print( "-->STOP" )
   --    return
   -- end
   for name, card in pairs(state.active_perso.state.cards) do
      print( "\n__lvl=" .. lvl .. " APPLY " .. Card.tostring( card ) )
      new_state = apply_action( state, action_play_card, {perso = state.active_perso,
                                                          card = card })
      print("NEW STATE\n" .. State.tostring( new_state))
      try_all_action( new_state, lvl+1)
   end
end

function test_sequence()
   l_states = {}
   print( "__INIT Fight" )
   state = init_fight( monster, {p_bidule} )
   state.active_perso = state.still_to_play[1]
   table.remove( state.still_to_play )
   print( state )
   try_all_action( state, 0 )
end
-- test_sequence()

-- print( state )

-- print( "\n__ACTION play card" )
-- state = apply_action( state, action_play_card, {perso = state.still_to_play[1],
--                                                 card = state.still_to_play[1].state.cards[1] } )
-- table.insert( l_states, state )
-- print(state)

-- print( "\n__ACTION play card" )
-- state = apply_action( state, action_play_card, {perso = state.active_perso,
--                                                 card = state.active_perso.state.cards[1] } )
-- table.insert( l_states, state )
-- print(state)

-- print( "\n__ACTION play card" )
-- state = apply_action( state, action_play_card, {perso = state.active_perso,
--                                                 card = state.active_perso.state.cards[1] } )
-- table.insert( l_states, state )
-- print(state)


-- print( "__101 " )
-- print( cards_larve[1] )
-- print( Card.display( cards_larve[1] ))
