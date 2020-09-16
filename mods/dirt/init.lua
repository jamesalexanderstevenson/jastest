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

-- Occasionally drop seeds and coins when digging in dirt
local nodes = {
	"default:dirt",
	"default:dirt_with_grass",
	"default:dirt_with_dry_grass",
	"default:dirt_with_snow",
	"default:dirt_with_rainforest_litter",
}

for i = 1, #nodes do
	minetest.override_item(nodes[i], {
		drop = {
			items = {
				{items = {"default:dirt"}},
				{items = {"crops:potato"}, rarity = 250},
				{items = {"crops:corn"}, rarity = 300},
				{items = {"crops:melon_seed"}, rarity = 300},
				{items = {"crops:green_bean_seed"}, rarity = 400},
				{items = {"crops:pumpkin_seed"}, rarity = 500},
				{items = {"crops:tomato_seed"}, rarity = 350},
				{items = {"crops:carrot_seeds"}, rarity = 350},
				{items = {"mtd:gold_coin"}, rarity = 200},
			}
		}
	})
end
