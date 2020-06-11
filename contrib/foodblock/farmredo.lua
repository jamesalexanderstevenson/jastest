-- Corn Block
minetest.register_node("foodblock:corn", {
	description = "Corn Block",
	tiles = {"foodblock_corn_top.png","foodblock_corn_bottom.png","foodblock_corn_side.png"},
	groups = {crumbly=2},
	sounds = default.node_sound_dirt_defaults(),
})

minetest.register_node("foodblock:corn_slab", {
	description = "Half Corn Block",
	drawtype = "nodebox",
	paramtype = "light",
	tiles = {"foodblock_corn_top.png","foodblock_corn_bottom.png","foodblock_corn_side.png"},
	node_box = {
		type = "fixed",
		fixed = {-1/2, -1/2, -1/2, 1/2, 0, 1/2},
	},
	groups = {crumbly=2},
	sounds = default.node_sound_dirt_defaults()
})

minetest.register_craft({
	output = "foodblock:corn",
	recipe = {
		{"crops:corn_cob","crops:corn_cob"},
		{"crops:corn_cob","crops:corn_cob"}
	}
})
minetest.register_craft({
	output = 'foodblock:corn_slab 6',
	recipe = {
		{"foodblock:corn","foodblock:corn","foodblock:corn"}
	}
})

minetest.register_craft({
	output = "foodblock:corn",
	recipe = {
		{"foodblock:corn_slab"},
		{"foodblock:corn_slab"}
	}
})

minetest.register_craft({
	output = "crops:corn_cob 4",
	recipe = {{"foodblock:corn"}},
})

minetest.register_craft({
	output = "crops:corn_cob 2",
	recipe = {{"foodblock:corn_slab"}},
})

---- Coffee block ----
minetest.register_node("foodblock:coffee", {
	description = "Coffee Block",
	tiles = {
		"foodblock_coffee_t.png","foodblock_coffee_b.png","foodblock_coffee_s.png",
		"foodblock_coffee_s.png","foodblock_coffee_b.png","foodblock_coffee_b.png",
		},
	groups = {crumbly=2},
	sounds = default.node_sound_dirt_defaults(),
})
--[[
minetest.register_craft({
	output = "foodblock:coffee",
	recipe = {
		{"farming:coffee_beans","farming:coffee_beans"},
		{"farming:coffee_beans","farming:coffee_beans"},
	}
})
minetest.register_craft({
	output = "farming:coffee_beans 4",
	recipe = {{"foodblock:coffee"}},
})
--]]

-- muffin block
minetest.register_node("foodblock:muffin", {
	description = "Muffin Block",
	drawtype = "nodebox",
	paramtype = "light",
	tiles = {
		"foodblock_muffin_t.png","foodblock_muffin_b.png","foodblock_muffin_s.png",
		},
	node_box = {
		type = "fixed",
		fixed = {
			{-7/16, 7/16,-7/16, 7/16, 8/16, 7/16},
			{-8/16, 0/16,-8/16, 8/16, 7/16, 8/16},
			{-7/16,-4/16,-7/16, 7/16, 0/16, 7/16},
			{-6/16,-8/16,-6/16, 6/16, 4/16, 6/16},
		},
	},
	groups = {crumbly=2},
	sounds = default.node_sound_dirt_defaults(),
})
--[[
minetest.register_craft({
	output = "foodblock:muffin",
	recipe = {
		{"farming:muffin_blueberry","farming:muffin_blueberry"},
		{"farming:muffin_blueberry","farming:muffin_blueberry"},
	}
})

minetest.register_craft({
	output = "foodblock:muffin",
	recipe = {
		{"moretrees:acorn_muffin","moretrees:acorn_muffin"},
		{"moretrees:acorn_muffin","moretrees:acorn_muffin"},
	}
})
--Register Uncraft
if minetest.get_modpath("moretrees") then
	minetest.register_craft({
		output = "moretrees:acorn_muffin 4",
		recipe = {{"foodblock:muffin"}},
	})
else
	minetest.register_craft({
		output = "farming:muffin_blueberry 4",
		recipe = {{"foodblock:muffin"}},
	})
end
minetest.register_craft({
	type = "shapeless",
	output = "farming:muffin_blueberry 5",
	recipe = {"foodblock:muffin","farming:muffin_blueberry"},
})
minetest.register_craft({
	type = "shapeless",
	output = "moretrees:acorn_muffin 5",
	recipe = {"foodblock:muffin","moretrees:acorn_muffin"},
})
--]]
