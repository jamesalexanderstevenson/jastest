-- sethome/init.lua

sethome = {}

local players = {}

-- Load support for MT game translation.
local S = minetest.get_translator("sethome")


local homes_file = minetest.get_worldpath() .. "/homes"
local homepos = {}

local function loadhomes()
	local input = io.open(homes_file, "r")
	if not input then
		return -- no longer an error
	end

	-- Iterate over all stored positions in the format "x y z player" for each line
	for pos, name in input:read("*a"):gmatch("(%S+ %S+ %S+)%s([%w_-]+)[\r\n]") do
		homepos[name] = minetest.string_to_pos(pos)
	end
	input:close()
end

loadhomes()

sethome.set = function(name, pos)
	local player = minetest.get_player_by_name(name)
	if not player or not pos then
		return false
	end
	player:set_attribute("sethome:home", minetest.pos_to_string(pos))

	-- remove `name` from the old storage file
	local data = {}
	local output = io.open(homes_file, "w")
	if output then
		homepos[name] = nil
		for i, v in pairs(homepos) do
			table.insert(data, string.format("%.1f %.1f %.1f %s\n", v.x, v.y, v.z, i))
		end
		output:write(table.concat(data))
		io.close(output)
		return true
	end
	return true -- if the file doesn't exist - don't return an error.
end

sethome.get = function(name)
	local player = minetest.get_player_by_name(name)
	local pos = minetest.string_to_pos(player:get_attribute("sethome:home"))
	if pos then
		return pos
	end

	-- fetch old entry from storage table
	pos = homepos[name]
	if pos then
		return vector.new(pos)
	else
		return nil
	end
end

sethome.go = function(name)
	local pos = sethome.get(name)
	local player = minetest.get_player_by_name(name)
	if player and pos then
		player:set_pos(pos)
		return true
	end
	return false
end

local listh = function(name, list)
	local player = minetest.get_player_by_name(name)
	local meta = player:get_meta()
	local homes = minetest.deserialize(meta:get_string("homes"))
	if not homes then
		return false, "No homes"
	end
	if list then
		return homes
	end
	local str = ""
	for k, v in pairs(homes) do
		if k ~= "sel" then
			str = str .. k .. ", "
		end
	end
	str = str:sub(1, -3)
	return true, str
end

sethome.homes = function(name, sel, act)
	if act then
		local fs = "size[7.76,4.34]" ..
				forms.x ..
				forms.q
		if act == "add" then
			fs = fs .. forms.title("New Home") ..
				"field[1.15,2.2;5.25,1;new_home;New home name:;]" ..
				"button_exit[6,1.88;1,1;ok;OK]" ..
				"field_close_on_enter[new_home;true]"
			minetest.show_formspec(name, "sethome:add", fs)
		elseif act == "rename" then
			if players[name].six == "No homes found" then
				return forms.dialog(name, "Err", true)
			end
			fs = fs .. forms.title("Rename Home") ..
				"field[1.15,2.2;5.25,1;rename_home;Rename home:;" .. players[name].six .. "]" ..
				"button_exit[6,1.88;1,1;ok;OK]" ..
				"field_close_on_enter[rename_home;true]"
			minetest.show_formspec(name, "sethome:rename", fs)
		elseif act == "delete" then
			forms.dialog(name, "Are you sure you want to delete " .. players[name].six .. "?", true, "sethome:delete", "Confirm Delete?")
		end
	else
		sel = sel or 1

		local bash = {}
		local str = ""
		local dit = listh(name, true)
		if not dit then
			dit = {["No homes found"] = true}
		end
		for k, _ in pairs(dit) do
			if k ~= "sel" then
				bash[#bash + 1] = k
				str = str .. k .. ","
			end
		end
		players[name] = bash
		players[name].six = bash[sel]

		local lab = bash[sel]
		if lab == "No homes found" then
			lab = "Set home with /sethome"
		end

		local fs = "size[8,8.5]" ..
				forms.x ..
				forms.q ..
				forms.title("Homes Management") ..
				"label[4,1;" .. lab .. "]" ..
				"button_exit[4,2;2,1;go;Go]" ..
				"button[6,2;2,1;new;New]" ..
				"button[4,3;2,1;rename;Rename]" ..
				"button[6,3;2,1;delete;Delete]" ..
				"table[0,1;3.5,7.5;home;" .. str:sub(1, -2) .. ";" .. sel .. "]"

		minetest.show_formspec(name, "sethome:homes", fs)
	end
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "sethome:homes" then
		local name = player:get_player_name()
		if fields.home then
			local t = minetest.explode_table_event(fields.home)
			if t and t.row then
				sethome.homes(name, t.row)
			end
		elseif fields.go then
			local bash = listh(name, true)
			if bash then
				local sel = players[name].six
				local p = vector.new(bash[sel])
				if p then
					player:set_pos(p)
					hud.message(player, "Teleported to " .. sel)
				end
			end
		elseif fields.new then
			sethome.homes(name, nil, "add")
		elseif fields.rename then
			sethome.homes(name, nil, "rename")
		elseif fields.delete then
			sethome.homes(name, nil, "delete")
		end
	elseif formname == "sethome:add" then
		local meta = player:get_meta()
		local homes = minetest.deserialize(meta:get_string("homes"))
		if not homes then
			homes = {sethome = {x = 0, y = 0, z = 0}}
		end
		if #homes > 20 then
			return false, "Too many homes"
		end
		local param = fields.new_home
		if param and param ~= "" then
			if param:len() > 20 then
				return forms.dialog(player, "[Server] Name too long", true, nil, "Error", true)
			elseif param == "sel" then
				return forms.dialog(player, "[Server] Restricted name", true, nil, "Error", true)
			else
				param = param:gsub("%W", "")
				if param == "" then
					return forms.dialog(player, "[Server] Empty name", true, nil, "Error", true)
				end
			end
			homes[param] = player:get_pos()
			meta:set_string("homes", minetest.serialize(homes))
			hud.message(player, "Home " .. param .. " set!")
		end
	elseif formname == "sethome:rename" then
		local name = player:get_player_name()
		local meta = player:get_meta()
		local homes = minetest.deserialize(meta:get_string("homes"))
		if not homes then
			forms.dialog(player, "[Server] No homes", true, nil, "Error", true)
			return
		end
		local param = fields.rename_home
		if param and param ~= "" then
			if param:len() > 20 then
				return forms.dialog(player, "[Server] Name too long", true, nil, "Error", true)
			elseif param == "sel" then
				return forms.dialog(player, "[Server] Restricted name", true, nil, "Error", true)
			else
				param = param:gsub("%W", "")
				if param == "" then
					return forms.dialog(player, "[Server] Empty name", true, nil, "Error", true)
				end
				local oldname = players[name].six
				if param == oldname or homes[param] then
					return forms.dialog(player, "[Server] Please choose a different name", true, nil, "Error", true)
				end
				homes[param] = {x = homes[oldname].x, y = homes[oldname].y, z = homes[oldname].z}
				homes[oldname] = nil
				meta:set_string("homes", minetest.serialize(homes))
				forms.dialog(player, "[Server] " .. oldname .. " renamed to " .. param, true)
			end
		end
	elseif formname == "sethome:delete" and fields.ok then
		local name = player:get_player_name()
		local meta = player:get_meta()
		local homes = minetest.deserialize(meta:get_string("homes"))
		if not homes then
			return forms.dialog(player, "[Server] Undefined", true, nil, "Error", true)
		end
		local d = players[name].six
		if homes[d] then
			homes[d] = nil
			meta:set_string("homes", minetest.serialize(homes))
			forms.dialog(player, "[Server] " .. d .. " has been deleted", true, nil, "Success")
		end
	end
end)

minetest.register_privilege("home", {
	description = S("Can use /sethome and /home"),
	give_to_singleplayer = false
})

minetest.register_chatcommand("home", {
	description = S("Teleport you to your home point"),
	params = "[home_name]",
	privs = {home = true},
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		local meta = player:get_meta()
		local homes = minetest.deserialize(meta:get_string("homes"))

		if param and param ~= "" then
			if homes[param] then
				player:set_pos(homes[param])
				return true, "Ok"
			end
		end

		if sethome.go(name) then
			return true, S("Teleported to home!")
		end
		return false, S("Set a home using /sethome")
	end,
})

minetest.register_chatcommand("homes", {
	description = "Manage homes",
	privs = "home",
	params = "[delete|list|set|go]",
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		local meta = player:get_meta()
		local homes = minetest.deserialize(meta:get_string("homes"))

		local params = param:split(" ")
		if params[1] == "delete" then
			if homes[params[2]] then
				homes[params[2]] = nil
				meta:set_string("homes", minetest.serialize(homes))
				return true, "Deleted " .. params[2]
			end
			return false, "Not found"
		end
		return listh(name)
	end,
})

minetest.register_chatcommand("sethome", {
	description = S("Set your home point"),
	params = "[home_name]",
	privs = {home = true},
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		local meta = player:get_meta()
		local homes = minetest.deserialize(meta:get_string("homes"))
		if not homes then
			homes = {sethome = {x = 0, y = 0, z = 0}}
		end
		if #homes > 20 then
			return false, "Too many homes"
		end
		if param and param ~= "" then
			if param:len() > 20 then
				return false, "[Server] Name too long"
			elseif param == "sel" then
				return false, "[Server] Restricted name"
			else
				param = param:gsub("%W", "")
				if param == "" then
					return false, "Empty name"
				end
			end
			homes[param] = player:get_pos()
			meta:set_string("homes", minetest.serialize(homes))
		else
			homes.sethome = player:get_pos()
			meta:set_string("homes", minetest.serialize(homes))

			name = name or "" -- fallback to blank name if nil
			if player and sethome.set(name, player:get_pos()) then
				return true, S("Home set!")
			end
			return false, S("Player not found!")
		end

	end,
})

minetest.register_on_joinplayer(function(player)
	players[player:get_player_name()] = {}
end)

minetest.register_on_leaveplayer(function(player)
	players[player:get_player_name()] = nil
end)
