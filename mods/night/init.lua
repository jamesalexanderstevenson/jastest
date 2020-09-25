-- jastest/mods/night
-- Copyright 2020 James Stevenson
-- GNU GPL 3+

night = {toggle = false}
local players = {}

local store = minetest.get_mod_storage()
local night_toggle = store:get("night_toggle")
night.toggle = night_toggle and night_toggle == "true"
local time = minetest.get_timeofday()
local del = 0

local function check_time_speed()
	local time_speed = minetest.settings:get("time_speed")
	if time_speed ~= 1 then
		minetest.settings:set("time_speed", "1")
	end
end

check_time_speed()

function night.check_time()
	check_time_speed()	
	local t = os.date("*t")
	if night.toggle then
                minetest.set_timeofday(((t.hour + 12) % 24 * 60 + t.min) / 1440)
        else
                minetest.set_timeofday((t.hour * 60 + t.min) / 1440)
        end
	store:set_string("night_toggle", tostring(night.toggle))

	time = minetest.get_timeofday()
	if time <= 0.2 or time >= 0.805 then
		night.night = true
	else
		night.night = false
	end
end

local function envis(name, param)
	local player = minetest.get_player_by_name(name)
	local envi = {
		physical = player:get_properties().physical,
		zoom_fov = player:get_properties().zoom_fov,
		fov = csm.players[name].fov.value,
		name = player:get_player_name(),
		fov = player:get_fov(),
		sky = player:get_sky(),
		sky_color = player:get_sky_color(),
		sun = player:get_sun(),
		moon = player:get_moon(),
		stars = player:get_stars(),
		clouds = player:get_clouds(),
		dnr = player:get_day_night_ratio() or "nil",
		nametag = player:get_nametag_attributes(),
	}
	local str = ""
	for k, v in pairs(envi) do
		--print(type(v))
		if type(v) == "string" then
			str = str .. k .. ": " .. v .. "\n"
		elseif type(v) == "number" then
			str = str .. k .. ": " .. v .. "\n"
		elseif type(v) == "boolean" then
			str = str .. k .. ": " .. tostring(v) .. "\n"
		else
			str = str .. k .. "\n"
		end
		--print(k, dump(v))
	end
	--print(dump(player:get_properties()))
	local debugger = minetest.check_player_privs(name, "debug")
	local amt
	local params = param:split(" ")
	if params[1] and params[1] == "dnr" then
		if not params[2] then
			return true, envi.dnr
		end
		amt = tonumber(params[2])
		if params[2] == "nil" then
			player:override_day_night_ratio(nil)
			return true, "Ratio unset"
		elseif not amt or amt < 0 or amt > 1 then
			return false, "[Server] Ratio is a number between zero and one"
		end
		if debugger then
			player:override_day_night_ratio(amt)
			return true, "[Server] Ratio set, use \"nil\" to unset"
		else
			return false, "[Server] You lack the debug priv"
		end
	elseif params[1] and params[1] == "nametag" then
		if not params[2] then
			return true, envi.nametag.text
		elseif params[2] == "nil" or params[2] == "hide" then
			player:set_nametag_attributes({text = "\n"})
			return true, "[Server] Nametag unset"
		elseif params[2] == "away" then
			player:set_nametag_attributes({text = name .. " [away]"})
			return true, "[Server] Nametag set as away"
		elseif debugger then
			player:set_nametag_attributes({text = params[2]})
			return true, "[Server] Nametag set"
		else
			player:set_nametag_attributes({text = name})
		end
	elseif params[1] and params[1] == "physical" then
		if not params[2] then
			return true, tostring(envi.physical)
		elseif debugger then
			if params[2] ~= "true" then
				player:set_properties({physical = false})
				return true, "physical: false"
			end
			player:set_properties({physical = true})
			return true, "physical: true"
		end
	elseif params[1] and params[1] == "zoom_fov" then
		if not params[2] then
			return true, envi.zoom_fov
		else
			local zfov = tonumber(params[2])
			if not zfov or zfov < 23 or zfov > 123 then
				return false, "[Server] zoom_fov out of range"
			end
			player:set_properties({zoom_fov = zfov})
			return true, params[2]
		end
	end
	return true, str
end

night.menu = function(name)
	local _, zf = envis(name, "zoom_fov")
	local fs = "size[8,8.5]" ..
			forms.x ..
			forms.q ..
			forms.title("Environmental Settings") ..
			"label[0,1;Nametag]" ..
			"button_exit[0,1.5;2,1;tag_away;Away]" ..
			"button_exit[2,1.5;2,1;tag_hide;Hide]" ..
			"button_exit[4,1.5;2,1;tag_reset;Reset]" ..
			"field[0.34,3.34;2,1;zfov;Zoom FOV;" .. tostring(zf) .. "]" ..
			"button_exit[2,3;1,1;zf_ok;OK]" ..
			"label[0,4.15;Cozy]" ..
			"button_exit[0,4.65;2,1;sit;Sit]" ..
			"button_exit[2,4.65;2,1;lay;Lay]" ..
			"button_exit[4,4.65;2,1;sleep;Sleep]"
	minetest.show_formspec(name, "night:menu", fs)
end

local function poll(name)
	local player = minetest.get_player_by_name(name)
	if player then
		local y = player:get_pos()
		if y then
			y = y.y
		end
		if y <= -25 and not players[name].underground then
			player:set_sky("#111111FF", "plain")
			players[name].underground = true
		elseif players[name].underground and y > -25 then
			player:set_sky("#FFFFFFFF", "regular")
			players[name].underground = false
		end
	end
	minetest.after(3.5, function()
		poll(name)
	end)
end

minetest.register_globalstep(function(dtime)
	if del <= 30 then
		del = del + dtime
		return
	end
	night.check_time()
	del = 0
end)

minetest.register_chatcommand("env", {
	description = "Change some settings",
	params = "",
	privs = "interact",
	func = envis,
})

minetest.register_on_joinplayer(function(player)
	player:set_properties({zoom_fov = 34})
	player:hud_set_flags({
		minimap = true,
		minimap_radar = true,
	})
	local name = player:get_player_name()
	players[name] = {underground = false}
	poll(name)
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "night:menu" then
		return
	end
	local name = player:get_player_name()
	if fields.zf_ok and tonumber(fields.zfov) then
		envis(name, "zoom_fov " .. fields.zfov)
	elseif fields.tag_reset then
		envis(name, "nametag reset")
	elseif fields.tag_hide then
		envis(name, "nametag hide")
	elseif fields.tag_away then
		envis(name, "nametag away")
	elseif fields.sit then
		cozy.set(player:get_player_name(), "sit")
	elseif fields.lay then
		cozy.set(player:get_player_name(), "lay")
	elseif fields.sleep then
		beds.on_rightclick(player:get_pos(), player)
	end
end)

minetest.register_on_leaveplayer(function(player)
	players[player:get_player_name()] = nil
end)

minetest.register_chatcommand("night", {
	description = "Display night/day status",
	params = "[time]",
	privs = "shout",
	func = function(name, params)
		params = tonumber(params)
		if params and minetest.check_player_privs(name, "server") then
			minetest.set_timeofday(params)
			hud.message("Time set")
		end
		return true, "Time:" .. minetest.get_timeofday() ..
				" / Night: " .. tostring(night.night) ..
				" / Toggle: " .. tostring(night.toggle)
	end,
})

minetest.register_chatcommand("sleep", {
	description = "Fall asleep and set your respawn",
	params = "[respawn]",
	privs = "interact",
	func = function(name, param)
		local player = minetest.get_player_by_name(name) 
		if not player then
			return false, "Must be in-game!"
		end
		beds.on_rightclick(player:get_pos(), player)
	end,
})

minetest.after(1, night.check_time)
