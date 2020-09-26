-- /mods/obsidian is part of jastest
-- copyright 2020 james alexander stevenson
-- gnu gpl 3+

local S = minetest.get_translator(minetest.get_current_modname())

minetest.register_alias("q:oblight", "default:obsidian_light_iron")
minetest.register_alias("q:oblight2", "default:obsidian_light_mese")
minetest.register_alias("walls:obsidianbrick", "obsidian:brick_wall")

minetest.register_node(":default:obsidian_light_iron", {
	description = "Obsidian Light",
	tiles = {"default_obsidian_block.png", "xdecor_iron_lightbox.png",
			"q_oblight.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	sounds = default.node_sound_glass_defaults(),
	groups = {cracky = 2, level = 2, obsidian = 1},
	light_source = 9,
})

minetest.register_node(":default:obsidian_light_mese", {
	description = "Obsidian Light",
	tiles = {"default_meselamp.png", "default_obsidian_block.png",
			"q_oblight2.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	sounds = default.node_sound_glass_defaults(),
	groups = {cracky = 2, level = 2, obsidian = 1},
	light_source = 9,
})

walls.register("obsidian:brick_wall", S("Obsidian Brick Wall"), {"obsidian_brick_wall.png"},
		"default:obsidianbrick", default.node_sound_stone_defaults())

minetest.override_item("obsidian:brick_wall", {
	groups = {cracky = 3, wall = 1},
	connects_to = {"group:wall", "group:stone", "group:fence", "group:obsidian"},
})
