---- Onion block ----

minetest.register_node("foodblock:onion", {
	description = "Onion Block",
	tiles = {"foodblock_onion_top.png","foodblock_onion_bottom.png","foodblock_onion_side.png"},
	groups = {crumbly=2},
	sounds = default.node_sound_dirt_defaults(),
})

minetest.register_node("foodblock:onion_slab", {
	description = "Half Onion Block",
	drawtype = "nodebox",
	paramtype = "light",
	tiles = {"foodblock_onion_htop.png","foodblock_onion_bottom.png","foodblock_onion_side.png"},
	node_box = {
		type = "fixed",
		fixed = {-1/2, -1/2, -1/2, 1/2, 0, 1/2},
	},
	groups = {crumbly=2},
	sounds = default.node_sound_dirt_defaults()
})
--[[
minetest.register_craft({
	output = "foodblock:onion",
	recipe = {
		{"ethereal:wild_onion_plant","ethereal:wild_onion_plant"},
		{"ethereal:wild_onion_plant","ethereal:wild_onion_plant"}
	}
})
minetest.register_craft({
	output = 'foodblock:onion_slab 6',
	recipe = {
		{"foodblock:onion","foodblock:onion","foodblock:onion"}
	}
})

minetest.register_craft({
	output = "foodblock:onion",
	recipe = {
		{"foodblock:onion_slab"},
		{"foodblock:onion_slab"}
	}
})
minetest.register_craft({
	output = "ethereal:wild_onion_plant 4",
	recipe = {{"foodblock:onion"}},
})

minetest.register_craft({
	output = "ethereal:wild_onion_plant 2",
	recipe = {{"foodblock:onion_slab"}},
})
--]]

-- Banana Block
minetest.register_node("foodblock:banana", {
	description = "Banana Block",
	paramtype2 = "facedir",
	tiles = {
		"foodblock_banana_t.png","foodblock_banana_s.png","foodblock_banana_l.png",
		"foodblock_banana_l.png^[transformFX","foodblock_banana_s.png","foodblock_banana_t.png",
	},
	groups = {crumbly=2},
	sounds = default.node_sound_dirt_defaults(),
})
--[[
minetest.register_craft({
	output = "foodblock:banana",
	recipe = {
		{"ethereal:banana","ethereal:banana"},
		{"ethereal:banana","ethereal:banana"}
	}
})

--Uncraft bananablock
if minetest.get_modpath("ethereal") then
	minetest.register_craft({
		output = "ethereal:banana 4",
		recipe = {{"foodblock:banana"}},
	})
elseif minetest.get_modpath("farming_plus") then
	minetest.register_craft({
		output = "foodblock:banana",
		recipe = {
			{"farming_plus:banana","farming_plus:banana"},
			{"farming_plus:banana","farming_plus:banana"}
		}
	})
end

-- Specified Uncraft
minetest.register_craft({
	type = "shapeless",
	output = "ethereal:banana 5",
	recipe = {"foodblock:banana" , "ethereal:banana"},
})

if minetest.get_modpath("farming_plus") then
	minetest.register_craft({
		output = "farming_plus:banana 4",
		recipe = {{"foodblock:banana"}},
	})
	minetest.register_craft({
		type = "shapeless",
		output = "farming_plus:banana 5",
		recipe = {"foodblock:banana" , "farming_plus:banana"},
	})
end
--]]
