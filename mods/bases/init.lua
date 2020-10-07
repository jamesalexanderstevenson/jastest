-- /mods/bases is part of jastest
-- copyright 2020 james alexander stevenson
-- gnu gpl 3+

bases = {}

local colors = {}
local ms = minetest.get_mod_storage()
local save = ms:get("colors")
if save then
	save = minetest.deserialize(m)
end
if save then
	colors = save
end

save = function()
	ms:set_string("colors", minetest.serialize(bases))
end

local ini = function(pos, y_offset)
	if not warpstones.ppp then--(pos, true) then
		minetest.chat_send_player(player:get_player_name(),
				"Must be a base!")
		return
	end
	local p1, p2 = s_protect.get_area_bounds(pos)
	p1.y = p1.y + 5
	p2.y = p2.y - 5
	local vm = minetest.get_voxel_manip()
	local e1, e2 = vm:read_from_map(p1, p2)
	local area = VoxelArea:new({MinEdge = e1, MaxEdge = e2})
	local data = vm:get_data()

	local c_air = minetest.CONTENT_AIR
	local c_obsidian = minetest.get_content_id("obsidian:obsidian")

	for z = p1.z, p2.z do
		for y = p1.y, p2.y do
			for x = p1.x, p2.x do
				local vi = area:index(x, y, z)
				if y == pos.y + y_offset - 16 then
					data[vi] = c_obsidian
				else
					data[vi] = c_air
				end
			end
		end
	end

	vm:set_data(data)
	vm:update_liquids()
	vm:write_to_map()
end

local place_base = function(name, pos, y, color)
	if not pos then
		return
	end
	pos = minetest.string_to_pos(pos)
	if not pos then
		return
	end
	if not warpstones.ppp then --(pos) then
		return
	end
	local player = minetest.get_player_by_name(name)
	if not player then
		return
	end
	y = y or 0
	if y < -75 or y > 75 then
		y = 0
	end
	local center = s_protect.get_center(pos)
	center.y = center.y + y
	local nn = "bases:base"
	if color then
		if colors[color] then
			return
		end
		nn = nn .. "_" .. color
		colors[color] = center
		save()
	end
	ini(center, y)
	minetest.set_node(center, {name = nn})
end

bases.set = function(name, args)
	local c = args[1]
	if not c then
		return
	end
	local a = {}
	for i = 2, #args do
		local b = args[i]
		if not b then
			break
		end
		a[#a + 1] = b
	end
	if c == "set" then
		local p = a[1]
		p = p:gsub("\\", "")
		local y = tonumber(a[2])
		local color = a[3]
		place_base(name, p, y, color)
	end
end

bases.initiate = function(player, pos, y, color)
	local name = player:get_player_name()
	local fs = "size[8,8]label[0,0;Attempting to restart the base!]"
	minetest.show_formspec(name, "bases:initiate", fs)
	bases.set(name, {"set", pos, y, color})
	teams.set_team(name, color)
end

local selected = {}

local boom = function(pos)
	tnt.boom(pos, {ignore_protection = true, explode_center = true, radius = 4})
end

local remover = function(pos)
	local n = minetest.get_node(pos)
	if n and n.name then
		n = n.name:sub(12, -1)
	end
	if colors[n] then
		colors[n] = nil
	end
	minetest.chat_send_all(n .. " destroyed!!")
	minetest.remove_node(pos)
	boom(pos)
	save()
end

local damage = function(pos, res, amt)
	local n = minetest.get_node(pos)
	if not (n and n.name:match("bases:")) then
		return
	end
	amt = amt or 0
	local meta = minetest.get_meta(pos)
	local st = meta:get("integrity")
	if not st then
		st = 5000
	end
	st = st - amt
	if st <= 0 then
		remover(pos)
	else
		meta:set_int("integrity", st)
		meta:set_string("infotext", "Integrity is at " .. st .. "!")
	end
	if res then
		return st
	end
end

local function activate(pos, player)
	local fs = "size[8,4]" ..
		"button[0,0;2,1;set;Set]" ..
		"button[2,0;2,1;show;Show]" ..
	""
	minetest.show_formspec(player:get_player_name(), "bases:base", fs)
end

local on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
	if node.name == "bases:base" then
		selected[clicker:get_player_name()] = pos
		activate(pos, clicker)
	end
end

local on_punch = function(pos, node, puncher, pointed_thing)
	if node.name == "bases:base" then
		return
	end
	boom(pos)
end

local on_timer = function(pos, elapsed)
	if elapsed > 667 then
		remover(pos)
	end
	local wt = minetest.get_node_timer(pos)
	wt:set(0.1, elapsed + 0.1)
end

local on_blast = function(pos)
	damage(pos, nil, 334)
	return
end

local after_place_node = function(pos, placer, itemstack, pointed_thing)
	if not minetest.check_player_privs(placer, "gamemaster") then
		minetest.remove_node(pos)
	end
end

local check_air = function(pos)
	local n = minetest.get_node(pos)
	return n and (n.name == "air" or
			n.name == "mobs:spawner" or
			n.name == "bases:base_red" or
			n.name == "bases:base_blue" or
			n.name == "bases:base_green")
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "bases:base" then
		local name = player:get_player_name()
		local pos = selected[name]
		if fields.show then
			hud.message(name, "no")
			--minetest.chat_send_player(name, tostring(warpstones.ppp(pos, true)))
		elseif fields.set then
			local a
			if not colors.red then
				colors.red = pos
				a = "red"
			elseif not colors.blue then
				colors.blue = pos
				a = "blue"
			elseif not colors.green then
				colors.green = pos
				a = "green"
			end
			if not a then
				return false, "Bases full."
			end
			minetest.swap_node(pos, {name = "bases:base_" .. a})
			--[[
			if not warpstones.ppp(pos, true) then
				warpstones.base(pos)
			end
			--]]
			save()
		end
	end
end)

minetest.register_node("bases:base", {
	description = "Base",
	tiles = {"xdecor_stone_rune.png^(bases_base.png^[opacity:99)"},
	groups = {not_in_creative_inventory = 1},
	on_rightclick = on_rightclick,
	can_dig = function() end,
	drop = "",
	after_place_node = after_place_node,
})

minetest.register_node("bases:base_green", {
	description = "Base Active (Green, You Hacker You!)",
	tiles = {"xdecor_stone_rune.png^(bases_base_green.png^[opacity:99)"},
	paramtype = "light",
	light_source = minetest.LIGHT_MAX,
	drop = "",
	groups = {not_in_creative_inventory = 1},
	on_rightclick = on_rightclick,
	on_punch = on_punch,
	can_dig = function() end,
	on_timer = on_timer,
	on_blast = on_blast,
	after_place_node = after_place_node,
})

minetest.register_node("bases:base_red", {
	description = "Base Active (Red, You Hacker You!)",
	tiles = {"xdecor_stone_rune.png^(bases_base_red.png^[opacity:99)"},
	paramtype = "light",
	light_source = minetest.LIGHT_MAX,
	drop = "",
	groups = {not_in_creative_inventory = 1},
	on_rightclick = on_rightclick,
	on_punch = on_punch,
	can_dig = function() end,
	on_timer = on_timer,
	on_blast = on_blast,
	after_place_node = after_place_node,
})

minetest.register_node("bases:base_blue", {
	description = "Base Active (Blue, You Hacker You!)",
	tiles = {"xdecor_stone_rune.png^(bases_base_blue.png^[opacity:99)"},
	paramtype = "light",
	light_source = minetest.LIGHT_MAX,
	drop = "",
	groups = {not_in_creative_inventory = 1},
	on_rightclick = on_rightclick,
	on_punch = on_punch,
	can_dig = function() end,
	on_timer = on_timer,
	on_blast = on_blast,
	after_place_node = after_place_node,
})

minetest.register_abm({
	nodenames = {"bases:base_green", "bases:base_red", "bases:base_blue"},
	interval = 2,
	chance = 1,
	catch_up = false,
	action = function(pos, node)
		local t = minetest.get_node_timer(pos)
		if not t:is_started() then
			t:start(0.1)
		end
		for xi = -3, 3 do
			for yi = -3, 3 do
				for zi = -3, 3 do
					if not (xi == 0 and yi == 0 and zi == 0) then
						local np = {x = pos.x + xi, y = pos.y + yi, z = pos.z + zi}
						if not check_air(np) then
							boom(np)
						end
					end
				end
			end
		end
	end,
})

minetest.register_on_leaveplayer(function(player)
	selected[player:get_player_name()] = nil
end)
