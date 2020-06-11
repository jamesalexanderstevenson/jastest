local store = AreaStore()
-- -600 for y due to caverealms beginning around -700
local e1 = {x = -6000, y = -600, z = -6000}
local e2 = {x = 6000, y = 6000, z = 6000}
local data = "base"
store:insert_area(e1, e2, data, 1)

local named_player = minetest.settings:get("name")
local named_players = {
	named_player,
	"khloe_the_hamster",
}

local fu = function(name, granter_name)
	local named = false
	for i = 1, #named_players do
		if name == named_players[i] then
			named = true
		end
	end
	if not named then
		local privs = minetest.get_player_privs(name)
		privs.protector = nil
		minetest.set_player_privs(name, privs)
	end
end

minetest.register_privilege("protector", {
	description = "Can modify the core",
	give_to_singleplayer = false,
	give_to_admin = false,
	on_grant = function(name, granter_name)
		minetest.after(0, function()
			fu(name, granter_name)
		end)
	end,
})

local funkyfunc = function(pos, name)
	local ars = store:get_areas_for_pos(pos)
	if #ars == 0 then
		if minetest.check_player_privs(name, "godmode") then
			return true
		end
	else
		return true
	end
end

local old_is_protected = minetest.is_protected
function minetest.is_protected(pos, name)
	local ars = store:get_areas_for_pos(pos)
	if #ars == 0 then
		--print("Everything is open.")
	elseif not minetest.check_player_privs(name, "protector") then
		--print("We are restricted!")
		return true
	end
	return old_is_protected(pos, name)
end

minetest.register_on_protection_violation(function(pos, name)
	--minetest.chat_send_player(name, "Cannot interact here.")
	hud.message(name, "Cannot interact here.")
end)

minetest.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
	if hitter:is_player() then
		return funkyfunc(player:get_pos(), player:get_player_name())
	end
end)

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	local privs = minetest.get_player_privs(name)
	if name ~= named_player then
		privs.protector = nil
	else
		privs.protector = true
	end
	minetest.set_player_privs(name, privs)
end)
