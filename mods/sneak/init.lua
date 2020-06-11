local sneaking = {}

local function poll(player)
	local name = player:get_player_name()
	if sneaking[name] == nil then
		return
	end
	if minetest.get_player_by_name(name) then
		local c = player:get_player_control()
		if c.sneak and not sneaking[name] then
			sneaking[name] = true
			player:set_properties({makes_footstep_sound = false})
		elseif sneaking[name] and not c.sneak then
			player:set_properties({makes_footstep_sound = true})
			sneaking[name] = false
		end
	end
	minetest.after(0.1, function()
		poll(player)
	end)
end

minetest.register_on_joinplayer(function(player)
	if not player then
		return
	end
	sneaking[player:get_player_name()] = false
	minetest.after(0.1, function()
		poll(player)
	end)
end)

minetest.register_on_leaveplayer(function(player)
	if not player then
		return
	end
	sneaking[player:get_player_name()] = nil
end)
