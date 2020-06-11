-- Raw Meat Block
minetest.register_node("foodblock:meatblockraw", {
	description = "Raw Meat Block",
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-3/16, -3/16, 7/16, 3/16, 3/16, 8/16}, --bone
			{-1/2, -1/2, -7/16, 1/2, 1/2, 7/16},  --meat
			{-3/16, -3/16, -7/16, 3/16, 3/16, -8/16}, --bone
		}
	},
	tiles = {
		"foodblock_meat_top.png","foodblock_meat_top.png","foodblock_meat_side.png",
		"foodblock_meat_side.png","foodblock_meat_front.png","foodblock_meat_front.png",
	},
	groups = {crumbly=2},
})
minetest.register_craft({
	output = "foodblock:meatblockraw",
	recipe = {
		{"mobs:meat_raw","mobs:meat_raw"},
		{"mobs:meat_raw","mobs:meat_raw"},
	}
})
	minetest.register_craft({
		output = "mobs:meat_raw 4",
		recipe = {
			{"foodblock:meatblockraw"},
		},
	})
-- Specified Uncraft
minetest.register_craft({
	type = "shapeless",
	output = "mobs:meat_raw 5",
	recipe = {"foodblock:meatblockraw" , "mobs:meat_raw"},
})

-- MilkBlock
minetest.register_node("foodblock:milkblock", {
	description = "Milk Block",
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-6/16, 6/16, -6/16, 6/16, 1/2, 6/16}, --cap
			{-1/2, -1/2, -1/2, 1/2, 6/16, 1/2}, 
		}
	},
	tiles = {"foodblock_milk_top.png","foodblock_milk_bottom.png","foodblock_milk_side.png"},
	groups = {crumbly=2},
	sounds = default.node_sound_glass_defaults(),
})
minetest.register_craft({
	output = "foodblock:milkblock",
	recipe = {
		{"","mobs:bucket_milk",""},
		{"mobs:bucket_milk","vessels:glass_bottle","mobs:bucket_milk"},
		{"","mobs:bucket_milk",""},
	},
	replacements = {
		{"mobs:bucket_milk","bucket:bucket_empty"},
		{"mobs:bucket_milk","bucket:bucket_empty"},
		{"mobs:bucket_milk","bucket:bucket_empty"},
		{"mobs:bucket_milk","bucket:bucket_empty"},
	}
})
--Uncraft MilkBlock
	minetest.register_craft({
		output = "vessels:glass_bottle",
		recipe = {
			{"","bucket:bucket_empty",""},
			{"bucket:bucket_empty","foodblock:milkblock","bucket:bucket_empty"},
			{"","bucket:bucket_empty",""},
		},
		replacements = {
			{"bucket:bucket_empty","mobs:bucket_milk"},
			{"bucket:bucket_empty","mobs:bucket_milk"},
			{"bucket:bucket_empty","mobs:bucket_milk"},
			{"bucket:bucket_empty","mobs:bucket_milk"},
		},
	})
-- Specified Uncraft
minetest.register_craft({
	output = "vessels:glass_bottle",
	recipe = {
		{"mobs:bucket_milk","bucket:bucket_empty",""},
		{"bucket:bucket_empty","foodblock:milkblock","bucket:bucket_empty"},
		{"","bucket:bucket_empty",""},
	},
	replacements = {
		{"mobs:bucket_milk","mobs:bucket_milk"},
		{"bucket:bucket_empty","mobs:bucket_milk"},
		{"bucket:bucket_empty","mobs:bucket_milk"},
		{"bucket:bucket_empty","mobs:bucket_milk"},
		{"bucket:bucket_empty","mobs:bucket_milk"},
	},
})

-- Egg block
minetest.register_node("foodblock:eggblock", {
	description = "Egg Block",
	tiles = {"foodblock_egg_top.png","foodblock_egg_bottom.png","foodblock_egg_side.png"},
	paramtype = "light",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-7/16, 5/16,-7/16, 7/16, 8/16, 7/16}, --cap
			{ -1/2,-7/16, -1/2,  1/2, 5/16,  1/2}, 
			{-7/16,-8/16,-7/16, 7/16,-7/16, 7/16}, 
		}
	},
	groups = {crumbly=2},
	sounds = default.node_sound_dirt_defaults(),
})
minetest.register_craft({
	output = "foodblock:eggblock",
	recipe = {
		{"mobs:egg","mobs:egg"},
		{"mobs:egg","mobs:egg"}
	}
})
minetest.register_node("foodblock:eggblock_slab", {
	description = "Half Egg Block",
	drawtype = "nodebox",
	paramtype = "light",
	tiles = {"foodblock_egg_htop.png","foodblock_egg_bottom.png","foodblock_egg_side.png"},
	node_box = {
		type = "fixed",
		fixed = {
			{-1/2, -7/16, -1/2, 1/2, 0, 1/2},
			{-7/16, -1/2,-7/16, 7/16,-7/16, 7/16}, 
		}
	},
	groups = {crumbly=2},
	sounds = default.node_sound_dirt_defaults()
})
minetest.register_craft({
	output = 'foodblock:eggblock_slab 6',
	recipe = {
		{"foodblock:eggblock","foodblock:eggblock","foodblock:eggblock"}
	}
})
minetest.register_craft({
	output = "foodblock:eggblock",
	recipe = {
		{"foodblock:eggblock_slab"},
		{"foodblock:eggblock_slab"}
	}
})

--Uncraft Eggblock
	minetest.register_craft({
		output = "mobs:egg 4",
		recipe = {{"foodblock:eggblock"}},
	})
	minetest.register_craft({
		output = "mobs:egg 2",
		recipe = {{"foodblock:eggblock_slab"}},
	})
-- Specified Uncraft
minetest.register_craft({
	type = "shapeless",
	output = "mobs:egg 5",
	recipe = {"foodblock:eggblock" , "mobs:egg"},
})
minetest.register_craft({
	type = "shapeless",
	output = "mobs:egg:3",
	recipe = {"foodblock:eggblock_slab" , "mobs:egg"},
})
