minetest.register_abm({
	nodenames = {"group:melty"},
	neighbors = {"group:igniter", "group:lava"},
	interval = 60,
	chance = 50,
	catch_up = true,
	action = function(pos, node)
		minetest.set_node(pos, {name = "default:water_source"})
	end,
})
