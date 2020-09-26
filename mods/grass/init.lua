-- /mods/grass is part of jastest
-- copyright 2020 james alexander stevenson
-- gnu gpl 3+

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
