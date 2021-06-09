c1 = {
   id = 1,
   closed_keys = {
      agression = { effect=3 },
      courage = { effect=2 },
   },
   free_key = 1
}

p_bidule = {
   name = "Bidule",
   agression = 1,
   courage = 1,
   pragmatisme = 0,
}

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
}

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
print( "__Apply c1 on monster" )
apply_card( monster, c1, monster, p_bidule )
print( "=> Monster dmg="..monster.damage )

print( "__Apply attack of Monster" )
apply_attack( monster, p_bidule )
print( "=> Monster dmg="..monster.damage )

   
