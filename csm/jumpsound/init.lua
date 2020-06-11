-- Jump! (CSM)
-- Copyright 2020 James Stevenson
-- GPL 3+

local del = minetest.get_us_time()

local touching = false
local in_water = false
local jumping = false

local ack

local floor = math.floor
local insert = table.insert

local a = minetest.after
local sp = minetest.sound_play

local function poll(player)
	player = player or minetest.localplayer
	if player then
		local j = player:get_control().jump
		touching = player:is_touching_ground()
		in_water = player:is_in_liquid()

		local m = minetest.mod_channel_join(player:get_name())
		if not ack then
			m:send_all("jump_enable")
		end
		if j and not touching and not jumping and
				not in_water and
				minetest.get_us_time() - del > 334000 then
			jumping = true
			del = minetest.get_us_time()
			if ack == "disabled" then
				sp({name = "jump_jump", gain = 0.9})
			else
				m:send_all("jump")
			end
		elseif touching then
			jumping = false
		end
	end

	a(0, function()
		poll(player)
	end)
end

minetest.register_on_modchannel_message(function(channel_name, sender, message)
	if sender == "" and message == "jump_ack" then
		ack = "enabled"
	end
end)

poll()
