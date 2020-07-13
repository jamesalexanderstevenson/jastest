--

local S = minetest.get_translator(minetest.get_current_modname())

-- Meze by Calinou
local meze_frequency = 32 * 32 * 32

minetest.register_node("mese:meze", {
	description = "Meze Block",
	tiles = {"mese_meze_block.png"},
	paramtype = "light",
	light_source = 3,
	is_ground_content = true,
	drop = "mese:meze",
	groups = {cracky = 1, level = 2},
	sounds = default.node_sound_stone_defaults(),
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		minetest.add_entity(pos, "mobs:mese_monster")
		minetest.after(3, function()
			if not minetest.get_player_by_name(digger:get_player_name()) then
				return
			end
			digger:set_hp(0)
		end)
		hud.message(digger, "You feel like you did a mistake.")
	end,
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mese:meze",
	wherein        = "default:desert_stone",
	clust_scarcity = meze_frequency,
	clust_num_ores = 3,
	clust_size     = 2,
	y_min          = 0,
	y_max          = 64,
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mese:meze",
	wherein        = "default:stone",
	clust_scarcity = meze_frequency,
	clust_num_ores = 3,
	clust_size     = 2,
	y_min          = 0,
	y_max          = 64,
})

-- Mese Crystals by RealBadAngel
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mese:crystal_ore1",
	wherein        = "default:stone",
	clust_scarcity = 18 * 18 * 18,
	clust_num_ores = 1,
	clust_size     = 1,
	y_min          = -255,
	y_max          = -64,
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mese:crystal_ore2",
	wherein        = "default:stone",
	clust_scarcity = 20 * 20 * 20,
	clust_num_ores = 1,
	clust_size     = 1,
	y_min          = -31000,
	y_max          = -256,
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mese:crystal_ore3",
	wherein        = "default:stone",
	clust_scarcity = 20 * 20 * 20,
	clust_num_ores = 1,
	clust_size     = 1,
	y_min          = -31000,
	y_max          = -256,
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mese:crystal_ore4",
	wherein        = "default:stone",
	clust_scarcity = 20 * 20 * 20,
	clust_num_ores = 1,
	clust_size     = 1,
	y_min          = -31000,
	y_max          = -256,
})

minetest.register_node("mese:crystal_ore1", {
	description = "Mese Crystal Ore",
	mesh = "mese_crystal_ore1.obj",
	tiles = {"mese_crystal_texture.png"},
	paramtype = "light",
	drawtype = "mesh",
	groups = {cracky = 1, oddly_breakable_by_hand = 1},
	drop = "default:mese_crystal 1",
	use_texture_alpha = true,
	sounds = default.node_sound_glass_defaults(),
	light_source = 7,
	selection_box = {
		type = "fixed",
		fixed = {-0.3, -0.5, -0.3, 0.3, 0.35, 0.3}
	},
	walkable = false,
	damage_per_second = 2,
})

minetest.register_node("mese:crystal_ore2", {
	description = "Mese Crystal Ore",
	mesh = "mese_crystal_ore2.obj",
	tiles = {"mese_crystal_texture.png"},
	paramtype = "light",
	drawtype = "mesh",
	groups = {cracky = 1, oddly_breakable_by_hand = 1},
	drop = "default:mese_crystal 2",
	use_texture_alpha = true,
	sounds = default.node_sound_glass_defaults(),
	light_source = 8,
	selection_box = {
		type = "fixed",
		fixed = {-0.3, -0.5, -0.3, 0.3, 0.35, 0.3}
	},
	walkable = false,
	damage_per_second = 2,
})

minetest.register_node("mese:crystal_ore3", {
	description = "Mese Crystal Ore",
	mesh = "mese_crystal_ore3.obj",
	tiles = {"mese_crystal_texture.png"},
	paramtype = "light",
	drawtype = "mesh",
	groups = {cracky = 1, oddly_breakable_by_hand = 1},
	drop = "default:mese_crystal 3",
	use_texture_alpha = true,
	sounds = default.node_sound_glass_defaults(),
	light_source = 9,
	selection_box = {
		type = "fixed",
		fixed = {-0.3, -0.5, -0.3, 0.3, 0.35, 0.3}
	},
	walkable = false,
	damage_per_second = 2,
})

minetest.register_node("mese:crystal_ore4", {
	description = "Mese Crystal Ore",
	mesh = "mese_crystal_ore4.obj",
	tiles = {"mese_crystal_texture.png"},
	paramtype = "light",
	drawtype = "mesh",
	groups = {cracky = 1, oddly_breakable_by_hand = 1},
	drop = "default:mese_crystal 4",
	use_texture_alpha = true,
	sounds = default.node_sound_glass_defaults(),
	light_source = 10,
	selection_box = {
		type = "fixed",
		fixed = {-0.3, -0.5, -0.3, 0.3, 0.35, 0.3}
	},
	walkable = false,
	damage_per_second = 2,
})

minetest.register_craftitem("mese:crystal_seed", {
	description = "Mese Crystal Seed",
	inventory_image = "mese_crystal_seed.png",
	on_place = function(itemstack, user, pointed_thing)
		if pointed_thing.type ~= "node" then
			return
		end
		local pos = pointed_thing.under
		local node = minetest.get_node(pos)
		if node.name == "default:obsidian" then
			local pos1 = pointed_thing.above
			local node1 = minetest.get_node(pos1)
			if node1.name == "air" then
				node.name = "mese:crystal_ore1"
				local name = user:get_player_name()
				if minetest.is_protected(pos, name) then
					minetest.record_protection_violation(pos, name)
					return itemstack
				end
				itemstack:take_item()
				minetest.add_node(pos1, node)
				return itemstack
			end
		end
	end,
})

local function check_lava (pos)
	local name = minetest.get_node(pos).name
	if name == "default:lava_source" or
			name == "default:lava_flowing" then
		return 1
	else
		return 0
	end
end

local function grow_mese_crystal_ore(pos, node)
	local pos1 = {x = pos.x, y = pos.y, z = pos.z}
	pos1.y = pos1.y - 1
	local name = minetest.get_node(pos1).name
	if name ~= "default:obsidian" then
		return
	end

	local lava_count = 0
	pos1.z = pos.z - 1
	lava_count = lava_count + check_lava(pos1)
	pos1.z = pos.z + 1
	lava_count = lava_count + check_lava(pos1)
	pos1.z = pos.z
	pos1.x = pos.x - 1
	lava_count = lava_count + check_lava(pos1)
	pos1.x = pos.x + 1
	lava_count = lava_count + check_lava(pos1)
	if lava_count < 2 then
		return
	end

	if node.name == "mese:crystal_ore3" then
		node.name = "mese:crystal_ore4"
		minetest.swap_node(pos, node)
	elseif node.name == "mese:crystal_ore2" then
		node.name = "mese:crystal_ore3"
		minetest.swap_node(pos, node)
	elseif node.name == "mese:crystal_ore1" then
		node.name = "mese:crystal_ore2"
		minetest.swap_node(pos, node)
	end
end

minetest.register_abm({
	nodenames = {"mese:crystal_ore1", "mese:crystal_ore2",
			"mese:crystal_ore3"},
	neighbors = {"default:obsidian", "default:lava_source"},
	interval = 80,
	chance = 20,
	action = function(...)
		grow_mese_crystal_ore(...)
	end
})

minetest.register_abm({
	nodenames = {"default:obsidian"},
	neighbors = {"group:water"},
	interval = 45,
	chance = 23,
	catch_up = false,
	action = function(pos, node)
		pos.y = pos.y + 1
		local nn = minetest.get_node(pos).name
		if nn ~= "air" then
			return
		end

		local pos1 = {x = pos.x, y = pos.y - 1, z = pos.z}
		local lava_count = 0
		pos1.z = pos.z - 1
		lava_count = lava_count + check_lava(pos1)
		pos1.z = pos.z + 1
		lava_count = lava_count + check_lava(pos1)
		pos1.z = pos.z
		pos1.x = pos.x - 1
		lava_count = lava_count + check_lava(pos1)
		pos1.x = pos.x + 1
		lava_count = lava_count + check_lava(pos1)
		if lava_count < 2 then
			return
		end

		minetest.set_node(pos, {name = "mese:crystal_ore1"})
	end,
})

minetest.register_craft({
	output = "mese:crystal_seed 3",
	recipe = {
		{"default:mese_crystal", "default:mese_crystal", "default:mese_crystal"},
		{"default:mese_crystal", "default:obsidian_shard", "default:mese_crystal"},
		{"default:mese_crystal", "default:mese_crystal", "default:mese_crystal"},
	}
})

minetest.register_tool("mese:crystalline_bell", {
	description = "Crystalline Bell",
	inventory_image = "mese_crystals_crystalline_bell.png",
	on_use = function(itemstack, user, pointed_thing)
		if pointed_thing.type ~= "node" then
			return
		end
		local pos = pointed_thing.under
		if minetest.is_protected(pos, user:get_player_name()) then
			return
		end
		local node = minetest.get_node(pos)
		local growth_stage = 0
		if node.name == "mese:crystal_ore4" then
			growth_stage = 4
		elseif node.name == "mese:crystal_ore3" then
			growth_stage = 3
		elseif node.name == "mese:crystal_ore2" then
			growth_stage = 2
		elseif node.name == "mese:crystal_ore1" then
			growth_stage = 1
		end
		if growth_stage == 4 then
			node.name = "mese:crystal_ore3"
			minetest.swap_node(pos, node)
		elseif growth_stage == 3 then
			node.name = "mese:crystal_ore2"
			minetest.swap_node(pos, node)
		elseif growth_stage == 2 then
			node.name = "mese:crystal_ore1"
			minetest.swap_node(pos, node)
		end -- TODO Take last stage.
		if growth_stage > 1 then
			itemstack:add_wear(65535 / 100)
			local player_inv = user:get_inventory()
			local stack = ItemStack("default:mese_crystal")
			if player_inv:room_for_item("main", stack) then
				player_inv:add_item("main", stack)
			end
			return itemstack
		end
	end,
})

minetest.register_craft({
	output = "mese:crystalline_bell",
	recipe = {
		{"default:diamond"},
		{"default:glass"},
		{"group:stick"},
	}
})

minetest.register_node("mese:meselamp_off", {
	description = S("Mese Lamp (You hacker you!)"),
	drawtype = "glasslike",
	tiles = {"default_meselamp.png"},
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky = 3, oddly_breakable_by_hand = 3, mese = 1},
	sounds = default.node_sound_glass_defaults(),
})
