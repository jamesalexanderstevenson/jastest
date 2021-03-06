-- /mods/env is part of jastest
-- copyright 2020 james alexander stevenson
-- gnu gpl 3+

local ob = {}
local u = {}

local function uw(player)
	local name = player:get_player_name()
	if not minetest.get_player_by_name(name) then
		return
	end

	local hp = player:get_hp()
	if hp == 0 then
		return
	end

	local b = player:get_breath()
	if b < 100 and not ob[name] then
		ob[name] = b
		u[name] = true
	elseif b < ob[name] then
		ob[name] = b
		u[name] = true
	elseif b == 0 then
		player:set_hp(hp / 2)
		ob[name] = nil
		u[name] = nil
		return
	elseif b > ob[name] then
		if u[name] then
			if b < 99 then
				minetest.after(0, minetest.sound_play,
						"catching_breath", {object = player})
			end
			u[name] = nil
		end
		ob[name] = b
	elseif b == 100 then
		ob[name] = nil
		u[name] = nil
		return
	end
	
	minetest.after(0.1, function()
		uw(player)
	end)
end

function minetest.handle_node_drops(pos, drops, digger)
	-- Add dropped items to object's inventory
	local inv = digger and digger:get_inventory()
	local give_item
	if inv then
		give_item = function(item)
			return item
		end
	else
		give_item = function(item)
			-- itemstring to ItemStack for left:is_empty()
			return ItemStack(item)
		end
	end

	for _, dropped_item in pairs(drops) do
		local left = give_item(dropped_item)
		if type(left) == "string" or not left:is_empty() then
			local p = {
				x = pos.x + math.random() / 2 - 0.25,
				y = pos.y + math.random() / 2 - 0.25,
				z = pos.z + math.random() / 2 - 0.25,
			}
			local o = minetest.add_item(p, left)
			if digger and digger:is_player() then
				local dir = vector.direction(o:get_pos(), digger:get_pos())
				if dir.y > 0 then
					dir.y = dir.y + 3
				else
					dir.y = dir.y + 1.5
				end
				o:add_velocity(dir)
			end
		end
	end
end

local function sur(player)
	local name = player:get_player_name()
	if not minetest.get_player_by_name(name) then
		return
	end
	-- TODO Check for mese boat instead of general attachment.
	if player:get_hp() > 0 and not player_api.player_attached[name] then
		local pos = player:get_pos()
		local p1 = {x = pos.x - 1.25, y = pos.y - 1.25, z = pos.z - 1.25}
		local p2 = {x = pos.x + 1.25, y = pos.y + 1.25, z = pos.z + 1.25}

		local air = minetest.find_nodes_in_area(p1, p2, "air")
		-- Collect nearby items
		for i = 1, #air do
			local oir = minetest.get_objects_inside_radius(air[i], 1.25)
			for ii = 1, #oir do
				local e = oir[ii]:get_luaentity()
				if e and e.itemstring and e.age > 0.67 then
					if player:get_inventory():room_for_item("main", e.itemstring) then
						oir[ii]:move_to(pos, true)
					end
				end
			end
		end

		local m = minetest.find_node_near(pos, 1, {"group:igniter", "group:torch"}, true)

		if m and not minetest.check_player_privs(name, "godmode") then
			local d = vector.distance(m, pos)
			if d <= 0.75 then
				player:set_hp(player:get_hp() - 5, {type = "set_hp", heat = true})
			end
		end


		local hp = player:get_hp()

		if hp <= 25 then
			for i, v in pairs(player:get_inventory():get_list("main")) do
				if i <= 8 and v:get_name() == "bandage:bandage" then
					hud.message(player, "Automatically applying bandage")
					v:take_item(1)
					player:get_inventory():set_stack("main", i, v)
					player:set_hp(hp + 5)
					break
				end
			end
		end

		if player:get_breath() < 100 and not ob[name] then
			uw(player)
		end
	end

	minetest.after(0.9, function()
		sur(player)
	end)
end

minetest.register_on_joinplayer(function(player)
	if not player then
		return
	end
	sur(player)
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	if ob[name] then
		ob[name] = nil
	end
	if u[name] then
		u[name] = nil
	end
end)

minetest.register_on_respawnplayer(function(player)
	local name = player:get_player_name()
	if ob[name] then
		ob[name] = nil
	end
	minetest.after(0.2,
			minetest.sound_play, "catching_breath", {object = player}, true)
end)

minetest.register_on_dieplayer(function(player)
	if not player then
		return
	end
	local pos = player:get_pos()
	if pos then
		minetest.add_particle({
			pos = pos,
			velocity = {x = 0, y = 1, z = 0},
			--acceleration = {x = 0, y = 0.1, z = 0},
			expirationtime = 9,
			size = 7,
			--collisiondetection = true,
			--collision_removal = true,
			--object_collision = false,
			--vertical = false,
			texture = "default_smoke_puff.png",
			--playername = "singleplayer",
			--animation = {Tile Animation defintion},
			glow = 14,
			--node = {name = "ignore", param2 = 0},
			--node_tile = 0,
		})
	end
end)

minetest.register_chatcommand("breath", {
	description = "Show breath meter",
	privs = "interact",
	func = function(name, param)
		if minetest.check_player_privs(name, "server") and param ~= "" then
			local b = tonumber(param)
			if b then
				minetest.get_player_by_name(name):set_breath(b)
				return true, "Set?"
			end
			return false, "Uhoh"
		else
			return true, minetest.get_player_by_name(name):get_breath()
		end
	end,
})

minetest.register_chatcommand("hp", {
	description = "Number of health points",
	privs = "interact",
	func = function(name)
		return true, minetest.get_player_by_name(name):get_hp()
	end,
})
