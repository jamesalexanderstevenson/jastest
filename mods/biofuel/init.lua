----------
--biofuel
----------
local modname = minetest.get_current_modname()

minetest.register_craft({
	output = modname .. ":biofuel_distiller",
	recipe = {
		{"default:copper_ingot", "default:copper_ingot", "default:copper_ingot"},
		{"default:steel_ingot" , "",                     "default:steel_ingot"},
		{"default:steel_ingot" , "default:steel_ingot",  "default:steel_ingot"},
	},
})

-- biofuel
minetest.register_node(modname .. ":biofuel",{
	description = "Bio Fuel",
	drawtype = "plantlike",
	tiles = {"biofuel_inv.png"},
	inventory_image = "biofuel_inv.png",
	wield_image = "biofuel_inv.png",
	paramtype = "light",
	is_ground_content = false,
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {-0.25, -0.5, -0.25, 0.25, 0.3, 0.25}
	},
	stack_max = 1,
	groups = {vessel = 1, dig_immediate = 3, attached_node = 1},
	sounds = default.node_sound_metal_defaults(),
})

local ferment = {
	{"default:papyrus", modname .. ":biofuel"},
	{"farming:wheat", modname .. ":biofuel"},
	{"farming:bread", modname .. ":biofuel"},
	{"crops:corn_cob", modname .. ":biofuel"},
	{"crops:potato", modname .. ":biofuel"},
	{"crops:tomato", modname .. ":biofuel"}
}

-- distiller
local function biofueldistiller_formspec(string)
	string = string or ""
	local fs = "size[8,8.5]" ..
			forms.x ..
			forms.q ..
			forms.title("Biofuel Distiller") ..
			"image[1.5,1.5;1,1;gui_furnace_arrow_bg.png^[lowpart:"..
			(string)..":gui_furnace_arrow_fg.png^[transformR270]"..
			"list[current_name;src;0.5,1.5;1,1;]" ..
			"list[current_name;dst;2.5,1.5;1,1;]" ..
			"image[2.5,1.5;1,1;biofuel_inv_slot.png]" ..
			"label[0.5,2.5;" .. string .. "]" ..
			"list[current_player;main;0,4.5;8,1;]" ..
			"list[current_player;main;0,5.75;8,3;8]" ..
			"listring[current_name;dst]" ..
			"listring[current_player;main]" ..
			"listring[current_name;src]" ..
			"listring[current_player;main]" ..
			"list[current_name;store;4.5,1.5;3,2]" ..
			default.get_hotbar_bg(0, 4.5)
	return fs
end

minetest.register_node(modname .. ":biofuel_distiller", {
	description = "Biofuel Distiller",
	tiles = {"biofuel_metal.png", "biofuel_aluminum.png", "biofuel_copper.png" },
	drawtype = "mesh",
	mesh = "biofuel_distiller.b3d",
	paramtype = "light",
	paramtype2 = "facedir",
	sounds = default.node_sound_stone_defaults(),
	groups = {
		cracky = 2, oddly_breakable_by_hand = 1,
	},
	legacy_facedir_simple = true,
	on_place = minetest.rotate_node,
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", "Biofuel Distiller")
		meta:set_float("status", 0.0)
		local inv = meta:get_inventory()
		inv:set_size("src", 1)
		inv:set_size("dst", 1)
		inv:set_size("store", 6)
		meta:set_string("formspec", biofueldistiller_formspec())
	end,
	can_dig = function(pos,player)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		if not inv:is_empty("dst") or
				not inv:is_empty("src") or
				not inv:is_empty("store") then
			return false
		end
		return true
	end,
	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return 0
		end
		return stack:get_count()
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return 0
		end
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		if listname == "src" then
			return stack:get_count()
		elseif listname == "dst" then
			if stack:get_name() == "vessels:steel_bottle" then
				return stack:get_count()
			end
			return 0
		elseif listname == "store" then
			return 0
		end
	end,
	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return 0
		end
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local stack = inv:get_stack(from_list, from_index)
		if to_list == "src" then
			return count
		elseif to_list == "dst" then
			return 0
		elseif to_list == "store" then
			return 0
		end
	end,
	on_metadata_inventory_put = function(pos)
		local timer = minetest.get_node_timer(pos)
		timer:start(5)
	end,
	on_timer = function(pos)
		local meta = minetest.get_meta(pos)
		if not meta then
			return
		end
		local inv = meta:get_inventory()

		-- is barrel empty?
		if not inv or inv:is_empty("src") then
			meta:set_float("status", 0.0)
			meta:set_string("infotext", "Biofuel Distiller")
			meta:set_string("formspec", biofueldistiller_formspec())
			return false
		end

		-- does it contain any of the source items on the list?
		local has_item

		for n = 1, #ferment do
			if inv:contains_item("src", ItemStack(ferment[n][1])) then
				has_item = n
				break
			end
		end

		if not has_item then
			return false
		end

		-- is there room for additional fermentation?
		--if not inv:room_for_item("dst", ferment[has_item][2]) then
		if not inv:room_for_item("store", ferment[has_item][2]) then
			meta:set_string("infotext", "Fuel Distiller (Full)")
			meta:set_string("formspec", biofueldistiller_formspec("Biofuel distiller is full"))
			return true
		end

		local status = meta:get_float("status")

		-- fermenting (change status)
		if status <= 100 then
			local fire = minetest.get_node({x = pos.x, y = pos.y - 1, z = pos.z}).name
			if fire:match("fire") or fire:match("lava") then
				fire = 2 
			else
				fire = 1
			end

			meta:set_string("infotext", "Fuel Distiller " .. status .. "% done")
			meta:set_float("status", status + fire)
			meta:set_string("formspec", biofueldistiller_formspec(status .. "% done"))
		elseif inv:get_stack("dst", 1):get_name() == "vessels:steel_bottle" then
			inv:remove_item("src", ferment[has_item][1])
			inv:remove_item("dst", "vessels:steel_bottle")
			inv:add_item("store", ferment[has_item][2])
			meta:set_float("status", 0.0)
		end
		if inv:is_empty("src") then
			meta:set_float("status", 0.0)
			meta:set_string("infotext", "Fuel Distiller")
			meta:set_string("formspec", biofueldistiller_formspec())
		end
		return true
	end,
})
