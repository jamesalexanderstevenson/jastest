mtd = {}

local players = {}
local bank = {}
local store = minetest.get_mod_storage()

local function save()
	store:set_string("players", minetest.serialize(players))
	store:set_string("bank", minetest.serialize(bank))
end

local preplayers = store:get_string("players")
if preplayers ~= "" then
	players = minetest.deserialize(preplayers)
end

local prebank = store:get_string("bank")
if prebank ~= "" then
	bank = minetest.deserialize(prebank)
end

minetest.register_privilege("mtd", {
	description = "Can manage MTD",
	give_to_singleplayer = false,
	give_to_admin = false,
})

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	if players[name] and not bank[name] then
		bank[name] = {opening_balance = 100}
		save()
	end
end)

minetest.register_craftitem("mtd:gold_coin", {
	description = "Gold coin",
	inventory_image = "mtd_gold_coin.png",
})

minetest.register_craft({
	output = "mtd:gold_coin 9",
	type = "shapeless",
	recipe = {"default:gold_ingot"},
})

minetest.register_chatcommand("deposit", {
	description = "Deposit money",
	privs = "mtd",
	params = "",--value",
	func = function(name, param)
		if not players[name] then
			return false, "Please use /register first"
		end
		local player = minetest.get_player_by_name(name)
		local inv = player:get_inventory()
		local amount = 1
		local has_coin = inv:contains_item("main", "mtd:gold_coin " .. amount)
	end,
})

minetest.register_chatcommand("cashout", {
	description = "Cash out",
	params = "",--"[value]",
	privs = "mtd",
	func = function(name, param)
		if not players[name] then
			return false, "Please use /register first"
		end
		if bank[name] then
			if bank[name].opening_balance > 0 then
				local player = minetest.get_player_by_name(name)
				player:get_inventory():add_item("main", "mtd:gold_coin")
				bank[name].opening_balance = bank[name].opening_balance - 1
				save()
				return true, bank[name].opening_balance
			end
		end
	end,
})

minetest.register_chatcommand("register", {
	description = "Register on server",
	params = "[email/contact]",
	privs = "shout",
	func = function(name, param)
		if not players[name] then
			players[name] = {}
			save()
		end
	end,
})
