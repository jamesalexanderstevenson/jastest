-- Fences and rails
fencematerial = {"brass", "wrought_iron"}
for _, m in ipairs(fencematerial) do
	local mat = "default:iron_lump"
	if m == "brass" then
		mat = "xdecor:brass_ingot"
	end
	default.register_fence("xdecor:fence_" .. m, {
		description = "Fence (" .. m .. ")",
		texture = "xdecor_" .. m .. ".png",
		inventory_image = "default_fence_overlay.png^xdecor_" ..
				m .. ".png^default_fence_overlay.png^[makealpha:255,126,126",
		wield_image = "default_fence_overlay.png^xdecor_" ..
				m .. ".png^default_fence_overlay.png^[makealpha:255,126,126",
		material = mat,
		material_type = "metal",
		groups = {cracky = 2,},
		sounds = default.node_sound_metal_defaults(),
	})
	default.register_fence_rail("xdecor:fence_rail_" .. m, {
		description = "Fence Rail (" .. m .. ")",
		texture = "xdecor_" .. m .. ".png",
		inventory_image = "default_fence_rail_overlay.png^xdecor_" ..
				m .. ".png^default_fence_rail_overlay.png^[makealpha:255,126,126",
		wield_image = "default_fence_rail_overlay.png^xdecor_" ..
				m .. ".png^default_fence_rail_overlay.png^[makealpha:255,126,126",
		material = mat,
		groups = {cracky = 2,},
		sounds = default.node_sound_metal_defaults(),
	})
end

-- Brass
minetest.register_craftitem("xdecor:brass_ingot", {
	description = "Brass ingot",
	inventory_image = "xdecor_brass_ingot.png",
})

minetest.register_craft({
	type = "shapeless",
	output = "xdecor:brass_ingot",
	recipe = {"default:copper_ingot", "default:tin_ingot"}
})

-- Cardboard box
minetest.register_craft({
	output = "xdecor:cardboard_box",
	recipe = {
		{"default:paper", "default:paper", "default:paper"},
		{"default:paper", "default:paper", "default:paper"}
	}
})

xdecor.register("cardboard_box", {
	description = "Cardboard box", groups = {snappy=3}, inventory = {size=8},
	tiles = {"xdecor_cardbox_top.png", "xdecor_cardbox_top.png", "xdecor_cardbox_sides.png"},
	node_box = {type="fixed", fixed={{-0.3125, -0.5, -0.3125, 0.3125, 0, 0.3125}}}
})

-- Plant pot
xdecor.register("plant_pot", {
	description = "Plant pot", groups = {snappy=3},
	tiles = {"xdecor_plant_pot_top.png", "xdecor_plant_pot_sides.png"}
})

minetest.register_craft({
	output = "xdecor:plant_pot",
	recipe = {
		{"default:clay_lump", "", "default:clay_lump"},
		{"default:clay_lump", "default:dirt", "default:clay_lump"},
		{"default:clay_lump", "default:clay_lump", "default:clay_lump"}
	}
})

-- Stereo
xdecor.register("stereo", {
	description = "Stereo",
	groups = {snappy=3},
	tiles = {
		"xdecor_stereo_top.png", "xdecor_stereo_bottom.png",
		"xdecor_stereo_left.png^[transformFX", "xdecor_stereo_left.png",
		"xdecor_stereo_back.png", "xdecor_stereo_front.png"
	}
})

minetest.register_craft({
	output = "xdecor:stereo",
	recipe = {
		{"default:steel_ingot", "default:copper_ingot", "default:steel_ingot"},
		{"default:steel_ingot", "default:copper_ingot", "default:steel_ingot"},
		{"default:steel_ingot", "default:copper_ingot", "default:steel_ingot"}
	}
})

-- Trash can
xdecor.register("trash_can", {
	description = "Trash Can",
	tiles = {"xdecor_wood.png"},
	groups = {choppy=3, flammable=3},
	sounds = default.node_sound_wood_defaults(),
	node_box = {
		type = "fixed",
		fixed = {{-0.3125, -0.5, 0.3125, 0.3125, 0.5, 0.375},
			{0.3125, -0.5, -0.375, 0.375, 0.5, 0.375},
			{-0.3125, -0.5, -0.375, 0.3125, 0.5, -0.3125},
			{-0.375, -0.5, -0.375, -0.3125, 0.5, 0.375},
			{-0.3125, -0.5, -0.3125, 0.3125, -0.4375, 0.3125}}
	},
	collision_box = {
		type = "fixed", fixed = {{-0.375, -0.5, -0.375, 0.375, 0.19, 0.375}}
	},
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", "Trash Can - throw your waste here")
		minetest.get_node_timer(pos):start(3)
	end,
	on_timer = function(pos, elapsed)
		minetest.get_node_timer(pos):start(3)
		local o = minetest.get_objects_inside_radius(pos, 0.85)
		for _, s in pairs(o) do
			if not s:is_player() then
				local l = s:get_luaentity()
				if l and l.itemstring then
					l.itemstring = ""
					l.object:remove()
					--TODO reset timer on stash
					--TODO then wait longer for accumilation
					--TODO then empty after some longer delay
				end
			end
		end
	end,
})

minetest.register_craft({
	output = "xdecor:trash_can",
	recipe = {
		{"group:wood", "", "group:wood"},
		{"group:wood", "", "group:wood"},
		{"group:wood", "group:wood", "group:wood"}
	}
})

-- Chandelier
xdecor.register("chandelier", {
	description = "Chandelier",
	drawtype = "plantlike",
	walkable = false,
	inventory_image = "xdecor_chandelier.png",
	tiles = {"xdecor_chandelier.png"},
	groups = {dig_immediate=3},
	light_source = 14,
	selection_box = xdecor.nodebox.slab_y(0.5, 0.5)
})

minetest.register_craft({
	output = "xdecor:chandelier",
	recipe = {
		{"default:gold_ingot", "default:gold_ingot", "default:gold_ingot"},
		{"default:torch", "default:torch", "default:torch"}
	}
})
