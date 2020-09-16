local grasses = {"default:grass_1", "default:grass_2", "default:grass_3",
		"default:grass_4", "default:grass_5"}

minetest.register_abm({
	label = "Auto-tree growth",
	nodenames = grasses,
	neighbors = {"group:soil"},
	interval = 51,
	chance = 5,
	catch_up = false,
	action = function(pos)
		if not minetest.get_node({x = pos.x, y = pos.y - 1, z = pos.z}).name:match("dirt") then
			return
		end
		local p1 = {x = pos.x + 2, y = pos.y, z = pos.z + 2}
		local p2 = {x = pos.x - 2, y = pos.y, z = pos.z - 2}
		local g = minetest.find_nodes_in_area(p1, p2, grasses)
		if #g >= 20 then
			if minetest.find_node_near(pos, 9, {"default:sapling", "default:tree"}) then
				return
			end
			minetest.place_node(pos, {name = "default:sapling"})
		end
	end,
})

minetest.register_abm({
	label = "Auto-plant sapling",
	nodenames = {"default:dirt", "default:grass"},
	neighbors = {"air"},
	interval = 30,
	chance = 10,
	catch_up = false,
	action = function(pos, node)
		pos = {x = pos.x, y = pos.y + 1, z = pos.z}
		local un = minetest.get_node(pos)
		if un and un.name then
			if un.name ~= "air" and minetest.registered_nodes[un.name] and
					not minetest.registered_nodes[un.name].buildable_to then
				return
			end
		else
			return
		end
		local o = minetest.get_objects_inside_radius(pos, 1)
		for i = 1, #o do
			local object = o[i]
			local entity = object:get_luaentity()
			if not (entity and entity.age) or entity.dropped_by or
					not (entity.itemstring and
					entity.itemstring == "default:sapling") then
				break
			end
			if entity.age > 3 then
				local p = object:get_pos()
				object:remove()
				minetest.set_node(p, {name = "default:sapling"})
				return
			end
		end
	end,
})
