
local S = mobs.intllib

-- name tag
minetest.register_craftitem("mobs:nametag", {
	description = S("Name Tag"),
	inventory_image = "mobs_nametag.png",
	groups = {flammable = 2}
})

minetest.register_craft({
	type = "shapeless",
	output = "mobs:nametag",
	recipe = {"default:paper", "dye:black", "farming:string"}
})

minetest.register_craftitem("mobs:rotten_flesh", {
	description = "Rotten Flesh",
	inventory_image = "mobs_rotten_flesh.png",
	on_use = minetest.item_eat(-10),
})

minetest.register_craft({
	type = "cooking",
	output = "mobs:meat",
	recipe = "mobs:rotten_flesh",
	cooktime = 20,
})

-- leather
minetest.register_craftitem("mobs:leather", {
	description = S("Leather"),
	inventory_image = "mobs_leather.png",
	groups = {flammable = 2}
})

-- raw meat
minetest.register_craftitem("mobs:meat_raw", {
	description = S("Raw Meat"),
	inventory_image = "mobs_meat_raw.png",
	on_use = minetest.item_eat(8),
	groups = {food_meat_raw = 1, flammable = 2}
})

-- cooked meat
minetest.register_craftitem("mobs:meat", {
	description = S("Meat"),
	inventory_image = "mobs_meat.png",
	on_use = minetest.item_eat(24),
	groups = {food_meat = 1, flammable = 2}
})

minetest.register_craft({
	type = "cooking",
	output = "mobs:meat",
	recipe = "mobs:meat_raw",
	cooktime = 5
})

-- lasso
minetest.register_tool("mobs:lasso", {
	description = S("Lasso (right-click animal to put in inventory)"),
	inventory_image = "mobs_magic_lasso.png",
	groups = {flammable = 2}
})

minetest.register_craft({
	output = "mobs:lasso",
	recipe = {
		{"farming:string", "", "farming:string"},
		{"", "default:diamond", ""},
		{"farming:string", "", "farming:string"}
	}
})

-- shears (right click to shear animal)
minetest.register_tool("mobs:shears", {
	description = S("Steel Shears (right-click to shear)"),
	inventory_image = "mobs_shears.png",
	groups = {flammable = 2}
})

minetest.register_craft({
	output = "mobs:shears",
	recipe = {
		{"", "default:steel_ingot", ""},
		{"", "group:stick", "default:steel_ingot"}
	}
})

-- protection rune
minetest.register_craftitem("mobs:protector", {
	description = S("Mob Protection Rune"),
	inventory_image = "mobs_protector.png",
	groups = {flammable = 2}
})

minetest.register_craft({
	output = "mobs:protector",
	recipe = {
		{"default:stone", "default:stone", "default:stone"},
		{"default:stone", "default:goldblock", "default:stone"},
		{"default:stone", "default:stone", "default:stone"}
	}
})

-- saddle
minetest.register_craftitem("mobs:saddle", {
	description = S("Saddle"),
	inventory_image = "mobs_saddle.png",
	groups = {flammable = 2}
})

minetest.register_craft({
	output = "mobs:saddle",
	recipe = {
		{"mobs:leather", "mobs:leather", "mobs:leather"},
		{"mobs:leather", "default:steel_ingot", "mobs:leather"},
		{"mobs:leather", "default:steel_ingot", "mobs:leather"}
	}
})

-- items that can be used as fuel
minetest.register_craft({
	type = "fuel",
	recipe = "mobs:nametag",
	burntime = 3
})

minetest.register_craft({
	type = "fuel",
	recipe = "mobs:lasso",
	burntime = 7
})

minetest.register_craft({
	type = "fuel",
	recipe = "mobs:leather",
	burntime = 4
})

minetest.register_craft({
	type = "fuel",
	recipe = "mobs:saddle",
	burntime = 7
})

-- this tool spawns same mob and adds owner, protected, nametag info
-- then removes original entity, this is used for fixing any issues.

local tex_obj

minetest.register_tool("mobs:mob_reset_stick", {
	description = S("Mob Reset Stick"),
	inventory_image = "default_stick.png^[colorize:#ff000050",
	stack_max = 1,
	groups = {not_in_creative_inventory = 1},

	on_use = function(itemstack, user, pointed_thing)

		if pointed_thing.type ~= "object" then
			return
		end

		local obj = pointed_thing.ref

		local control = user:get_player_control()
		local sneak = control and control.sneak

		-- spawn same mob with saved stats, with random texture
		if obj and not sneak then

			local self = obj:get_luaentity()
			local obj2 = minetest.add_entity(obj:get_pos(), self.name)

			if obj2 then

				local ent2 = obj2:get_luaentity()

				ent2.protected = self.protected
				ent2.owner = self.owner
				ent2.nametag = self.nametag
				ent2.gotten = self.gotten
				ent2.tamed = self.tamed
				ent2.health = self.health
				ent2.order = self.order

				if self.child then
					obj2:set_velocity({x = 0, y = self.jump_height, z = 0})
				end

				obj2:set_properties({nametag = self.nametag})

				obj:remove()
			end
		end

		-- display form to enter texture name ending in .png
		if obj and sneak then

			tex_obj = obj

			local name = user:get_player_name()
			local tex = ""

			minetest.show_formspec(name, "mobs_texture", "size[8,4]"
			.. "field[0.5,1;7.5,0;name;"
			.. minetest.formspec_escape(S("Enter texture:")) .. ";" .. tex .. "]"
			.. "button_exit[2.5,3.5;3,1;mob_texture_change;"
			.. minetest.formspec_escape(S("Change")) .. "]")
		end
	end
})

-- Nametag
minetest.register_on_player_receive_fields(function(player, formname, fields)
	-- right-clicked with nametag and name entered?
	if formname == "mobs_texture" and fields.name and fields.name ~= "" then

		local name = player:get_player_name()

		-- does mob still exist?
		if not tex_obj
		or not tex_obj:get_luaentity() then
			return
		end

		-- make sure nametag is being used to name mob
		local item = player:get_wielded_item()

		if item:get_name() ~= "mobs:mob_reset_stick" then
			return
		end

		-- limit name entered to 64 characters long
		if string.len(fields.name) > 64 then
			fields.name = string.sub(fields.name, 1, 64)
		end

		-- update texture
		local self = tex_obj:get_luaentity()

		self.base_texture = {fields.name}

		tex_obj:set_properties({textures = {fields.name}})

		-- reset external variable
		tex_obj = nil
	end
end)

-- raw rabbit
minetest.register_craftitem("mobs:rabbit_raw", {
	description = S("Raw Rabbit"),
	inventory_image = "mobs_rabbit_raw.png",
	on_use = minetest.item_eat(10),
	groups = {food_meat_raw = 1, food_rabbit_raw = 1, flammable = 2},
})

-- cooked rabbit
minetest.register_craftitem("mobs:rabbit_cooked", {
	description = S("Cooked Rabbit"),
	inventory_image = "mobs_rabbit_cooked.png",
	on_use = minetest.item_eat(20),
	groups = {food_meat = 1, food_rabbit = 1, flammable = 2},
})

minetest.register_craft({
	type = "cooking",
	output = "mobs:rabbit_cooked",
	recipe = "mobs:rabbit_raw",
	cooktime = 5,
})

-- rabbit hide
minetest.register_craftitem("mobs:rabbit_hide", {
	description = S("Rabbit Hide"),
	inventory_image = "mobs_rabbit_hide.png",
	groups = {flammable = 2},
})

minetest.register_craft({
	type = "fuel",
	recipe = "mobs:rabbit_hide",
	burntime = 2,
})

minetest.register_craft({
	output = "mobs:leather",
	type = "shapeless",
	recipe = {
		"mobs:rabbit_hide", "mobs:rabbit_hide",
		"mobs:rabbit_hide", "mobs:rabbit_hide"
	}
})

-- cooked rat, yummy!
minetest.register_craftitem("mobs:rat_cooked", {
	description = S("Cooked Rat"),
	inventory_image = "mobs_cooked_rat.png",
	on_use = minetest.item_eat(10),
	groups = {food_rat = 1, flammable = 2},
})

minetest.register_craft({
	type = "cooking",
	output = "mobs:rat_cooked",
	recipe = "mobs:rat",
	cooktime = 5,
})

-- fried egg
minetest.register_craftitem("mobs:chicken_egg_fried", {
	description = S("Fried Egg"),
	inventory_image = "mobs_chicken_egg_fried.png",
	on_use = minetest.item_eat(10),
	groups = {food_egg_fried = 1, flammable = 2},
})

minetest.register_craft({
	type  =  "cooking",
	recipe  = "mobs:egg",
	output = "mobs:chicken_egg_fried",
})

-- raw chicken
minetest.register_craftitem("mobs:chicken_raw", {
	description = S("Raw Chicken"),
	inventory_image = "mobs_chicken_raw.png",
	on_use = minetest.item_eat(-10),
	groups = {food_meat_raw = 1, food_chicken_raw = 1, flammable = 2},
})

-- cooked chicken
minetest.register_craftitem("mobs:chicken_cooked", {
	description = S("Cooked Chicken"),
	inventory_image = "mobs_chicken_cooked.png",
	on_use = minetest.item_eat(20),
	groups = {food_meat = 1, food_chicken = 1, flammable = 2},
})

minetest.register_craft({
	type  =  "cooking",
	recipe  = "mobs:chicken_raw",
	output = "mobs:chicken_cooked",
})

-- feather
minetest.register_craftitem("mobs:chicken_feather", {
	description = S("Feather"),
	inventory_image = "mobs_chicken_feather.png",
	groups = {flammable = 2},
})

minetest.register_craft({
	type = "fuel",
	recipe = "mobs:chicken_feather",
	burntime = 1,
})

-- lava orb
minetest.register_craftitem("mobs:lava_orb", {
	description = S("Lava orb"),
	inventory_image = "zmobs_lava_orb.png",
})

minetest.register_craft({
	type = "fuel",
	recipe = "mobs:lava_orb",
	burntime = 80,
})

-- honey block & compat.
minetest.register_alias("mobs:honey", "xdecor:honey")
minetest.register_alias("mobs:beehive", "xdecor:hive")

minetest.register_node("mobs:honey_block", {
	description = S("Honey Block"),
	tiles = {"mobs_honey_block.png"},
	groups = {snappy = 3, flammable = 2},
	sounds = default.node_sound_dirt_defaults(),
})

minetest.register_craft({
	output = "mobs:honey_block",
	recipe = {
		{"xdecor:honey", "xdecor:honey", "xdecor:honey"},
		{"xdecor:honey", "xdecor:honey", "xdecor:honey"},
		{"xdecor:honey", "xdecor:honey", "xdecor:honey"},
	}
})

minetest.register_craft({
	output = "xdecor:honey 9",
	recipe = {
		{"mobs:honey_block"},
	}
})

-- raw mutton
minetest.register_craftitem("mobs:mutton_raw", {
	description = S("Raw Mutton"),
	inventory_image = "mobs_mutton_raw.png",
	on_use = minetest.item_eat(10),
	groups = {food_meat_raw = 1, food_mutton_raw = 1, flammable = 2},
})

-- cooked mutton
minetest.register_craftitem("mobs:mutton_cooked", {
	description = S("Cooked Mutton"),
	inventory_image = "mobs_mutton_cooked.png",
	on_use = minetest.item_eat(34),
	groups = {food_meat = 1, food_mutton = 1, flammable = 2},
})

minetest.register_craft({
	type = "cooking",
	output = "mobs:mutton_cooked",
	recipe = "mobs:mutton_raw",
	cooktime = 5,
})

-- raw porkchop
minetest.register_craftitem("mobs:pork_raw", {
	description = S("Raw Porkchop"),
	inventory_image = "mobs_pork_raw.png",
	on_use = minetest.item_eat(10),
	groups = {food_meat_raw = 1, food_pork_raw = 1, flammable = 2},
})

-- cooked porkchop
minetest.register_craftitem("mobs:pork_cooked", {
	description = S("Cooked Porkchop"),
	inventory_image = "mobs_pork_cooked.png",
	on_use = minetest.item_eat(34),
	groups = {food_meat = 1, food_pork = 1, flammable = 2},
})

minetest.register_craft({
	type = "cooking",
	output = "mobs:pork_cooked",
	recipe = "mobs:pork_raw",
	cooktime = 5,
})

-- bucket of milk
minetest.register_craftitem("mobs:bucket_milk", {
	description = S("Bucket of Milk"),
	inventory_image = "mobs_bucket_milk.png",
	stack_max = 1,
	on_use = minetest.item_eat(10, "bucket:bucket_empty"),
	groups = {food_milk = 1, flammable = 3},
})

-- glass of milk
minetest.register_craftitem("mobs:glass_milk", {
	description = S("Glass of Milk"),
	inventory_image = "mobs_glass_milk.png",
	on_use = minetest.item_eat(5, "vessels:drinking_glass"),
	groups = {food_milk_glass = 1, flammable = 3, vessel = 1},
})

minetest.register_craft({
	type = "shapeless",
	output = "mobs:glass_milk 4",
	recipe = {
		"vessels:drinking_glass", "vessels:drinking_glass",
		"vessels:drinking_glass", "vessels:drinking_glass",
		"mobs:bucket_milk"
	},
	replacements = { {"mobs:bucket_milk", "bucket:bucket_empty"} }
})

minetest.register_craft({
	type = "shapeless",
	output = "mobs:bucket_milk",
	recipe = {
		"mobs:glass_milk", "mobs:glass_milk",
		"mobs:glass_milk", "mobs:glass_milk",
		"bucket:bucket_empty"
	},
	replacements = { {"mobs:glass_milk", "vessels:drinking_glass 4"} }
})


-- butter
minetest.register_craftitem("mobs:butter", {
	description = S("Butter"),
	inventory_image = "mobs_butter.png",
	on_use = minetest.item_eat(2),
	groups = {food_butter = 1, flammable = 2},
})

minetest.register_craft({
	type = "shapeless",
	output = "mobs:butter",
	recipe = {"mobs:bucket_milk", "default:sapling"},
	replacements = {{ "mobs:bucket_milk", "bucket:bucket_empty"}}
})

-- cheese wedge
minetest.register_craftitem("mobs:cheese", {
	description = S("Cheese"),
	inventory_image = "mobs_cheese.png",
	on_use = minetest.item_eat(10),
	groups = {food_cheese = 1, flammable = 2},
})

minetest.register_craft({
	type = "cooking",
	output = "mobs:cheese",
	recipe = "mobs:bucket_milk",
	cooktime = 5,
	replacements = {{ "mobs:bucket_milk", "bucket:bucket_empty"}}
})

-- cheese block
minetest.register_node("mobs:cheeseblock", {
	description = S("Cheese Block"),
	tiles = {"mobs_cheeseblock.png"},
	is_ground_content = false,
	groups = {crumbly = 3},
	sounds = default.node_sound_dirt_defaults()
})

minetest.register_craft({
	output = "mobs:cheeseblock",
	recipe = {
		{"mobs:cheese", "mobs:cheese", "mobs:cheese"},
		{"mobs:cheese", "mobs:cheese", "mobs:cheese"},
		{"mobs:cheese", "mobs:cheese", "mobs:cheese"},
	}
})

minetest.register_craft({
	output = "mobs:cheese 9",
	recipe = {
		{"mobs:cheeseblock"},
	}
})
