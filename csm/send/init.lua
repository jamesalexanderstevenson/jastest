local m = minetest.mod_channel_join("main")

minetest.register_on_modchannel_message(function(channel_name, sender, message)
	if sender == "" then
		sender = "Server"
	end
	print(sender .. " on " .. channel_name .. " sends: " .. message)
end)

minetest.register_chatcommand("send", {
	func = function(param)
		print("writeable: " .. tostring(m:is_writeable()))
		m:send_all(param)
		return true, "Sent: " .. param
	end,
})
