local function is_value_in_table(tbl, val) -- helper, does as said
	for _, v in pairs(tbl) do
		if v == val then
			return true
		end
	end
	return false
end

local function insert_all(tbl, tbl2)
	for i = 1, #tbl2 do
		table.insert(tbl, tbl2[i])
	end
end

--local common_spawn_chance = tonumber(minetest.settings:get("lumberjack_spawn_chance")) or 30000


local individual_biomes = {}
-- local lumberjack_biomes = {}
-- local herdsman_biomes = {}
-- local miner_biomes = {}
-- local fisherman_biomes = {}
-- local gardener_biomes = {}

minetest.register_on_mods_loaded(function()
    insert_all(individual_biomes, animalia.registered_biome_groups["grassland"].biomes)
    
	-- insert_all(lumberjack_biomes, animalia.registered_biome_groups["boreal"].biomes)
    
    -- insert_all(herdsman_biomes, animalia.registered_biome_groups["grassland"].biomes)
    
	-- --insert_all(miner_biomes, friends_foes.registered_biome_groups["desert"].biomes)
    -- insert_all(miner_biomes, animalia.registered_biome_groups["mountains"].biomes)
    -- insert_all(miner_biomes, animalia.registered_biome_groups["cave"].biomes)
	
	-- insert_all(fisherman_biomes, animalia.registered_biome_groups["ocean"].biomes)
    
	-- insert_all(gardener_biomes, animalia.registered_biome_groups["deciduous"].biomes)
end)

creatura.register_abm_spawn("friends_foes:individual", {
	chance = 100000,
	min_height = 0,
	max_height = 1024,
	min_group = 1,
	max_group = 2,
	biomes = individual_biomes,
	nodes = {"group:soil"},
})