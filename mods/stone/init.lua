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
		{"stone:cobble_compressed_doubly",
				"stone:cobble_compressed_doubly", "stone:cobble_compressed_doubly"},
		{"stone:cobble_compressed_doubly",
				"stone:cobble_compressed_doubly", "stone:cobble_compressed_doubly"},
		{"stone:cobble_compressed_doubly",
				"stone:cobble_compressed_doubly", "stone:cobble_compressed_doubly"},
	}
})

minetest.register_craft({
	output = "stone:cobble_compressed_quadruply",
	recipe = {
		{"stone:cobble_compressed_triply",
				"stone:cobble_compressed_triply", "stone:cobble_compressed_triply"},
		{"stone:cobble_compressed_triply",
				"stone:cobble_compressed_triply", "stone:cobble_compressed_triply"},
		{"stone:cobble_compressed_triply",
				"stone:cobble_compressed_triply", "stone:cobble_compressed_triply"},
	}
})

minetest.register_craft({
	output = "stone:cobble_compressed_quintuply",
	recipe = {
		{"stone:cobble_compressed_quadruply",
				"stone:cobble_compressed_quadruply", "stone:cobble_compressed_quadruply"},
		{"stone:cobble_compressed_quadruply",
				"stone:cobble_compressed_quadruply", "stone:cobble_compressed_quadruply"},
		{"stone:cobble_compressed_quadruply",
				"stone:cobble_compressed_quadruply", "stone:cobble_compressed_quadruply"},
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

minetest.register_craft({
	output = "default:stone_with_coal",
	recipe = {{"default:stone", "default:coal_lump"}}
})

minetest.register_craft({
	output = "default:stone_with_iron",
	recipe = {{"default:stone", "default:iron_lump"}}
})

minetest.register_craft({
	output = "default:stone_with_copper",
	recipe = {{"default:stone", "default:copper_lump"}}
})

minetest.register_craft({
	output = "default:stone_with_tin",
	recipe = {{"default:stone", "default:tin_lump"}}
})

minetest.register_craft({
	output = "default:stone_with_gold",
	recipe = {{"default:stone", "default:gold_lump"}}
})

minetest.register_craft({
	output = "default:stone_with_mese",
	recipe = {{"default:stone", "default:mese_crystal"}}
})

minetest.register_craft({
	output = "default:stone_with_diamond",
	recipe = {{"default:stone", "default:diamond"}}
})

minetest.register_craft({
	output = "oresplus:stone_with_emerald",
	recipe = {{"default:stone", "oresplus:emerald"}}
})

minetest.register_abm({
	label = "Transform cobble",
	nodenames = {"default:cobble"},
	neighbors = {"group:water", "group:lava", "air"},
	interval = 18,
	chance = 80,
	catch_up = false,
	action = function(pos, node)
		local law = minetest.find_node_near(pos, 2, "group:water")
		local la = minetest.find_node_near(pos, 1, "group:lava")
		if la then
			minetest.set_node(pos, {name = "default:stone"})
		elseif law then
			minetest.set_node(pos, {name = "default:mossycobble"})
		end
	end
})
