-- Food mod by rubenwardy
-- Boilerplate to support localized strings if intllib mod is installed.
local S = 0
if minetest.get_modpath("intllib") then
	S = intllib.Getter()
else
	S = function ( s ) return s end
end

-- Cocoa
minetest.register_craftitem("foodblock:cocoa", {
	description = S("Cocoa Beans"),
	inventory_image = "foodblock_cocoa_beans.png",
})

-- Milk Chocolate Item
minetest.register_craftitem("foodblock:milk_chocolate_item",{
	description = S("Milk Chocolate"),
	inventory_image = "food_milk_chocolate.png",
	on_use = minetest.item_eat(3),
})

minetest.register_craft({
	output = "foodblock:milk_chocolate_item",
	recipe = {
		{"", "mobs:bucket_milk", ""},
		{"foodblock:cocoa", "foodblock:cocoa", "foodblock:cocoa"}
	},
	replacements = {{"mobs:bucket_milk", "bucket:bucket_empty"}}
})

-- Milk Chocolate Block
minetest.register_node("foodblock:chocom_block", {
	description = "Milk Chocolate Block",
	tiles = {"foodblock_chocom_top.png", "foodblock_chocom_bottom.png", "foodblock_chocom_side.png"},
	groups = {crumbly = 2},
	sounds = default.node_sound_dirt_defaults(),
})

minetest.register_craft({
	output = "foodblock:chocom_block",
	recipe = {
		{"foodblock:milk_chocolate_item", "foodblock:milk_chocolate_item"},
		{"foodblock:milk_chocolate_item", "foodblock:milk_chocolate_item"},
	}
})

minetest.register_craft({
	output = "foodblock:milk_chocolate_item 4",
	recipe = {{"foodblock:chocom_block"}},
})

minetest.register_node("foodblock:chocom_block_slab", {
	description = "Half Milk Chocolate Block",
	drawtype = "nodebox",
	paramtype = "light",
	tiles = {"foodblock_chocom_top.png", "foodblock_chocom_bottom.png", "foodblock_chocom_side.png"},
	node_box = {
		type = "fixed",
		fixed = {-1/2, -1/2, -1/2, 1/2, 0, 1/2},
	},
	groups = {crumbly = 2},
	sounds = default.node_sound_dirt_defaults()
})

minetest.register_craft({
	output = "foodblock:chocom_block_slab 6",
	recipe = {
		{"foodblock:chocom_block","foodblock:chocom_block","foodblock:chocom_block"}
	}
})

minetest.register_craft({
	output = "foodblock:chocom_block",
	recipe = {
		{"foodblock:chocom_block_slab"},
		{"foodblock:chocom_block_slab"},
	}
})

minetest.register_craft({
	output = "foodblock:milk_chocolate_item 4",
	recipe = {{"foodblock:chocom_block_slab"}},
})

-- Dark Chocolate Item
minetest.register_craftitem("foodblock:dark_chocolate_item",{
	description = S("Dark Chocolate"),
	inventory_image = "food_dark_chocolate.png",
	on_use = minetest.item_eat(3),
})

minetest.register_craft({
	output = "foodblock:dark_chocolate_item",
	recipe = {
		{"foodblock:cocoa", "foodblock:cocoa", "foodblock:cocoa"}
	}
})

-- Dark Chocolate Block
minetest.register_node("foodblock:chocod_block", {
	description = "Dark Chocolate Block",
	tiles = {"foodblock_chocod_top.png","foodblock_chocod_bottom.png","foodblock_chocod_side.png"},
	groups = {crumbly=2},
	sounds = default.node_sound_dirt_defaults(),
})

minetest.register_craft({
	output = "foodblock:chocod_block",
	recipe = {
		{"foodblock:dark_chocolate_item", "foodblock:dark_chocolate_item"},
		{"foodblock:dark_chocolate_item", "foodblock:dark_chocolate_item"},
	}
})

minetest.register_craft({
	output = "foodblock:dark_chocolate_item 4",
	recipe = {{"foodblock:chocod_block"}},
})

minetest.register_node("foodblock:chocod_block_slab", {
	description = "Half Dark Chocolate Block",
	drawtype = "nodebox",
	paramtype = "light",
	tiles = {"foodblock_chocod_top.png", "foodblock_chocod_bottom.png", "foodblock_chocod_side.png"},
	node_box = {
		type = "fixed",
		fixed = {-1/2, -1/2, -1/2, 1/2, 0, 1/2},
	},
	groups = {crumbly = 2},
	sounds = default.node_sound_dirt_defaults()
})

minetest.register_craft({
	output = "foodblock:chocod_block_slab 6",
	recipe = {
		{"foodblock:chocod_block", "foodblock:chocod_block", "foodblock:chocod_block"}
	}
})

minetest.register_craft({
	output = "foodblock:chocod_block",
	recipe = {
		{"foodblock:chocod_block_slab"},
		{"foodblock:chocod_block_slab"},
	}
})

minetest.register_craft({
	output = "foodblock:dark_chocolate_item 2",
	recipe = {{"foodblock:chocod_block_slab"}},
})
