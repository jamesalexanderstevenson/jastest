-- /mods/setup is part of jastest
-- copyright 2020 james alexander stevenson
-- gnu gpl 3+

setup = {}
setup.sel = {}

local players = {}
local initial_items = {}
local respawn_items = {}
local listnames = {}

local welcome_msg = minetest.settings:get("welcome_message")
if not welcome_msg or welcome_msg == "" then
	welcome_msg = "Hi {$name}, welcome to {$server}!"
end
if welcome_msg:find("{$server}") then
	local server_name = minetest.settings:get("server_name")
	if not server_name or server_name == "" then
		server_name = "My Server"
	end
	welcome_msg = welcome_msg:gsub("{$server}", server_name)
end

setup.init = function(item, priority, respawn, listname)
	if not item or not tonumber(priority) then
		return
	end
	if listname and listnames[listname] then
		listnames[listname][item] = priority
	elseif listname then
		listnames[listname] = {[item] = priority}
	end
	if respawn then
		respawn_items[item] = priority
	end
	if not listname then
		initial_items[item] = priority
	end
end

local function giveit(player, init, respawn)
	local name = player:get_player_name()
	if minetest.get_player_by_name(name) then
		local inv = player:get_inventory()
		if not players[name] and init then
			-- new player
			local slip = initial_items
			players[name] = {items = slip}
			if welcome_msg then
				if welcome_msg:find("{$name}") then
					minetest.after(2.3, forms.log, welcome_msg:gsub("{$name}", name))
				else
					minetest.after(2.3, forms.log, welcome_msg, true)
				end
			end
		elseif respawn then
			-- respawning player
			local slip = respawn_items
			players[name] = {items = slip}
		elseif not players[name] then
			-- returning player
			players[name] = {items = {}}
			if not init then
				forms.log("*** " .. name .. " joined the game.", false)
			end
		end
		for k, v in pairs(listnames) do
			if not inv:get_list(k) then
				local c = 0
				local it
				for kk, vv in pairs(v) do
					c = c + 1
					it = kk
				end
				inv:set_size(k, c)
				if it then
					inv:add_item(k, it)
					break
				end

			end
		end
		local lap = {}
		for k, v in pairs(players[name].items) do
			for kk, vv in pairs(players[name].items) do
				if v > vv then
					table.insert(lap, k)
					break
				else
					table.insert(lap, 1, k)
					break
				end

			end
		end
		for k, v in pairs(lap) do
			local pit = inv:add_item("main", v)
			if pit then
				minetest.add_item(player:get_pos(), pit)
			end
		end
		players[name] = nil
		return
	end
	minetest.after(0.2, function()
		giveit(player)
	end)
end

minetest.register_on_newplayer(function(player)
	giveit(player, true)
end)

minetest.register_on_joinplayer(function(player)
	giveit(player)
end)

minetest.register_on_respawnplayer(function(player)
	giveit(player, false, true)
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	if name then
		forms.log("*** " .. name .. " left the game.", false)
	end
	if setup.sel[name] then
		setup.sel[name] = nil
	end
end)
