minetest.register_abm({
	nodenames = {"group:melty"},
	neighbors = {"group:igniter", "group:lava"},
	interval = 30,
	chance = 15,
	catch_up = false,
	action = function(pos, node)
		minetest.set_node(pos, {name = "default:water_source"})
	end,
})
