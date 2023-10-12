local builtin_item = minetest.registered_entities["__builtin:item"]

local item = {
    set_item = function(self, itemstring)
		--minetest.log("log", "set_item function has executed normally")
		builtin_item.set_item(self, itemstring)

		local stack = ItemStack(itemstring)
        self.itemstack = stack
		local itemdef = minetest.registered_items[stack:get_name()]
		if itemdef and itemdef.groups.flammable ~= 0 then
            local result = minetest.get_craft_result({
                method = "cooking",
                items = {stack}
            })
            if result then
                self.flammable = 1
            else
                self.flammable = itemdef.groups.flammable
            end
		end
	end,

    burn_up = function(self)
        local p = self.object:get_pos()

        -- Cooking input and output
        local stack = self.itemstack
        local result = minetest.get_craft_result({
            method = "cooking",
            items = {stack}
        })
        if result then
            local new_item = minetest.add_item(p, result.item)
            if new_item then
                new_item:add_velocity(vector.new(math.random(-10, 10) * 0.1, math.random(1, 10) * 0.1, math.random(-10, 10) * 0.1))
            end
            stack:take_item(1)
            minetest.log("log", "item cooked! should create output and leave remainder: ".. stack:to_string())
            minetest.add_item(p, stack)
            self.object:remove() -- edit to cook item instead of removing it
        end

        -- Sound and particles
		minetest.sound_play("default_item_smoke", {
			pos = p,
			gain = 1.0,
			max_hear_distance = 8,
		}, true)
		minetest.add_particlespawner({
			amount = 3,
			time = 0.1,
			minpos = {x = p.x - 0.1, y = p.y + 0.1, z = p.z - 0.1 },
			maxpos = {x = p.x + 0.1, y = p.y + 0.2, z = p.z + 0.1 },
			minvel = {x = 0, y = 2.5, z = 0},
			maxvel = {x = 0, y = 2.5, z = 0},
			minacc = {x = -0.15, y = -0.02, z = -0.15},
			maxacc = {x = 0.15, y = -0.01, z = 0.15},
			minexptime = 4,
			maxexptime = 6,
			minsize = 5,
			maxsize = 5,
			collisiondetection = true,
			texture = "default_item_smoke.png"
		})
	end
}

-- set defined item as new __builtin:item, with the old one as fallback table
setmetatable(item, { __index = builtin_item })
minetest.register_entity(":__builtin:item", item)