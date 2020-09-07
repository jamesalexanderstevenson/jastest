--[[ Walkie Talkie Minetest Mod (Part of Glitchtest Game)
     Copyright (C) 2018 James A. Stevenson
     GNU GPL 3 ]]

walkie = {}
walkie.players = {}
walkie.meters = {}

local floor = math.floor
local pi = math.pi

local wps = {[1] = "death", [2] = "cmd", [3] = "spawn", [4] = "respawn",}

local hud_elem_compass = {
	hud_elem_type = "image",
	position = {x = 1, y = 1},
	name = "Compass",
	scale = {x = 1, y = 1},
	text = "walkie_empty.png",
	alignment = {x = -1, y = -1},
	offset = {x = -20, y = -156},
}

local hud_elem_coords = {
	hud_elem_type = "text",
	position = {x = 1, y = 1},
	name = "Coordinates",
	scale = {x = 200, y = 20},
	text = "",
	number = 0xFFFFFF,
	direction = 1,
	alignment = {x = -1, y = -1},
	offset = {x = -20, y = -136},
}

local hud_elem_waypoint = {
	hud_elem_type = "waypoint",
	name = "death",
	text = "",
	number = 0xFFFFFF,
	precision = 1,
	alignment = "bottom",
	offset = {x = 0, y = -24},
}

local function updater(player)
	if not player then
		return
	end
	local name = player:get_player_name()
	if not walkie.players[name] then
		return
	end
	local wielding = player:get_wielded_item():get_name() == "walkie:talkie"
	if wielding and not walkie.players[name].active then
		walkie.players[name].active = true
		-- Show compass & coordinates.
		walkie.players[name].pos = player:get_pos()
		walkie.players[name].dir = player:get_look_horizontal()
		local p = vector.round(walkie.players[name].pos)
		local d = floor(walkie.players[name].dir * pi)
		if d >= 1 and d < 4 then
			player:hud_change(walkie.meters[name].compass,
					"text",
					"walkie_compass_nw.png")
		elseif d >= 4 and d < 6 then
			player:hud_change(walkie.meters[name].compass,
					"text",
					"walkie_compass_n.png^[transformR270")
		elseif d >= 6 and d < 9 then
			player:hud_change(walkie.meters[name].compass,
					"text",
					"walkie_compass_nw.png^[transformR270")
		elseif d >= 9 and d < 11 then
			player:hud_change(walkie.meters[name].compass,
					"text",
					"walkie_compass_n.png^[transformR180")
		elseif d >= 11 and d < 14 then
			player:hud_change(walkie.meters[name].compass,
					"text",
					"walkie_compass_nw.png^[transformR180")
		elseif d >= 14 and d < 16 then
			player:hud_change(walkie.meters[name].compass,
					"text",
					"walkie_compass_n.png^[transformR90")
		elseif d >= 16 and d < 19 then
			player:hud_change(walkie.meters[name].compass,
					"text",
					"walkie_compass_nw.png^[transformR90")
		else
			player:hud_change(walkie.meters[name].compass,
					"text",
					"walkie_compass_n.png")
		end
		player:hud_change(walkie.meters[name].coords,
				"text",
				p.x .. ", " .. p.y .. ", " .. p.z)

		-- Add waypoint HUD.
		if not walkie.meters[name].waypoint and
				walkie.players[name].waypoints.pos then
			local pos = walkie.players[name].waypoints.pos
			if pos then
				walkie.players[name].waypoints.ci = 1
				local hud_def = hud_elem_waypoint
				hud_def.world_pos = pos
				local id = player:hud_add(hud_def)
				walkie.meters[name].waypoint = id
				if walkie.players[name].waypoints.death then
					hud.message(player, "Now showing death waypoint")
				else
					hud.message(player, "Now showing waypoints")
				end
				minetest.sound_play("walkie_blip", {object = player}, true)
			end
		end
	elseif walkie.players[name].active and not wielding then
		walkie.players[name].active = false
		-- "Remove" compass and coordinate HUDs.
		player:hud_change(walkie.meters[name].coords,
				"text",
				"")
		player:hud_change(walkie.meters[name].compass,
				"text",
				"walkie_empty.png")
		-- Remove waypoints HUD.
		if walkie.meters[name].waypoint then
			player:hud_remove(walkie.meters[name].waypoint)
			walkie.meters[name].waypoint = nil
		end
	end
	minetest.after(0.12, updater, player)
end

local function cycle_wp(player)
	local name = player:get_player_name()
	local ci = walkie.players[name].waypoints.ci
	if not ci then
		ci = 1
	else
		ci = ci % #wps + 1
	end
	local wp = walkie.players[name].waypoints.pos
	walkie.players[name].waypoints.ci = ci
	local id = wps[ci]
	local pos = walkie.players[name].waypoints[id]
	if not pos then
		pos = minetest.get_player_by_name(id)
		if pos then
			pos = pos:get_pos()
		end
	end
	if pos then
		hud.message(player, "Now showing " .. id .. " waypoint")
		player:hud_change(walkie.meters[name].waypoint, "world_pos", pos)
		player:hud_change(walkie.meters[name].waypoint, "name", id)
	else
		hud.message(player, "No position data for " .. id .. " waypoint")
	end
	minetest.sound_play("walkie_blip", {object = player})
end

setup.init("walkie:talkie", 2)
--setup.init("walkie:talkie", 2, true)

minetest.register_on_joinplayer(function(player)
	if not player then
		return
	end
	local name = player:get_player_name()
	local compass = player:hud_add(hud_elem_compass)
	local coords = player:hud_add(hud_elem_coords)
	walkie.meters[name] = {
		compass = compass,
		coords = coords,
	}
	walkie.players[name] = {waypoints = {}, active = false}
	local waypoints = minetest.deserialize(player:get_meta():get_string("waypoints"))
	local p = minetest.settings:get("static_spawnpoint")
	if p then
		p = minetest.string_to_pos(p)
		if not p then
			p = {x = 0, y = 0, z = 0}
		end
	end
	if waypoints then
		walkie.players[name].waypoints = waypoints
	else
		walkie.players[name].waypoints = {
			pos = p,
			death = nil,
			players = {},
			cmd = nil,
			spawn = p,
			respawn = nil,
		}
	end
	-- Check and set spawn each restart and relog
	walkie.players[name].waypoints.spawn = p
	wps[#wps + 1] = name
	updater(player)
end)

minetest.register_on_leaveplayer(function(player)
	if not player then
		return
	end
	local name = player:get_player_name()
	walkie.players[name] = nil
	walkie.meters[name] = nil
	for i = 1, #wps do
		if wps[i] == name then
			table.remove(wps, i)
			return
		end
	end
end)

minetest.register_on_respawnplayer(function(player)
	if not player then
		return
	end
	local name = player:get_player_name()
	local pos = player:get_pos()
	if not walkie.players[name] then
		return
	end
	walkie.players[name].waypoints.respawn = pos
end)

minetest.register_on_dieplayer(function(player)
	if not player then
		return
	end
	local name = player:get_player_name()
	local pos = player:get_pos()
	if not walkie.players[name] then
		return
	end
	walkie.players[name].waypoints.death = pos
	walkie.players[name].waypoints.pos = pos
	player:hud_change(walkie.meters[name].waypoint, "world_pos", pos)
	player:get_meta():set_string("waypoints",
			minetest.serialize(walkie.players[name].waypoints))
end)

minetest.register_chatcommand("waypoint", {
	description = "Set waypoint position",
	params = "",
	privs = "interact",
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		walkie.players[name].waypoints.cmd = player:get_pos()
		return true, "[Server] Waypoint set"
	end,
})

minetest.register_craftitem("walkie:talkie", {
	description = "Walkie Talkie",
	inventory_image = "walkie_talkie.png",
	stack_max = 1,
	groups = {trade_value = 4,},
	on_use = function(itemstack, user, pointed_thing)
		local under = pointed_thing.under
		if under then
			local oldnode_under = minetest.get_node_or_nil(under)
			if oldnode_under and minetest.registered_nodes[oldnode_under.name].on_punch then
				minetest.registered_nodes[oldnode_under.name].on_punch(under,
						oldnode_under, user, pointed_thing)
				return itemstack, false
			else
				cycle_wp(user)
				return itemstack
			end
		end

		cycle_wp(user)
		return itemstack
	end,
	on_place = function(itemstack, placer, pointed_thing, param2)
		local under = pointed_thing.under
		local oldnode_under = minetest.get_node_or_nil(under)
		if oldnode_under and minetest.registered_nodes[oldnode_under.name].on_rightclick then
			if true then --oldnode_under.name == "xdecor:itemframe" then
				return minetest.item_place(itemstack, placer, pointed_thing, param2)
			--[[
			else
				minetest.registered_nodes[oldnode_under.name].on_rightclick(under,
						oldnode_under, placer, pointed_thing)
				return itemstack, false
			--]]
			end
		end
		terminal.display("item", placer)
		return itemstack, false
	end,
	on_secondary_use = function(itemstack, user, pointed_thing)
		terminal.display("item", user)
	end,
})

minetest.register_craft({
	output = "walkie:talkie",
	recipe = {
		{"default:copper_ingot", "default:steel_ingot", "default:copper_ingot"},
		{"", "default:mese_crystal", ""},
		{"default:copper_ingot", "default:steel_ingot", "default:copper_ingot"},
	}
})

minetest.register_craft({
	output = "default:mese_crystal",
	recipe = {{"walkie:talkie"}},
})
