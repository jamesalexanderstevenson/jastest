-- support for i18n
local S = armor_i18n.gettext

if minetest.global_exists("armor") and armor.elements then
	table.insert(armor.elements, "shield")
	local mult = armor.config.level_multiplier or 1
	armor.config.level_multiplier = mult * 0.9
end

-- Regisiter Shields

armor:register_armor("shields:shield_admin", {
	description = S("Admin Shield"),
	inventory_image = "shields_inv_shield_admin.png",
	groups = {armor_shield=1000, armor_use=0, not_in_creative_inventory=1},
	on_use = armor.on_use,
})

minetest.register_alias("adminshield", "shields:shield_admin")

armor:register_armor("shields:shield_wood", {
	description = S("Wooden Shield"),
	inventory_image = "shields_inv_shield_wood.png",
	groups = {armor_shield=1, armor_use=5000, flammable=1},
	armor_groups = {fleshy=5},
	damage_groups = {cracky=3, snappy=2, choppy=3, crumbly=2, level=1},
	reciprocate_damage = true,
	on_use = armor.on_use,
})
armor:register_armor("shields:shield_enhanced_wood", {
	description = S("Enhanced Wood Shield"),
	inventory_image = "shields_inv_shield_enhanced_wood.png",
	groups = {armor_shield=1, armor_use=5000},
	armor_groups = {fleshy=8},
	damage_groups = {cracky=3, snappy=2, choppy=3, crumbly=2, level=2},
	reciprocate_damage = true,
	on_use = armor.on_use,
})
minetest.register_craft({
	output = "shields:shield_enhanced_wood",
	recipe = {
		{"default:steel_ingot"},
		{"shields:shield_wood"},
		{"default:steel_ingot"},
	},
})

armor:register_armor("shields:shield_cactus", {
	description = S("Cactus Shield"),
	inventory_image = "shields_inv_shield_cactus.png",
	groups = {armor_shield=1, armor_use=1000},
	armor_groups = {fleshy=5},
	damage_groups = {cracky=3, snappy=3, choppy=2, crumbly=2, level=1},
	reciprocate_damage = true,
	on_use = armor.on_use,
})
armor:register_armor("shields:shield_enhanced_cactus", {
	description = S("Enhanced Cactus Shield"),
	inventory_image = "shields_inv_shield_enhanced_cactus.png",
	groups = {armor_shield=1, armor_use=1000},
	armor_groups = {fleshy=8},
	damage_groups = {cracky=3, snappy=3, choppy=2, crumbly=2, level=2},
	reciprocate_damage = true,
	on_use = armor.on_use,
})
minetest.register_craft({
	output = "shields:shield_enhanced_cactus",
	recipe = {
		{"default:steel_ingot"},
		{"shields:shield_cactus"},
		{"default:steel_ingot"},
	},
})

armor:register_armor("shields:shield_steel", {
	description = S("Steel Shield"),
	inventory_image = "shields_inv_shield_steel.png",
	groups = {armor_shield=1, armor_use=800,},
	armor_groups = {fleshy=10},
	damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
	reciprocate_damage = true,
	on_use = armor.on_use,
})

armor:register_armor("shields:shield_bronze", {
	description = S("Bronze Shield"),
	inventory_image = "shields_inv_shield_bronze.png",
	groups = {armor_shield=1, armor_use=400,},
	armor_groups = {fleshy=10},
	damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
	reciprocate_damage = true,
	on_use = armor.on_use,
})

armor:register_armor("shields:shield_diamond", {
	description = S("Diamond Shield"),
	inventory_image = "shields_inv_shield_diamond.png",
	groups = {armor_shield=1, armor_use=200},
	armor_groups = {fleshy=15},
	damage_groups = {cracky=2, snappy=1, choppy=1, level=3},
	reciprocate_damage = true,
	on_use = armor.on_use,
})

armor:register_armor("shields:shield_gold", {
	description = S("Gold Shield"),
	inventory_image = "shields_inv_shield_gold.png",
	groups = {armor_shield=1, armor_use=300,},
	armor_groups = {fleshy=10},
	damage_groups = {cracky=1, snappy=2, choppy=2, crumbly=3, level=2},
	reciprocate_damage = true,
	on_use = armor.on_use,
})

armor:register_armor("shields:shield_mithril", {
	description = S("Mithril Shield"),
	inventory_image = "shields_inv_shield_mithril.png",
	groups = {armor_shield=1, armor_use=100},
	armor_groups = {fleshy=15},
	damage_groups = {cracky=2, snappy=1, level=3},
	reciprocate_damage = true,
	on_use = armor.on_use,
})

armor:register_armor("shields:shield_crystal", {
	description = S("Crystal Shield"),
	inventory_image = "shields_inv_shield_crystal.png",
	groups = {armor_shield=1, armor_use=100, armor_fire=1},
	armor_groups = {fleshy=15},
	damage_groups = {cracky=2, snappy=1, level=3},
	reciprocate_damage = true,
	on_use = armor.on_use,
})

for k, v in pairs(armor.materials) do
	minetest.register_craft({
		output = "shields:shield_"..k,
		recipe = {
			{v, v, v},
			{v, v, v},
			{"", v, ""},
		},
	})
end
