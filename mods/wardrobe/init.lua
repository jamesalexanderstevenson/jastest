wardrobe = {}
wardrobe.players = {}

minetest.register_on_leaveplayer(function(player)
	wardrobe.players[player:get_player_name()] = nil
end)

minetest.register_alias("wardrobe", "wardrobe:wardrobe")

minetest.register_node("wardrobe:wardrobe", {
	description = "Wardrobe",
	tiles = {"default_wood.png", "default_wood.png", "default_wood.png",
			"default_wood.png", "wardrobe_wardrobe.png"},
	groups = {choppy = 3, oddly_breakable_by_hand = 2}, --furniture is 2?
	paramtype2 = "facedir",
	sounds = default.node_sound_wood_defaults(),
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		--TODO favorite
		local name = clicker:get_player_name()
		wardrobe.players[name] = pos
		skins.show(name, true)
	end,
	on_use = function(itemstack, user, pointed_thing)
		skins.show(user:get_player_name(), true)
	end,
})

minetest.register_chatcommand("wardrobe", {
	description = "Show Wardrobe",
	params = "",
	privs = "interact",
	func = function(name)
		skins.show(name, true)
		return true, "[Server] Showing Wardrobe"
	end,
})

minetest.register_craft({
	output = "wardrobe:wardrobe",
	recipe = {
		{"group:wood", "group:wood", "group:wood"},
		{"group:wool", "group:wool", "group:wool"},
		{"group:wood", "group:wood", "group:wood"},
	}
})
