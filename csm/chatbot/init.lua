minetest.register_on_receiving_chat_message(function(message)
	local msg_id = message:find(">")
	if not msg_id then
		return
	end
	local msg = message:sub(msg_id + 2)
	if msg:find("hi chatbot") == 1 or msg:find("hello chatbot") == 1 then
		minetest.send_chat_message("hi")
	elseif msg:find("hey chatbot") == 1 then
		minetest.send_chat_message("hey is for horses")
	end
	minetest.sound_play("walkie_blip")
	minetest.log("action", "ES1CHAT: " .. message)
end)
