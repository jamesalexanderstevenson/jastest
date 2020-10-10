-- /mods/classes is part of jastest
-- copyright 2020 james alexander stevenson
-- gnu gpl 3+

classes = {}
classes.roles = {
	miner = {name = "miner", min_level = 1},
	scout = {name = "scout", min_level = 3},
	mage = {name = "mage", min_level = 5},
	node = {name = "node", min_level = 7},
}

local polling = {}

-- Mage fireball
local function particles(pos, texture)
	return {
		pos = pos,
		velocity = {x = 0, y = 0.1, z = 0},
		acceleration = {x = 0, y = 0.01, z = 0},
		expirationtime = math.random(),
		size = 0.34 + math.random() + math.random(),
		collisiondetection = false,
		collision_removal = false,
		object_collision = false,
		verticle = false,
		texture = texture,
		--playername = "singleplayer",
		--animation = {Tile Animation definition},
		glow = 14,
	}
end

local function boom(pos)
	local def = {
		radius = 1,
		damage_radius = 3,
		explode_center = true,
	}
	return tnt.boom(pos, def)
end

local function charge(player, amount)
	if not player then
		return
	end
	local pos = player:get_pos()
	if not pos then
		return
	end
	local meta = player:get_meta()
	if not meta then
		return minetest.after(0.1, charge, player, 0)
	end
	if meta:get_string("classes:class") ~= "mage" then
		return
	end
	local wielded_item = player:get_wielded_item()
	if wielded_item:get_name() ~= "" then
		return minetest.after(0.23, charge, player, 0)
	end
	pos.y = pos.y + 1.25
	local dir = player:get_look_dir()
	if amount >= 9 then
		pos = vector.add(pos, dir)
		local arrow = minetest.add_entity(pos,
				"classes:mage_fireball",
				player:get_player_name())
		arrow:set_acceleration(dir)
		arrow:set_velocity(vector.multiply(dir, 12))
		player:set_hp(player:get_hp() * 0.8)
		return minetest.after(0.1, charge, player, -9)
	elseif amount < 0 then
		return minetest.after(0.1, charge, player, amount + 0.25)
	end
	local ctrl = player:get_player_control()
	if not ctrl.LMB then
		return minetest.after(0.1, charge, player, 0)
	else
		if amount > 0 then
			pos = vector.add(pos, dir)
			minetest.add_particle(particles(pos,
					"default_item_smoke.png"))
			minetest.add_particle(particles(pos,
					"tnt_smoke.png"))
			minetest.add_particle(particles(pos,
					"default_mese_crystal.png"))
		end
		return minetest.after(0.1, charge, player, amount + 1)
	end
end

-- Change class
local function change_class(player, class)
	local name = player:get_player_name()
	local inv = player:get_inventory()
	if not class then
		local meta = player:get_meta()
		class = meta:get("classes:class") or "miner"
	end
	if class == "miner" then
		inv:set_size("hand", 1)
		inv:set_stack("hand", 1, "classes:miner")
	elseif class == "mage" then
		inv:set_size("hand", 1)
		inv:set_stack("hand", 1, "classes:mage")
		charge(player, 0)
	end
end

local function lvlup(player)
	local meta = player:get_meta()
	meta:set_int("classes:xp", 0)
	local level = meta:get_int("classes:level")
	meta:set_int("classes:level", level + 1)
	hud.message(player, "Level up! You're now at level " ..
			tostring(level + 1))
end

classes.addxp = function(player, xp, reset, class)
	if not player then
		return
	end
	local meta = player:get_meta()
	if reset then
		meta:set_int("classes:xp", 0)
		meta:set_int("classes:level", 1)
		class = class or "miner"
		meta:set_string("classes:class", class)
		change_class(player, class)
		hud.message(player, "Level, XP, and class reset")
		return
	end
	if player:get_hp() == 0 then
		return
	end
	local ixp = meta:get_int("classes:xp")
	ixp = ixp + (xp or 1)
	if ixp > 99 then
		lvlup(player)
		return
	end
	meta:set_int("classes:xp", ixp)
	hud.message(player, "+" .. tostring(xp) .. " XP")
	return
end

local function poll(name)
	local player = minetest.get_player_by_name(name)
	if polling[name] and player then
		classes.addxp(player, math.random(3))
		minetest.after(59, function()
			poll(name)
		end)
	end
end

local function class_command(name, param)
	local player = minetest.get_player_by_name(name)
	if not player then
		return false, "[Server] Must be in-game"
	end
	local params = param:split(" ")
	local meta = player:get_meta()
	local level = meta:get_int("classes:level")
	if level < 1 then
		level = 1
	end
	local class = meta:get("classes:class")
	if not class then
		class = "miner"
	end
	if params[1] then
		local arg1 = params[1]
		local arg2 = params[2]
		local arg3 = params[3]
		local arg4 = params[4]
		if arg1 == "change" then
			if not classes.roles[arg2] then
				return false, "[Server] Invalid class"
			end
			if level < classes.roles[arg2].min_level then
				return false, "[Server] Level too low"
			end
			if class == arg2 then
				return false, "[Server] Class is already " ..
						arg2
			end
			classes.addxp(player, nil, true, arg2)
			change_class(player, arg2)
			return true, "[Server] Class changed to " .. arg2
		elseif arg1 == "level" then
			return true, "[Server] Your level is " ..
					tostring(level)
		elseif arg1 == "list" then
			return true, "[Server] miner, scout, mage, node"
		elseif arg1 == "xp" then
			if arg2 == "add" and tonumber(arg3) and
					minetest.check_player_privs(name,
							"debug") then
				if arg4 then
					local pp = minetest.get_player_by_name(arg4)
					if pp then
						classes.addxp(pp, tonumber(arg3))
					else
						return false, "[Server] No player"
					end
				else
					classes.addxp(player, tonumber(arg3))
				end
				return true, "[Server] Added XP"
			end
			return true, "[Server] Your XP is " ..
					tostring(meta:get_int("classes:xp"))
		end
	end
	meta:set_int("classes:level", level)
	meta:set_string("classes:class", class)
	return true, "[Server] Your current class is " .. class
end

-- Wieldhand Default Miner
minetest.register_item("classes:miner", {
	type = "none",
	wield_image = "wieldhand.png",
	wield_scale = {x=1,y=1,z=2.5},
	groups = {not_in_creative_inventory = 1},
	tool_capabilities = {
		full_punch_interval = 0.9,
		max_drop_level = 0,
		groupcaps = {
			crumbly = {
				times = {
					[2] = 5,
					[3] = 2.5,
				},
				uses = 0,
				maxlevel = 1,
			},
			snappy = {
				times = {
					[3] = 0.40,
				},
				uses = 0,
				maxlevel = 1,
			},
			cracky = {
				times = {
					[1] = 15,
					[2] = 12.5,
					[3] = 10,
				},
				uses = 0,
				maxlevel = 2,
			},
			oddly_breakable_by_hand = {
				times = {
					[1] = 2,
					[2] = 1,
					[3] = 0.5,
				},
				uses = 0,
			},
		},
		damage_groups = {fleshy = 1},
	}
})

-- Wieldhand Mage w/ Fireball
minetest.register_tool("classes:mage", {
	type = "none",
	wield_image = "blank.png",
	groups = {not_in_creative_inventory = 1},
	tool_capabilities = {
		full_punch_interval = 2,
		max_drop_level = 1,
		groupcaps = {
			crumbly = {},
			snappy = {},
			oddly_breakable_by_hand = {},
		},
		damage_groups = {fleshy = 0},
	},
})

minetest.register_entity("classes:mage_fireball", {
	description = "Fireball",
	visual = "sprite",
	textures = {"mobs_fireball.png"},
	glow = 14,
	on_activate = function(self, staticdata, dtime_s)
		self.owner = staticdata or "singleplayer"
	end,
	on_step = function(self, dtime)
		local step = self.step or 0
		self.step = step + 1
		local pos = self.object:get_pos()
		if step > 36 then
			self.object:remove()
			return boom(pos)
		end
		local objects = minetest.get_objects_inside_radius(pos, 0.85)
		for i = 1, #objects do
			if objects[i]:is_player() then
				if objects[i]:get_player_name() ~= self.owner then
					self.object:remove()
					return boom(pos)
				end
			elseif objects[i]:get_luaentity().horny ~= nil then
				-- It's a mob!
				self.object:remove()
				return boom(pos)
			end
		end
		local node = minetest.get_node_or_nil(pos)
		if not node then
			return
		end
		local node_name = node.name
		if not node_name then
			return
		end
		local node_def = minetest.registered_nodes[node_name]
		if not node_def then
			return
		end
		local walkable = node_def.walkable
		if not walkable then
			return
		end
		self.object:remove()
		return boom(pos)
	end,
})

minetest.register_on_joinplayer(function(player)
	minetest.after(1, function(player)
		if player then
			local name = player:get_player_name()
			change_class(player)
			polling[name] = true
			poll(name)
		end
	end, player)
end)

minetest.register_on_dieplayer(function(player)
	classes.addxp(player, nil, true, "miner")
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	if polling[name] then
		polling[name] = nil
	end
end)

minetest.register_chatcommand("class", {
	description = "Class, level, and XP status",
	privs = "interact",
	params = "[change | level | xp]",
	func = class_command,
})
