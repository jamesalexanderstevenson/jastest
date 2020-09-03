-- JASTEST CSM
-- Copyright 2020 James Stevenson
-- GNU GPL 3+

local sprinting = false
local sprinting_ack
local automap = false
local minimap_ack

local level = 2
local map = minetest.ui.minimap
local radar = false

local function sprint(player)
	player = player or minetest.localplayer
	if player then
		local m = minetest.mod_channel_join(player:get_name())
		if sprinting_ack == "enabled" then
			local keys = player:get_control()
			if keys.aux1 and not sprinting then
				sprinting = true
				m:send_all("aux1")
			elseif sprinting and not keys.aux1 then
				sprinting = false
				m:send_all("aux0")
			end
		elseif not sprinting_ack then
			m:send_all("sprint_enable")
		end
	end
	minetest.after(0, function()
		sprint(player)
	end)
end

local function minimap(player)
	player = player or minetest.localplayer
	if player then
		local m = minetest.mod_channel_join(player:get_name())
		if minimap_ack == "enabled" then
		elseif not minimap_ack then
			m:send_all("minimap_enable")
		end
		if player:get_pos().y < -25 and not radar then
			radar = true
			level = level + 3
			--[[
			if map then
				map:show()
				map:set_mode(level)
			end
			--]]
		elseif radar and player:get_pos().y >= -25 then
			radar = false
			level = level - 3
			--[[
			if map then
				map:show()
				map:set_mode(level)
			end
			--]]
		end
		local walkie = player:get_wielded_item():get_name() == "walkie:talkie"
		if minimap_ack and walkie and map and not automap then
			map:show()
			map:set_mode(level)
			automap = true
		elseif not walkie and map and automap then
			map:hide()
			automap = false
		else
			map = minetest.ui.minimap
		end
	end
	minetest.after(0, function()
		minimap(player)
	end)
end

minetest.register_on_modchannel_message(function(channel_name, sender, message)
	if sender == "" then
		if message == "minimap_ack" then
			minimap_ack = "enabled"
		elseif message == "sprint_ack" then
			sprinting_ack = "enabled"
		end
	end
end)

minetest.register_chatcommand("map", {
	params = "<level>",
	description = "Set minimap zoom level",
	func = function(param)
		param = tonumber(param)
		if param then
			if param < 1 or param > 3 then
				return false, "[Client] A level between 1 and 3"
			end
			level = param
			return true, "Level set to " .. param
		end
	end,
})

minetest.register_chatcommand("sprint", {
	description = "Enable or disable client-side sprint polling",
	params = "<enable|disable>",
	func = function(param)
		local player = minetest.localplayer
		local name = player:get_name()
		local m = minetest.mod_channel_join(name)
		if param == "enable" then
			m:send_all("sprint_enable")
			return true, "[CSM] Sprint enabled"
		elseif param == "disable" then
			sprinting_ack = "disabled"
			m:send_all("sprint_disable")
			return true, "[CSM] Sprint disabled"
		end
		return false, "[CSM] enable or disable"
	end,
})

sprint()
minimap()
