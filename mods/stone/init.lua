-- Compressed cobble & stone tile
local c = function()
	local n = minetest.registered_nodes["default:cobble"]
	local o = {}
	for k, v in pairs(n) do
		o[k] = v
	end
	return o
end

local n

n = c()
n.description = "Cobblestone Compressed"
n.tiles = {"default_cobble.png^[colorize:black:31"}
n.drop = "stone:cobble_compressed"
n.groups = {cracky = 2}
minetest.register_node("stone:cobble_compressed", n)

n = c()
n.description = "Cobblestone Compressed Doubly"
n.tiles = {"default_cobble.png^[colorize:black:63"}
n.drop = "stone:cobble_compressed_doubly"
n.groups = {cracky = 2}
minetest.register_node("stone:cobble_compressed_doubly", n)

n = c()
n.description = "Cobblestone Compressed Triply"
n.tiles = {"default_cobble.png^[colorize:black:96"}
n.drop = "stone:cobble_compressed_triply"
n.groups = {cracky = 1}
minetest.register_node("stone:cobble_compressed_triply", n)

n = c()
n.description = "Cobblestone Compressed Quadruply"
n.tiles = {"default_cobble.png^[colorize:black:127"}
n.drop = "stone:cobble_compressed_quadruply"
n.groups = {cracky = 1}
minetest.register_node("stone:cobble_compressed_quadruply", n)

n = c()
n.description = "Cobblestone Compressed Quintuply"
n.tiles = {"default_cobble.png^[colorize:black:151"}
n.drop = "stone:cobble_compressed_quintuply"
n.groups = {cracky = 1}
minetest.register_node("stone:cobble_compressed_quintuply", n)

minetest.register_craft({
	output = "stone:cobble_compressed",
	recipe = {
		{"default:cobble", "default:cobble", "default:cobble"},
		{"default:cobble", "default:cobble", "default:cobble"},
		{"default:cobble", "default:cobble", "default:cobble"},
	}
})

minetest.register_craft({
	output = "stone:cobble_compressed_doubly",
	recipe = {
		{"stone:cobble_compressed", "stone:cobble_compressed", "stone:cobble_compressed"},
		{"stone:cobble_compressed", "stone:cobble_compressed", "stone:cobble_compressed"},
		{"stone:cobble_compressed", "stone:cobble_compressed", "stone:cobble_compressed"},
	}
})

minetest.register_craft({
	output = "stone:cobble_compressed_triply",
	recipe = {
		{"stone:cobble_compressed_doubly", "stone:cobble_compressed_doubly", "stone:cobble_compressed_doubly"},
		{"stone:cobble_compressed_doubly", "stone:cobble_compressed_doubly", "stone:cobble_compressed_doubly"},
		{"stone:cobble_compressed_doubly", "stone:cobble_compressed_doubly", "stone:cobble_compressed_doubly"},
	}
})

minetest.register_craft({
	output = "stone:cobble_compressed_quadruply",
	recipe = {
		{"stone:cobble_compressed_triply", "stone:cobble_compressed_triply", "stone:cobble_compressed_triply"},
		{"stone:cobble_compressed_triply", "stone:cobble_compressed_triply", "stone:cobble_compressed_triply"},
		{"stone:cobble_compressed_triply", "stone:cobble_compressed_triply", "stone:cobble_compressed_triply"},
	}
})

minetest.register_craft({
	output = "stone:cobble_compressed_quintuply",
	recipe = {
		{"stone:cobble_compressed_quadruply", "stone:cobble_compressed_quadruply", "stone:cobble_compressed_quadruply"},
		{"stone:cobble_compressed_quadruply", "stone:cobble_compressed_quadruply", "stone:cobble_compressed_quadruply"},
		{"stone:cobble_compressed_quadruply", "stone:cobble_compressed_quadruply", "stone:cobble_compressed_quadruply"},
	}
})

minetest.register_craft({
	output = "default:cobble 9",
	recipe = {{"stone:cobble_compressed"}}
})

minetest.register_craft({
	output = "stone:cobble_compressed 9",
	recipe = {{"stone:cobble_compressed_doubly"}}
})

minetest.register_craft({
	output = "stone:cobble_compressed_doubly 9",
	recipe = {{"stone:cobble_compressed_triply"}}
})

minetest.register_craft({
	output = "stone:cobble_compressed_triply 9",
	recipe = {{"stone:cobble_compressed_quadruply"}}
})

minetest.register_craft({
	output = "stone:cobble_compressed_quadruply 9",
	recipe = {{"stone:cobble_compressed_quintuply"}}
})
