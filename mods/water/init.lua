minetest.register_abm({
	nodenames = {"group:melty"},
	neighbors = {"group:igniter", "group:lava"},
	interval = 10,
	chance = 100,
	catch_up = true,
	action = function(pos, node)
		minetest.set_node(pos, {name = "default:water_source"})
	end,
})
