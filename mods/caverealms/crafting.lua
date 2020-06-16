--CaveRealms crafting.lua

--CRAFT ITEMS--

--mycena powder
minetest.register_craftitem("caverealms:mycena_powder", {
	description = "Mycena Powder",
	inventory_image = "caverealms_mycena_powder.png",
	on_use = minetest.item_eat(1),
})

--CRAFT RECIPES--

--mycena powder
minetest.register_craft({
	output = "caverealms:mycena_powder",
	type = "shapeless",
	recipe = {"caverealms:mycena"}
})


--glow mese block
minetest.register_craft({
	output = "caverealms:glow_mese",
	recipe = {
		{"default:mese_crystal_fragment","default:mese_crystal_fragment","default:mese_crystal_fragment"},
		{"default:mese_crystal_fragment","caverealms:mycena_powder","default:mese_crystal_fragment"},
		{"default:mese_crystal_fragment","default:mese_crystal_fragment","default:mese_crystal_fragment"}
	}
})

--reverse craft for glow mese
minetest.register_craft({
	output = "default:mese_crystal_fragment 8",
	type = "shapeless",
	recipe = {"caverealms:glow_mese"}
})

--use for coal dust
minetest.register_craft({
	output = "default:coalblock",
	recipe = {
		{"caverealms:coal_dust","caverealms:coal_dust","caverealms:coal_dust"},
		{"caverealms:coal_dust","caverealms:coal_dust","caverealms:coal_dust"},
		{"caverealms:coal_dust","caverealms:coal_dust","caverealms:coal_dust"}
	}
})

minetest.register_craft({
	output = "bucket:bucket_river_water",
	type = "shapeless",
	recipe = {"bucket:bucket_empty", "caverealms:thin_ice"}
})

minetest.register_craft({
	output = "bucket:bucket_river_water",
	type = "shapeless",
	recipe = {"bucket:bucket_empty", "default:ice"}
})
