-- ********************************************************************** Card
Card = {}
Card.mt = {} -- metatable that will be shared
function Card.tostring( card )
   local s = "C: " .. card.title .. " (" .. card.id .. ")"
   return s
end
Card.mt.__tostring = Card.tostring

function Card.disp_open( card )
   local s = "   "
   if card.open_keys.agression then
      if card.open_keys.agression == 2 then
         s = s .. "A"
      else
         s = s .. "a"
      end
   else
      s = s .. "."
   end
   if card.open_keys.courage then
      if card.open_keys.courage == 2 then
         s = s .. "C"
      else
         s = s .. "c"
      end
   else
      s = s .. "."
   end
   if card.open_keys.pragmatisme then
      if card.open_keys.pragmatisme == 2 then
         s = s .. "P"
      else
         s = s .. "p"
      end
   else
      s = s .. "."
   end
   s = s .. "_"
   if card.open_magic then
      s = s .. "m"
   else
      s = s .. "."
   end
   s = s .. "_"
   s = s .. card.open_free
   -- if card.open_free == 2 then
   --    s = s .. "2"
   -- elseif card.open_free == 1 then
   --    s = s .. "1"
   -- elseif card.open_free == 0 then
   --    s = s .. "0"
   -- elseif card.open_free == "NEG" then
   --    s = s .. "X"
   -- end

   return s
end
function Card.disp_effect( effect )
   if effect == nil then
      return "."
   end
   local s = ""
   if type(effect) == 'number' then
      s = s .. effect
   elseif effect == "sequence" then
      s = s .. "S"
   elseif effect == "card" then
      s = s .. "C"
   elseif effect == "nothing" then
      s = s .. "x"
   else
      s = s .. "?"
   end
   return s
end
function Card.disp_closed( card )
   local s = "C: "
   s = s .. Card.disp_effect( card.closed_keys.agression )
   s = s .. Card.disp_effect( card.closed_keys.courage )
   s = s .. Card.disp_effect( card.closed_keys.pragmatisme )
   s = s .. "_"
   s = s .. Card.disp_effect( card.closed_magic )
   s = s .. "_"
   s = s .. Card.disp_effect( card.closed_free )
   return s
end
function Card.display( card, offset)
   if offset == nil then
      offset = ""
   end
   local s = offset .. Card.disp_closed( card )
   s = s .. " «" .. card.title .. "»" .. " (" .. card.id .. ")"
   s = s .. "\n" .. offset .. Card.disp_open( card )
   return s
end

function Card.equal_sequence( l1, l2 )
   -- same length and same order
   if #l1 ~= #l2 then
      return false
   end
   for idx, val in ipairs(l1) do
      if l1[idx] ~= l2[idx] then
         return false
      end
   end
   return true
end

function Card.equal_list( l1, l2 )
   -- same length and in other
   if #l1 ~= #l2 then
      return false
   end
   for idx, val1 in ipairs(l1) do
      -- also in l2 ?
      found = false
      for idx2, val2 in ipairs(l2) do
         if val1 == val2 then
            found = true
            break
         end
      end
      if not found then return false end
   end
   return true
end
   


-- *****************************************************************************
-- *********************************************************************** LARVE
-- *****************************************************************************
cards_larve = {
   l01 = {
      id="l01",
      title="En Garde",
      closed_keys = {
      },
      closed_magic = "sequence",
      closed_free = "nothing",
      open_keys = {
         agression =1,
         courage = 1,
         pragmatisme = 1,
      },
      open_magic = 1,
      open_free = 2,
      power="END: choisissez atk de ennemi sauf repli; DEFAUSSE après atk",
   },
   l02 = {
      id="l02",
      title="Attaque",
      closed_keys = {
         agression = 1,
      },
      closed_free = 1,
      open_keys = {
         agression = 2,
         courage = 1,
      },
      open_magic = 1,
      open_free = 1,
      power="END: 1 wound; DELAY 1 card;",
   },
   l03 = {
      id="l03",
      title="Rassembler ses pensées",
      closed_keys = {
         pragmatisme = "sequence",
      },
      closed_magic = "sequence",
      closed_free = "nothing",
      open_keys = {
         courage = 1,
         pragmatisme = 1,
      },
      open_free = 2,
      power="DELAY -2, 2 card",
   },
   l04 = {
      id="l04",
      title="Coup Final",
      closed_keys = {
         agression = 2,
         courage = "sequence",
      },
      closed_magic = 1,
      closed_free = 1,
      open_keys = {
      },
      open_free = 0,
      power="END: -2, 1 wound",
   },
   l05 = {
      id="l05",
      title="Maléfice",
      closed_keys = {
        pragmatisme = "card",
      },
      closed_magic = 2,
      closed_free = 1,
      open_keys = {
         courage = 1,
         pragmatisme = 1,
      },
      open_magic = 1,
      open_free = 2,
      power="INST 1 pour chaque magic_full contre violet",
   },
   l06 = {
      id="l06",
      title="Magie Guerrière",
      closed_keys = {
         agression = 1,
      },
      closed_magic = "sequence",
      closed_free = 1,
      open_keys = {
         agression =1,
         pragmatisme = 1,
      },
      open_free = 2,
      power="INST 1 terror; DELAY 2",
   },
   l07 = {
      id="l07",
      title="Repositionnement",
      closed_keys = {
      },
      closed_free = "sequence",
      open_keys = {
         agression =1,
         courage = 1,
         pragmatisme = 1,
      },
      open_magic = 1,
      open_free = 1,
      power="SI fuite NO Opportunity",
   },
   l08 = {
      id="l08",
      title="Défense",
      closed_keys = {
         pragmatisme = "sequence",
      },
      closed_magic = "sequence",
      closed_free = "nothing",
      open_keys = {
         agression =1,
         pragmatisme = 1,
      },
      open_magic = 1,
      open_free = 2,
      power="END: -2 wound; DELAY 1 card",
   },
   l09 = {
      id="l09",
      title="Charge",
      closed_keys = {
         agression = 1,
         courage = "sequence",
      },
      closed_free = 1,
      open_keys = {
         agression =2,
         courage = 1,
      },
      open_free = 1,
      power="END: 1 wound; DELAY 1 card",
   },
   l10 = {
      id="l10",
      title="Piège Entravant",
      closed_keys = {
         pragmatisme = "sequence",
      },
      closed_magic = "sequence",
      closed_free = "card",
      open_keys = {
         agression =1,
         courage = 1,
         pragmatisme = 1,
      },
      open_free = 0,
      power="END NO atk, -1, DEFAUSSE",
   },
   l11 = {
      id="l11",
      title="Trouver la Faiblesse",
      closed_keys = {
      },
      closed_magic = "sequence",
      closed_free = "card",
      open_keys = {
         pragmatisme = 2,
      },
      open_magic = 1,
      open_free = 3,
      power="END 1 wound; DELAY card",
   },
   l12 = {
      id="l12",
      title="Distraction",
      closed_keys = {
         pragmatisme = 1,
      },
      closed_free = "sequence",
      open_keys = {
         agression =1,
         courage = 1,
      },
      open_free = 1,
      power="END SI x wounds ALORS -x INSTEAD",
   },
   l13 = {
      id="l13",
      title="Attaque Prudente",
      closed_keys = {
         agression = 1,
         pragmatisme = "sequence",
      },
      closed_free = 1,
      open_keys = {
         agression =1,
         courage = 1,
         pragmatisme = 1,
      },
      open_free = 2,
      power="END annule -1, annule 1 wound",
   },
   l14s = {
      id="l14s",
      title="Magie du Sang",
      closed_keys = {
         courage = "sequence",
      },
      closed_magic = "card",
      closed_free = "nothing",
      open_keys = {
         agression =1,
         courage = 2,
      },
      open_magic = 1,
      open_free = 1,
      power="ALWAYS + INST -1 Vie, 3 charges; charge = magie",
   },
   l15 = {
      id="l15",
      title="Attaque Risquée",
      closed_keys = {
         courage = "card",
         pragmatisme = 1,
      },
      closed_free = 1,
      open_keys = {
         agression = 2,
         pragmatisme = 2,
      },
      open_free = 1,
      power="INST p0.5 2 wound / p0.5 2",
   },
   l14 = {
      id="l14",
      title="Cris de Guerre",
      closed_keys = {
         courage = "sequence",
      },
      closed_magic = 1,
      closed_free = "card",
      open_keys = {
         agression =1,
         courage = 1,
      },
      open_free = 1,
      power="END annule 1 wound",
   },
}
for name, val in pairs(cards_larve) do
   setmetatable(val, Card.mt )
end
   

   
