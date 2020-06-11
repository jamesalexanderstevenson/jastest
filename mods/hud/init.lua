hud = {}
local players = {}
local players_id = {}
local messages = {}
local red = {}

hud.get_armor_total = function(name)
	return players[name].total
end

local gen_string = function(name)
	local output = ""
	for i = 4, 1, -1 do
		local mm = messages[name][i]
		output = output .. "\n" .. mm
	end
	return output
end

local timer = function(player)
	local name = player:get_player_name()
	messages[name][5] = messages[name][5] + 1
	minetest.after(9, function()
		if not minetest.get_player_by_name(name) then
			return
		end
		for i = 4, 1, -1 do
			if messages[name] and messages[name][i] and
					messages[name][i] ~= "" then
				messages[name][i] = ""
				player:hud_change(players_id[name].messages, "text", gen_string(name))
				messages[name][5] = messages[name][5] - 1
				break
			end
		end
	end)
end

function hud.message(player, message, delay)
	if not message then
		return
	end
	if delay then
		minetest.after(delay, function()
			hud.message(player, message)
		end)
		return
	end
	local name
	if type(player) ~= "string" then
		name = player:get_player_name()
	else
		name = player
		player = minetest.get_player_by_name(name)
	end
	local m = messages[name]
	if not m then
		return
	end
	for i = 4, 2, -1 do
		local mm = m[i]
		m[i] = m[i - 1]
	end
	m[1] = message
	player:hud_change(players_id[name].messages, "text", gen_string(name))
	if messages[name][5] <= 4 then
		timer(player)
	end
end

hud.update = function(player, rep, force_armor_update)
	if not minetest.get_player_by_name(player:get_player_name()) then
		return
	end
	local name, inv = armor:get_valid_player(player)
	if inv then
		local as = inv:get_list("armor")
		if players[name] then
			for i = 1, 6 do
				local asa = as[i]
				local asap = as[i]:get_name()
				local asaw = asa:get_wear()
				local asawp = (65535 - asaw) * 0.0002 / 4
				if asap:match("helmet") then
					if asaw > 0 then
						players[name].helmet = asawp
					else
						players[name].helmet = 4
					end
				elseif asap:match("chestplate") then
					if asaw > 0 then
						players[name].chestplate= asawp
					else
						players[name].chestplate = 4
					end
				elseif asap:match("leggings") then
					if asaw > 0 then
						players[name].leggings = asawp
					else
						players[name].leggings = 4
					end
				elseif asap:match("boots") then
					if asaw > 0 then
						players[name].boots = asawp
					else
						players[name].boots = 4
					end
				elseif asap:match("shield") then
					if asaw > 0 then
						players[name].shield = asawp
					else
						players[name].shield = 4
					end
				end
			end

			if players[name].helmet > 0 then
				for i = 1, 6 do
					local asa = as[i]
					local asap = as[i]:get_name()
					if asap:match("helmet") then
						break
					elseif not asap:match("helmet") and i == 6 then
						players[name].helmet = 0
					end
				end
			end
			if players[name].chestplate > 0 then
				for i = 1, 6 do
					local asa = as[i]
					local asap = as[i]:get_name()
					if asap:match("chestplate") then
						break
					elseif not asap:match("chestplate") and i == 6 then
						players[name].chestplate = 0
					end
				end
			end
			if players[name].leggings > 0 then
				for i = 1, 6 do
					local asa = as[i]
					local asap = as[i]:get_name()
					if asap:match("leggings") then
						break
					elseif not asap:match("leggings") and i == 6 then
						players[name].leggings = 0
					end
				end
			end
			if players[name].boots > 0 then
				for i = 1, 6 do
					local asa = as[i]
					local asap = as[i]:get_name()
					if asap:match("boots") then
						break
					elseif not asap:match("boots") and i == 6 then
						players[name].boots = 0
					end
				end
			end
			if players[name].shield > 0 then
				for i = 1, 6 do
					local asa = as[i]
					local asap = as[i]:get_name()
					if asap:match("shield") then
						break
					elseif not asap:match("shield") and i == 6 then
						players[name].shield = 0
					end
				end
			end
		end
	end
	if name and players[name] then
		local total = players[name].helmet +
				players[name].chestplate +
				players[name].leggings +
				players[name].boots +
				players[name].shield
		if players[name].total ~= total or force_armor_update then
			player:hud_change(players_id[name].armor, "number", math.ceil(total))
			players[name].total = total
		end

		local stam = stamina.get_stamina(name)
		if stam > 100 then
			stam = 100
		end
		local sat = stamina.get_satiation(name)
		if stam > sat then
			stam = sat
		elseif stam < 1 then
			stam = 0
		end
		if stam ~= players[name].old_stamina then
			player:hud_change(players_id[name].stamina, "number", stam)
			players[name].old_stamina = stam
		end
		if (stamina.is_poisoned(name) or stam <= 10) and not red[name] then
			player:hud_change(players_id[name].stamina, "text", "stamina_sb_red.png")
			red[name] = true
		elseif red[name] and (stam > 10 and not stamina.is_poisoned(name)) then
			player:hud_change(players_id[name].stamina, "text", "stamina_sb_green.png")
			red[name] = false
		end
			
	end
	if rep then
		minetest.after(1, hud.update, player, rep)
	end
end

minetest.hud_replace_builtin("breath", {
        hud_elem_type = "statbar",
        position = {x = 1, y = 0.5},
        text = "bubble.png",
        number = 10,
        direction = 3,
        size = {x = 24, y = 8},
        offset = {x = -48, y = 32},
})

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	players_id[name] = {armor = -1, stamina = -1}
	players_id[name].stamina = player:hud_add({
		name = "stamina",
		hud_elem_type = "statbar",
		position = {x = 0.5, y = 1},
		text = "stamina_sb_green.png",
		text2 = "stamina_sb_white.png",
		item = 100,
		number = 100,
		direction = 0,
		size = {x = 9, y = 3},
		offset = {x = -225, y = -66},
	})
	players_id[name].armor = player:hud_add({
		name = "armor",
		hud_elem_type = "statbar",
		position = {x = 0.5, y = 1},
		text = "hud_sb_armor.png",--^[colorize:green:203",
		text2 = "hud_sb_armor_bg.png",
		number = 0,
		item = 20,
		direction = 0,
		size = {x = 24, y = 24},
		offset = {x = 24, y = -(48 + 24 + 16)},
	})
	players_id[name].messages = player:hud_add({
		hud_elem_type = "text",
		name = "hmsg",
		number = 0xFFFFFF,
		position = {x = 0.02, y = 0.7},
		text = "",
		scale = {x = 100, y = 25},
		alignment = {x = 1, y = -1},
	})
	players[name] = {
		helmet = 0,
		chestplate = 0,
		leggings = 0,
		boots = 0,
		shield = 0,
		total = 0,
		old_stamina = 0,
	}
	messages[name] = {[1] = "", [2] = "", [3] = "", [4] = "", [5] = 1}
	red[name] = false
	minetest.after(1, hud.update, player, false, true)
	hud.update(player, true)
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	players[name] = nil
	messages[name] = nil
	red[name] = nil
end)

minetest.register_chatcommand("hmsg", {
	description = "Display HUD message",
	params = "<message>",
	privs = "debug",
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if not player then
			return false, "Not in-game!"
		end
		hud.message(player, param)
	end,
})
