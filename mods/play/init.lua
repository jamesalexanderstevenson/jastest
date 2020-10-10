-- /mods/play is part of jastest
-- copyright 2020 james alexander stevenson
-- gnu gpl 3+

play = {}

local rand = math.random
local step = 1
local players = {}
local internal_sounds = {}
local nodes = {}
local heartbeat = {ebb = 1, flow = -1}

local function sound_scrape()
	for k, v in pairs(nodes) do
		if v.sounds then
			for _, vv in pairs(v.sounds) do
				local n = vv.name
				if n ~= "" then
					if not internal_sounds[n] then
						internal_sounds[n] = 1
					end
				end
			end
		end
	end
end

play.sounds = {
	"play_c3h",
	"play_c3h",
	"play_c8l",
	"play_c8l",
	"phit",
}

local aplay = function(sound, spt)
	minetest.sound_play(sound, {
		pos = spt.pos,
		pitch = spt.pitch,
		gain = spt.gain,
	}, true)
end

play.play = function(sound, pos)
	-- find intensity values (affecting pitch and gain, mostly,
	-- as well as grains) in player setup
	local pitch = rand() / 3
	-- if pitch and/or gain is low enough
	local gain = rand() / 12
	-- extend duration of step/silence
	local f = function(x)
		return x + rand(-2, 2)
	end
	local ppos = vector.apply(pos, f)
	local spt = {
		pos = ppos,
		pitch = pitch,
		gain = gain,
	}
	aplay(sound, spt)
	local o = minetest.get_objects_inside_radius(ppos, 2)
	for i = 1, #o do
		if o[i]:is_player() then
			local name = o[i]:get_player_name()
			aplay(sound, {to_player = name, pitch = pitch, gain = gain / 2})
		end
	end
end

play.start = function(name)
	players[name].switched_on = true
end

play.stop = function(name)
	players[name].switched_on = false
end

local rplay = function(name, param)
	local player = minetest.get_player_by_name(name)
	local pos = player:get_pos()
	local sound = play.sounds[rand(#play.sounds)]
	local label = "Playing " .. sound
	play.play(sound, pos)
	if param == "internal" then
		for sound2, v in pairs(internal_sounds) do
			if rand() < 0.2 then
				label = label .. " + " .. sound2
				play.play(sound2, pos)
			end
		end
	end
	return true, label
end

local delay = 0

minetest.register_globalstep(function(dtime)
	--print(heartbeat.ebb, heartbeat.flow, delay)
	if heartbeat.ebb >= -1 then
		heartbeat.ebb = heartbeat.ebb - dtime / 2 / #players
		return
	end
	heartbeat.ebb = -1
	if heartbeat.flow <= 1 then
		heartbeat.flow = heartbeat.flow + dtime / 2 / #players
		return
	end
	heartbeat.ebb = -1
	if delay < rand(3, 6) then
		delay = delay + dtime * rand(12)
		return
	end
	delay = 0
	local r
	local rplayers = minetest.get_connected_players()
	for _, v in pairs(rplayers) do
		local name = v:get_player_name()
		if minetest.get_player_by_name(name) then
			if players[name].switched_on then
				_, r = rplay(name, "internal")
			end
		end
	end
end)

minetest.register_chatcommand("play", {
	description = "Play a sound",
	params = "[internal]",
	func = rplay,
})

minetest.register_chatcommand("ambient", {
	params = "on|off",
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		local meta = player:get_meta()
		if param == "off" or param == "false" then
			meta:set_string("ambient", "")
			players[name].switched_on = false
		elseif param == "on" or param == "true" then
			meta:set_string("ambient", "switched_on")
			players[name].switched_on = true
		end
		return true, tostring(players[name].switched_on)
	end,
})

minetest.register_on_mods_loaded(function()
	nodes = minetest.registered_nodes
	--sound_scrape()
end)

minetest.register_on_joinplayer(function(player)
	local switched_on = player:get_meta():get_string("ambient") == "switched_on"
	players[player:get_player_name()] = {switched_on = switched_on}
end)

minetest.register_on_leaveplayer(function(player)
	players[player:get_player_name()] = nil
end)
