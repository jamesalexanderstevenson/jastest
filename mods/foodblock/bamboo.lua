-- Bamboo Block

minetest.register_node("foodblock:bamboo", {
	description = "Bamboo Block",
	paramtype2 = "facedir",
	tiles = {
		"foodblock_bamboo_t.png",
		"foodblock_bamboo_t.png",
		"foodblock_bamboo_s.png"
	},
	groups = {choppy = 2, oddly_breakable_by_hand = 1},
	sounds = default.node_sound_wood_defaults(),
	on_place = minetest.rotate_node,
})


minetest.register_craft({
	output = "foodblock:bamboo",
	recipe = {
		{"default:papyrus", "default:papyrus"},
		{"default:papyrus", "default:papyrus"},
	}
})

-- Register Uncraft
minetest.register_craft({
	output = "default:papyrus 4",
	recipe = {{"foodblock:bamboo"}},
})

minetest.register_craft({
	type = "shapeless",
	output = "default:papyrus 5",
	recipe = {"foodblock:bamboo" , "default:papyrus"},
})

-- Takenoko (Bamboo Sprout) Block
minetest.register_node("foodblock:takenoko", {
	description = "Takenoko Block",
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-8/16,-8/16,-8/16, 8/16, 0/16, 8/16},
			{-7/16, 0/16,-7/16, 7/16, 4/16, 7/16},
			{-6/16, 4/16,-6/16, 6/16, 6/16, 6/16},
			{-4/16, 6/16,-4/16, 4/16, 8/16, 4/16},
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-8/16,-8/16,-8/16, 8/16, 8/16, 8/16}, --regular
		}
	},
	tiles = {"foodblock_takenoko_t.png", "foodblock_takenoko_b.png", "foodblock_takenoko_s.png"},
	groups = {choppy = 2, oddly_breakable_by_hand = 1},
	sounds = default.node_sound_wood_defaults(),
	on_place = minetest.rotate_node,
})
--[[

minetest.register_craft({
	output = "foodblock:takenoko",
	recipe = {
		{"ethereal:bamboo_sprout","ethereal:bamboo_sprout"},
		{"ethereal:bamboo_sprout","ethereal:bamboo_sprout"},
	}
})
minetest.register_craft({
	output = "foodblock:takenoko",
	recipe = {
		{"take:takenoko","take:takenoko"},
		{"take:takenoko","take:takenoko"},
	}
})

--Register Uncraft
if minetest.get_modpath("ethereal") then
	minetest.register_craft({
		output = "ethereal:bamboo_sprout 4",
		recipe = {{"foodblock:takenoko"}},
	})
elseif minetest.get_modpath("take") then
	minetest.register_craft({
		output = "take:takenoko 4",
		recipe = {{"foodblock:takenoko"}},
	})
end

minetest.register_craft({
	type = "shapeless",
	output = "ethereal:bamboo_sprout 5",
	recipe = {"foodblock:takenoko" , "ethereal:bamboo_sprout"},
})
minetest.register_craft({
	type = "shapeless",
	output = "take:takenoko 5",
	recipe = {"foodblock:takenoko" , "take:takenoko"},
})
--]]
