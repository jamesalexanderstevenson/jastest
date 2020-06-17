-- jastest/mods/server/init.lua is part of jastest
-- Copyright 2020 James Stevenson
-- Licensed GNU GPL v3+

-- TODO I didn't know about
-- minetest.register_on_privilege_grant() and
-- minetest.register_on_privilege_revoke(), so
-- please replace this sillyness with this more
-- proper approach. Thanks future, probable self!

server = {}

local inseq = minetest.request_insecure_environment()
local mod_name = minetest.get_current_modname()
local input_file = minetest.get_modpath(mod_name) .. "/input_file"
local S = minetest.get_translator(mod_name)
local delay = 0
local spawn_pos_hard = {x = 64, y = 65, z = 16}
local spawn_set = minetest.settings:get("static_spawnpoint")
local spawn_pos = minetest.string_to_pos(spawn_set) or spawn_pos_hard
local items
local items_tabstr = ""
local admin_name = minetest.settings:get("name")
local pool = {[admin_name] = true}
local store = minetest.get_mod_storage()
local prepool = minetest.deserialize(store:get("pool"))
if prepool then
	pool = prepool
end

local default_privs = {}
for _, v in pairs(minetest.settings:get("default_privs"):split(", ")) do
	default_privs[v] = true
end

server.check_items = function(player, oneshot)
	if not minetest.get_player_by_name(player:get_player_name()) then
		return
	end
	local inv = player:get_inventory()
	local lists = inv:get_lists()
	for k, v in pairs(lists) do
		for kk, vv in pairs(v) do
			if vv:get_count() > 99 then
				inv:set_stack(k, kk, nil)
			end
		end
	end
	if not oneshot then
		minetest.after(49, server.check_items, player)
	end
end

server.is_admin = function(name)
	return pool[name]
end

minetest.log = function()
end

local function check_privs(name)
	if minetest.get_player_by_name(name) then
		if not pool[name] then
			local privs = minetest.get_player_privs(name)
			for k, v in pairs(privs) do
				if not (k == "fast" or k == "fly") and not default_privs[k] then
					privs[k] = nil
				end
			end
			minetest.set_player_privs(name, privs)
		end
	end
end

minetest.register_privilege("debug", {
	description = "Can use debug functions",
	give_to_admin = false,
	give_to_singleplayer = false,
})

minetest.register_on_chat_message(function(name, message)
	local output_file = minetest.get_modpath(mod_name) .. "/output_file"
	local h = inseq.io.open(output_file, "a")
	h:write("<" .. name .. "> " .. message .. "\n")
	h:flush()
	table.insert(forms.lines, 1, "<" .. name .."> " .. message)
end)

minetest.register_globalstep(function(dtime)
	if delay < 60 then
		delay = delay + dtime
		return
	else
		delay = 0
	end
	local mo = minetest.get_connected_players()
	for i = 1, #mo do
		check_privs(mo[i]:get_player_name())
	end
end)

minetest.register_on_joinplayer(function(player)
	minetest.after(1, function()
		check_privs(player:get_player_name())
	end)
end)

-- Chat Commands
minetest.register_chatcommand("debug", {
	description = "Debug functions",
	params = "",
	privs = "debug",
	func = function(name, param)
		local pos = minetest.get_player_by_name(name):get_pos()
		print(minetest.is_protected(pos, ""))
		return true, "Printed"
	end
})

minetest.register_chatcommand("check_items", {
	description = "Check inventory for strange stacks",
	params = "A person, place, or thing",
	privs = "warden",
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		local target = minetest.get_player_by_name(param)
		if param == "" then
			server.check_items(player, true)
			return true, "[Server] Checking your inventory"
		elseif target then
			if minetest.check_player_privs(name, "protector") then
				server.check_items(target)
				return true, "[Server] Checking " .. target:get_player_name()
			end
			server.check_items(target, true)
			return true, "[Server] Checking " .. target:get_player_name()
		end
		return false, "[Server] Try again"
	end,
})

minetest.register_chatcommand("spawn", {
	params = "none",
	privs = "interact",
	description = "Teleport to spawn",
	func = function(name)
		local player = minetest.get_player_by_name(name)
		if not player then
			return
		end
		player:set_pos(spawn_pos)
		return true, "[Server] Teleported to spawn location"
	end,
})

minetest.register_chatcommand("motd", {
	description = S("Show the message of the day"),
	params = "[set]",
	privs = "shout",
	func = function(name)
		return true, minetest.settings:get("motd") or "nil"
	end,
})

minetest.register_chatcommand("what", {
	description = "What is this thing?",
	params = "[dump|d]: Dump ItemStack",
	privs = "interact",
	func = function(name, param)
		local d = minetest.check_player_privs(name, "debug")
		if (param == "d" or param == "dump") then
			if d then
				local str = minetest.get_player_by_name(name):get_wielded_item():to_string()
				print(str)
				return true, str
			else
				local str = minetest.get_player_by_name(name):get_wielded_item():to_string()
				print(str)
				return false, "[Server] Insufficient privileges"
			end
		elseif param == "registered_nodes" then
			if d then
				local p = {}
				for k, v in pairs(minetest.registered_nodes) do
					p[#p + 1] = k
				end
				table.sort(p)
				print(dump(p))
			else
				return false, "No"
			end
		elseif param == "registered_craftitems" then
			if d then
				local p = {}
				for k, v in pairs(minetest.registered_craftitems) do
					p[#p + 1] = k
				end
				table.sort(p)
				print(dump(p))
			else
				return false, "No"
			end

		end
		local thing = minetest.get_player_by_name(name):get_wielded_item()
		return true, thing:get_description() .. " (" .. thing:get_name() .. ")"
	end,
})

minetest.register_chatcommand("items", {
	func = function(name, param)
		if not items then
			items = {}
			for k, v in pairs(minetest.registered_items) do
				if not (v.groups and v.groups.not_in_creative_inventory) then
					table.insert(items, k)
				else
					print("not itemized: " .. k)
				end
			end
			table.sort(items)
			tabstr = table.concat(items, ",")
		end
		local fs = "size[8,8.5]" ..
				"table[0,0;8,8.5;items;" .. tabstr .. "]"
		minetest.show_formspec(name, "setup:items", fs)
	end,
})

minetest.register_chatcommand("whois", {
	description = "Self discovery apparatus",
	privs = "server",
	params = "[names]",
	func = function(name, param)
		local player = minetest.get_player_by_name(param) or
				minetest.get_player_by_name(name)
		return true, player:get_player_name()
	end,
})

minetest.register_chatcommand("killme", {
	description = S("Set HP to zero and respawn"),
	params = "[delay]",
	privs = "interact",
	func = function(name)
		local player = minetest.get_player_by_name(name)
		if player then
			if minetest.check_player_privs(name, "server") then
				minetest.set_node(minetest.get_player_by_name(name):get_pos(), {name = "bones:bones"})
			end
			if minetest.settings:get_bool("enable_damage") then
				player:set_hp(0, {
					type = "set_hp",
					killme = true,
				})
				return true
			else
				for _, callback in pairs(minetest.registered_on_respawnplayers) do
					if callback(player) then
						return true
					end
				end

				-- There doesn't seem to be a way to get a default spawn pos
				-- from the lua API
				return false, S("No static_spawnpoint defined")
			end
		else
			-- Show error message if used when not logged in, eg: from IRC mod
			return false, S("You need to be online to be killed!")
		end
	end,
})

-- Chatcommand overrides
minetest.override_chatcommand("admin", {
	description = "List or manage admins",
	params = "[list|add|delete]",
	privs = "shout",
	func = function(name, param)
		local privs = minetest.get_player_privs(name)
		if name ~= admin_name then
			if admin_name then
				return true, "[Server] The administrator of this server is " .. admin_name .. "."
			else
				return false, "[Server] There's no administrator named in the config file."
			end
		end
		param = param:split(" ")
		if param[2] and param[2] == admin_name then
			return false, "[Server] Cannot modify admin name"
		end
		if param[1] == "add" then
			if param[2] then
				pool[param[2]] = true
				store:set_string("pool", minetest.serialize(pool))
				return true, "[Server] Added " .. param[2]
			else
				return false, "[Server] No name"
			end
		elseif param[1] == "delete" then
			if not param[2] then
				return false, "[Server] No argument"
			end
			if pool[param[2]] then
				pool[param[2]] = nil
				store:set_string("pool", minetest.serialize(pool))
				return true, "[Server] Removed " .. param[2]
			end
			return false, "[Server] Name not found"
		elseif param[1] == "list" then
			for k, v in pairs(pool) do
				minetest.chat_send_player(name, k)
			end
			return true, "[Server] Listed"
		end
		return true, "[Server] /admin <list|delete|add>"
	end,
})

minetest.override_chatcommand("me", {
	func = function(name, param)
		local s = "* " .. name .. " " .. param
		minetest.chat_send_all(s)
		print(s)
		local output_file = minetest.get_modpath(mod_name) .. "/output_file"
		local h = inseq.io.open(output_file, "a")
		h:write(s .. "\n")
		h:flush()
		table.insert(forms.lines, 1, s)
	end,
})

minetest.override_chatcommand("msg", {
	func = function(name, param)
		local sendto, message = param:match("^(%S+)%s(.+)$")
		if not sendto then
			return false, "Invalid usage, see /help msg."
		end
		if not minetest.get_player_by_name(sendto) then
			return false, "The player " .. sendto
					.. " is not online."
		end
		local s = "DM from " .. name .. " to " .. sendto .. "> " .. message
		print(s)
		local output_file = minetest.get_modpath(mod_name) .. "/output_file"
		local h = inseq.io.open(output_file, "a")
		h:write(s .. "\n")
		h:flush()

		minetest.chat_send_player(sendto, "DM from " .. name .. ": "
				.. message)
		return true, "Message sent."
	end,
})

-- Pick and setter
minetest.register_craftitem("server:setter", {
	description = "Super Setter",
	inventory_image = "default_tool_steelpick.png^default_obsidian_shard.png",
	groups = {not_in_creative_inventory = 1},
	on_use = function(itemstack, user, pointed_thing)
		if not minetest.check_player_privs(user, "protector") then
			return {name = "default:pick_steel"}
		end
		local alt = user:get_player_control().sneak
		local p = pointed_thing.under
		if not p then
			return itemstack
		end
		local n = minetest.get_node_or_nil(p)
		if not n then
			return itemstack
		end
		minetest.remove_node(p)
		if not alt then
			minetest.check_for_falling(p)
		end
		return itemstack
	end,
	on_drop = function(itemstack, dropper, pos)
		itemstack:clear()
		return itemstack
	end,
})

minetest.register_tool("server:adminpick", {
	description = "Admin Pickaxe",
	inventory_image = "server_adminpick.png",
	range = 11,
	groups = {not_in_creative_inventory = 1},
	tool_capabilities = {
		full_punch_interval = 0.1,
		max_drop_level = 3,
		groupcaps = {
			unbreakable =   {times={[1] = 0, [2] = 0, [3] = 0}, uses = 0, maxlevel = 3},
			dig_immediate = {times={[1] = 0, [2] = 0, [3] = 0}, uses = 0, maxlevel = 3},
			fleshy =	{times={[1] = 0, [2] = 0, [3] = 0}, uses = 0, maxlevel = 3},
			choppy =	{times={[1] = 0, [2] = 0, [3] = 0}, uses = 0, maxlevel = 3},
			bendy =		{times={[1] = 0, [2] = 0, [3] = 0}, uses = 0, maxlevel = 3},
			cracky =	{times={[1] = 0, [2] = 0, [3] = 0}, uses = 0, maxlevel = 3},
			crumbly =	{times={[1] = 0, [2] = 0, [3] = 0}, uses = 0, maxlevel = 3},
			snappy =	{times={[1] = 0, [2] = 0, [3] = 0}, uses = 0, maxlevel = 3}
		},
		damage_groups = {fleshy = 1000}
	},
	on_drop = function(itemstack, dropper, pos)
		itemstack:clear()
		return itemstack
	end,
	after_use = function(itemstack, user, node, digparams)
		if not server.is_admin(user:get_player_name()) then
			return ""
		end
	end,
	on_place = function(itemstack, placer, pointed_thing)
		if not server.is_admin(placer:get_player_name()) then
			return ""
		end
		if pointed_thing and pointed_thing.type == "node" then
			local pos = pointed_thing.under or pointed_thing.above
			if pos then
				tnt.boom(pos, {
					radius = 1,
					damage_radius = 1,
					explode_center = true,
					ignore_protection = true,
					ignore_on_blast = true,
				})
			end
		end
		return itemstack
	end,
})

--[[
local function kill_node(pos, _, puncher)
	if puncher:get_wielded_item():get_name() == "server:adminpick" then
		if not minetest.check_player_privs(puncher:get_player_name(), "protector") then
			puncher:set_wielded_item("")
			return
		end

		local nn = minetest.get_node(pos).name
		if nn == "air" then
			return
		end
		local node_drops = minetest.get_node_drops(nn, "server:adminpick")
		for i = 1, #node_drops do
			local add_node = puncher:get_inventory():add_item("main", node_drops[i])
			if add_node then
				minetest.add_item(pos, add_node)
			end
		end
		minetest.remove_node(pos)
		minetest.check_for_falling(pos)
	end
end
--]]

minetest.register_on_mods_loaded(function()
	for k, v in pairs(minetest.registered_privileges) do
		local old
		if v.on_grant then
			old = v.on_grant
		end
		minetest.registered_privileges[k].on_grant = function(name, granter_name)
			minetest.after(0.1, function()
				check_privs(name)
				if granter_name then
					check_privs(granter_name)
				end
			end)
			if old then
				old(name, granter_name)
			end
		end
	end
	--[[
	for node in pairs(minetest.registered_nodes) do
		local def = minetest.registered_nodes[node]
		for i in pairs(def) do
			if i == "on_punch" then
				local rem = def.on_punch
				local function new_on_punch(pos, new_node, puncher, pointed_thing)
					kill_node(pos, new_node, puncher)
					return rem(pos, new_node, puncher, pointed_thing)
				end
				minetest.override_item(node, {
					on_punch = new_on_punch
				})
			end
		end
	end
	--]]
end)

minetest.register_privilege("creative")
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "setup:items" and
				minetest.check_player_privs(player, "creative") and
				fields.items and fields.items:sub(1, 3) == "DCL" then
		local d = fields.items:sub(5)
		local it = ItemStack(items[tonumber(d:sub(1, d:find(":") - 1))])
		it:set_count(it:get_stack_max())
		local inv = player:get_inventory()
		it = inv:add_item("main", it)
		if not it:is_empty() then
			ll_items.throw_inventory(player:get_pos(), {it}, true)
		end
	end
end)
