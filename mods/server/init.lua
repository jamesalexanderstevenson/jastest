-- /mods/server is part of jastest
-- copyright 2020 james alexander stevenson
-- gnu gpl 3+

server = {}

local inseq = minetest.request_insecure_environment()
local mod_name = minetest.get_current_modname()
local input_file = minetest.get_modpath(mod_name) .. "/input_file"
local S = minetest.get_translator(mod_name)
local delay = 0
local spawn_pos_hard = {x = 64, y = 65, z = 16}
local spawn_set = minetest.settings:get("static_spawnpoint")
server.spawn_pos = minetest.string_to_pos(spawn_set) or spawn_pos_hard

local items
local items_tabstr = ""
local admin_name = minetest.settings:get("name")
local default_privs = minetest.string_to_privs(minetest.settings:get("default_privs"))

minetest.log = function()
end

minetest.register_on_joinplayer(function(player)
	minetest.after(1.5, function()
		local name = player:get_player_name()
		if minetest.get_player_by_name(name) and
				name ~= admin_name and
				not minetest.is_singleplayer() then
			minetest.set_player_privs(name, default_privs)
		end
	end)
end)

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

-- Chat Commands
minetest.register_chatcommand("debug", {
	description = "Debug functions",
	params = "",
	privs = "debug",
	func = function(name, param)
		local pos = minetest.get_player_by_name(name):get_pos()
		return true, "minetest.is_protected(pos, \"\"): " .. tostring(minetest.is_protected(pos, ""))
	end
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
		player:set_pos(server.spawn_pos)
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
minetest.register_craftitem("server:setter2", {
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

minetest.register_tool("server:adminpick2", {
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
	on_place = function(itemstack, placer, pointed_thing)
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
