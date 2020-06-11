jail = {}
jail.players = {}

local function jailing(name, time_jail)
	if not jail.players[name] then
		jail.players[name] = minetest.get_us_time()
	end
	local time_countdown = (minetest.get_us_time() - jail.players[name]) / 1000000
	if time_countdown * 60 >= time_jail then
		jail.players[name] = nil
		local player = minetest.get_player_by_name(name)
		if player then
			player:set_pos({x = 64, y = 65, z = 16})
		end
		return
	end
	minetest.after(60, function()
		jailing(name, time_jail)
	end)
end

minetest.register_privilege("warden", {
	description = "Can jail players",
	give_to_admin = false,
	give_to_singleplayer = false,
})

minetest.register_chatcommand("jail", {
	description = "Jail a player for n minutes, where n is greater than 0 and less than 16.",
	params = "[name [time]]",
	privs = "warden",
	func = function(name, param)
		param = param:split(" ")
		local player = minetest.get_player_by_name(name)
		if not param[1] then
			player:set_pos({x = 19995, y = -20003, z = 19997})
			return true, "Going to jail"
		end
		local p = minetest.get_player_by_name(param[1])
		if p then
			local del
			if not param[2] then
				del = 1
			else
				del = tonumber(param[2]) or 1
			end
			if del < 1 or del > 15 then
				return true, "Too small, or too large an amount of time"
			end
			jailing(name, del)
			p:set_pos({x = 19995, y = -20003, z = 19997})
			return true, "Sent player to jail"
		else
			return true, "No such player"
		end
	end,
})

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	if jail.players[name] then
		player:set_pos({x = 19995, y = -20003, z = 19997})
	end
end)
