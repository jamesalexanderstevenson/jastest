-- /mods/dirt is part of jastest
-- copyright 2020 james alexander stevenson
-- gnu gpl 3+

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
