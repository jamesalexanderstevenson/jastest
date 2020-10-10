-- /mods/csm is part of jastest
-- copyright 2020 james alexander stevenson
-- gnu gpl 3+

csm = {}
csm.players = {}

local m = minetest.mod_channel_join("main")

csm.ack = function(name, message)
	local mm = csm.players[name].channel
	mm:send_all(message)
	minetest.after(1, function()
		if message == "sprint_enable" then
			if not csm.players[name].sprinting.ack then
				if forms then
					forms.dialog(name, "Awaiting an acknowledgement on your named mod channel.\n\n\nfailed",
							true, nil, nil, true, true)
				else
					minetest.chat_send_player(name, "No ack, WIP")
				end
			end
		end
	end)
end

minetest.register_on_modchannel_message(function(channel_name, sender, message)
	--print("S channel: " .. channel_name)
	--print("S sender: " .. sender)
	--print("S message: " .. message)
	if not csm.players[sender] then
		return
	end
	if channel_name == sender then
		if message == "sprint_enable" then
			csm.players[sender].sprinting.state = "enabled"
			csm.players[sender].channel:send_all("sprint_ack")
		elseif message == "sprint_disable" then
			csm.players[sender].sprinting.state = "disabled"
			csm.players[sender].channel:send_all("sprint_ack")
		end
		if message == "aux1" then
			csm.players[sender].sprinting.aux1 = true
		elseif message == "aux0" then
			csm.players[sender].sprinting.aux1 = false
		end

		if message == "jump_enable" then
			csm.players[sender].jumping.state = "enabled"
			csm.players[sender].channel:send_all("jump_ack")
		elseif message == "jump_disable" then
			csm.players[sender].jumping.state = "disabled"
			csm.players[sender].channel:send_all("jump_ack")
		end
		if message == "jump" then
			csm.players[sender].jumping.jump = true
			jump.jump(sender)
		end

		if message == "zoom_enable" then
			csm.players[sender].channel:send_all("zoom_ack")
		elseif message == "zoom_disable" then
			csm.players[sender].channel:send_all("zoom_ack")
		end
		if message == "zfov_enable" then
			csm.players[sender].zoom_fov.state = "enabled"
			csm.players[sender].channel:send_all("zoom_ack")
		elseif message:sub(1, 4) == "zfov" then
			local zfov = tonumber(message:sub(6))
			if zfov then
				csm.players[sender].zoom_fov.value = zfov
				minetest.get_player_by_name(sender):set_properties({zoom_fov = zfov})
			end
		end
		if message == "fov_enable" then
			csm.players[sender].channel:send_all("zoom_ack")
		elseif message == "fov_disable" then
			csm.players[sender].channel:send_all("zoom_ack")
		elseif message:sub(1, 3) == "fov" then
			local fov = tonumber(message:sub(5))
			if fov then
				fov = math.floor(fov - 8)
				print("fov", fov)
				csm.players[sender].fov.value = fov
			end
		end

		if message == "minimap_enable" then
			csm.players[sender].channel:send_all("minimap_ack")
		elseif message == "minimap_disable" then
			csm.players[sender].channel:send_all("minimap_ack")
		end
	end
end)

minetest.register_chatcommand("csm", {
	description = "Manage CSM",
	privs = "",
	params = "",
	func = function(name, param)
		local privs = minetest.get_player_privs(name)
		local level = 0
		if privs.server then
			level = 10
		end
		if level and level > 9 then
			--print("writeable: " .. tostring(m:is_writeable()))
			m:send_all(param)
			return true, "Sent: " .. param
		end
		return false, "Failed: " .. param
	end,
})

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	local ch = minetest.mod_channel_join(name)
	local fov = player:get_fov()
	csm.players[name] = {
		channel = ch,
		sprinting = {state = "disabled", aux1 = false, ack = false},
		jumping = {state = "disabled", jump = false, ack = false},
		zooming = {state = "disabled", zoom = false, ack = false},
		zoom_fov = {state = "disabled", value = 34, ack = false},
		fov = {state = "disabled", value = fov, ack = false},
	}
end)
