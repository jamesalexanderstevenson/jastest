supersprint = {}
local sprint_toggle = {}
local t = {}
local sprinting = {}
local players = {}
local accelerating = {}
local hid = {}
local gid = {}

supersprint.is_sprinting = function(name)
	return sprinting[name]
end

local function rm(o)
	local n = o:get_player_name()
	sprint_toggle[n] = not sprint_toggle[n]
	local op = ""
	if sprint_toggle[n] then
		op = "supersprint_icon.png"
	end
	o:hud_change(hid[n], "text", op)
end

local function control(player, field)
	local controls = player:get_player_control()
	if field then
		return controls[field]
	else
		return controls
	end
end

local function physics(player, enabled)
	if enabled then
		player:set_physics_override({
			speed = 2,
			jump = 1.5,
			gravity = 0.96,
			new_move = false,
			sneak_glitch = true,
			sneak = true,
		})
	else
		player:set_physics_override({
			speed = 1,
			jump = 1,
			gravity = 1,
			new_move = true,
			sneak_glitch = false,
			sneak = true,
		})
	end
end

local function boost(player, old_pos)
	local name = player:get_player_name()
	local vel = player:get_player_velocity()
	local sneak = player:get_player_control().sneak 
	if vel.y >= 6.5 and players[name] < 1 and
			sneak and accelerating[name] then
		players[name] = players[name] + 1
		local boost = vector.multiply(vel, 0.35)
		player:add_player_velocity(boost)
	elseif vel.y <= 0 and not sneak then
		players[name] = 0
	end
end

local function sprint(player)
	if not player then
		return
	end

	local name = player:get_player_name()
	local attached = player_api.player_attached[name]
	if minetest.get_player_by_name(name) and not attached then
		local stam = stamina.get_stamina(name)
		local sat = stamina.get_stamina(name)
		local pos = player:get_pos()
		local c = control(player)
		local s = sprinting[name]
		local vel = player:get_player_velocity()
		local y = vel.y < -14
		if vel.x > 5 or vel.z > 5 or
				vel.x < -5 or vel.z < -5 then
			accelerating[name] = true
		else
			accelerating[name] = false
		end

		if csm.players[name] and csm.players[name].sprinting and
					csm.players[name].sprinting.state == "enabled" then
			if csm.players[name].sprinting.aux1 and not y and not s and
					 stam >= 1 and not stamina.is_poisoned(name) and
					 not stamina.is_cooldowned(name) and
					 sat >= 10 then
				sprinting[name] = true
				physics(player, true)
			elseif s and not csm.players[name].sprinting.aux1 then
				sprinting[name] = false
				physics(player, false)
			elseif s and y or stam <= 0 or sat <= 0 then
				sprinting[name] = false
				physics(player, false)
			end
		else
			local del = minetest.get_us_time() - t[name]
			if not s and (c.aux1 or sprint_toggle[name]) and
					stam >= 1 and sat >= 10 and
					not y then
				if del >= 500000 then
					gid[name] = 0
				end
				if gid[name] == 0 then
					gid[name] = 1
				elseif gid[name] == 1 and del <= 500000 then
					rm(player)
					gid[name] = 0
				end
				t[name] = minetest.get_us_time()
				sprinting[name] = true
				physics(player, true)
			elseif s and ((not sprint_toggle[name] and not c.aux1) or y or stam <= 0 or
					stamina.is_poisoned(name) or stamina.is_cooldowned(name) or sat <= 0) then
				sprinting[name] = false
				physics(player, false)
			elseif sprint_toggle[name] and c.aux1 and del >= 100000 then
				rm(player)
				t[name] = minetest.get_us_time()
			end
		end
		if sprinting[name] and
				(c.up or c.down or c.left or
				c.right or c.jump) then
			if players[name] <= 1 then
				boost(player, pos)
			end
		end
	end
	minetest.after(0, function()
		sprint(player)
	end)
end

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	sprint_toggle[name] = false
	sprinting[name] = false
	players[name] = 0
	accelerating[name] = false
	t[name] = 0
	gid[name] = 0
	player:set_physics_override({
		sneak_glitch = false,
		sneak = true,
		new_move = true,
	})

	hid[name] = player:hud_add({
		hud_elem_type = "image",
		position = {x = 0.96, y = 0.6},
		text = "",
		scale = {x = 1, y = 1},
	})
	 
	sprint(player)
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	sprint_toggle[name] = nil
	sprinting[name] = nil
	players[name] = nil
	accelerating[name] = nil
	t[name] = nil
	gid[name] = nil
	hid[name] = nil
end)

minetest.register_chatcommand("supersprint", {
	func = function(name)
		rm(minetest.get_player_by_name(name))
		return true, "[Server] Toggled sprint mode"
	end,
})
