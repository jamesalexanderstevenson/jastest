local path = minetest.get_modpath(minetest.get_current_modname())
dofile(path .. "/api.lua")

mobs.spawning = true
mobs.mobs = {}
mobs.players = {}
local rand = math.random
local mp = {}
local mpi = {}
local threshold1 = 15
local threshold1_dist = 20 
local threshold2 = 10
local threshold2_dist = 10
local mob_types = {}
mobs.loho = function(player, pos)
	local lo = {x = pos.x + rand(-16, 16), y = pos.y + rand(-16, 16), z = pos.z + rand(-16, 16)}
	local lon = minetest.get_node_or_nil(lo)
	if lon and lon.name == "air" then
		local lpo = {x = lo.x, y = lo.y - 1, z = lo.z}
		local n = minetest.get_node_or_nil(lpo)
		if not n then
			mobs.loho(nil, lo)
			return
		end
		local nodef = minetest.registered_nodes[n.name]
		local normal
		if nodef then
			normal = nodef.drawtype and (nodef.drawtype == "normal" or
					nodef.drawtype == "plantlike")
			if not normal then
				mobs.loho(nil, lo)
				return
			end
		end
		if n and n.name ~= "air" then
			local ma = {}
			for k, _ in pairs(mobs.spawning_mobs) do
				ma[#ma + 1] = k
			end
			local maap = ma[rand(#ma)]
			if not maap then
				return
			end
			local animal = mob_types[maap] == "animal"
			local hostile = mob_types[maap] == "monster"
			local npc = mob_types[maap] == "npc"

			local flower = n.name:find("flower")
			local dirt = n.name:find("dirt")
			local grass = n.name:find("grass")
			local sand = n.name:find("sand")
			local snow = n.name:find("snow")
			local stone = n.name:find("stone")
			local obsidian = n.name:find("obsidian")
			local lava = n.name:find("lava")

			local l1, l2, out_of_sight
			if player then
				l1 = player:get_look_dir()
				l2 = vector.direction(pos, lpo)
				out_of_sight = vector.distance(l1, l2) > 0.89
			else
				local s = minetest.get_objects_inside_radius(pos, 16)
				local look = false
				for k, v in pairs(s) do
					if v:is_player() then
						l1 = v:get_look_dir()
						l2 = vector.direction(pos, lpo)
						out_of_sight = vector.distance(l1, l2) > 0.89
						if not out_of_sight then
							look = true
						end
					end
				end
				if look then
					out_of_sight = false
				else
					out_of_sight = true
				end
			end
			if out_of_sight then
				local o = minetest.get_objects_inside_radius(pos, 16)
				if (animal or npc) and (dirt or snow or grass) and
						lpo.y >= 0 and not night.night then
					if maap:find("sheep") then
						maap = "mobs:sheep_white"
					end
					if snow and rand() >= 0.5 then
						maap = "mobs:penguin"
					end
					if flower then
						maap = "mobs:bee"
					end
					local c = 0
					for k, v in pairs(o) do
						local loa = v:get_luaentity()
						if loa and loa.health then
							c = c + 1
						end
					end
					local ob = minetest.get_objects_inside_radius(lo, 16)
					for k, v in pairs(ob) do
						local loa = v:get_luaentity()
						if loa and loa.health then
							c = c + 1
						end
					end
					if c < threshold1 and 
							vector.distance(pos, lo) > threshold1_dist then
						minetest.add_entity(lo, maap)
						--[[
						print("top", "night:", night.night, lpo.y, os.date(),
								maap, "prot:", minetest.is_protected(lpo, ""))
						--]]
					end
				elseif (hostile or npc) and
						(stone or obsidian or grass or dirt or sand) and
						(lpo.y < -16 or night.night) then
					if maap == "mobs:lava_flan" and not lava then
						maap = "mobs:oerkki"
					elseif lava then
						maap = "mobs:lava_flan"
					elseif sand and rand() >= 0.5 then
						maap = "mobs:sand_monster"
					elseif dirt and rand() >= 0.5 then
						maap = "mobs:dirt_monster"
					end
					if minetest.is_protected(lpo, "") or rand() >= 0.9 then
						maap = "mobs:rat"
						if rand() < 0.1 then
							maap = "mobs:npc"
						elseif rand() >= 0.95 then
							maap = "mobs:trader"
						end
					end
					local c = 0
					for k, v in pairs(o) do
						local loa = v:get_luaentity()
						if loa and loa.health then
							c = c + 1
						end
					end
					local ob = minetest.get_objects_inside_radius(lo, 16)
					for k, v in pairs(ob) do
						local loa = v:get_luaentity()
						if loa and loa.health then
							c = c + 1
						end
					end
					if c < threshold2 and
							vector.distance(pos, lo) > threshold2_dist then
						minetest.add_entity(lo, maap)
						--[[
						print("bottom", "night:", night.night, lpo.y, os.date(),
								maap, "prot:", minetest.is_protected(lpo, ""))
						--]]
					end
				end
			end
		end
	end
end

minetest.register_abm({
	label = "Mob spawning",
	nodenames = "air",
	neighbors = {
		"group:cracky",
		"group:crumbly",
		"group:snappy",
		"group:choppy",
		"group:oddly_breakable_by_hand",
		"group:dig_immediate"
	},
	interval = 10,
	chance = 5000,
	catch_up = false,
	action = function(pos, node, active_object_count, active_object_count_wider)
		if active_object_count < 1 and active_object_count_wider < 16 then
			mobs.loho(nil, pos)
		end
	end,
})

-- Rideable Mobs
dofile(path .. "/mount.lua")

-- Mob Items
dofile(path .. "/crafts.lua")

function mobs.show_gui(name)
	local fs = "size[8,8.5]" .. forms.x
	local now = minetest.get_us_time()
	local player = minetest.get_player_by_name(name)
	if mobs.players[name] then
		local diff = now - mobs.players[name].epoch
		local cd = math.ceil(diff / 1000000)
		local object = mobs.players[name].object
		if object then
			local ent = object:get_luaentity()
			if ent and ent.name == mobs.players[name].name then
				ent.master = name
				ent.owner = name
				ent.following = player
				ent.state = "following"
				ent.tamed = true
				ent.protected = true
				ent.remove_ok = false
				mobs.players[name].ent = ent
			elseif not ent then
				ent = mobs.players[name].ent
			end
			if not ent then
				return
			end
			local hp = ent.health
			local leash = tostring(mobs.players[name].leash)
			fs = fs .. "textarea[0.34,1;8,8.5;;Yours is " .. mobs.players[name].name ..
					"\nIt was created " .. tostring(math.ceil(diff / 1000000)) .. " seconds ago" ..
					"\n" .. tostring(ent.health) .. "hp\nState: " .. ent.state ..
					"\nProtected: " .. tostring(ent.protected) .. ";]" ..
					"button[0,0;2,1;reload;Refresh]" ..
					"button[2,0;2,1;bring;Bring]" ..
					"checkbox[4,0;leash;Leash;" .. leash .. "]"
		else
			fs = fs .. "textarea[0.34,1;8,8.5;;Attempting to reset" ..
					"\n" .. tostring(300 - cd) .. " seconds remain;]" ..
					"button[0,0;2,1;reload;Refresh]"
			mobs.players[name] = nil
			player:get_meta():set_string("mobs:purse", "")
		end
	else
		local mobs_str = ""
		for k, _ in pairs(mobs.spawning_mobs) do
			local d = minetest.registered_entities[k].description
			mpi[#mpi + 1] = k
			mobs_str = mobs_str .. "," .. d
		end
		fs = fs .. "button[0,0;2,1;mobs:spawn_mob;Spawn]" ..
				"table[0,1;7.67,7.5;mobs:select;" .. mobs_str:sub(2) .. ";1]"
	end
	minetest.show_formspec(name, "mobs:show_gui", fs)
end

local function poll(player)
	local name = player:get_player_name()
	if not mp[name] then
		return
	end
	local obj = player:get_meta():get_string("mobs:purse")
	if obj ~= "" and not mobs.players[name] then
		mobs.players[name] = minetest.deserialize(obj)
	end

	local pos = vector.new(player:get_pos())
	mobs.loho(player, pos)

	minetest.after(0.12 * #minetest.get_connected_players(), function()
		poll(player)
	end)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "mobs:show_gui" then
		return
	end
	local name = player:get_player_name()
	if fields["mobs:spawn_mob"] then
		local r = mp[name]
		if r then
			--local priv = minetest.check_player_privs(name, "gamemaster")
			if not mobs.players[name] then
				local p = player:get_pos()
				local o = minetest.get_objects_inside_radius(p, 3)
				local c = 1
				for i = 1, #o do
					local e = o[i]:get_luaentity()
					if e and e.health then
						c = c + 1
					end
				end
				if c <= 2 then
					local en = mpi[r]
					if not en then
						en = mpi[1]
					end
					local tt = minetest.add_entity(p, en)
					mobs.players[name] = {
						name = en,
						epoch = minetest.get_us_time(),
						leash = false,
					}
					player:get_meta():set_string("mobs:purse", minetest.serialize(mobs.players[name]))
					mobs.players[name].object = tt
					mobs.show_gui(name)
				else
					hud.message(player, "Too many mobs in the vicinity")
				end
			else
				local msg = "Attempting to spawn your mob!"
				forms.dialog(name, msg)
				minetest.after(0.34, forms.dialog, name, msg .. "\n\n\nfailed", true, "mobs:spawn_failed",
						"Mobs?", true, true)
			end
		end
	elseif fields["mobs:select"] then
		local r = minetest.explode_table_event(fields["mobs:select"]).row
		if r then
			mp[name] = r
		end
	elseif fields.bring then
		local p = mobs.players[name].object
		if p then
			local pb = p:get_pos()
			if pb then
				p:move_to(player:get_pos())
				if vector.distance(player:get_pos(), p:get_pos()) > 24 then
					p:set_pos(player:get_pos())
				end
			else
			end
		end
	elseif fields.leash then
		mobs.players[name].leash = not mobs.players[name].leash
		mobs.show_gui(name)
	elseif fields.reload then
		mobs.show_gui(name)
	end
end)

minetest.register_chatcommand("mobs", {
	description = "Show the mobs menu",
	privs = "shout",
	params = "",
	func = function(name, param)
		if param == "spawning" and
				minetest.check_player_privs(name, "server") then
			mobs.spawning = not mobs.spawning
			return true, tostring(mobs.spawning)
		elseif param == "spawning_mobs" then
			print(dump(mobs.spawning_mobs))
			for k, v in pairs(mobs.spawning_mobs) do
				print(minetest.registered_entities[k].description)
			end
			return true, ""
		end
		mobs.show_gui(name)
	end,
})

mobs.spawnwave = {
}

minetest.register_on_joinplayer(function(player)
	mp[player:get_player_name()] = "1"
	poll(player)
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	mp[name] = nil
	mobs.players[name] = nil
end)

dofile(path .. "/bee.lua")
dofile(path .. "/bunny.lua")
dofile(path .. "/chicken.lua")
dofile(path .. "/cow.lua")
dofile(path .. "/dirt_monster.lua")
dofile(path .. "/dungeon_master.lua")
dofile(path .. "/igor.lua")
dofile(path .. "/kitten.lua")
dofile(path .. "/lava_flan.lua")
dofile(path .. "/mese_monster.lua")
dofile(path .. "/npc.lua")
dofile(path .. "/oerkki.lua")
dofile(path .. "/panda.lua")
dofile(path .. "/penguin.lua")
dofile(path .. "/rat.lua")
dofile(path .. "/sand_monster.lua")
dofile(path .. "/sheep.lua")
dofile(path .. "/spider.lua")
dofile(path .. "/stone_monster.lua")
dofile(path .. "/trader.lua")
dofile(path .. "/tree_monster.lua")
dofile(path .. "/warthog.lua")
dofile(path .. "/zombies.lua")

for k, v in pairs(mobs.spawning_mobs) do
	mob_types[k] = minetest.registered_entities[k].type
end
