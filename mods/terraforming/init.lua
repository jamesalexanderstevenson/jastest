-- /mods/terraforming is part of jastest
-- copyright 2020 james alexander stevenson
-- gnu gpl 3+

minetest.register_abm({
	label = "Melt frozen liquids",
	nodenames = {"group:melty"},
	neighbors = {"group:igniter", "group:lava"},
	interval = 9,
	chance = 80,
	catch_up = false,
	action = function(pos, node)
		minetest.set_node(pos, {name = "default:water_source"})
	end,
})

minetest.register_abm({
	label = "Transform cobble",
	nodenames = {"default:cobble"},
	neighbors = {"group:water", "group:lava", "air"},
	interval = 18,
	chance = 80,
	catch_up = false,
	action = function(pos, node)
		local law = minetest.find_node_near(pos, 2, "group:water")
		local la = minetest.find_node_near(pos, 1, "group:lava")
		if la then
			minetest.set_node(pos, {name = "default:stone"})
		elseif law then
			minetest.set_node(pos, {name = "default:mossycobble"})
		end
	end
})

minetest.register_abm({
	label = "Mossycobble to dirt",
	nodenames = {"default:mossycobble"},
	neighbors = {
		"default:grass_4",
		"default:grass_5"
	},
	interval = 58,
	chance = 16,
	catch_up = false,
	action = function(pos, node)
		local grass = minetest.get_node({x = pos.x, y = pos.y + 1, z = pos.z})
		if grass and grass.name:match("grass") then
			minetest.set_node(pos, {name = "default:dirt"})
		end
	end,
})

minetest.register_abm({
	label = "Dirt to grassy dirt",
	nodenames = {"default:dirt"},
	neighbors = {
		"default:grass_4",
		"default:grass_5",
		"default:papyrus",
	},
	interval = 57,
	chance = 16,
	catch_up = false,
	action = function(pos, node)
		local grass = minetest.get_node({x = pos.x, y = pos.y + 1, z = pos.z})
		if grass and grass.name:match("grass") or
				grass.name == "default:papyrus" then
			minetest.set_node(pos, {name = "default:dirt_with_grass"})
		end
	end,
})

minetest.register_abm({
	label = "Broken leaves repair",
	nodenames = {
		"default:leaves_broken",
		"default:jungleleaves_broken",
		"default:pine_needles_broken",
		"default:pine_bush_needles_broken",
		"default:acacia_leaves_broken",
		"default:acacia_bush_leaves_broken",
		"default:aspen_leaves_broken",
		"default:blueblerry_bush_leaves_broken",
		"default:bush_leaves_broken",
	},
	neighbors = {"air"},
	interval = 61,
	chance = 48,
	catch_up = false,
	action = function(pos, node)
		local nn = minetest.get_node(pos)
		minetest.swap_node(pos, {name = nn.name:sub(1, -8)})
	end,
})

minetest.register_abm({
	label = "Player breaks leaves",
	nodenames = {
		"default:leaves",
		"default:jungleleaves",
		"default:pine_needles",
		"default:pine_bush_needles",
		"default:acacia_leaves",
		"default:acacia_bush_leaves",
		"default:aspen_leaves",
		"default:blueblerry_bush_leaves",
		"default:bush_leaves",
	},
	neighbors = {"air"},
	interval = 9,
	chance = 8,
	catch_up = false,
	action = function(pos, node)
		local nn = minetest.get_node(pos)
		if nn.param2 == 1 then
			return
		end
		local a = {x = pos.x, y = pos.y + 0.95, z = pos.z}
		local o = minetest.get_objects_inside_radius(a, 0.95)
		for i = 1, #o do
			if o[i]:is_player() then
				local ppy = o[i]:get_pos().y
				minetest.swap_node(pos, {name = nn.name .. "_broken"})
				minetest.after(0.1, minetest.sound_play,
						"default_tool_breaks", {
							gain = 0.15,
							pos = pos,
						}, true)
				minetest.after(0, minetest.sound_play,
						"default_grass_footstep", {
							gain = 0.5,
							pos = pos,
						}, true)
				minetest.add_particlespawner({
					amount = 8,
					time = 0.001,
					minpos = vector.subtract(pos, {x=0.5, y=0.5, z=0.5}),
					maxpos = vector.add(pos, {x=0.5, y=0.5, z=0.5}),
					minvel = vector.new(-0.5, -1, -0.5),
					maxvel = vector.new(0.5, 0, 0.5),
					minacc = vector.new(0, -movement_gravity, 0),
					maxacc = vector.new(0, -movement_gravity, 0),
					minsize = 0,
					maxsize = 0,
					node = node,
				})
				if math.random() > 0.33 then
					minetest.after(0.36, function()
						if not o[i] then
							return
						end
						if o[i]:get_pos().y < ppy then
							o[i]:set_hp(o[i]:get_hp() - math.random(10, 20), {
								type = "set_hp",
								roughage = true,
							})
						end
					end)
				end
				if math.random() < 0.13 then
					minetest.after(1, function()
						if minetest.get_node(pos).name == nn.name .. "_broken" then
							minetest.swap_node(pos, {name = nn.name})
						end
					end)
				end
				return
			end
		end
	end,
})

minetest.register_abm({
	label = "Water drop",
	nodenames = {"default:water_source"},
	neighbors = {"default:water_flowing", "air"},
	interval = 21,
	chance = 64,
	catch_up = false,
	action = function(pos, node)
		local pb = {x = pos.x, y = pos.y - 1, z = pos.z}
		local nb = minetest.get_node(pb)
		if not nb.name then
			return
		end
		if nb.name == "default:water_flowing" or nb.name == "air" then
			minetest.remove_node(pos)
			minetest.set_node(pb, {name = "default:water_source"})
		end
	end,
})

minetest.register_abm({
	label = "River water drop",
	nodenames = {"default:river_water_source"},
	neighbors = {"default:river_water_flowing", "air"},
	interval = 20,
	chance = 64,
	catch_up = false,
	action = function(pos, node)
		local pb = {x = pos.x, y = pos.y - 1, z = pos.z}
		local nb = minetest.get_node(pb)
		if not nb.name then
			return
		end
		if nb.name == "default:river_water_flowing" or nb.name == "air" then
			minetest.remove_node(pos)
			minetest.set_node(pb, {name = "default:river_water_source"})
		end
	end,
})

minetest.register_abm({
	label = "Lava drop",
	nodenames = {"default:lava_source"},
	neighbors = {"default:lava_flowing", "air"},
	interval = 19,
	chance = 64,
	catch_up = false,
	action = function(pos, node)
		local pb = {x = pos.x, y = pos.y - 1, z = pos.z}
		local nb = minetest.get_node(pb)
		if not nb.name then
			return
		end
		if nb.name == "default:lava_flowing" or nb.name == "air" then
			minetest.remove_node(pos)
			minetest.set_node(pb, {name = "default:lava_source"})
		end
	end,
})

minetest.register_abm({
	label = "Renew liquid",
	nodenames = {
		"default:water_flowing",
		"default:river_water_flowing",
		"default:lava_flowing",
	},
	neighbors = {"air"},
	interval = 18,
	chance = 24,
	catch_up = false,
	action = function(pos, node)
		local l = node.name:sub(1, -8)
		l = l .. "source"

		local f = minetest.find_node_near(pos, 1, l)
		if f and math.random() >= 0.334 then
			local p1 = {x = pos.x + 1, y = pos.y, z = pos.z + 1}
			local p2 = {x = pos.x - 1, y = pos.y, z = pos.z - 1}
			local ar = minetest.find_nodes_in_area(p1, p2, l)
			if #ar >= 7 then
				minetest.set_node(pos, {name = l})
			end
		end
	end,
})
