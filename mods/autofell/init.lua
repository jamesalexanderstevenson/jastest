-- jastest/mods/autofell
-- Part of jastest Minetest Game
-- Copyright 2020 James Alexander Stevenson
-- GNU GPL 3+

local function chop(pos, oldnode)
	local above_pos = {x = pos.x, y = pos.y + 1, z = pos.z}
	local newnode = minetest.get_node_or_nil(above_pos)
	-- Destroy the node if it's the same as its caller
	if not newnode then
		return
	end
	if newnode.name == oldnode.name and
			--newnode.param1 == oldnode.param1 and
			newnode.param2 == oldnode.param2 then
		ll_items.throw_inventory(above_pos, {newnode.name})
		minetest.set_node(above_pos, {name = "air"})
		minetest.after(0.1, function()
			chop(above_pos, newnode)
		end)
	end
end


local function after_dig_trees(pos, oldnode, oldmetadata, digger)
	if oldnode and --oldnode.param1 and oldnode.param1 == 0 and
			oldnode.param2 and oldnode.param2 == 0 then
		minetest.after(0.1, function()
			chop(pos, oldnode)
		end)
	end
end

local function swap(pointed_thing)
	if not pointed_thing then
		return
	end
	if pointed_thing.type ~= "node" then
		return
	end
	if not pointed_thing.above then
		return
	end
	local n = minetest.get_node_or_nil(pointed_thing.above)
	if not n then
		return
	end
	if n.param2 == 0 then
		minetest.set_node(pointed_thing.above, {name = n.name,
				param1 = n.param1, param2 = 2})
	end
end

local function on_place_trees(itemstack, placer, pointed_thing)
	local t = minetest.rotate_node(itemstack, placer, pointed_thing)
	swap(pointed_thing)
	return t
end

minetest.override_item("default:tree", {
	after_dig_node = after_dig_trees,
	on_place = on_place_trees,
})

minetest.override_item("default:pine_tree", {
	after_dig_node = after_dig_trees,
	on_place = on_place_trees,
})

minetest.override_item("default:jungletree", {
	after_dig_node = after_dig_trees,
	on_place = on_place_trees,
})

minetest.override_item("default:aspen_tree", {
	after_dig_node = after_dig_trees,
	on_place = on_place_trees,
})

minetest.override_item("default:acacia_tree", {
	after_dig_node = after_dig_trees,
	on_place = on_place_trees,
})
