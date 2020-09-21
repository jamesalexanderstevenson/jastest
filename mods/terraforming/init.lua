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
