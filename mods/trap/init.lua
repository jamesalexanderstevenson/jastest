minetest.register_node("trap:obsidian", {
	description = "Trap Obsidian",
	tiles = {"default_obsidian.png"},
	sounds = default.node_sound_stone_defaults(),
	drop = "default:obsidian",
	groups = {cracky = 1, level = 2},
	_runit = function(pos)
		minetest.swap_node(pos, {name = "trap:obsidian_ghost"})
	end,
})

minetest.register_node("trap:obsidian_ghost", {
	description = "Trap Obsidian",
	tiles = {"default_obsidian.png^[colorize:grey:50"},
	sounds = default.node_sound_stone_defaults(),
	drop = "default:obsidian",
	walkable = false,
	groups = {cracky = 1, level = 2, not_in_creative_inventory = 1},
	damage_per_second = 1,
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		if placer and placer:is_player() and placer:get_player_control().sneak then
			local node = minetest.get_node(pos)
			node.param2 = 1
			minetest.set_node(pos, node)
		end
	end,
	_runit = function(pos)
		minetest.swap_node(pos, {name = "trap:obsidian"})
	end,
})

minetest.register_abm({
	nodenames = "trap:obsidian",
	neighbors = "air",
	interval = 1,
	chance = 1,
	catch_up = false,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local above = vector.round({x = pos.x, y = pos.y + 1, z = pos.z})
		local objects = minetest.get_objects_inside_radius(above, 1.1)
		for i = 1, #objects do
			if objects[i]:is_player() then
				minetest.swap_node(pos, {name ="trap:obsidian_ghost"})
				minetest.sound_play("default_metal_footstep", {pos = pos}, true)
				return
			end
		end
	end,
})

minetest.register_abm({
	nodenames = "trap:obsidian_ghost",
	neighbors = "air",
	interval = 1,
	chance = 1,
	catch_up = false,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local nn = minetest.get_node(pos)
		if nn.param2 == 1 then
			return
		end
		local above = vector.round({x = pos.x, y = pos.y + 1, z = pos.z})
		local objects = minetest.get_objects_inside_radius(above, 0.95)
		for i = 1, #objects do
			if objects[i]:is_player() then
				return
			end
		end
		minetest.swap_node(pos, {name ="trap:obsidian"})
	end,
})

minetest.register_node("trap:baricade", {
	description = "Baricade",
	drawtype = "plantlike",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	inventory_image = "xdecor_baricade.png",
	tiles = {"xdecor_baricade.png"},
	groups = {choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
	damage_per_second = 4,
	selection_box = {type = "fixed", fixed = {
		-0.5,
		-0.5,
		-0.5,
		0.5,
		-0.2,
		0.5
	}},
	collision_box = {type = "fixed", fixed = {
		-0.5,
		-0.5,
		-0.5,
		0.5,
		-0.2,
		0.5
	}},
})

minetest.register_craft({
	output = "trap:baricade",
	recipe = {
		{"group:stick", "", "group:stick"},
		{"", "steel:ingot", ""},
		{"group:stick", "", "group:stick"}
	}
})

minetest.register_node("trap:cobweb", {
	description = "Cobweb",
	drawtype = "plantlike",
	tiles = {"xdecor_cobweb.png"},
	paramtype = "light",
	inventory_image = "xdecor_cobweb.png",
	liquid_viscosity = 8,
	liquidtype = "source",
	liquid_alternative_flowing = "trap:cobweb",
	liquid_alternative_source = "trap:cobweb",
	liquid_renewable = false,
	liquid_range = 0,
	damage_per_second = 1,
	walkable = false,
	selection_box = {type = "regular"},
	groups = {snappy = 3, liquid = 3, flammable = 3},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_craft({
	output = "trap:cobweb",
	recipe = {
		{"farming:cotton", "", "farming:cotton"},
		{"", "farming:cotton", ""},
		{"farming:cotton", "", "farming:cotton"}
	}
}) 
