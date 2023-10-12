-- Player interaction behaviors
-- idle

-- Tree cutting behaviors

creatura.register_utility("friends_foes:find_tree", function(self)
    timeout = timeout or 3
    pos2 = minetest.find_node_near(self.pos, 25, "group:tree")
	local function func(_self)
		local pos = _self.object:get_pos()
		if not pos then return end
		if not pos2 then return true end
		if not _self:get_action() then
			local anim = (_self.animations["run"] and "run") or "walk"
			creatura.action_wander_walk(_self, 4, pos2, 2, anim)
		end
		timeout = timeout - _self.dtime
		if timeout <= 0 then
			return true
		end
	end
	self:set_utility(func)
end)

creatura.register_utility("friends_foes:chop_tree", function(self)
    timeout = timeout or 3
    local function func(_self)
        pos2 = minetest.find_node_near(self.pos, 10, "group:tree")
        
        if not _self:get_action() then
            -- set animations
            
            minetest.dig_node(pos2)
        end
        timeout = timeout - _self.dtime
        if timeout <= 0 then return true end
    end
    self:set_utility(func)
end)

-- Farming behaviors

-- Herb gathering behaviors

-- Mining behaviors

-- 