-- MCTS on TaintedGrail Combat
require( "tg_combat" )

MCTS = {
   K = 1.0
}

-- ***************************************************************************
-- ********************************************************************** Node
-- ***************************************************************************
Node = {
   id=0
}
DNode = {}
DNode.mt = {} -- metatable that will be shared
function DNode.tostring( node )
   local s = "DNode " .. node.id .. " *************\n"
   s = s .. "n=" .. node.nb
   s = s .. " with " .. node.nb_child .. " childs\n"
   s = s .. State.tostring( node.state )
   return s
end
DNode.mt.__tostring = DNode.tostring
function DNode.add_anode_child( dnode, action, anode )
   dnode.child[action.name] = anode
   dnode.nb_child = dnode.nb_child + 1
   anode.father = dnode
end

Tree = {}
function Tree.tostring( tree, before )
   local s = before.." "
   s = s .. DNode.tostring( tree )
   if tree.nb_child > 0 then
      for act_name, anode in pairs(tree.child) do
         --print( "Tree.anode with "..before..":"..tree.id )
         s = s .. "\n" .. Tree.anodestring( anode, before..":"..tree.id )
      end
   end
   return s
end
function Tree.anodestring( anode, before )
   local s = before.." "
   s = s .. ANode.tostring( anode )
   if anode.nb_child > 0 then
      for idx, dnode in ipairs(anode.child) do
         s = s .. "\n" .. Tree.tostring( dnode, before..">"..anode.action.name )
      end
   end
   return s
end

function make_dnode( state )
   dnode = {
      id = Node.id,
      state = state,
      nb = 0,
      -- childs are a -> ANode{Q}
      child = {},
      nb_child = 0,
      father = nil,
   }
   Node.id = Node.id + 1
   setmetatable(dnode, DNode.mt )
   return dnode
end

ANode = {}
ANode.mt = {} -- metatable that will be shared
function ANode.tostring( node )
   local s = "ANode " .. node.id .. " *************\n"
   s = s .. "act = " .. node.action.name .. "\n"
   s = s .. "n=" .. node.nb
   s = s .. " cr=" .. node.cr
   s = s .. " r=" .. node.reward
   s = s .. " with " .. node.nb_child .. " childs\n"
   s = s .. State.tostring( node.state )
   return s
end
ANode.mt.__tostring = ANode.tostring
function ANode.add_dnode_child( anode, dnode )
   table.insert( anode.child, dnode )
   anode.nb_child = anode.nb_child + 1
   dnode.father = anode
end
function make_anode( state, action )
   anode = {
      id = Node.id,
      state = state,
      action = action,
      cr = 0,
      nb = 0,
      reward = 0,
      -- childs are DNodes
      child = {},
      nb_child = 0,
      father = nil,
   }
   Node.id = Node.id + 1
   setmetatable(anode, ANode.mt )
   return anode
end

function growtree( tree_root, model, policy )
   --
   -- Params:
   -- - tree_root : root DNode of a MCTS
   -- - model : function transition of MDP next_state,r = model(state, action)
   -- - policy : default policy action = policy( state )
   
   -- initialize
   cur_node = tree_root
   cr = 0
   -- find a leaf
   repeat 
      action = select_action( cur_node, MCTS.K )
      print( "  will apply action=" .. action.name )
      next_s,reward = model( cur_node.state, action )

      -- add anode if needed
      if not cur_node.child[action.name] then
         print( "__ADDING ANODE to Node.id=" .. cur_node.id )
         next_anode = make_anode( cur_node.state, action )
         DNode.add_anode_child( cur_node, action, next_anode )
         print( Tree.tostring( cur_node, "AFTER ADD" ))
      end
      anode = cur_node.child[action.name]
      anode.reward = reward
      print( ANode.tostring( anode ))

      -- add dnode if needed
      next_dnode = nil
      for idx, dnode in ipairs(anode.child) do
         if State.equal( dnode.state, next_s ) then
            next_dnode = dnode
            print( "__FOUND next DNODE as Node.id=" .. dnode.id )
            break
         end
      end
      -- TODO check have equal state when copy
      if next_dnode == nil then
         print( "__ADDING DNODE to Node.id=" .. anode.id )
         next_dnode = make_dnode( next_s )
         ANode.add_dnode_child( anode, next_dnode )
         print( Tree.anodestring( anode, "AFTER ADD" ))
      end
      cur_node = next_dnode
   until cur_node.nb == 0 or is_final( cur_node.state )
   
   print( "-- Evaluate Leaf Node" )
   cr = eval( cur_node, model, policy )
   print( "   cr=" .. cr )

   -- go up and update
   --cur_node.nb = cur_node.nb +1
   while cur_node ~= tree_root do
      print( " updating node " .. cur_node.id )
      cur_node.nb = cur_node.nb +1
      -- get father anode, then dnode
      a_node = cur_node.father
      cr = cr + a_node.reward
      a_node.cr = a_node.cr + cr
      a_node.nb = a_node.nb + 1
      -- up to d_node
      cur_node = a_node.father
   end
end

function select_action( x, K)
   -- all possible actions
   actions = possible_actions( x.state )
   -- argmax of \hat{Q}
   best_a = {}
   best_q = -math.huge
   for idx, act in ipairs(actions) do
      -- in the current (x,a) child nodes ?
      hatq = math.huge
      if x.child[act] and x.child[act].nb > 0 then
         an = child[act]
         hatq = an.cr / an.nb + K * math.sqrt( math.log( x.nb ) / (an.nb ) )
      end
            
      if hatq > best_q then
         best_a = {act}
         best_q = hatq
      elseif hatq == best_q then
            table.insert( best_a, act )
      end
   end         

   sel_action =  best_a[math.random(#best_a)]
   print( "__SELECT action " .. sel_action.name .. " Q=" .. best_q  )
   return sel_action
end

-- eval( x:state, model, policy ) -> r
-- Evaluate a lead node by applying the given policy
function eval( x, model, policy )
   r = 0
   state = x.state
   while not is_final( state ) do
      action = policy( state )
      print( "next action=" .. action.name )
      next_s,reward = model( state, action )
      r = r + reward
      state = next_s
   end
   return r
end

-- ***************************************************************************
-- **************************************************************** test nodes
-- ***************************************************************************
function test_node_eq()
   state = init_fight( monster, {p_bidule} )
   print( state )

   d1 = make_dnode( state )
   d1bis = make_dnode( state )
   eq11 = d1.state == d1bis.state
   print( "d1.state == d1bis.state : " .. tostring(eq11) )
   same11 = State.equal( d1.state, d1bis.state )
   print( "d1.state EQ d1bis.state : " .. tostring(same11) )
   
   clone_s = State.clone_state( state )
   d2 = make_dnode( clone_s )
   eq12 = d1.state == d2.state
   print( "d1.state == d2.state : " .. tostring(eq12) )
   same12 = State.equal( d1.state, d2.state )
   print( "d1.state EQ d2.state : " .. tostring(same12) )

   seq_s = State.clone_state( state )
   print( seq_s )
   table.insert( seq_s.card_seq, cards_larve["l01"] )
   table.insert( seq_s.card_seq, cards_larve["l02"] )
   print( seq_s )
   s2 = make_dnode( seq_s )
   same22 = State.equal( s2.state, d2.state )
   print( "s2.state EQ d2.state : " .. tostring(same22))
   print( d2 )
   print( s2 )
   table.insert( d2.state.card_seq, cards_larve["l02"] )
   same22 = State.equal( s2.state, d2.state )
   print( "s2.state EQ d2.state : " .. tostring(same22))
   table.insert( d2.state.card_seq, cards_larve["l01"] )
   same22 = State.equal( s2.state, d2.state )
   print( "s2.state EQ d2.state : " .. tostring(same22))
   print( d2 )
   
   list_s = State.clone_state( state )
   l2 = make_dnode( list_s )
   table.insert( l2.state.card_seq, cards_larve["l02"] )
   same22l = State.equal( s2.state, l2.state )
   print( "s2.state EQ l2.state : " .. tostring(same22l))
   table.insert( l2.state.card_seq, cards_larve["l01"] )
   same22l = State.equal( s2.state, l2.state )
   print( "s2.state EQ l2.state : " .. tostring(same22l))
   print( l2 )
   same2d2l = State.equal( d2.state, l2.state )
   print( "d2.state EQ l2.state : " .. tostring(same2d2l))
   
end
--test_node_eq()
-- ***************************************************************************
-- ***************************************************************** TEST MCTS
-- ***************************************************************************
function test_mcts()
   print( "__INIT MCTS _______________________" )
   state = init_fight( monster, {p_bidule} )
   tree = make_dnode( state )
   print( Tree.tostring(tree, "T") )

   for i=1,10 do
      print( "\n__GROWTREE " .. i .. "________________________" )
      growtree( tree, env_transition, policy_uniform )
      print( Tree.tostring(tree, "T") )
   end
   
end
test_mcts()
