-- local rand = PseudoRandom(1234)

minetest.register_abm({
	nodenames = {"default:dirt_with_grass", "default:dirt_with_rainforest_litter", "default:dirt_with_coniferous_litter"},
	interval = 60, -- Run every minute
    chance = 100, -- One node has a chance of 1 in 100 to get selected
    action = function(pos, node, active_object_count,
            active_object_count_wider)
		local pos = {x = pos.x, y = pos.y + math.random(1,6), z = pos.z}
		if not minetest.find_node_near(pos, 25, "fireflies:firefly") 
		and not minetest.find_node_near(pos, 25, "fireflies:hidden_firefly") -- if there is *not* a firefly within 25 nodes
		and (minetest.get_timeofday() < 0.25 or minetest.get_timeofday() > 0.75) -- and it is nighttime
		and minetest.get_node(pos).name == "air" then -- and the node at the checked position is air
			minetest.set_node(pos, {name = "fireflies:firefly"}) -- create a flashy friend
			minetest.get_node_timer(pos):start(1)
		end
    end
})
