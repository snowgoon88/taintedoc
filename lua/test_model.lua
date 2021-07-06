-- Manuel test of Model
require( "tg_combat" )

-- *********************************************************************** CMD
function parse_cmd( ans )
   if ans == "q" then
      print( "__QUIT" )
      os.exit()
   end
   --help
   if ans == "h" then
      print( "  q: QUIT" )
      print( "  ss :  SHOW state" )
      print( "  sm :  SHOW monster" )
      print( "  spc : SHOW all player cards" )
      print( "  show card_key : SHOW the given card" )
      print( "  pa :  SHOW possible actions " )
      print( "  act action_name : apply the given action " )
      print( "  re : RESET" )
      return
   end
   -- RESET
   if ans == "re" then
      state = init_fight( monster, {p_bidule} )
      return
   end
   -- Possible Actions
   if ans == "pa" then
      actions = possible_actions( state )
      return
   end
   -- apply action
   s, e = string.find( ans, "act ")
   if s == 1 then
      act_name = string.sub( ans, 1+string.len("act ") )
      actions = possible_actions( state )
      for idx, act in ipairs(actions) do
         i, j = string.find( act.name, act_name )
         if i == 1 then
            new_state, reward = env_transition( state, act )
            print( "__NEW STATE r=" .. reward )
            print( new_state )
            state = new_state
            return
         end
      end
      return
   end
   -- show state
   if ans == "ss" then
      print( state )
      return
   end
   -- show monster
   if ans == "sm" then
      print( state.monster )
      print( Card.disp_open( monster ) )
      return
   end
   -- show all player card for active or still_to_play[1]
   if ans == "spc" then
      perso = state.active_perso
      if perso == nil then
         perso = state.still_to_play[1]
      end
      if perso ~= nil then
         for key, card in pairs(perso.state.cards) do
            print( Card.display(card) )
         end
      end
      return
   end
   -- show particular card
   s, e = string.find( ans, "show ")
   print( s , e)
   if s == 1 then
      card_name = string.sub( ans, 1+string.len("show ") )
      print( "__SHOW ".."-"..card_name.."-" )
      print( Card.display(cards_larve[card_name]) )
   end
   -- 
end

-- *********************************************************************** I/O
print( "__INIT MCTS _______________________" )
state = init_fight( monster, {p_bidule} )

while true do
   io.stdout:write( "choice > " )
   local ans = io.stdin:read()
   print( "READ -"..ans.."-" )
   parse_cmd( ans )
end



