-- /mods/backpacks is part of jastest
-- copyright 2020 james alexander stevenson
-- gnu gpl 3+

local backpacks = {}

backpacks.form = "size[8,7.8]" ..
	"list[current_name;main;0,0;8,3]" ..
	"field[0.3,3.3;7,1;rename;;${infotext}]" ..
	"button_exit[7,2.97;1,1;ok;OK]" ..
	"list[current_player;main;0,3.95;8,1]" ..
	"list[current_player;main;0,5.05;8,3;8]" ..
	"listring[current_name;main]" ..
	"listring[current_player;main]" ..
	default.get_hotbar_bg(0, 3.95) ..
""

backpacks.on_construct = function(pos)
	local meta = minetest.get_meta(pos)
	meta:set_string("infotext", "Backpack")
	meta:set_string("formspec", backpacks.form)
	local inv = meta:get_inventory()
	inv:set_size("main", 8 * 3)
end

--[[
backpacks.after_place_node = function(pos, placer, itemstack, pointed_thing)
	local n_meta = minetest.get_meta(pos)
	local i_meta = itemstack:get_meta()
	local description = i_meta:get_string("description")
	local infotext = description
	if infotext == "" then
		infotext = itemstack:get_definition().description
	end
	n_meta:set_string("description", description)
	n_meta:set_string("infotext", infotext)
	local inv = n_meta:get_inventory()
	if i_meta:get_string("inventory") ~= "" then
		inv:set_list("main", minetest.deserialize(i_meta:get_string("inventory")))
	end
	itemstack:take_item()
end
--]]

local function check_attached_node(p, n)
	local def = minetest.registered_nodes[n.name]
	local d = {x = 0, y = 0, z = 0}
	if def.paramtype2 == "wallmounted" or
			def.paramtype2 == "colorwallmounted" then
		-- The fallback vector here is in case 'wallmounted to dir' is nil due
		-- to voxelmanip placing a wallmounted node without resetting a
		-- pre-existing param2 value that is out-of-range for wallmounted.
		-- The fallback vector corresponds to param2 = 0.
		d = minetest.wallmounted_to_dir(n.param2) or {x = 0, y = 1, z = 0}
	else
		d.y = -1
	end
	local p2 = vector.add(p, d)
	local nn = minetest.get_node(p2).name
	local def2 = minetest.registered_nodes[nn]
	if def2 and not def2.walkable then
		return false
	end
	return true
end

local function copy_pointed_thing(pointed_thing)
	return {
		type  = pointed_thing.type,
		above = vector.new(pointed_thing.above),
		under = vector.new(pointed_thing.under),
		ref   = pointed_thing.ref,
	}
end

local function on_place(itemstack, placer, pointed_thing, param2)
	local def = itemstack:get_definition()
	if def.type ~= "node" or pointed_thing.type ~= "node" then
		return itemstack, false
	end

	local under = pointed_thing.under
	local oldnode_under = minetest.get_node_or_nil(under)
	if oldnode_under and minetest.registered_nodes[oldnode_under.name].on_rightclick then
		--minetest.registered_nodes[oldnode_under.name].on_rightclick(under,
				--oldnode_under, placer, pointed_thing)
		--return itemstack, false
		return minetest.item_place(itemstack, placer, pointed_thing, param2)
	end
	local above = pointed_thing.above
	local oldnode_above = minetest.get_node_or_nil(above)
	if not oldnode_above or oldnode_above.name ~= "air" then
		return itemstack, false
	end
	local playername = placer and placer:get_player_name() or ""
	local log = playername ~= "" and minetest.log or function() end

	if not oldnode_under or not oldnode_above then
		log("info", playername .. " tried to place"
			.. " node in unloaded position " .. minetest.pos_to_string(above))
		return itemstack, false
	end

	local olddef_under = minetest.registered_nodes[oldnode_under.name]
	olddef_under = olddef_under or minetest.nodedef_default
	local olddef_above = minetest.registered_nodes[oldnode_above.name]
	olddef_above = olddef_above or minetest.nodedef_default

	if not olddef_above.buildable_to and not olddef_under.buildable_to then
		log("info", playername .. " tried to place"
			.. " node in invalid position " .. minetest.pos_to_string(above)
			.. ", replacing " .. oldnode_above.name)
		return itemstack, false
	end

	-- Place above pointed node
	local place_to = {x = above.x, y = above.y, z = above.z}

	-- If node under is buildable_to, place into it instead (eg. snow)
	if olddef_under.buildable_to then
		log("info", "node under is buildable to")
		place_to = {x = under.x, y = under.y, z = under.z}
		if minetest.is_protected(place_to, playername) then
			return itemstack, false
		end
	end

	log("action", playername .. " places node "
		.. def.name .. " at " .. minetest.pos_to_string(place_to))

	local oldnode = minetest.get_node(place_to)
	local newnode = {name = def.name, param1 = 0, param2 = param2 or 0}

	-- Calculate direction for wall mounted stuff like torches and signs
	if def.place_param2 ~= nil then
		newnode.param2 = def.place_param2
	elseif (def.paramtype2 == "wallmounted" or
			def.paramtype2 == "colorwallmounted") and not param2 then
		local dir = {
			x = under.x - above.x,
			y = under.y - above.y,
			z = under.z - above.z
		}
		newnode.param2 = minetest.dir_to_wallmounted(dir)
	-- Calculate the direction for furnaces and chests and stuff
	elseif (def.paramtype2 == "facedir" or
			def.paramtype2 == "colorfacedir") and not param2 then
		local placer_pos = placer and placer:get_pos()
		if placer_pos then
			local dir = {
				x = above.x - placer_pos.x,
				y = above.y - placer_pos.y,
				z = above.z - placer_pos.z
			}
			newnode.param2 = minetest.dir_to_facedir(dir)
			log("action", "facedir: " .. newnode.param2)
		end
	end

	local metatable = itemstack:get_meta():to_table().fields

	-- Transfer color information
	if metatable.palette_index and not def.place_param2 then
		local color_divisor = nil
		if def.paramtype2 == "color" then
			color_divisor = 1
		elseif def.paramtype2 == "colorwallmounted" then
			color_divisor = 8
		elseif def.paramtype2 == "colorfacedir" then
			color_divisor = 32
		end
		if color_divisor then
			local color = math.floor(metatable.palette_index / color_divisor)
			local other = newnode.param2 % color_divisor
			newnode.param2 = color * color_divisor + other
		end
	end

	-- Check if the node is attached and if it can be placed there
	if minetest.get_item_group(def.name, "attached_node") ~= 0 and
		not check_attached_node(place_to, newnode) then
		log("action", "attached node " .. def.name ..
			" can not be placed at " .. minetest.pos_to_string(place_to))
		return itemstack, false
	end

	ll_items.throw_inventory(place_to, minetest.get_node_drops(oldnode.name))

	-- Add node and update
	minetest.add_node(place_to, newnode)

	--local take_item = true
	--[[
	-- Run callback
	if def.after_place_node and not prevent_after_place then
		-- Deepcopy place_to and pointed_thing because callback can modify it
		local place_to_copy = {x=place_to.x, y=place_to.y, z=place_to.z}
		local pointed_thing_copy = copy_pointed_thing(pointed_thing)
		if def.after_place_node(place_to_copy, placer, itemstack,
				pointed_thing_copy) then
			take_item = false
		end
	end

	-- Run script hook
	for _, callback in ipairs(minetest.registered_on_placenodes) do
		-- Deepcopy pos, node and pointed_thing because callback can modify them
		local place_to_copy = {x=place_to.x, y=place_to.y, z=place_to.z}
		local newnode_copy = {name=newnode.name, param1=newnode.param1, param2=newnode.param2}
		local oldnode_copy = {name=oldnode.name, param1=oldnode.param1, param2=oldnode.param2}
		local pointed_thing_copy = copy_pointed_thing(pointed_thing)
		if callback(place_to_copy, newnode_copy, placer, oldnode_copy, itemstack, pointed_thing_copy) then
			take_item = false
		end
	end
	--]]
	local n_meta = minetest.get_meta(place_to)
	local i_meta = itemstack:get_meta()
	local description = i_meta:get_string("description")
	local infotext = description
	if infotext == "" then
		infotext = itemstack:get_definition().description
	end
	n_meta:set_string("description", description)
	n_meta:set_string("infotext", infotext)
	local inv = n_meta:get_inventory()
	if i_meta:get_string("inventory") ~= "" then
		inv:set_list("main", minetest.deserialize(i_meta:get_string("inventory")))
	end

	--if take_item then
		itemstack:take_item()
	--end
	return itemstack, true
end

backpacks.on_dig = function(pos, node, digger)
	--[[
	if minetest.is_protected(pos, digger:get_player_name()) then
		return false
	end
	--]]
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local list = {}
	local il = inv:get_list("main")
	if not il then
		return
	end
	for i, stack in ipairs(il) do
		if stack:get_name() == "" then
			list[i] = ""
		else 
			list[i] = stack:to_string()
		end
	end
	local fields = {fields = {
		description = meta:get_string("description"),
		infotext = meta:get_string("description"),
		formspec = backpacks.form
	}}
	local new_list_as_string = minetest.serialize(list)
	local new = ItemStack(node)
	new:get_meta():from_table(fields)
	new:get_meta():set_string("inventory", new_list_as_string)
	minetest.remove_node(pos)
	local player_inv = digger:get_inventory()
	if player_inv:room_for_item("main", new) then
		player_inv:add_item("main", new)
	else
		minetest.add_item(pos, new)
	end
end

backpacks.allow_metadata_inventory_put = function(pos, listname, index, stack, player)
	if not string.match(stack:get_name(), "backpacks:backpack_") then
		return stack:get_count()
	else
		return 0
	end
end

backpacks.preserve_metadata = function(pos, oldnode, oldmeta, drops)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local list = {}
	for i, stack in ipairs(inv:get_list("main")) do
		if stack:get_name() == "" then
			list[i] = ""
		else
			list[i] = stack:to_string()
		end
	end
	local fields = {fields = {
		description = meta:get_string("description"),
		infotext = meta:get_string("description"),
		formspec = backpacks.form,
	}}
	local new_list_as_string = minetest.serialize(list)
	local new = ItemStack(oldnode)
	new:get_meta():from_table(fields)
	new:get_meta():set_string("inventory", new_list_as_string)
	if drops and drops[1] then
		drops[1] = new
	end
end

backpacks.on_receive_fields = function(pos, formname, fields, sender)
	if formname ~= "" then
		return
	end
	if fields.rename or
			(fields.key_enter and
			fields.key_enter_field == "rename") then
		local new_name = minetest.formspec_escape(fields.rename)
		local meta = minetest.get_meta(pos)
		meta:set_string("description", new_name)
		meta:set_string("infotext", new_name)
	end
end

backpacks.on_blast = function() -- TODO throw_contents
end

--[[
local wield_index = {}
local function update_wielded(player, inv)
	local p_inv = player:get_inventory()
	local wielded = p_inv:get_stack("hand", 1)
	local list = inv:get_list("dmain")
	for i = 1, #list do
		list[i] = list[i]:to_string()
	end
	wielded:get_meta():set_string("inventory", minetest.serialize(list))
	p_inv:set_stack("hand", 1, wielded)
end

minetest.register_allow_player_inventory_action(function(player, action, inventory, inventory_info)
	local name = player:get_player_name()
	if (inventory_info.to_index and inventory_info.to_index == wield_index[name]) or
			(inventory_info.from_index and inventory_info.from_index == wield_index[name]) or
			(inventory_info.index and inventory_info.index == wield_index[name]) then
		return 0
	--else
		--return inventory_info.count or inventory_info.stack:get_count()

	end
end)

--minetest.register_on_player_inventory_action(function(player, action, inventory, inventory_info)
--end)

backpacks.d_inv = {
	--allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
		--return count
	--end,
	allow_put = function(inv, listname, index, stack, player)
		if stack:get_name():match("backpacks:backpack_") then
			return 0
		end
		return stack:get_count()
	end,
	--allow_take = function(inv, listname, index, stack, player)
		--return stack:get_count()
	--end,
	on_move = function(inv, from_list, from_index, to_list, to_index, count, player)
		update_wielded(player, inv)
	end, 
	on_put = function(inv, listname, index, stack, player)
		update_wielded(player, inv)
	end,
	on_take = function(inv, listname, index, stack, player)
		update_wielded(player, inv)
	end,
}

backpacks.on_use = function(itemstack, user, pointed_thing)
	if not user then
		return
	end
	local name = user:get_player_name()
	wield_index[name] = user:get_wield_index()
	local d_inv = minetest.get_inventory({type = "detached",
			name = "backpack_" .. name})
	if not d_inv then
		d_inv = minetest.create_detached_inventory("backpack_"
				.. name, backpacks.d_inv)
		d_inv:set_size("dmain", 8 * 2)
	end
	local meta = itemstack:get_meta()
	local list = minetest.deserialize(meta:get_string("inventory")) or {}
	d_inv:set_list("dmain", list)
	local formspec = "size[8,7.5]" ..
		jas0.exit_button() ..
		"list[detached:backpack_" .. name .. ";dmain;0,0.7;8,2]" ..
		"field[0.3,3;7,1;rename;;" .. (meta:get("description") or
				itemstack:get_definition().description) .. "]" ..
		"button_exit[7,2.67;1,1;ok;OK]" ..
		"list[current_player;main;0,3.65;8,1]" ..
		"list[current_player;main;0,4.75;8,3;8]" ..
		"listring[detached:backpack_" .. name .. ";dmain]" ..
		"listring[current_player;main]" ..
		default.get_hotbar_bg(0, 3.65) ..
	""
	minetest.show_formspec(name, "backpacks:backpack", formspec)
	local h = user:get_inventory()
	h:set_size("hand", 1)
	h:set_stack("hand", 1, itemstack)
	local faux = ItemStack(itemstack:get_name())
	faux:get_meta():set_string("description", meta:get("description") or
			itemstack:get_definition().description)
	return faux
end

minetest.register_on_leaveplayer(function(player)
	if not player then
		return
	end
	minetest.remove_detached_inventory("backpack_" .. player:get_player_name())
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "backpacks:backpack" then
		return
	end
	if fields.rename or
			(fields.key_enter and
			fields.key_enter_field == "rename") then
		local new_name = minetest.formspec_escape(fields.rename)
		local wielded = player:get_inventory():get_stack("hand", 1)
		local meta = wielded:get_meta()
		meta:set_string("description", new_name)
		meta:set_string("infotext", new_name)
		player:get_inventory():set_stack("hand", 1, wielded)
	end
	if fields.quit then
		player:set_wielded_item(player:get_inventory():get_stack("hand", 1))
		if player:get_meta():get_string("class") == "mage" then
			player:get_inventory():set_stack("hand", 1, "jas0:mage")
		else
			player:get_inventory():set_list("hand", {})
		end
		wield_index[player:get_player_name()] = nil
	end
end)
--]]

--[[
minetest.register_on_joinplayer(function(player)
	if not player then
		return
	end

	local inv = player:get_inventory()
	inv:set_size("backpack", 1)
end)
--]]

minetest.register_alias("backpacks:backpack", "backpacks:backpack_wool_white")
minetest.register_alias("backpack", "backpacks:backpack_wool_white")
minetest.register_alias("backpack_leather", "backpacks:backpack_wool_leather")

-- Colored Wool Backpacks
for k, v in ipairs(dye.dyes) do
	minetest.register_node("backpacks:backpack_wool_" .. v[1], {
		description = v[2] .. " Wool Backpack",
		tiles = {
			"wool_" .. v[1] .. ".png^backpacks_backpack_topbottom.png", -- Top
			"wool_" .. v[1] .. ".png^backpacks_backpack_topbottom.png", -- Bottom
			"wool_" .. v[1] .. ".png^backpacks_backpack_sides.png", -- Right Side
			"wool_" .. v[1] .. ".png^backpacks_backpack_sides.png", -- Left Side
			"wool_" .. v[1] .. ".png^backpacks_backpack_back.png", -- Back
			"wool_" .. v[1] .. ".png^backpacks_backpack_front.png" -- Front
		},
		drawtype = "nodebox",
		paramtype = "light",
		paramtype2 = "facedir",
		node_box = {
			type = "fixed",
			fixed = {
				{-0.4375, -0.5, -0.375, 0.4375, 0.5, 0.375},
				{0.125, -0.375, 0.4375, 0.375, 0.3125, 0.5},
				{-0.375, -0.375, 0.4375, -0.125, 0.3125, 0.5},
				{0.125, 0.1875, 0.375, 0.375, 0.375, 0.4375},
				{-0.375, 0.1875, 0.375, -0.125, 0.375, 0.4375},
				{0.125, -0.375, 0.375, 0.375, -0.25, 0.4375},
				{-0.375, -0.375, 0.375, -0.125, -0.25, 0.4375},
				{-0.3125, -0.375, -0.4375, 0.3125, 0.1875, -0.375},
				{-0.25, -0.3125, -0.5, 0.25, 0.125, -0.4375},
			}
		},
		groups = {dig_immediate = 3, oddly_diggable_by_hand = 3, attached_node = 1},
		stack_max = 1,
		on_construct = backpacks.on_construct,
		--after_place_node = backpacks.after_place_node,
		on_place = on_place,
		on_dig = backpacks.on_dig,
		allow_metadata_inventory_put = backpacks.allow_metadata_inventory_put,
		preserve_metadata = backpacks.preserve_metadata,
		on_receive_fields = backpacks.on_receive_fields,
		on_use = backpacks.on_use,
		on_blast = backpacks.on_blast,
	})
	minetest.register_craft({
		output = "backpacks:backpack_wool_" .. v[1],
		recipe = {
			{"wool:" .. v[1], "wool:" .. v[1], "wool:" .. v[1]},
			{"wool:" .. v[1], "", "wool:" .. v[1]},
			{"wool:" .. v[1], "wool:" .. v[1], "wool:" .. v[1]},
		}
	})
	minetest.register_craft({
		output = "wool:" .. v[1] .. " 5",
		type = "shapeless",
		recipe = {"backpacks:backpack_wool_" .. v[1]},
	})
end

-- Leather backpack
minetest.register_node("backpacks:backpack_leather", {
	description = "Leather Backpack",
	tiles = {
		"backpacks_leather.png^backpacks_backpack_topbottom.png", -- Top
		"backpacks_leather.png^backpacks_backpack_topbottom.png", -- Bottom
		"backpacks_leather.png^backpacks_backpack_sides.png",     -- Right Side
		"backpacks_leather.png^backpacks_backpack_sides.png",     -- Left Side
		"backpacks_leather.png^backpacks_backpack_back.png",      -- Back
		"backpacks_leather.png^backpacks_backpack_front.png"      -- Front
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.4375, -0.5, -0.375, 0.4375, 0.5, 0.375},
			{0.125, -0.375, 0.4375, 0.375, 0.3125, 0.5},
			{-0.375, -0.375, 0.4375, -0.125, 0.3125, 0.5},
			{0.125, 0.1875, 0.375, 0.375, 0.375, 0.4375},
			{-0.375, 0.1875, 0.375, -0.125, 0.375, 0.4375},
			{0.125, -0.375, 0.375, 0.375, -0.25, 0.4375},
			{-0.375, -0.375, 0.375, -0.125, -0.25, 0.4375},
			{-0.3125, -0.375, -0.4375, 0.3125, 0.1875, -0.375},
			{-0.25, -0.3125, -0.5, 0.25, 0.125, -0.4375},
		}
	},
	groups = {dig_immediate = 3, oddly_diggable_by_hand = 3, attached_node = 1},
	stack_max = 1,
	on_construct = backpacks.on_construct,
	--after_place_node = backpacks.after_place_node,
	on_place = on_place,
	on_dig = backpacks.on_dig,
	allow_metadata_inventory_put = backpacks.allow_metadata_inventory_put,
	preserve_metadata = backpacks.preserve_metadata,
	on_receive_fields = backpacks.on_receive_fields,
	on_use = backpacks.on_use,
	on_blast = backpacks.on_blast,
})

minetest.register_craft({
	output = "backpacks:backpack_leather",
	recipe = {
		{"mobs:leather", "mobs:leather", "mobs:leather"},
		{"mobs:leather", "", "mobs:leather"},
		{"mobs:leather", "mobs:leather", "mobs:leather"},
	}
})
minetest.register_craft({
	output = "mobs:leather",
	type = "shapeless",
	recipe = {"backpacks:backpack_leather 5"},
})


minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
	if not player then
		return
	end
	local pos = player:get_pos()
	local craft_size = player:get_inventory():get_size("craft")
	for i = 1, craft_size do
		local craft_grid_item_name = old_craft_grid[i]:get_name()
		if craft_grid_item_name:match("backpacks:backpack_") then
			local contents = minetest.deserialize(old_craft_grid[i]:get_meta():get("inventory"))
			if not contents then
				return
			end
			for i = 1, 16 do
				local it = contents[i]
				if it ~= "" then
					local o = minetest.add_item(pos, it)
					if o then
						-- From tnt
						o:set_acceleration({
							x = 0,
							y = -10,
							z = 0,
						})
						o:set_velocity({
							x = math.random(-3, 3),
							y = math.random(0, 10),
							z = math.random(-3, 3),
						})
					end
				end
			end
			return
		end
	end
end)

local newpo = ItemStack([[backpacks:backpack_leather 1 0 "\u0001inventory\u0002return {\"default:book_written 1 0 \\\"\\\\u0001text\\\\u0002Keep stuff safe in your backpack, and keep your backpack safe in its safe slot!\\\\u0003owner\\\\u0002jastvn\\\\u0003description\\\\u0002\\\\u001b(T@default)\\\\\\\"\\\\u001bFWelcome\\\\u001bE\\\\\\\" by \\\\u001bFjastvn\\\\u001bE\\\\u001bE\\\\u0003page_max\\\\u00021\\\\u0003title\\\\u0002Welcome\\\\u0003page\\\\u00021\\\\u0003\\\"\", \"\", \"\", \"\", \"\", \"\", \"\", \"\", \"\", \"\", \"\", \"\", \"\", \"\", \"\", \"\", \"\", \"\", \"\", \"\", \"\", \"\", \"\", \"\"}\u0003description\u0002Leather Backpack\u0003infotext\u0002Leather Backpack\u0003formspec\u0002size[8,7.8]list[current_name;main;0,0;8,3]field[0.3,3.3;7,1;rename;;${infotext}]button_exit[7,2.97;1,1;ok;OK]list[current_player;main;0,3.95;8,1]list[current_player;main;0,5.05;8,3;8]listring[current_name;main]listring[current_player;main]image[0,3.95;1,1;gui_hb_bg.png]image[1,3.95;1,1;gui_hb_bg.png]image[2,3.95;1,1;gui_hb_bg.png]image[3,3.95;1,1;gui_hb_bg.png]image[4,3.95;1,1;gui_hb_bg.png]image[5,3.95;1,1;gui_hb_bg.png]image[6,3.95;1,1;gui_hb_bg.png]image[7,3.95;1,1;gui_hb_bg.png]\u0003"]])

setup.init(newpo, 20, false, "backpack")
