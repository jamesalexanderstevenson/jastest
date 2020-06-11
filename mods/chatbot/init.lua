-- jastest/mods/chatbot is part of jastest
-- jastest is Copyright 2020 by James Stevenson
-- jastest is released under the GNU GPL v3+

chatbot = {}
local new_pos

-- name of chatbot client player
local chatbox = "chatbot"

local function say(msg)
	local pre = "<chatbot> "
	minetest.chat_send_all(pre .. msg)
end

chatbot.runner = function(player)
	local name = player:get_player_name()
	if name ~= chatbox then
		return
	end
	local hp
	local is_player = player:is_player()
	if is_player then
		hp = player:get_hp()
	end
	local meta = player:get_meta()
	local t = meta:get("chatbot:damager")
	t = tonumber(t) or minetest.get_us_time()
	if hp and hp < 100 then
		--player:set_hp(100)
		local d = (minetest.get_us_time() - t) / 1000000
		if d < 3 then
			if not new_pos then
				new_pos = {}
				for k, v in pairs(warpstones.warps) do
					for kk, vv in pairs(v) do
						table.insert(new_pos, vv)
					end
				end
			end
			player:set_pos(new_pos[math.random(#new_pos)])
			say("I'm outta here!")
		end
		meta:set_string("chatbot:damager",
				tostring(minetest.get_us_time()))
	end
	minetest.after(1, chatbot.runner, player)
end

minetest.register_privilege("chatbot", {
	description = "Can manage the chatbot",
	give_to_admin = "false",
	give_to_singleplayer = "false",
})

minetest.register_chatcommand("chatbot", {
	privs = "chatbot",
	func = function(name, param)
	end,
})

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	if name == chatbox then
		player:set_properties({nametag = "\n"})
		chatbot.runner(player)
	end
end)
