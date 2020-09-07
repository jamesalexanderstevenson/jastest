minetest.register_abm({
	nodenames = {"group:melty"},
	neighbors = {"group:igniter", "group:lava"},
	interval = 2,
	chance = 2,
	catch_up = false,
	action = function(pos, node)
		minetest.set_node(pos, {name = "default:water_source"})
	end,
})
