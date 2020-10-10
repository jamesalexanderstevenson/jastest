-- /mods/ambience is part of jastest
-- copyright 2020 james alexander stevenson
-- gnu gpl 3+

ambience = {}

local playing = {}
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

ambience.sounds = {
	"ambience_c3h",
	"ambience_c8l",
	"ambience_c8l",
	"ambience_c8l",
	"ambience_phit",
	"ambience_phit",
}

local aplay = function(sound, spt)
	minetest.sound_play(sound, {
		pos = spt.pos,
		pitch = spt.pitch,
		gain = spt.gain,
	}, true)
end

ambience.play = function(sound, pos)
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
	if sound:find("phit") then
		gain = gain / 5 
	end
	aplay(sound, spt)
	local o = minetest.get_objects_inside_radius(ppos, 2)
	for i = 1, #o do
		if o[i]:is_player() then
			local name = o[i]:get_player_name()
			aplay(sound, {to_player = name, pitch = pitch, gain = gain / 2})
		end
	end
end

ambience.start = function(name)
	players[name].switched_on = true
end

ambience.stop = function(name)
	players[name].switched_on = false
end

local rplay = function(name, param)
	local player = minetest.get_player_by_name(name)
	local pos = player:get_pos()
	local sound = ambience.sounds[rand(#ambience.sounds)]
	local label = "Playing " .. sound
	ambience.play(sound, pos)
	if param == "internal" then
		for sound2, v in pairs(internal_sounds) do
			if rand() < 0.2 then
				label = label .. " + " .. sound2
				ambience.play(sound2, pos)
			end
		end
	end
	return true, label
end

ambience.ss = function(name, param)
	if param == "start" and not playing[name] then
		playing[name] = true
	elseif playing[name] and param == "stop" then
		playing[name] = false
	end
	local player = minetest.get_player_by_name(name)
	if not playing[name] or not player then
		return false, "[Server] Sound " .. param
	end

	local pos = player:get_pos()
	local p1 = {x = pos.x + 4, y = pos.y + 4, z = pos.z + 4}
	local p2 = {x = pos.x - 4, y = pos.y, z = pos.z - 4}
	local _, ty = minetest.find_nodes_in_area(p1, p2, "air")
	local ma = ty.air and ty.air / 100

	local tv = minetest.add_entity(pos, "ambience:tv")
	if tv then
		if sound and sound ~= "" then
			sound = sound
		else
			sound = "ambience_wind"
		end

		-- Gain
		local gain = ma / 34
		if gain > 1 then
			gain = 1
		end

		-- Pitch
		local pitch = (rand() * rand()) / ma
		if rand() >= 0.67 or pitch < 0.5 then
			pitch = pitch + 1
		elseif pitch > 1.15 then
			pitch = rand()
		end

		local sss = {
			name = sound,
		}
		local spt = {
			gain = gain,
			pitch = pitch,
			object = tv,
		}

		tv:add_velocity({x = rand(-0.1, 0.1), y = 0.1, z = rand(-0.1, 0.1)})

		if tv:get_luaentity() then
			local del
			if gain >= 0.1 then
				del = ((rand() + rand() + rand()) * pitch / (ma * 0.94)) * 3.14
				if del > 2.5 then
					del = 2
				end
				minetest.sound_play(sss, spt, true)
			else
				del = 2.34
			end
			minetest.after(del, function()
				ambience.ss(name, sound)
			end)
		end
	end
	return true, "[Server] Sound " .. param
end

minetest.register_abm({
	label = "Lava sounds",
	nodenames = "default:lava_source",
	neighbors = "default:obsidian",
	interval = 6.0,
	chance = 3,
	catch_up = false,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local o = minetest.get_objects_inside_radius(pos, 3)
		for i = 1, #o do
			local p = o[i]
			if p:is_player() then
				local name = p:get_player_name()
				local n = music.players[name]
				if n < 3 then
					music.players[name] = n + 1
					pos.y = pos.y - 5
					minetest.sound_play("ambience_lava", {
						pos = pos,
						gain = rand(),
						pitch = rand(),
					}, true)
					minetest.after(rand(5, 10), function()
						if music.players[name] then
							music.players[name] = music.players[name] - 1
						end
					end)
					break
				end
			end
		end
	end,
})

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

minetest.register_on_mods_loaded(function()
	nodes = minetest.registered_nodes
	--sound_scrape()
end)

minetest.register_entity("ambience:tv", {
	initial_properties = {
		visual = "sprite",
		textures = {"doors_blank.png"},
		pointable = false,
	},
	on_step = function(self, dtime)
		local t = self.timer or 0
		if t > 5 then
			self.object:remove()
		end
		self.timer = t + dtime
	end,
})

minetest.register_chatcommand("ambience", {
	description = "Toggle ambience sound effects",
	params = "on|off",
	privs = "interact",
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		local meta = player:get_meta()
		if param == "off" or param == "false" or param == "stop" then
			meta:set_string("ambient", "")
			players[name].switched_on = false
			ambience.ss(name, "stop")
		elseif param == "on" or param == "true" or param == "start" then
			meta:set_string("ambient", "switched_on")
			players[name].switched_on = true
			ambience.ss(name, "start")
		end
		return true, tostring(players[name].switched_on)
	end,
})

minetest.register_on_joinplayer(function(player)
	local switched_on = player:get_meta():get_string("ambient") == "switched_on"
	local name = player:get_player_name()
	players[name] = {switched_on = switched_on}
	if switched_on then
		ambience.ss(name, "start")
	end
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	if playing[name] then
		playing[name] = nil
	end
	players[name] = nil
end)
