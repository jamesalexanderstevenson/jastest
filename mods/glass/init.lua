for i = 1, #dye.dyes do
	local d = dye.dyes[i]
	local cc = d[1]
	if d[1] == white then
		break
	elseif d[1]:find("dark_") then
		cc = d[1]:gsub("_", "")
	end
	local m = "^[colorize:" .. cc .. ":55]"
	-- Connected
	minetest.register_node("glass:glass_connected_" .. cc, {
		description = d[2] .. " Glass (Connected)",
		drawtype = "glasslike_framed",
		tiles = {"default_glass.png" .. m,
				"default_glass_detail.png" .. m},
		paramtype = "light",
		paramtype2 = "glasslikeliquidlevel",
		sunlight_propagates = true,
		is_ground_content = false,
		groups = {cracky = 3, oddly_breakable_by_hand = 3, not_cuttable = 1},
		sounds = default.node_sound_glass_defaults(),
	})
	minetest.register_craft({
		type = "shapeless",
		output = "glass:glass_connected_" .. cc,
		recipe = {"default:glass", "dye:" .. d[1]},
	})
	-- Framed
	minetest.register_node("glass:glass_" .. cc, {
		description = d[2] .. " Glass (Framed)",
		drawtype = "glasslike",
		tiles = {"default_glass.png" .. m,
				"default_glass_detail.png" .. m},
		paramtype = "light",
		sunlight_propagates = true,
		is_ground_content = false,
		groups = {cracky = 3, oddly_breakable_by_hand = 3},
		sounds = default.node_sound_glass_defaults(),
	})
	minetest.register_craft({
		type = "shapeless",
		output = "glass:glass_" .. cc,
		recipe = {"glass:glass_connected_" .. cc},
	})
	-- Pane
	xpanes.register_pane(cc .. "_pane", {
		description = d[2] .. " Glass Pane",
		textures = {"default_glass.png" .. m,
				"", "xpanes_edge.png"},
		inventory_image = "default_glass.png" .. m,
		wield_image = "default_glass.png" .. m,
		sounds = default.node_sound_glass_defaults(),
		groups = {snappy=2, cracky=3, oddly_breakable_by_hand=3},
		recipe = {
			{"glass:glass_connected_" .. cc, "glass:glass_connected_" .. cc, "glass:glass_connected_" .. cc},
			{"glass:glass_connected_" .. cc, "glass:glass_connected_" .. cc, "glass:glass_connected_" .. cc}
		}
	})
end
minetest.register_alias("glass:glass_connected_white", "default:glass")

minetest.register_node("glass:obsidian_glass", {
	description = "Obsidian Glass",
	drawtype = "glasslike",
	tiles = {"default_obsidian_glass.png", "default_obsidian_glass_detail.png"},
	paramtype = "light",
	is_ground_content = false,
	sunlight_propagates = true,
	sounds = default.node_sound_glass_defaults(),
	groups = {cracky = 3, obsidian = 1},
})

minetest.register_node("glass:glass", {
	description = "Glass",
	drawtype = "glasslike",
	tiles = {"default_glass.png", "default_glass_detail.png"},
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky = 3, oddly_breakable_by_hand = 3},
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_craft({
	type = "shapeless",
	output = "glass:glass",
	recipe = {"default:glass"},
})

minetest.register_craft({
	type = "shapeless",
	output = "glass:obsidian_glass",
	recipe = {"default:obsidian_glass"},
})
