--  2  2 = northeast
-- -2  2 = northwest
--  2 -2 = southeast
-- -2 -2 = southwest

funblock = {}
funblock.players = {}

local cooldown = {}

local function editor(pos, player)
	local name = player:get_player_name()
	local meta = minetest.get_meta(pos)
	local stuff = meta:get_string("stuff")
	local fs = "size[8,8.5]" ..
		"textarea[0.3,0;8,8.5;stuff;;" .. stuff .. "]" ..
		"button[0,8;2,1;save;Save]"
	funblock.players[name] = pos
	minetest.show_formspec(name, "funblock:edit", fs)
end

local runit = function(player, pos, aoc, aocw)
	if not player then
		return
	end
	local name = player:get_player_name()
	local meta = minetest.get_meta(pos)
	local stuff = meta:get_string("stuff")
	if stuff ~= "" then
		local split_stuff = stuff:split("\n")
		for i = 1, #split_stuff do
			local ss = split_stuff[i]
			if ss:find("teleport") == 1 then
				local p = minetest.string_to_pos(ss:sub(10))
				if p then
					player:set_pos(p)
				elseif ss:match("random") then
					local x, y, z
					local ns = math.random()
					local msg = "A: North-West"
					if ns > 0.75 then
						msg = "D: North-East"
						x = 20000 
						z = 20000
						y = 33
					elseif ns > 0.5 then
						msg = "C: South-West"
						x = -20000
						z = -20000
						y = 3
					elseif ns > 0.25 then
						msg = "B: South-East"
						x = 20000
						z = -20000
						y = 7
					else
						x = -20000
						z = 20000
						y = 19
					end
					local pp = {x = x, y = y, z = z}
					player:set_pos(pp)
					hud.message(player, msg)
				end
			elseif ss:find("say") == 1 then
				hud.message(player, ss:sub(5))
			elseif ss:find("spawn") == 1 then
				local sss = ss:split(" ")
				if sss[3] then
					local pap = minetest.string_to_pos(sss[3])
					if pap then
						pos = pap
					end
				else
					pos = {x = pos.x, y = pos.y + 2, z = pos.z}
				end
				local objects = minetest.get_objects_inside_radius(pos, 3)
				local count = 0
				for _, v in pairs(objects) do
					if mobs.spawning_mobs[v:get_entity_name()] then
						count = count + 1
					end
				end
				if count < 1 then
					local nnn = sss[2]
					if mobs.spawning_mobs[nnn] then
						minetest.add_entity(pos, nnn)
					else 
						for mm, _ in pairs(mobs.spawning_mobs) do
							if mm:match(nnn) then
								minetest.add_entity(pos, mm)
								break
							end
						end
					end
				end
			elseif ss:find("detect") == 1 then
				local sss = ss:split(" ")
				if sss[2] == "player" then
					if sss[3] == "true" then
						meta:set_string("detect", "player")
					elseif sss[3] == "false" then
						meta:set_string("detect", "")
					end
				end
			elseif ss:find("race") == 1 then
				local sss = ss:split(" ")
				if sss[2] == "start" then
					local pps = sss[3]
					if pps then
						pps = minetest.string_to_pos(pps)
					end
					race.start(name, pps)
				elseif sss[2] == "finish" then
					race.finish(name)
				end
			elseif ss:find("boost") == 1 then
				local sss = ss:split(" ")
				local sn = tonumber(sss[2])
				if sn then
					player:add_player_velocity({x = 0, y = sn, z = 0})
				end
			end
		end
	end
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "funblock:edit" then
		if fields.save and fields.stuff then
			local pos = funblock.players[player:get_player_name()]
			local meta = minetest.get_meta(pos)
			meta:set_string("stuff", fields.stuff)
		end
		return
	end
end)

minetest.register_node("funblock:block", {
	description = "Function Block",
	tiles = {
		"function_block.png",
	},
	groups = {cracky = 3, oddly_breakable_by_hand = 3},
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		local meta = minetest.get_meta(pos)
		local name = clicker:get_player_name()
		local owner = meta:get_string("owner")
		if minetest.check_player_privs(name, "protection_bypass") or
				name == owner then
			editor(pos, clicker)
		end
		return itemstack
	end,
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_int("switch", 1)
		meta:set_string("owner", "")
	end,
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local meta = minetest.get_meta(pos)
		local name = placer:get_player_name()
		--print(meta:get_int("switch"))
		meta:set_string("owner", name)
	end,
	_runit = runit,
})

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	funblock.players[name] = nil
	cooldown[name] = nil
end)

minetest.register_abm({
	label = "Funblock",
	nodenames = {"funblock:block"},
	interval = 1,
	chance = 1,
	catch_up = false,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local meta = minetest.get_meta(pos)
		-- check for uninitialized
		if meta:get_string("detect") == "player" then
			for _, object in pairs(minetest.get_objects_inside_radius(pos, 3)) do
				if object:is_player() then
					local player = object
					local name = object:get_player_name()
					if not minetest.get_player_by_name(name) then
						return
					end
					if cooldown[name] then
						local del = (minetest.get_us_time() - cooldown[name]) / 1000000
						if del < 10 then
							return
						end
					end
					runit(player, pos, active_object_count, active_object_count_wider)
					cooldown[name] = minetest.get_us_time()
				end
			end
		end
	end,
})
