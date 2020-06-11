minetest.register_node("intercomm:intercomm", {
	description = "Intercomm",
	drawtype = "nodebox",
	tiles = {"walkie_intercomm_wall.png"},
	inventory_image = "walkie_intercomm.png",
	wield_image = "walkie_intercomm.png",
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	is_ground_content = false,
	stack_max = 1,
	light_source = 8,
	walkable = false,
	node_box = {
		type = "wallmounted",
		wall_top    = {-0.4375, 0.5, -0.3125, 0.4375, 0.5, 0.3125},
		wall_bottom = {-0.4375, -0.5, -0.3125, 0.4375, -0.4375, 0.3125},
		wall_side   = {-0.5, -0.375, -0.4375, -0.4375, 0.375, 0.4375},
	},
	groups = {
		cracky = 3,
		oddly_breakable_by_hand = 1,
		attached_node = 1,
		actuator = 2
	},
	legacy_wallmounted = true,
	sounds = {
		footstep = {name = "default_hard_footstep", gain = 0.5},
		dig = {name = "walkie_blip", gain = 1.0},
		dug = {name = "walkie_blip", gain = 1.0},
		place = {name = "walkie_blip", gain = 1.0},
		place_failed = {name = "walkie_blip", gain = 1.0}
	},
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local m = minetest.get_meta(pos)
		local s = minetest.deserialize(itemstack:get_meta():get"stuff")
		if s then
			for k, v in pairs(s) do
				m:set_string(k, v)
			end
		end
	end,
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		terminal.display("node", clicker, pos)
	end,
	_on_function = function(pos)
		local args = minetest.deserialize(minetest.get_meta(pos):get_string("_on_function"))
		return args
	end,
	preserve_metadata = function(pos, oldnode, oldmeta, drops)
		local m = minetest.serialize(oldmeta)
		drops[1]:get_meta():set_string("stuff", m)
	end,
	on_blast = function()
	end,
})

minetest.register_craft({
	output = "intercomm:intercomm",
	recipe = {
		{"default:copper_ingot", "default:mese_crystal", "default:copper_ingot"},
		{"default:steel_ingot", "walkie:talkie", "default:steel_ingot"},
		{"default:copper_ingot", "diamond:diamond", "default:copper_ingot"},
	}
})
