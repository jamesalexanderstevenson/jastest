minetest.register_abm({
	nodenames = {"group:melty"},
	neighbors = {"group:igniter", "group:lava"},
	interval = 5,
	chance = 5,
	catch_up = false,
	action = function(pos, node)
		minetest.set_node(pos, {name = "default:water_source"})
	end,
})
