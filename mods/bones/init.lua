-- bones/init.lua

-- Minetest 0.4 mod: bones
-- See README.txt for licensing and other information.

-- Load support for MT game translation.
local S = minetest.get_translator("bones")

bones = {}

local function is_owner(pos, name)
	local owner = minetest.get_meta(pos):get_string("owner")
	if owner == "" or owner == name or minetest.check_player_privs(name, "protection_bypass") then
		return true
	end
	return false
end

local bones_formspec =
	"size[8,9]" ..
	"list[current_name;main;0,0.3;8,4;]" ..
	"list[current_player;main;0,4.85;8,1;]" ..
	"list[current_player;main;0,6.08;8,3;8]" ..
	"listring[current_name;main]" ..
	"listring[current_player;main]" ..
	default.get_hotbar_bg(0, 4.85)

local share_bones_time = tonumber(minetest.settings:get("share_bones_time")) or 1200
local share_bones_time_early = tonumber(minetest.settings:get("share_bones_time_early")) or share_bones_time / 4

minetest.register_node("bones:bones", {
	description = S("Bones"),
	tiles = {
		"bones_top.png^[transform2",
		"bones_bottom.png",
		"bones_side.png",
		"bones_side.png",
		"bones_rear.png",
		"bones_front.png"
	},
	paramtype2 = "facedir",
	groups = {dig_immediate = 2},
	sounds = default.node_sound_gravel_defaults(),

	can_dig = function(pos, player)
		local inv = minetest.get_meta(pos):get_inventory()
		local name = ""
		if player then
			name = player:get_player_name()
		end
		return is_owner(pos, name) and inv:is_empty("main")
	end,

	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		if is_owner(pos, player:get_player_name()) then
			return count
		end
		return 0
	end,

	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		return 0
	end,

	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		if is_owner(pos, player:get_player_name()) then
			return stack:get_count()
		end
		return 0
	end,

	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		if meta:get_inventory():is_empty("main") then
			local inv = player:get_inventory()
			if inv:room_for_item("main", {name = "bones:bones"}) then
				inv:add_item("main", {name = "bones:bones"})
			else
				minetest.add_item(pos, "bones:bones")
			end
			minetest.remove_node(pos)
		end
	end,

	on_punch = function(pos, node, player)
		if not is_owner(pos, player:get_player_name()) then
			return
		end

		if minetest.get_meta(pos):get_string("infotext") == "" then
			return
		end

		local inv = minetest.get_meta(pos):get_inventory()
		local player_inv = player:get_inventory()
		local has_space = true

		for i = 1, inv:get_size("main") do
			local stk = inv:get_stack("main", i)
			if player_inv:room_for_item("main", stk) then
				inv:set_stack("main", i, nil)
				player_inv:add_item("main", stk)
			else
				has_space = false
				break
			end
		end

		-- remove bones if player emptied them
		if has_space then
			if player_inv:room_for_item("main", {name = "bones:bones"}) then
				player_inv:add_item("main", {name = "bones:bones"})
			else
				minetest.add_item(pos,"bones:bones")
			end
			minetest.remove_node(pos)
		end
	end,

	on_timer = function(pos, elapsed)
		local meta = minetest.get_meta(pos)
		local time = meta:get_int("time") + elapsed
		if time >= share_bones_time then
			meta:set_string("infotext", S("@1's old bones", meta:get_string("owner")))
			meta:set_string("owner", "")
		else
			meta:set_int("time", time)
			return true
		end
	end,
	on_blast = function(pos)
	end,
})

local function may_replace(pos, player)
	local node_name = minetest.get_node(pos).name
	local node_definition = minetest.registered_nodes[node_name]

	-- if the node is unknown, we return false
	if not node_definition then
		return false
	end

	-- allow replacing air and liquids
	if node_name == "air" or node_definition.liquidtype ~= "none" then
		return true
	end

	-- don't replace filled chests and other nodes that don't allow it
	local can_dig_func = node_definition.can_dig
	if can_dig_func and not can_dig_func(pos, player) then
		return false
	end

	-- default to each nodes buildable_to; if a placed block would replace it, why shouldn't bones?
	-- flowers being squished by bones are more realistical than a squished stone, too
	-- exception are of course any protected buildable_to
	return node_definition.buildable_to and not minetest.is_protected(pos, player:get_player_name())
end

local drop = function(pos, itemstack)
	local obj = minetest.add_item(pos, itemstack:take_item(itemstack:get_count()))
	if obj then
		obj:set_velocity({
			x = math.random(-10, 10) / 9,
			y = 5,
			z = math.random(-10, 10) / 9,
		})
	end
end

local player_inventory_lists = { "main", "craft" }
bones.player_inventory_lists = player_inventory_lists

local function is_all_empty(player_inv)
	for _, list_name in ipairs(player_inventory_lists) do
		if not player_inv:is_empty(list_name) then
			return false
		end
	end
	return true
end

local bone_veg = {
	saplings = {
		"default:sapling",
		"default:aspen_sapling",
		"default:junglesapling",
		"default:emergent_jungle_sapling",
		"default:acacia_sapling",
		"default:pine_sapling",
		"default:pine_bush_sapling",
		"default:bush_sapling",
		"default:blueberry_bush_sapling",
		"default:acacia_bush_sapling",
	},
	plants = {
		"farming:seed_wheat", "farming:wheat_",
		"farming:seed_cotton", "farming:cotton_",
		"crops:corn_base_seed",
	},
	seedlings = {
		"default:large_cactus_seedling",
	},
	dirt = {
		"default:dirt",
	},
}

local function grow(pos, group, item)
	--print(pos, group, item)
	if item == "default:dirt" then
		minetest.set_node(pos, {name = "default:dirt_with_grass"})
	else
		local t = minetest.get_node_timer(pos)
		local ts = t:is_started()
		local to = t:get_timeout()
		local te = t:get_elapsed()
		t:set(to * 0.5, te * 2)
	end
end

local function bone_meal(itemstack, user, pointed_thing)
	if pointed_thing.type ~= "node" then
		return itemstack
	end
	local pos = pointed_thing.under
	local n = minetest.get_node(pos)
	for k, v in pairs(bone_veg) do
		for i = 1, #v do
			if n.name == v[i] or
					n.name:sub(1, -2) == v[i] then
				itemstack:take_item()
				grow(pos, k, v[i])
			end
		end
	end
	return itemstack
end

minetest.register_on_dieplayer(function(player, reason)
	local player_name = player:get_player_name()
	if minetest.check_player_privs(player_name, "godmode") then
		return
	end

	local bones_mode = "drop" --[[minetest.settings:get("bones_mode") or "bones"
	if bones_mode ~= "bones" and bones_mode ~= "drop" and bones_mode ~= "keep" then
		bones_mode = "bones"
	end]]

	local bones_position_message = minetest.settings:get_bool("bones_position_message") == true
	local pos = vector.round(player:get_pos())
	local pos_string = minetest.pos_to_string(pos)

	-- return if keep inventory set or in creative mode
	if bones_mode == "keep" or (creative and creative.is_enabled_for
			and creative.is_enabled_for(player:get_player_name())) then
		minetest.log("action", player_name .. " dies at " .. pos_string ..
			". No bones placed")
		if bones_position_message then
			minetest.chat_send_player(player_name, S("@1 died at @2.", player_name, pos_string))
		end
		return
	end

	local player_inv = player:get_inventory()
	if is_all_empty(player_inv) then
		minetest.log("action", player_name .. " dies at " .. pos_string ..
			". No bones placed")
		if bones_position_message then
			minetest.chat_send_player(player_name, S("@1 died at @2.", player_name, pos_string))
		end
		return
	end

	-- check if it's possible to place bones, if not find space near player
	if bones_mode == "bones" and not may_replace(pos, player) then
		local air = minetest.find_node_near(pos, 1, {"air"})
		if air and not minetest.is_protected(air, player_name) then
			pos = air
		else
			bones_mode = "drop"
		end
	end

	if bones_mode == "drop" then
		local backpack_stack = player_inv:get_stack("backpack", 1)
		local has_backpack = backpack_stack:get_name():match("backpack") == "backpack"
		local backpack_inv, backpack_meta
		if has_backpack then
			backpack_meta = backpack_stack:get_meta():to_table()
			backpack_inv = minetest.deserialize(backpack_meta.fields.inventory)
		end
		for _, list_name in ipairs(player_inventory_lists) do
			for i = 1, player_inv:get_size(list_name) do
				if list_name == "main" and has_backpack and i > 8 then
					local given = false
					if backpack_inv then
						for ii = 1, #backpack_inv do
							if backpack_inv[ii] == "" and
									not player_inv:get_stack(list_name, i):to_string():match("backpacks:backpack_") then
								backpack_inv[ii] = player_inv:get_stack(list_name, i):to_string()
								given = true
								break
							end
						end
					end
					if not given then
						drop(pos, player_inv:get_stack(list_name, i))
					end
				else
					drop(pos, player_inv:get_stack(list_name, i))
				end
			end
			player_inv:set_list(list_name, {})
		end

		if has_backpack then
			backpack_meta.fields.inventory = minetest.serialize(backpack_inv)
			backpack_stack:get_meta():from_table(backpack_meta)
			player_inv:set_stack("backpack", 1, backpack_stack)
		end

		ll_items.throw_inventory(pos, {"bones:bones", "bones:bone", "bones:skull"})
		--minetest.log("action", player_name .. " dies at " .. pos_string ..
		--	". Inventory dropped")
		--minetest.chat_send_all(minetest.colorize("Red", "[Server] ") ..
		--		player_name .. " died at " .. pos_string)
		print(player_name, dump(reason))
		if reason.type == "punch" then
			if reason.object then
				local ent = reason.object:get_luaentity()
				if reason.object:is_player() then
					forms.log("[Server] " .. reason.object:get_player_name() .. " fragged " ..
							player_name .. " at " .. pos_string, true)
				elseif ent then
					if ent.description then
						forms.log("[Server] " .. player_name .. " got eaten by a " ..
								ent.description .. " at " .. pos_string, true)
					else
						forms.log("[Server] " .. player_name .. " got eaten by a mob at " ..
								pos_string, true)
					end
				end
			end
		elseif reason.type == "fall" then
			forms.log("[Server] " .. player_name .. " did the lemming thing at " ..
					pos_string, true)
		elseif reason.starving then
			forms.log("[Server] " .. player_name .. " starved to death at " .. pos_string, true)
		elseif reason.poisoned then
			forms.log("[Server] " .. player_name .. " died of poisoning at " ..
					pos_string, true)
		elseif reason.tnt then
			forms.log("[Server] " .. player_name .. " was blown up at " .. pos_string, true)
		else
			forms.log("[Server] " .. player_name .. " died at " .. pos_string, true)
		end
		return
	end

	local param2 = minetest.dir_to_facedir(player:get_look_dir())
	minetest.set_node(pos, {name = "bones:bones", param2 = param2})

	minetest.log("action", player_name .. " dies at " .. pos_string ..
		". Bones placed")
	if bones_position_message then
		minetest.chat_send_player(player_name,
				S("@1 died at @2, and bones were placed.", player_name, pos_string))
	end

	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	inv:set_size("main", 8 * 4)

	for _, list_name in ipairs(player_inventory_lists) do
		for i = 1, player_inv:get_size(list_name) do
			local stack = player_inv:get_stack(list_name, i)
			if inv:room_for_item("main", stack) then
				inv:add_item("main", stack)
			else -- no space left
				drop(pos, stack)
			end
		end
		player_inv:set_list(list_name, {})
	end

	meta:set_string("formspec", bones_formspec)
	meta:set_string("owner", player_name)

	if share_bones_time ~= 0 then
		meta:set_string("infotext", S("@1's fresh bones", player_name))

		if share_bones_time_early == 0 or not minetest.is_protected(pos, player_name) then
			meta:set_int("time", 0)
		else
			meta:set_int("time", (share_bones_time - share_bones_time_early))
		end

		minetest.get_node_timer(pos):start(10)
	else
		meta:set_string("infotext", S("@1's bones", player_name))
	end
end)

minetest.register_craftitem("bones:bone", {
	description = "Bone",
	inventory_image = "bones_bone.png",
	groups = {bone = 1},
})

minetest.register_node("bones:skull", {
	description = "Skull",
	walkable = false,
	tiles = {"bones_skull.png"},
	inventory_image = "bones_skull.png",
	wield_image = "bones_skull.png",
	drawtype = "torchlike",
	sunlight_propagates = true, -- Doesn't work for torchlike?
	light_source = 5,
	paramtype = "light",
	groups = {bone = 1, attached_node = 1, dig_immediate = 3},
	selection_box = {
		type = "fixed",
		fixed = {-0.3, -0.5, -0.3, 0.3, 0.25, 0.3}
	},
})

minetest.register_craftitem("bones:bone_meal", {
	description = "Bone Meal",
	inventory_image = "bones_bone_meal.png",
	on_use = bone_meal,
})

minetest.register_craft({
	output = "bones:bones",
	type = "shapeless",
	recipe = {"group:bone", "group:bone"},
})

minetest.register_craft({
	type = "shapeless",
	output = "bones:bone_meal 18",
	recipe = {"bones:bones"},
})

minetest.register_craft({
	output = "bones:bone_meal 9",
	recipe = {{"group:bone"}},
})
