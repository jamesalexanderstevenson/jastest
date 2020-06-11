-- SuperSprint! (CSM)
-- Copyright 2020 James Stevenson
-- GPL 3+

local sprinting = false
local ack

local function sprint(player)
	player = player or minetest.localplayer
	if player then
		local m = minetest.mod_channel_join(player:get_name())
		if ack == "enabled" then
			local keys = player:get_control()
			if keys.aux1 and not sprinting then
				sprinting = true
				m:send_all("aux1")
			elseif sprinting and not keys.aux1 then
				sprinting = false
				m:send_all("aux0")
			end
		elseif not ack then
			m:send_all("sprint_enable")
		end
	end
	minetest.after(0, function()
		sprint(player)
	end)
end

sprint()

minetest.register_on_modchannel_message(function(channel_name, sender, message)
	if sender == "" and message == "sprint_ack" then
		ack = "enabled"
	end
end)

minetest.register_chatcommand("sprint", {
	params = "<enable|disable>",
	func = function(param)
		local player = minetest.localplayer
		local name = player:get_name()
		local m = minetest.mod_channel_join(name)
		if param == "enable" then
			m:send_all("sprint_enable")
			return true, "[CSM] Sprint enabled"
		elseif param == "disable" then
			ack = "disabled"
			m:send_all("sprint_disable")
			return true, "[CSM] Sprint disabled"
		end
		return false, "[CSM] enable or disable"
	end,
})
