-- fire/init.lua

-- Global namespace for functions
fire = {}

-- Load support for MT game translation.
local S = minetest.get_translator("fire")

-- 'Enable fire' setting
local fire_enabled = minetest.settings:get_bool("enable_fire")
if fire_enabled == nil then
	-- enable_fire setting not specified, check for disable_fire
	local fire_disabled = minetest.settings:get_bool("disable_fire")
	if fire_disabled == nil then
		-- Neither setting specified, check whether singleplayer
		fire_enabled = minetest.is_singleplayer()
	else
		fire_enabled = not fire_disabled
	end
end

--
-- Items
--

-- Flood flame function
local function flood_flame(pos, _, newnode)
	-- Play flame extinguish sound if liquid is not an 'igniter'
	if minetest.get_item_group(newnode.name, "igniter") == 0 then
		minetest.sound_play("fire_extinguish_flame",
			{pos = pos, max_hear_distance = 16, gain = 0.15}, true)
	end
	-- Remove the flame
	return false
end

-- Flame nodes
local fire_node = {
	drawtype = "firelike",
	description = "Fire",
	tiles = {{
		name = "fire_medium_flame_animated.png",
		animation = {
			type = "vertical_frames",
			aspect_w = 16,
			aspect_h = 16,
			length = 1
		}}
	},
	inventory_image = "fire_basic_flame.png",
	paramtype = "light",
	light_source = 13,
	walkable = false,
	buildable_to = true,
	sunlight_propagates = true,
	floodable = true,
	damage_per_second = 4,
	groups = {igniter = 2, dig_immediate = 3, fire = 1, not_in_creative_inventory = 1},
	drop = "",
	on_flood = flood_flame
}

-- Small flame node
local small_flame_fire_node = table.copy(fire_node)
--flame_fire_node.description = S("Fire")
--flame_fire_node.groups.not_in_creative_inventory = 1
small_flame_fire_node.tiles = {{
	name = "fire_small_flame_animated.png",
	animation = {
		type = "vertical_frames",
		aspect_w = 16,
		aspect_h = 16,
		length = 1
	}
}}

small_flame_fire_node.on_timer = function(pos) -- execute occasionally

	local p = minetest.find_node_near(pos:offset(0, -1, 0), 1, {"group:flammable"})
	if not p then -- if there isn't a flammable node within radius 1
		minetest.remove_node(pos) -- remove this flame node
		return
	end
	--local flammability = minetest.get_item_group(minetest.get_node(p).name, "flammable")
	minetest.log("log", "uuuuuh... the node called " .. minetest.get_node(p).name .. " is flammable")
	if minetest.get_item_group(minetest.get_node(p).name, "flammable") >= 2 then
		minetest.set_node(pos, {name = "fire_2:medium_flame"})
	end
	-- Restart timer if there is a flammable node
	return true
end

small_flame_fire_node.on_construct = function(pos)
	minetest.get_node_timer(pos):start(math.random(8, 16))
end

minetest.register_node("fire_2:small_flame", small_flame_fire_node)

-- Medium flame node
local medium_flame_fire_node = table.copy(fire_node)
--flame_fire_node.description = S("Fire")
medium_flame_fire_node.tiles = {{
	name = "fire_medium_flame_animated.png",
	animation = {
		type = "vertical_frames",
		aspect_w = 16,
		aspect_h = 16,
		length = 1
	}}
}

medium_flame_fire_node.on_timer = function(pos) -- execute occasionally

	local near_node = minetest.find_node_near(pos, 1, {"group:flammable"})
	if not near_node then -- if there isn't a flammable node within radius 1
		minetest.remove_node(pos) -- set this flame node to a small flame
		return
	end

	if minetest.get_item_group(near_node.name, "flammable") >= 2 then
		minetest.set_node(pos, {name = "fire_2:large_flame"})
	end
	-- Restart timer if there is a flammable node
	return true
end
medium_flame_fire_node.on_construct = function(pos)
	minetest.get_node_timer(pos):start(math.random(8, 16))
end

minetest.register_node("fire_2:medium_flame", medium_flame_fire_node)

-- Large flame node
local large_flame_fire_node = table.copy(fire_node)
--flame_fire_node.description = S("Fire")
large_flame_fire_node.tiles = {{
	name = "fire_large_flame_animated.png",
	animation = {
		type = "vertical_frames",
		aspect_w = 16,
		aspect_h = 16,
		length = 1
	}}
}
--flame_fire_node.groups.not_in_creative_inventory = 1
large_flame_fire_node.on_timer = function(pos) -- execute occasionally

	-- this segment could be rewritten
	--local under_node = minetest.get_node({pos.x, pos.y - 1, pos.z})
	-- if there isn't a flammable node within radius 1
	local near_node = minetest.find_node_near(pos, "group:flammable")
	if not near_node then
		minetest.set_node(pos, {name = "fire_2:medium_flame"})
	end
	-- Restart timer if there is a flammable node
	return true
end
large_flame_fire_node.on_construct = function(pos)
	minetest.get_node_timer(pos):start(math.random(8, 16))
end

minetest.register_node("fire_2:large_flame", large_flame_fire_node)



-- Permanent flame node
local permanent_fire_node = table.copy(fire_node)
permanent_fire_node.description = S("Permanent Fire")

minetest.register_node("fire_2:permanent_flame", permanent_fire_node)

-- Flint and Steel
minetest.register_tool("fire_2:flint_and_steel", {
	description = S("Flint and Steel"),
	inventory_image = "fire_flint_steel.png",
	sound = {breaks = "default_tool_breaks"},

	on_use = function(itemstack, user, pointed_thing)
		local sound_pos = pointed_thing.above or user:get_pos()
		minetest.sound_play("fire_flint_and_steel",
			{pos = sound_pos, gain = 0.2, max_hear_distance = 8}, true)
		local player_name = user:get_player_name()
		if pointed_thing.type == "node" then
			local node_under = minetest.get_node(pointed_thing.under).name
			local nodedef = minetest.registered_nodes[node_under]
			if not nodedef then
				return
			end
			if minetest.is_protected(pointed_thing.under, player_name) then
				minetest.chat_send_player(player_name, "This area is protected")
				return
			end
			if math.random(1, 8) == 1 then
				if nodedef.on_ignite then
					nodedef.on_ignite(pointed_thing.under, user)
				elseif minetest.get_item_group(node_under, "flammable") >= 1
						and minetest.get_node(pointed_thing.above).name == "air" then
					minetest.set_node(pointed_thing.above, {name = "fire_2:small_flame"})
				end
			end
		end
		if not minetest.is_creative_enabled(player_name) then
			-- Wear tool
			local wdef = itemstack:get_definition()
			itemstack:add_wear_by_uses(66)

			-- Tool break sound
			if itemstack:get_count() == 0 and wdef.sound and wdef.sound.breaks then
				minetest.sound_play(wdef.sound.breaks,
					{pos = sound_pos, gain = 0.5}, true)
			end
			return itemstack
		end
	end
})

minetest.register_craft({
	output = "fire_2:flint_and_steel",
	recipe = {
		{"default:flint", "default:steel_ingot"}
	}
})

-- Crucible
minetest.register_node("fire_2:crucible", {
	description = "Crucible",
	drop = "fire_2:crucible",
	walkable = true,  -- If true, objects collide with node

    pointable = true,  -- If true, can be pointed at

    diggable = true,  -- If false, can never be dug
	
	on_timer = function(pos, elapsed)
		
		-- check the flame beneath
		local under = {pos.x, pos.y - 1, pos.z}
		local block_below = minetest.get_node(under)
		
		local cook_speed = 8
		
		-- if block_below.name == "fire_2:small_flame" then
		-- 	-- heat things slower
		-- 	-- cook only foods
		-- else if block_below.name == "fire_2:medium_flame" then
		-- 	-- heat things regular speed
		-- 	-- 
		-- else if block_below.name == "fire_2:large_flame" then
		-- 	-- heat things fast
		-- end
		
		
		-- cook/smelt contents based on heat of flame
		
		minetest.get_node_timer(pos):start(cook_speed)
	end
}
)

-- Override coalblock to enable permanent flame above
-- Coalblock is non-flammable to avoid unwanted basic_flame nodes
minetest.override_item("default:coalblock", {
	after_destruct = function(pos)
		pos.y = pos.y + 1
		if minetest.get_node(pos).name == "fire_2:permanent_flame" then
			minetest.remove_node(pos)
		end
	end,
	on_ignite = function(pos)
		local flame_pos = {x = pos.x, y = pos.y + 1, z = pos.z}
		if minetest.get_node(flame_pos).name == "air" then
			minetest.set_node(flame_pos, {name = "fire_2:permanent_flame"})
		end
	end
})


--
-- Sound
--

-- Enable if no setting present
local flame_sound = minetest.settings:get_bool("flame_sound", true)

if flame_sound then
	local handles = {}
	local timer = 0

	-- Parameters
	local radius = 8 -- Flame node search radius around player
	local cycle = 3 -- Cycle time for sound updates

	-- Update sound for player
	function fire.update_player_sound(player)
		local player_name = player:get_player_name()
		-- Search for flame nodes in radius around player
		local ppos = player:get_pos()
		local areamin = vector.subtract(ppos, radius)
		local areamax = vector.add(ppos, radius)
		local fpos, num = minetest.find_nodes_in_area(
			areamin,
			areamax,
			{"fire_2:medium_flame", "fire_2:permanent_flame"}
		)
		-- Total number of flames in radius
		local flames = (num["fire_2:medium_flame"] or 0) +
			(num["fire_2:permanent_flame"] or 0)
		-- Stop previous sound
		if handles[player_name] then
			minetest.sound_stop(handles[player_name])
			handles[player_name] = nil
		end
		-- If flames
		if flames > 0 then
			-- Find centre of flame positions
			local fposmid = fpos[1]
			-- If more than 1 flame
			if #fpos > 1 then
				local fposmin = areamax
				local fposmax = areamin
				for i = 1, #fpos do
					local fposi = fpos[i]
					if fposi.x > fposmax.x then
						fposmax.x = fposi.x
					end
					if fposi.y > fposmax.y then
						fposmax.y = fposi.y
					end
					if fposi.z > fposmax.z then
						fposmax.z = fposi.z
					end
					if fposi.x < fposmin.x then
						fposmin.x = fposi.x
					end
					if fposi.y < fposmin.y then
						fposmin.y = fposi.y
					end
					if fposi.z < fposmin.z then
						fposmin.z = fposi.z
					end
				end
				fposmid = vector.divide(vector.add(fposmin, fposmax), 2)
			end
			-- Play sound
			local handle = minetest.sound_play("fire_fire", {
				pos = fposmid,
				to_player = player_name,
				gain = math.min(0.06 * (1 + flames * 0.125), 0.18),
				max_hear_distance = 32,
				loop = true -- In case of lag
			})
			-- Store sound handle for this player
			if handle then
				handles[player_name] = handle
			end
		end
	end

	-- Cycle for updating players sounds
	minetest.register_globalstep(function(dtime)
		timer = timer + dtime
		if timer < cycle then
			return
		end

		timer = 0
		local players = minetest.get_connected_players()
		for n = 1, #players do
			fire.update_player_sound(players[n])
		end
	end)

	-- Stop sound and clear handle on player leave
	minetest.register_on_leaveplayer(function(player)
		local player_name = player:get_player_name()
		if handles[player_name] then
			minetest.sound_stop(handles[player_name])
			handles[player_name] = nil
		end
	end)
end


-- Deprecated function kept temporarily to avoid crashes if mod fire nodes call it
function fire.update_sounds_around() end

--
-- ABMs
--

if fire_enabled then
	-- Ignite neighboring nodes, add basic flames
	minetest.register_abm({
		label = "Ignite flame",
		nodenames = {"fire_2:small_flame", "fire_2:medium_flame"},
		neighbors = {"group:igniter", "group:flammable"},
		interval = 1,
		chance = 1,
		catch_up = false,
		action = function(pos)
			local p = minetest.find_node_near(pos:offset(0, -1, 0), 1, {"group:flammable"})
			if not p then return end
			local flammability = minetest.get_item_group(minetest.get_node(p).name, "flammable")
			local above_p = p:offset(0, 1, 0)
			local above_node = minetest.get_node(above_p)
			if above_node.name == "ignore" or above_node.name == "air" and
			math.random(1, 8 - flammability) == 1 then
				minetest.log("log", "flammable: " .. flammability)
				minetest.set_node(above_p, {name = "fire_2:small_flame"})
			end
		end
	})

	-- Remove flammable nodes around basic flame
	minetest.register_abm({
		label = "Remove flammable nodes",
		nodenames = {"fire_2:medium_flame", "fire_2:small_flame", "fire_2:large_flame"},
		neighbors = "group:flammable",
		interval = 5,
		chance = 18,
		catch_up = false,
		action = function(pos)
			local p = minetest.find_node_near(pos, 1, {"group:flammable"})
			if not p then
				return
			end
			local flammable_node = minetest.get_node(p)
			local def = minetest.registered_nodes[flammable_node.name]
			if math.random(1, 4) == 1 then
					if def.on_burn then
					def.on_burn(p)
				else
					minetest.remove_node(p)
					minetest.check_for_falling(p)
				end
			end
		end
	})
end