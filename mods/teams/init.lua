-- /mods/teams is part of jastest
-- copyright 2020 james alexander stevenson
-- gnu gpl 3+

teams = {}

local _teams = {}
local players = {}

teams.get_team = function(name)
	return players[name]
end

local function get_members(team)
	local a = {}
	for k, v in pairs(players) do
		if v == team then
			a[#a + 1] = k
		end
	end
	return a
end

local function manage(name, ti)
	local ts = {}
	for _, v in pairs(players) do
		local a = false
		for i = 1, #ts do
			if ts[i] == v then
				a = true
			end
		end
		if not a then
			ts[#ts + 1] = v
		end
	end
	local ps = ""
	local team = ts[ti]
	if team then
		ps = table.concat(get_members(team), ",")
	end
	ts = table.concat(ts, ",")
	local tn = ""
	local pn = ""
	local fs = "size[8.5,8]" ..
		"table[0,0;4,8;teams;" .. ts .. ";" .. tn .. "]" ..
		"table[4.25,0;4,8;players;" .. ps .. ";" .. pn .. "]" ..
	""
	minetest.show_formspec(name, "teams:manage", fs)
end

local function set_clothing(player, team)
	local name = player:get_player_name()
	local d_inv = minetest.get_inventory({type = "detached",
			name = name .. "_clothing"})
	local old_team = teams.get_team(name)
	if old_team ~= "red" and old_team ~= "green" and old_team ~= "blue" then
		local itemss = {}
		for i = 1, d_inv:get_size("clothing") do
			local stack = d_inv:get_stack("clothing", i)
			if stack:get_count() > 0 then
				table.insert(itemss, stack)
				d_inv:set_stack("clothing", i, nil)
				clothing:run_callbacks("on_unequip", player, i, stack)
			end
		end
		ll_items.throw_inventory(player:get_pos(), itemss)
	end
	local c = {"hat", "shirt", "pants", "cape"}
	for i = 1, 4 do
		local stack = ItemStack({name = "clothing:" .. c[i] .. "_" .. team})
		d_inv:set_stack("clothing", i, stack)
		clothing:run_callbacks("on_equip", player, i, stack)
	end
	clothing.save(player, d_inv)
	clothing:set_player_clothing(player)
end

teams.set_team = function(name, team)
	if not team then
		return
	end
	local player = minetest.get_player_by_name(name)
	if not player then
		return
	end
	local old_team = teams.get_team(name)
	if old_team then
		for k, v in pairs(_teams[old_team]) do
			if v == name then
				_teams[old_team][k] = nil
			end
		end
	end
	if team == "red" or team == "blue" or
			team == "green" then
		if old_team and old_team ~= team then
			set_clothing(player, team)
		end
	end
	players[name] = team
	local t = _teams[team]
	if t then
		table.insert(_teams[team], name)
	else
		_teams[team] = {name}
	end
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "teams:manage" then
		return
	end
	if fields.teams then
		local t = minetest.explode_table_event(fields.teams)
		if t.row and t.row ~= 0 then
			manage(player:get_player_name(), t.row)
		end
	end
end)

minetest.register_on_leaveplayer(function(player)
	players[player:get_player_name()] = nil
end)

minetest.register_chatcommand("team", {
	description = "Set or show team(s)",
	privs = "interact",
	params = "[set <name>]",
	func = function(name, param)
		if param == "" then
			manage(name)
			return true, players[name]
		end
		param = param:split(" ")
		if param[1] == "show" then
			local m = teams.get_team(name)
			if m then
				m = "Your team is: " .. m
			else
				m = "Not set!"
			end
			return true, m
		elseif param[1] == "set" then
			if param[2] then
				local n = param[2]:gsub("%W", "")
				if n == "blue" or n == "red" then
					ctf.players[name] = n
					ctf.players[name] = n
				end
				teams.set_team(name, n)
				return true, "[Server] Your team is now set to " .. n
			else
				return false, "[Server] Cannot unset team"
			end
		else
			return false, "[Server] Invalid usage"
		end
	end,
})

minetest.register_chatcommand("roster", {
	description = "Show team roster",
	privs = "shout",
	params = "",
	func = function(name, param)
		if not minetest.get_player_by_name(name) then
			return false, "Must be in-game!"
		end
		manage(name)
	end,
})
