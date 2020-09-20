-- /mods/ambience is part of jastest
-- copyright 2020 james alexander stevenson
-- gnu gpl 3+

ambience = {}
local playing = {}
local r = math.random

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
		local pitch = (r() * r()) / ma
		if r() >= 0.67 or pitch < 0.5 then
			pitch = pitch + 1
		elseif pitch > 1.15 then
			pitch = r()
		end

		local sss = {
			name = sound,
		}
		local spt = {
			gain = gain,
			pitch = pitch,
			object = tv,
		}

		tv:add_velocity({x = r(-0.1, 0.1), y = 0.1, z = r(-0.1, 0.1)})

		if tv:get_luaentity() then
			local del
			if gain >= 0.1 then
				del = ((r() + r() + r()) * pitch / (ma * 0.94)) * 3.14
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

minetest.register_chatcommand("sound", {
	description = "Play a sound",
	privs = "interact",
	params = "[start|stop]",
	func = ambience.ss,
})

minetest.register_on_joinplayer(function(player)
	if player:get_meta():get_string("ambient") == "switched_on" then
		ambience.ss(player:get_player_name(), "start")
	end
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	if playing[name] then
		playing[name] = nil
	end
end)
