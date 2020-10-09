-- support for i18n
local S = armor_i18n.gettext

local els = {"wood", "cactus", "steel", "bronze",
		"gold", "diamond", "mithril", "crystal", "admin"}

local pcs = {"helmet", "chestplate", "leggings", "boots", "shield"}

table.insert(armor.elements, "shield")
local mult = armor.config.level_multiplier or 1
armor.config.level_multiplier = mult * 0.9

armor.on_use = function(itemstack, user, pointed_thing)
	local nn = itemstack:get_name()
	local n
	for i = 1, #pcs do
		if nn:match(pcs[i]) then
			n = i
		end
	end
	local _, inv = armor:get_valid_player(user)
	local stack = inv:get_stack("armor", n)
	local old_name = stack:get_name()
	local old_wear = stack:get_wear()
	local lvl
	for i = 1, #els do
		-- check old level
		if old_name:match(els[i]) then
			lvl = i
			if nn:match(els[i]) then
				if old_wear <= itemstack:get_wear() then
					return itemstack
				end
			else
				for ii = 1, #els do
					if nn:match(els[ii]) then
						if ii < lvl then
							return itemstack
						end
					end
				end
			end
		end
	end
	ll_items.throw_inventory(user:get_pos(), {stack})
	armor:set_inventory_stack(user, n, itemstack)
	armor:set_player_armor(user)
	armor:update_player_visuals(player)
	armor:save_armor_inventory(player)
	itemstack:take_item()
	return itemstack
end

-- Admin (pink)
armor:register_armor("3d_armor:helmet_admin", {
	description = S("Admin Helmet"),
	inventory_image = "3d_armor_inv_helmet_admin.png",
	armor_groups = {fleshy=100},
	groups = {armor_head=1, armor_use=0, armor_water=1,
			not_in_creative_inventory=1},
	on_drop = function(itemstack, dropper, pos)
		return
	end,
	on_use = armor.on_use,
})

armor:register_armor("3d_armor:chestplate_admin", {
	description = S("Admin Chestplate"),
	inventory_image = "3d_armor_inv_chestplate_admin.png",
	armor_groups = {fleshy=100},
	groups = {armor_torso=1, armor_use=0,
			not_in_creative_inventory=1},
	on_drop = function(itemstack, dropper, pos)
		return
	end,
	on_use = armor.on_use,
})

armor:register_armor("3d_armor:leggings_admin", {
	description = S("Admin Leggings"),
	inventory_image = "3d_armor_inv_leggings_admin.png",
	armor_groups = {fleshy=100},
	groups = {armor_legs=1, armor_use=0,
			not_in_creative_inventory=1},
	on_drop = function(itemstack, dropper, pos)
		return
	end,
	on_use = armor.on_use,
})

armor:register_armor("3d_armor:boots_admin", {
	description = S("Admin Boots"),
	inventory_image = "3d_armor_inv_boots_admin.png",
	armor_groups = {fleshy=100},
	groups = {armor_feet=1, armor_use=0,
			not_in_creative_inventory=1},
	on_drop = function(itemstack, dropper, pos)
		return
	end,
	on_use = armor.on_use,
})

armor:register_armor("3d_armor:shield_admin", {
	description = S("Admin Shield"),
	inventory_image = "3d_armor_inv_shield_admin.png",
	groups = {armor_shield=1000, armor_use=0, not_in_creative_inventory=1},
	on_use = armor.on_use,
})

minetest.register_alias("shields:shield_admin", "3d_armor:shield_admin")

-- Wood
armor:register_armor("3d_armor:helmet_wood", {
	description = S("Wood Helmet"),
	inventory_image = "3d_armor_inv_helmet_wood.png",
	groups = {armor_head=1, armor_use=5000, flammable=1},
	armor_groups = {fleshy=5},
	damage_groups = {cracky=3, snappy=2, choppy=3, crumbly=2, level=1},
	on_use = armor.on_use,
})

armor:register_armor("3d_armor:chestplate_wood", {
	description = S("Wood Chestplate"),
	inventory_image = "3d_armor_inv_chestplate_wood.png",
	groups = {armor_torso=1, armor_use=5000, flammable=1},
	armor_groups = {fleshy=10},
	damage_groups = {cracky=3, snappy=2, choppy=3, crumbly=2, level=1},
	on_use = armor.on_use,
})

armor:register_armor("3d_armor:leggings_wood", {
	description = S("Wood Leggings"),
	inventory_image = "3d_armor_inv_leggings_wood.png",
	groups = {armor_legs=1, armor_use=5000, flammable=1},
	armor_groups = {fleshy=10},
	damage_groups = {cracky=3, snappy=2, choppy=3, crumbly=2, level=1},
	on_use = armor.on_use,
})

armor:register_armor("3d_armor:boots_wood", {
	description = S("Wood Boots"),
	inventory_image = "3d_armor_inv_boots_wood.png",
	armor_groups = {fleshy=5},
	damage_groups = {cracky=3, snappy=2, choppy=3, crumbly=2, level=1},
	groups = {armor_feet=1, armor_use=5000, flammable=1},
	on_use = armor.on_use,
})

armor:register_armor("3d_armor:shield_wood", {
	description = S("Wooden Shield"),
	inventory_image = "3d_armor_inv_shield_wood.png",
	groups = {armor_shield=1, armor_use=5000, flammable=1},
	armor_groups = {fleshy=5},
	damage_groups = {cracky=3, snappy=2, choppy=3, crumbly=2, level=1},
	reciprocate_damage = true,
	on_use = armor.on_use,
})

minetest.register_alias("shields:shield_wood", "3d_armor:shield_wood")

armor:register_armor("3d_armor:shield_enhanced_wood", {
	description = S("Enhanced Wood Shield"),
	inventory_image = "3d_armor_inv_shield_enhanced_wood.png",
	groups = {armor_shield=1, armor_use=5000},
	armor_groups = {fleshy=8},
	damage_groups = {cracky=3, snappy=2, choppy=3, crumbly=2, level=2},
	reciprocate_damage = true,
	on_use = armor.on_use,
})

minetest.register_alias("shields:shield_enhanced_wood", "3d_armor:shield_enhanced_wood")

minetest.register_craft({
	output = "3d_armor:shield_enhanced_wood",
	recipe = {
		{"default:steel_ingot"},
		{"3d_armor:shield_wood"},
		{"default:steel_ingot"},
	},
})

-- Cactus
armor:register_armor("3d_armor:helmet_cactus", {
	description = S("Cactus Helmet"),
	inventory_image = "3d_armor_inv_helmet_cactus.png",
	groups = {armor_head=1, armor_use=1000},
	armor_groups = {fleshy=5},
	damage_groups = {cracky=3, snappy=3, choppy=2, crumbly=2, level=1},
	on_use = armor.on_use,
})

armor:register_armor("3d_armor:chestplate_cactus", {
	description = S("Cactus Chestplate"),
	inventory_image = "3d_armor_inv_chestplate_cactus.png",
	groups = {armor_torso=1, armor_use=1000},
	armor_groups = {fleshy=10},
	damage_groups = {cracky=3, snappy=3, choppy=2, crumbly=2, level=1},
	on_use = armor.on_use,
})

armor:register_armor("3d_armor:leggings_cactus", {
	description = S("Cactus Leggings"),
	inventory_image = "3d_armor_inv_leggings_cactus.png",
	groups = {armor_legs=1, armor_use=1000},
	armor_groups = {fleshy=10},
	damage_groups = {cracky=3, snappy=3, choppy=2, crumbly=2, level=1},
	on_use = armor.on_use,
})

armor:register_armor("3d_armor:boots_cactus", {
	description = S("Cactus Boots"),
	inventory_image = "3d_armor_inv_boots_cactus.png",
	groups = {armor_feet=1, armor_use=1000},
	armor_groups = {fleshy=5},
	damage_groups = {cracky=3, snappy=3, choppy=2, crumbly=2, level=1},
	on_use = armor.on_use,
})

armor:register_armor("3d_armor:shield_cactus", {
	description = S("Cactus Shield"),
	inventory_image = "3d_armor_inv_shield_cactus.png",
	groups = {armor_shield=1, armor_use=1000},
	armor_groups = {fleshy=5},
	damage_groups = {cracky=3, snappy=3, choppy=2, crumbly=2, level=1},
	reciprocate_damage = true,
	on_use = armor.on_use,
})

minetest.register_alias("shields:shield_cactus", "3d_armor:shield_cactus")

armor:register_armor("3d_armor:shield_enhanced_cactus", {
	description = S("Enhanced Cactus Shield"),
	inventory_image = "3d_armor_inv_shield_enhanced_cactus.png",
	groups = {armor_shield=1, armor_use=1000},
	armor_groups = {fleshy=8},
	damage_groups = {cracky=3, snappy=3, choppy=2, crumbly=2, level=2},
	reciprocate_damage = true,
	on_use = armor.on_use,
})

minetest.register_alias("shields:shield_enhanced_cactus", "3d_armor:shield_enhanced_cactus")

minetest.register_craft({
	output = "3d_armor:shield_enhanced_cactus",
	recipe = {
		{"default:steel_ingot"},
		{"3d_armor:shield_cactus"},
		{"default:steel_ingot"},
	},
})

-- Steel
armor:register_armor("3d_armor:helmet_steel", {
	description = S("Steel Helmet"),
	inventory_image = "3d_armor_inv_helmet_steel.png",
	groups = {armor_head=1, armor_use=800,},
	armor_groups = {fleshy=10},
	damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
	on_use = armor.on_use,
})

armor:register_armor("3d_armor:chestplate_steel", {
	description = S("Steel Chestplate"),
	inventory_image = "3d_armor_inv_chestplate_steel.png",
	groups = {armor_torso=1, armor_use=800,},
	armor_groups = {fleshy=15},
	damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
	on_use = armor.on_use,
})

armor:register_armor("3d_armor:leggings_steel", {
	description = S("Steel Leggings"),
	inventory_image = "3d_armor_inv_leggings_steel.png",
	groups = {armor_legs=1, armor_use=800,},
	armor_groups = {fleshy=15},
	damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
	on_use = armor.on_use,
})

armor:register_armor("3d_armor:boots_steel", {
	description = S("Steel Boots"),
	inventory_image = "3d_armor_inv_boots_steel.png",
	groups = {armor_feet=1, armor_use=800,},
	armor_groups = {fleshy=10},
	damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
	on_use = armor.on_use,
})

armor:register_armor("3d_armor:shield_steel", {
	description = S("Steel Shield"),
	inventory_image = "3d_armor_inv_shield_steel.png",
	groups = {armor_shield=1, armor_use=800,},
	armor_groups = {fleshy=10},
	damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
	reciprocate_damage = true,
	on_use = armor.on_use,
})

minetest.register_alias("shields:shield_steel", "3d_armor:shield_steel")

-- Bronze
armor:register_armor("3d_armor:helmet_bronze", {
	description = S("Bronze Helmet"),
	inventory_image = "3d_armor_inv_helmet_bronze.png",
	groups = {armor_head=1, armor_use=400,},
	armor_groups = {fleshy=10},
	damage_groups = {cracky=3, snappy=2, choppy=2, crumbly=1, level=2},
	on_use = armor.on_use,
})

armor:register_armor("3d_armor:chestplate_bronze", {
	description = S("Bronze Chestplate"),
	inventory_image = "3d_armor_inv_chestplate_bronze.png",
	groups = {armor_torso=1, armor_use=400,},
	armor_groups = {fleshy=15},
	damage_groups = {cracky=3, snappy=2, choppy=2, crumbly=1, level=2},
	on_use = armor.on_use,
})

armor:register_armor("3d_armor:leggings_bronze", {
	description = S("Bronze Leggings"),
	inventory_image = "3d_armor_inv_leggings_bronze.png",
	groups = {armor_legs=1, armor_use=400,},
	armor_groups = {fleshy=15},
	damage_groups = {cracky=3, snappy=2, choppy=2, crumbly=1, level=2},
	on_use = armor.on_use,
})

armor:register_armor("3d_armor:boots_bronze", {
	description = S("Bronze Boots"),
	inventory_image = "3d_armor_inv_boots_bronze.png",
	groups = {armor_feet=1, armor_use=400,},
	armor_groups = {fleshy=10},
	damage_groups = {cracky=3, snappy=2, choppy=2, crumbly=1, level=2},
	on_use = armor.on_use,
})

armor:register_armor("3d_armor:shield_bronze", {
	description = S("Bronze Shield"),
	inventory_image = "3d_armor_inv_shield_bronze.png",
	groups = {armor_shield=1, armor_use=400,},
	armor_groups = {fleshy=10},
	damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
	reciprocate_damage = true,
	on_use = armor.on_use,
})

minetest.register_alias("shields:shield_bronze", "3d_armor:shield_bronze")

-- Gold
armor:register_armor("3d_armor:helmet_gold", {
	description = S("Gold Helmet"),
	inventory_image = "3d_armor_inv_helmet_gold.png",
	groups = {armor_head=1, armor_use=300,},
	armor_groups = {fleshy=10},
	damage_groups = {cracky=1, snappy=2, choppy=2, crumbly=3, level=2},
	on_use = armor.on_use,
})

armor:register_armor("3d_armor:chestplate_gold", {
	description = S("Gold Chestplate"),
	inventory_image = "3d_armor_inv_chestplate_gold.png",
	groups = {armor_torso=1, armor_use=300,},
	armor_groups = {fleshy=15},
	damage_groups = {cracky=1, snappy=2, choppy=2, crumbly=3, level=2},
	on_use = armor.on_use,
})

armor:register_armor("3d_armor:leggings_gold", {
	description = S("Gold Leggings"),
	inventory_image = "3d_armor_inv_leggings_gold.png",
	groups = {armor_legs=1, armor_use=300,},
	armor_groups = {fleshy=15},
	damage_groups = {cracky=1, snappy=2, choppy=2, crumbly=3, level=2},
	on_use = armor.on_use,
})

armor:register_armor("3d_armor:boots_gold", {
	description = S("Gold Boots"),
	inventory_image = "3d_armor_inv_boots_gold.png",
	groups = {armor_feet=1, armor_use=300,},
	armor_groups = {fleshy=10},
	damage_groups = {cracky=1, snappy=2, choppy=2, crumbly=3, level=2},
	on_use = armor.on_use,
})

armor:register_armor("3d_armor:shield_gold", {
	description = S("Gold Shield"),
	inventory_image = "3d_armor_inv_shield_gold.png",
	groups = {armor_shield=1, armor_use=300,},
	armor_groups = {fleshy=10},
	damage_groups = {cracky=1, snappy=2, choppy=2, crumbly=3, level=2},
	reciprocate_damage = true,
	on_use = armor.on_use,
})

minetest.register_alias("shields:shield_gold", "3d_armor:shield_gold")

-- Diamond
armor:register_armor("3d_armor:helmet_diamond", {
	description = S("Diamond Helmet"),
	inventory_image = "3d_armor_inv_helmet_diamond.png",
	groups = {armor_head=1, armor_use=200},
	armor_groups = {fleshy=15},
	damage_groups = {cracky=2, snappy=1, choppy=1, level=3},
	on_use = armor.on_use,
})

armor:register_armor("3d_armor:chestplate_diamond", {
	description = S("Diamond Chestplate"),
	inventory_image = "3d_armor_inv_chestplate_diamond.png",
	groups = {armor_torso=1, armor_use=200},
	armor_groups = {fleshy=20},
	damage_groups = {cracky=2, snappy=1, choppy=1, level=3},
	on_use = armor.on_use,
})

armor:register_armor("3d_armor:leggings_diamond", {
	description = S("Diamond Leggings"),
	inventory_image = "3d_armor_inv_leggings_diamond.png",
	groups = {armor_legs=1, armor_use=200},
	armor_groups = {fleshy=20},
	damage_groups = {cracky=2, snappy=1, choppy=1, level=3},
	on_use = armor.on_use,
})

armor:register_armor("3d_armor:boots_diamond", {
	description = S("Diamond Boots"),
	inventory_image = "3d_armor_inv_boots_diamond.png",
	groups = {armor_feet=1, armor_use=200},
	armor_groups = {fleshy=15},
	damage_groups = {cracky=2, snappy=1, choppy=1, level=3},
	on_use = armor.on_use,
})

armor:register_armor("3d_armor:shield_diamond", {
	description = S("Diamond Shield"),
	inventory_image = "3d_armor_inv_shield_diamond.png",
	groups = {armor_shield=1, armor_use=200},
	armor_groups = {fleshy=15},
	damage_groups = {cracky=2, snappy=1, choppy=1, level=3},
	reciprocate_damage = true,
	on_use = armor.on_use,
})

minetest.register_alias("shields:shield_diamond", "3d_armor:shield_diamond")

-- Mithril
armor:register_armor("3d_armor:helmet_mithril", {
	description = S("Mithril Helmet"),
	inventory_image = "3d_armor_inv_helmet_mithril.png",
	groups = {armor_head=1, armor_use=100},
	armor_groups = {fleshy=15},
	damage_groups = {cracky=2, snappy=1, level=3},
	on_use = armor.on_use,
})

armor:register_armor("3d_armor:chestplate_mithril", {
	description = S("Mithril Chestplate"),
	inventory_image = "3d_armor_inv_chestplate_mithril.png",
	groups = {armor_torso=1, armor_use=100},
	armor_groups = {fleshy=20},
	damage_groups = {cracky=2, snappy=1, level=3},
	on_use = armor.on_use,
})

armor:register_armor("3d_armor:leggings_mithril", {
	description = S("Mithril Leggings"),
	inventory_image = "3d_armor_inv_leggings_mithril.png",
	groups = {armor_legs=1, armor_use=100},
	armor_groups = {fleshy=20},
	damage_groups = {cracky=2, snappy=1, level=3},
	on_use = armor.on_use,
})

armor:register_armor("3d_armor:boots_mithril", {
	description = S("Mithril Boots"),
	inventory_image = "3d_armor_inv_boots_mithril.png",
	groups = {armor_feet=1, armor_use=100},
	armor_groups = {fleshy=15},
	damage_groups = {cracky=2, snappy=1, level=3},
	on_use = armor.on_use,
})

armor:register_armor("3d_armor:shield_mithril", {
	description = S("Mithril Shield"),
	inventory_image = "3d_armor_inv_shield_mithril.png",
	groups = {armor_shield=1, armor_use=100},
	armor_groups = {fleshy=15},
	damage_groups = {cracky=2, snappy=1, level=3},
	reciprocate_damage = true,
	on_use = armor.on_use,
})

minetest.register_alias("shields:shield_mithril", "3d_armor:shield_mithril")

-- Crystal
armor:register_armor("3d_armor:helmet_crystal", {
	description = S("Crystal Helmet"),
	inventory_image = "3d_armor_inv_helmet_crystal.png",
	groups = {armor_head=1, armor_use=100, armor_fire=1},
	armor_groups = {fleshy=15},
	damage_groups = {cracky=2, snappy=1, level=3},
	on_use = armor.on_use,
})

armor:register_armor("3d_armor:chestplate_crystal", {
	description = S("Crystal Chestplate"),
	inventory_image = "3d_armor_inv_chestplate_crystal.png",
	groups = {armor_torso=1, armor_use=100, armor_fire=1},
	armor_groups = {fleshy=20},
	damage_groups = {cracky=2, snappy=1, level=3},
	on_use = armor.on_use,
})

armor:register_armor("3d_armor:leggings_crystal", {
	description = S("Crystal Leggings"),
	inventory_image = "3d_armor_inv_leggings_crystal.png",
	groups = {armor_legs=1, armor_use=100, armor_fire=1},
	armor_groups = {fleshy=20},
	damage_groups = {cracky=2, snappy=1, level=3},
	on_use = armor.on_use,
})

armor:register_armor("3d_armor:boots_crystal", {
	description = S("Crystal Boots"),
	inventory_image = "3d_armor_inv_boots_crystal.png",
	groups = {armor_feet=1, armor_use=100,},
	armor_groups = {fleshy=15},
	damage_groups = {cracky=2, snappy=1, level=3},
	on_use = armor.on_use,
})

armor:register_armor("3d_armor:shield_crystal", {
	description = S("Crystal Shield"),
	inventory_image = "3d_armor_inv_shield_crystal.png",
	groups = {armor_shield=1, armor_use=100, armor_fire=1},
	armor_groups = {fleshy=15},
	damage_groups = {cracky=2, snappy=1, level=3},
	reciprocate_damage = true,
	on_use = armor.on_use,
})

minetest.register_alias("shields:shield_crystal", "3d_armor:shield_crystal")

for k, v in pairs(armor.materials) do
	minetest.register_craft({
		output = "3d_armor:helmet_"..k,
		recipe = {
			{v, v, v},
			{v, "", v},
			{"", "", ""},
		},
	})
	minetest.register_craft({
		output = "3d_armor:chestplate_"..k,
		recipe = {
			{v, "", v},
			{v, v, v},
			{v, v, v},
		},
	})
	minetest.register_craft({
		output = "3d_armor:leggings_"..k,
		recipe = {
			{v, v, v},
			{v, "", v},
			{v, "", v},
		},
	})
	minetest.register_craft({
		output = "3d_armor:boots_"..k,
		recipe = {
			{v, "", v},
			{v, "", v},
		},
	})
	minetest.register_craft({
		output = "3d_armor:shield_"..k,
		recipe = {
			{v, v, v},
			{v, v, v},
			{"", v, ""},
		},
	})
end
