ctf = {}
ctf.players = {}

-- nodebox flag, red and blue
-- one flag depends on the other
-- flag dug, its base pos is remembered
-- after 30s flag is returned or
-- flag is placed at its partner flag's base pos
-- round is won, flag is returned

local function flag_take(pos, node, digger, color)
	print("Picked up the " .. color .. " flag")
	local ist = ItemStack({name = "ctf:flag_" .. color})
	local mist = ist:get_meta()
	mist:set_string("pos", minetest.pos_to_string(pos))
	minetest.set_node(pos, {name = "air"})
	digger:get_inventory():add_item("main", ist)
end

local function flag_take_red(pos, node, digger)
	local team = ctf.players[digger:get_player_name()]
	if team and team == "blue" then
		flag_take(pos, node, digger, "red")
	end
end

local function flag_take_blue(pos, node, digger)
	local team = ctf.players[digger:get_player_name()]
	if team and team == "red" then
		flag_take(pos, node, digger, "blue")
	end
end

local function return_flag(color)
	if color == "blue" then
		minetest.chat_send_all("Red wins!")
	else
		minetest.chat_send_all("Red wins!")
	end
end

local function return_flag_red(m)
	local p = m.fields.pos
	local pos
	if p then
		pos = minetest.string_to_pos(p)
		minetest.set_node(pos, {name = "ctf:flag_red"})
	end
	return_flag("red")
end

local function return_flag_blue(m)
	local p = m.fields.pos
	local pos
	if p then
		pos = minetest.string_to_pos(p)
		minetest.set_node(pos, {name = "ctf:flag_blue"})
	end
	return_flag("blue")
end

local function flag_cap(pos, node, clicker, itemstack, pointed_thing, color)
	print("base: " .. color)
	local f = itemstack:get_name()
	local m = itemstack:get_meta():to_table()
	if color == "red" and f == "ctf:flag_blue" then
		print("red wins")
		minetest.after(0, return_flag_blue, m)
		itemstack:clear()
		return itemstack
	elseif color == "blue" and f == "ctf:flag_red" then
		print("blue wins")
		minetest.after(0, return_flag_red, m)
		itemstack:clear()
		return itemstack
	end
	print("flag: " .. f)
end

local function flag_cap_red(pos, node, clicker, itemstack, pointed_thing)
	flag_cap(pos, node, clicker, itemstack, pointed_thing, "red")
end

local function flag_cap_blue(pos, node, clicker, itemstack, pointed_thing)
	flag_cap(pos, node, clicker, itemstack, pointed_thing, "blue")
end

minetest.register_privilege("gamemaster", {
	description = "Can administer games",
	give_to_singleplayer = false,
	give_to_admin = false,
})

minetest.register_node("ctf:flag_red", {
	description = "Red Flag",
	tiles = {"default_stone.png^[colorize:red:255"},
	groups = {dig_immediate = 3, not_in_creative_inventory = 1},
	stack_max = 1,
	walkable = false,
	on_dig = flag_take_red,
	on_rightclick = flag_cap_red,
	on_place = function() end,
})

minetest.register_node("ctf:flag_blue", {
	description = "Blue Flag",
	tiles = {"default_stone.png^[colorize:blue:255"},
	groups = {dig_immediate = 3, not_in_creative_inventory = 1},
	stack_max = 1,
	walkable = false,
	on_dig = flag_take_blue,
	on_rightclick = flag_cap_blue,
	on_place = function() end,
})

minetest.register_chatcommand("team", {
	func = function(name, param)
		if param == "red" then
			ctf.players[name] = param
			return true, "[Server] You have joined the red team"
		elseif param == "blue" then
			ctf.players[name] = param
			return true, "[Server] You have joined the blue team"
		elseif param == "leave" or param == "nil" and
				ctf.players[name] then
			ctf.players[name] = nil
			return true, "[Server] No longer a member of either team"
		elseif ctf.players[name] then
			return true, "[Server] You are a member of the " ..
					ctf.players[name] .. " team"
		else
			return true, "[Server] Type /team blue or /team red"
		end
	end,
})

minetest.register_on_leaveplayer(function(player)
	ctf.players[player:get_player_name()] = nil
end)
