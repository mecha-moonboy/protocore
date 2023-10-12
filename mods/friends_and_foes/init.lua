friends_foes = {}

local path = minetest.get_modpath("friends_foes")

-- dofile(path.."/api/behaviors.lua")


friends_foes.entities = {
    "friends_foes:individual"
}

for i = 1, #friends_foes.entities do
	local name = friends_foes.entities[i]:split(":")[2]
	dofile(path.."/entities/" .. name .. ".lua")
end

if minetest.settings:get_bool("spawn_mobs", true) then
	dofile(path.."/api/spawning.lua")
end

minetest.register_on_mods_loaded(function() -- when this mod is loaded with other mods
    for name, def in pairs(minetest.registered_entities) do -- for each key/value pair in registered entities
        if def.logic -- if the entitiy definition contains logic
		or def.brainfunc -- or a brain
		or def.bh_tree -- or a behavior tree
		or def._cmi_is_mob then -- or whatever this means
            
            
			local old_punch = def.on_punch -- store the old punch function
			if not old_punch then -- if there is no on_punch function
				old_punch = function() end -- create an empty function
			end
            
            -- augment the on_punch function by wrapping it in another
			local on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir, damage)
                -- execute the old definition of on_punch, this is why old_punch cannot be nil
				old_punch(self, puncher, time_from_last_punch, tool_capabilities, dir, damage)
                
                -- get the position of the punched object
				local pos = self.object:get_pos()
                
				if not pos then return end -- if position is nil, return
                
                -- if the puncher is a player, get their name
				local plyr_name = puncher:is_player() and puncher:get_player_name()
                -- if the puncher is a player that has pets or [empty]?
				local pets = (plyr_name and animalia.pets[plyr_name]) or {}
                
				for _, obj in ipairs(pets) do -- for each pet
					local ent = obj and obj:get_luaentity() -- if pet isn't nil and it contains a luaentity
					if ent
					and ent.assist_owner then -- and assist_owner is non-nil or true
						ent.owner_target = self -- idk, honestly
					end
				end
			end
			def.on_punch = on_punch -- assign the new value
			minetest.register_entity(":" .. name, def) -- register the entity
		end
    end
end)

minetest.log("action", "[MOD] Friends and Foes [0.0.0] loaded")