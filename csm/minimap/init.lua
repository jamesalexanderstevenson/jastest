-- MiniMap! (CSM) Part of JASTEST
-- Copyright 2020 James Stevenson
-- GPL 3+

local ack
local level = 2
local map = minetest.ui.minimap
local radar = false
local automap = false
local tick = false

local function minimap(player)
	player = player or minetest.localplayer
	if player and map then
		if ack and ack == "enabled" then
			if player:get_pos().y < -25 and not radar then
				tick = true
				radar = true
				level = level + 3
			elseif radar and player:get_pos().y >= -25 then
				tick = true
				radar = false
				level = level - 3
			end

			local walkie = player:get_wielded_item():get_name() == "walkie:talkie"
			if walkie and (not automap or tick) then
				if tick then
					tick = false
				end
				map:show()
				map:set_mode(level)
				automap = true
			elseif automap and not walkie then
				map:hide()
				automap = false
			end
			minetest.after(0, function()
				minimap(player)
			end)
		else
			minetest.mod_channel_join(player:get_name()):send_all("minimap_enable")
			minetest.after(1, function()
				minimap(player)
			end)
		end
	else
		map = minetest.ui.minimap
		minetest.after(0.5, function()
			minimap(player)
		end)
	end
end

minetest.register_on_modchannel_message(function(channel_name, sender, message)
	if sender == "" and message == "minimap_ack" then
		ack = "enabled"
	end
end)

minetest.register_chatcommand("map", {
	params = "[level <n>]",
	description = "Set minimap zoom level",
	func = function(param)
		if param then
			local set = param:split(" ")
			local arg1 = set[1]
			local arg2 = set[2]
			if arg1 == "level" then
				if not arg2 then
					return true, "[Client] Level is " .. tostring(level)
				elseif tonumber(arg2) then
					arg2 = tonumber(arg2)
					if arg2 < 1 or arg2 > 3 then
						return false, "[Client] A level between 1 and 3"
					else
						level = arg2
						return true, "[Client] Set to " .. tostring(level)
					end
				else
					return false, "[Client] A level between 1 and 3"
				end
			else
				return false, "[Client] Invalid usage"
			end
		else
			return false, "[Client] Invalid usage"
		end
	end
})

minimap()
