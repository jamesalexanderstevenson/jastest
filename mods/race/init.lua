-- /mods/race is part of jastest
-- copyright 2020 james alexander stevenson
-- gnu gpl 3+

race = {}
local players = {}

race.start = function(name, pos)
	local player = minetest.get_player_by_name(name)
	if not player then
		return
	end
	if pos then
		player:set_pos(pos)
	end
	players[name].start = minetest.get_us_time()
	hud.message(player, "Start!")
end

race.finish = function(name, pos)
	local player = minetest.get_player_by_name(name)
	if not player then
		return
	end
	if pos then
		if vector.distance(pos, player:get_pos()) > 1 then
			return
		end
	end
	if not players[name].start then
		return
	end
	players[name].finish = minetest.get_us_time()
	local st = players[name].start
	local fn = players[name].finish
	minetest.chat_send_all(name .. " in " .. tostring((fn - st) / 1000000))
	players[name].start = nil
	players[name].finish = nil
end

minetest.register_on_joinplayer(function(player)
	players[player:get_player_name()] = {}
end)

minetest.register_on_leaveplayer(function(player)
	players[player:get_player_name()] = nil
end)
