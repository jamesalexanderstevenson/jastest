minetest.register_chatcommand("rules", {
	description = "Show server rules",
	params = "[list|add|remove]",
	privs = "shout",
	func = function(name)
		return true, "You get what you concentrate on\nThere is no other main rule"
	end,
})
