flood = {}

flood.on_flood = function(pos, oldnode, newnode)
	local name = oldnode.name
	local drops = minetest.get_node_drops(name)
	for i = 1, #drops do
		minetest.add_item(pos, drops[i])
	end
end
