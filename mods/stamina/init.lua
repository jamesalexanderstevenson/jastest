-- /mods/stamina is part of jastest
-- copyright 2020 james alexander stevenson
-- gnu gpl 3+

stamina = {}
local players = {}
local poisoned = {}
local hunger_del = {}
local hunger_drain_time = 10
local stamina_del = {}
local stamina_drain_time = 1
local damage_del = {}
local damage_drain_time = 2
local cooldown = {}

stamina.is_cooldowned = function(name)
	return cooldown[name] ~= nil
end

stamina.get_stamina = function(name, percent)
	if not minetest.get_player_by_name(name) then
		return
	end
	if percent then
		local ret = (players[name].stamina / players[name].satiation) * 100
		if ret > 100 then
			ret = 100
		end
		return ret
	end
	return players[name].stamina
end

stamina.get_satiation = function(name)
	if not minetest.get_player_by_name(name) then
		return
	end
	return players[name].satiation
end

stamina.is_poisoned = function(name)
	if poisoned[name] and poisoned[name].active then
		return true
	else
		return false
	end
end

local function save_sat(name)
	local sat = players[name].satiation
	local meta = minetest.get_player_by_name(name):get_meta():set_string("satiation", tostring(sat))
end

local function load_sat(name)
	local sat = minetest.get_player_by_name(name):get_meta():get_string("satiation")
	if sat ~= "" then
		sat = tonumber(sat)
	else
		sat = 100
	end
	players[name].satiation = sat
end

local function move_check(player, t)
	local name = player:get_player_name()
	if not minetest.get_player_by_name(name) then
		return 0
	end
	local c = player:get_player_control()
	local m = players[name].movement
	if c.aux1 or c.jump then
		m = m + 0.15
	end
	if c.LMB or c.RMB then
		m = m + 0.15
	end
	if c.up or c.down or c.left or c.right then
		m = m + 0.15
	end
	if c.sneak then
		m = m - 0.15
	end
	if m < 0 or cozy.players[name] ~= "stand" then
		m = 0
	else
		m = m + 0.1
	end
	return m
end

local function poll(name)
	if not players[name] then
		if hunger_del[name] then
			hunger_del[name] = nil
		end
		if stamina_del[name] then
			stamina_del[name] = nil
		end
		if damage_del[name] then
			damage_del[name] = nil
		end
		return
	end
	local player = minetest.get_player_by_name(name)
	if player then
		if not hunger_del[name] then
			hunger_del[name] = minetest.get_us_time()
		end
		if not stamina_del[name] then
			stamina_del[name] = minetest.get_us_time()
		end
		if not damage_del[name] then
			damage_del[name] = minetest.get_us_time()
		end
		local now = minetest.get_us_time()
		local sat = players[name].satiation
		local stam = players[name].stamina
		local movement = players[name].movement
		local godmode = minetest.check_player_privs(name, "godmode") 
		local attached = player_api.player_attached[name]

		if (now - hunger_del[name]) / 1000000 > hunger_drain_time then
			if movement > 1 then
				-- TODO interpolate
				movement = 1
			end
			if not godmode then
				sat = sat - movement
			end
			players[name].satiation = sat
			hud.update(player)
			save_sat(name)
			hunger_del[name] = minetest.get_us_time()
			players[name].movement = 0
		end

		if (now - stamina_del[name]) / 1000000 > stamina_drain_time then
			if supersprint.is_sprinting(name) and stam > 0 and
					not attached and not godmode then
				players[name].stamina = stam - 1
				if players[name].stamina < 0 then
					players[name].stamina = 0
				end
			elseif stam < sat and not supersprint.is_sprinting(name) and
					not cooldown[name] and not stamina.is_poisoned(name) then
				players[name].stamina = stam + 2
				if players[name].stamina > 100 then
					players[name].stamina = 100
				end
			elseif stam < 1 then
				stam = 0
				cooldown[name] = true
			elseif cooldown[name] then
				if stam >= sat then
					stam = sat
					cooldown[name] = nil
				end
			elseif stam > sat then
				players[name].stamina = sat
			end
			hud.update(player)
			stamina_del[name] = minetest.get_us_time()
			players[name].movement = move_check(player)
		end

		local hp = player:get_hp()
		if (now - damage_del[name]) / 1000000 > damage_drain_time then
			if hp ~= 0 and players[name].satiation < 2 and not godmode then
				if hp < 5 then
					player:set_hp(0, {
						type = "set_hp",
						starving = true,
					})
				else
					player:set_hp(hp - math.random(5), {
						type = "set_hp",
						starving = true,
					})
				end

			end
			damage_del[name] = minetest.get_us_time()
		end
	end
	minetest.after(0, function()
		poll(name)
	end)
end

local function poison(player, amount, rep)
	local name = player:get_player_name()
	if amount > 0 then
		return
	end
	if poisoned[name] and not poisoned[name].active then
		return
	end
	if not minetest.get_player_by_name(name) then
		return
	end
	if rep and rep <= 0 then
		hud.message(player, "You are no longer poisoned")
		poisoned[name] = nil
		return
	end
	rep = rep or math.ceil(-amount / 3)
	rep = rep - 1
	local sat = players[name].satiation
	local stam = players[name].stamina
	local hp = player:get_hp()
	if hp == 0 then
		poisoned[name] = nil
		return
	end
	sat = sat + amount
	if sat < 0 then
		sat = 0
	end
	players[name].satiation = sat
	stam = stam + amount
	if stam < 0 then
		stam = 0
	end
	players[name].stamina = stam
	hp = hp + amount
	player:set_hp(hp, {
		type = "set_hp",
		poisoned = true,
	})
	poisoned[name] = {amount = amount, rep = rep, active = true}

	minetest.after(1, function()
		poison(player, amount, rep)
	end)
end

minetest.register_on_item_eat(function(hp_change, replace_with_item, itemstack, user, pointed_thing)
	local hp = user:get_hp()
	if hp == 0 then
		return
	end
	local name = user:get_player_name()
	local sat = players[name].satiation
	local stam = players[name].stamina
	if sat >= 100 then
		return itemstack
	end
	local hp_max = 100
	local is_poisoned = poisoned[name] and poisoned[name].active
	if hp_change > 0 and not is_poisoned then
		-- feed
		sat = sat + hp_change
		if sat > 100 then
			sat = 100
		end
		players[name].satiation = sat
		stam = stam + hp_change
		if stam > 100 then
			stam = 100
		end
		players[name].stamina = stam
	elseif hp_change < 0 and not minetest.check_player_privs(name, "godmode") then
		hud.message(user, "You are poisoned!")
		if is_poisoned then
			return itemstack
		end
		poison(user, hp_change)
	elseif is_poisoned then
		hud.message(user, "You are poisoned!")
		return itemstack
	end
	hud.update(user)
	save_sat(name)
	itemstack:take_item()
	minetest.after(0, minetest.sound_play, "stamina_eat", {object = user}, true)
	return replace_with_item or itemstack
end)

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	players[name] = {
		stamina = 100,
		satiation = 100,
		movement = 0,
	}
	load_sat(name)
	poll(name)
	minetest.after(0.5, hud.update, player)
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	save_sat(name)
	players[name] = nil
	hunger_del[name] = nil
	stamina_del[name] = nil
	if cooldown[name] then
		cooldown[name] = nil
	end
end)

minetest.register_on_dieplayer(function(player)
	local name = player:get_player_name()
	if poisoned[name] and poisoned[name].active then
		poisoned[name].active = nil
	end
	cooldown[name] = nil
	players[name].satiation = 0
	players[name].stamina = 0
end)

minetest.register_on_respawnplayer(function(player)
	if not player then
		return
	end
	local name = player:get_player_name()
	players[name].satiation = 100
	players[name].stamina = 100
	if poisoned[name] and poisoned[name].active then
		poisoned[name].active = nil
		hud.message(player, "You are no longer poisoned")
	end
end)

minetest.register_chatcommand("stamina", {
	description = "Set or display stamina",
	privs = "interact",
	params = "[value]",
	func = function(name, param)
		local privs = minetest.check_player_privs(name, "server")
		if param ~= "" then
			if not privs then
				return false, "No privs"
			end
			local player = minetest.get_player_by_name(name)
			players[name].stamina = tonumber(param)
			hud.update(player)
			return true, "Set to " .. param
		end
		return true, players[name].stamina
	end,
})

minetest.register_chatcommand("satiation", {
	description = "Set or display stamina",
	privs = "interact",
	params = "[value]",
	func = function(name, param)
		local privs = minetest.check_player_privs(name, "server")
		if param ~= "" then
			if not privs then
				return false, "No privs"
			end	
			local player = minetest.get_player_by_name(name)
			players[name].satiation = tonumber(param)
			hud.update(player)
			return true, "Set to " .. param
		end
		return true, players[name].satiation
	end,
})
