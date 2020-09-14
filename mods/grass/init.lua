-- jastest/mods/grass 'jastest'
-- Copyright 2020 James Steveson
-- GNU GPL 3+

for n = 1, 5 do
	minetest.register_craft({
		type = "shapeless",
		output = "default:dirt_with_grass",
		recipe = {
			"default:dirt",
			"default:grass_" .. n,
		}
	})
end

minetest.register_craft({
	type = "shapeless",
	output = "default:dirt_with_grass",
	recipe = {
		"default:dirt",
		"default:junglegrass",
	}
})

minetest.register_craft({
	type = "shapeless",
	output = "default:dirt_with_rainforest_litter",
	recipe = {
		"default:dirt",
		"default:jungleleaves",
	}
})

minetest.register_craft({
	type = "shapeless",
	output = "default:stick 2",
	recipe = {"default:dry_shrub"},
})

minetest.override_item("default:dry_shrub",
		{groups = {snappy = 3, flammable = 3, attached_node = 1}})

minetest.override_item("default:dirt_with_dry_grass",
		{groups = {crumbly = 3, soil = 1, spreading_dirt_type = 1}})

local fsnn = {
	"farming:cotton_wild",
	"farming:cotton_6",
	"farming:wheat_6",
	"crops:carrot_plant_5",
	"crops:melon_plant_4",
	"crops:pumpkin_plant_4",
	"default:junglegrass",
	"default:dry_shrub",
	"flowers:rose",
	"flowers:tulip",
	"flowers:dandelion_yellow",
	"flowers:chrysanthemum_green",
	"flowers:geranium",
	"flowers:viola",
	"flowers:dandelion_white",
	"flowers:tulip_black",
	"flowers:mushroom_red",
	"flowers:mushroom_brown",
	"default:grass_1",
	"default:grass_2",
	"default:grass_3",
	"default:grass_4",
	"default:grass_5",
	"default:dry_grass_1",
	"default:dry_grass_2",
	"default:dry_grass_3",
	"default:dry_grass_4",
	"default:dry_grass_5",
	"default:bush_sapling",
	"default:sapling",
	"default:fern_1",
	"default:fern_2",
	"default:fern_3",
	"default:marram_grass_1",
	"default:marram_grass_2",
	"default:marram_grass_3",
}

local fsnn_dry = {
	"default:dry_grass_1",
	"default:dry_grass_2",
	"default:dry_grass_3",
	"default:dry_grass_4",
	"default:dry_grass_5",
}

minetest.register_abm({
	label = "Biome growth",
	nodenames = {"default:dirt_with_grass"},
	neighbors = fsnn_dry,
	chance = 50,
	interval = 150,
	catch_up = false,
	action = function(pos, node)
		pos.y = pos.y + 1
		local name = minetest.get_node(pos).name
		for i = 1, #fsnn_dry do
			if name == fsnn_dry[i] then
				pos.y = pos.y - 1
				minetest.set_node(pos,
						{name = "default:dirt_with_dry_grass"})
			end
		end
	end,
})

minetest.register_abm({
	label = "Flora spread 2",
	nodenames = {"group:spreading_dirt_type"},
	neighbors = "air",
	chance = 256, 
	interval = 30,
	catch_up = false,
	action = function(pos, node)
		if minetest.get_node(pos).name == "default:dirt_with_snow" then
			return
		end
		pos.y = pos.y + 1
		if minetest.get_node(pos).name ~= "air" or
				minetest.get_node_light(pos) < 12 then
			return
		end
		local p1 = {x = pos.x + 2, y = pos.y + 2, z = pos.z + 2}
		local p2 = {x = pos.x - 2, y = pos.y - 2, z = pos.z - 2}
		local a, b = minetest.find_nodes_in_area(p1, p2, fsnn)
		if #a < 6 then
			minetest.set_node(pos, {name = fsnn[math.random(#fsnn)]})
		end
	end,
})

minetest.register_abm({
	label = "Grass atop mossycobble",
	nodenames = {"default:mossycobble"},
	neighbors = {"air", "group:water"},
	interval = 17,
	chance = 80,
	catch_up = false,
	action = function(pos, node)
		pos.y = pos.y + 1
		local node = minetest.get_node(pos)
		if node and node.name and node.name == "air" then
			if minetest.find_node_near(pos, 5, "group:water") then
				minetest.set_node(pos, {name = "default:grass_" .. math.random(5)})
			end
		end
	end,
})
