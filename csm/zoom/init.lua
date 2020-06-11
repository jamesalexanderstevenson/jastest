-- Zoom! (CSM)
-- Copyright 2020 James Stevenson
-- GPL 3+

local zooming = false
local zfov = 34
local fov
local ack

local function zoom(player)
	player = player or minetest.localplayer
	if player then
		local m = minetest.mod_channel_join(player:get_name())
		if ack == "enabled" then
			local keys = player:get_control()
			if keys.zoom and not zooming then
				zooming = true
				m:send_all("zoom1")
			elseif zooming and not keys.zoom then
				zooming = false
				m:send_all("zoom0")
			end
		elseif not ack then
			m:send_all("zoom_enable")
		end
		if ack and not fov then
			local camera = minetest.camera
			fov = camera:get_fov().actual
			m:send_all("fov " .. tostring(fov))
		end
	end
	minetest.after(0, function()
		zoom(player)
	end)
end

minetest.register_on_modchannel_message(function(channel_name, sender, message)
	if sender == "" and message == "zoom_ack" then
		ack = "enabled"
	end
end)

minetest.register_chatcommand("zoom", {
	description = "TODO: Incorporate zoom/fov structures",
	params = "<enable|disable>",
	func = function(param)
		local player = minetest.localplayer
		local name = player:get_name()
		local m = minetest.mod_channel_join(name)
		if param == "enable" then
			m:send_all("zoom_enable")
			return true, "[CSM] Zoom enabled"
		elseif param == "disable" then
			ack = "disabled"
			m:send_all("zoom_disable")
			return true, "[CSM] Zoom disabled"
		else
			local v = tonumber(param)
			if v then
				m:send_all("zfov " .. v)
				return true, "[CSM] zoom_fov set to " .. param
			end
			return false, "[CSM] zoom_fov: bad value"
		end
		return false, "[CSM] enable, disable, or value for zoom_fov"
	end,
})

zoom()
