-- /mods/bandage is part of jastest
-- copyright 2020 james alexander stevenson
-- gnu gpl 3+

minetest.register_craftitem("bandage:bandage", {
	description = "Bandage",
	inventory_image = "bandage_bandage.png",
	on_use = function(itemstack, user, pointed_thing)
		local hp = user:get_hp()
		if hp < 100 then
			user:set_hp(hp + 5)
			itemstack:take_item()
		end
		return itemstack
	end
})

minetest.register_craft({
	output = "bandage:bandage",
	type = "shapeless",
	recipe = {"default:paper", "farming:cotton"}
})
