-- /mods/staves is part of jastest
-- copyright 2020 james alexander stevenson
-- gnu gpl 3+

local cooldown = {}
local boom = {radius = 3, explode_center = true}

local warp = function(name, pos)
	local player = minetest.get_player_by_name(name)
	if not player then
		return
	end
	local e = pos
	e.y = e.y + 1
	local ne = minetest.get_node(e)
	local nn = minetest.get_node(pos)
	local def
	if nn and nn.name then
		def = minetest.registered_nodes[nn.name]
	end
	if def then
		def = def.walkable
	end
	if ne and ne.name ~= "air" then
		def = nil
	end
	if def then
		def = vector.floor(e)
		def.y = def.y + 1
		player:set_pos(def)
	else
		local p1 = {x = pos.x + 1, y = pos.y + 1, z = pos.z + 1}
		local p2 = {x = pos.x - 1, y = pos.y - 1, z = pos.z - 1}
		local a = minetest.find_nodes_in_area_under_air(p1, p2, "group:reliable")
		if a and a[1] then
			pos = a[math.random(#a)]
			pos.y = pos.y + 1
		else
			a = minetest.find_node_near(pos, 1, {"air"}, true)
			if a then
				pos = a
			end
		end
		player:set_pos(pos)
	end
end

minetest.register_entity("staves:warp", {
	description = "Warp",
	visual = "sprite",
	textures = {"mobs_fireball.png^[brighten^[colorize:blue:59"},
	glow = 14,
	on_activate = function(self, staticdata, dtime_s)
		self.owner = staticdata or "singleplayer"
	end,
	on_step = function(self, dtime)
		local step = self.step or 0
		self.step = step + 1
		local pos = self.object:get_pos()
		if step > 56 then
			warp(self.owner, pos)
			self.object:remove()
			return
		end
		local objects = minetest.get_objects_inside_radius(pos, 0.85)
		for i = 1, #objects do
			if objects[i]:is_player() then
				if objects[i]:get_player_name() ~= self.owner then
					warp(self.owner, self.object:get_pos())
					self.object:remove()
					return
				end
			elseif objects[i]:get_luaentity().horny ~= nil then
				warp(self.owner, self.object:get_pos())
				self.object:remove()
				return
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
		warp(self.owner, self.object:get_pos())
		self.object:remove()
	end,

})

minetest.register_tool("staves:teleportation", {
	description = "Staff of Teleportation",
	inventory_image = "staves_teleportation.png",
	wield_scale = {x = 1, y = 1.2, z = 1},
	on_use = function(itemstack, user, pointed_thing)
		local name = user:get_player_name()
		if not cooldown[name] then
			cooldown[name] = true
			minetest.after(1, function()
				if cooldown[name] then
					cooldown[name] = nil
				end
			end)
			local pos = user:get_pos()
			pos.y = pos.y + 1.25
			local dir = user:get_look_dir()
			pos = vector.add(pos, dir)
			local arrow = minetest.add_entity(pos, "staves:warp", name)
			arrow:set_acceleration(dir)
			arrow:set_velocity(vector.multiply(dir, 9))
			itemstack:add_wear(3800)
		end
		return itemstack
	end,
})

minetest.register_craft({
	output = "staves:teleportation",
	recipe = {
		{"default:diamond"},
		{"default:obsidian_shard"},
		{"group:stick"},
	},
})

minetest.register_entity("staves:fireball", {
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
			return tnt.boom(pos, boom)
		end
		local objects = minetest.get_objects_inside_radius(pos, 0.85)
		for i = 1, #objects do
			if objects[i]:is_player() then
				if objects[i]:get_player_name() ~= self.owner then
					self.object:remove()
					return tnt.boom(pos, boom)
				end
			elseif objects[i]:get_luaentity().horny ~= nil then
				-- It's a mob!
				self.object:remove()
				return tnt.boom(pos, boom)
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
		return tnt.boom(pos, boom)
	end,
})

minetest.register_tool("staves:destruction", {
	description = "Staff of Destruction",
	inventory_image = "staves_destruction.png",
	wield_scale = {x = 1, y = 1.2, z = 1},
	on_use = function(itemstack, user, pointed_thing)
		local name = user:get_player_name()
		if not cooldown[name] then
			cooldown[name] = true
			minetest.after(1, function()
				if cooldown[name] then
					cooldown[name] = nil
				end
			end)
			local pos = user:get_pos()
			pos.y = pos.y + 1.25
			local dir = user:get_look_dir()
			pos = vector.add(pos, dir)
			local arrow = minetest.add_entity(pos, "staves:fireball", name)
			arrow:set_acceleration(dir)
			arrow:set_velocity(vector.multiply(dir, 9))
			itemstack:add_wear(7600)
		end
		return itemstack
	end,
})

minetest.register_craft({
	output = "staves:destruction",
	recipe = {
		{"default:mese_crystal"},
		{"default:obsidian_shard"},
		{"group:stick"},
	},
})

minetest.register_on_leaveplayer(function(player)
	cooldown[player:get_player_name()] = nil
end)
