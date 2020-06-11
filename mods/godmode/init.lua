local regen = {}
local cooldown = {}

local function regenerate(player)
	local hp = player:get_hp()
	local name = player:get_player_name()
	local stam = stamina.get_stamina(name, true)
	local sat = stamina.get_satiation(name)
	if hp < 100 and hp > 0 and
			stam and stam >= 75 and
			sat and sat >= 75 then
		if cooldown[name] and cooldown[name] > 0 then
			cooldown[name] = cooldown[name] - 1
		else
			cooldown[name] = nil
			player:set_hp(hp + 2)
		end
	elseif hp < 100 and hp > 0 and
			minetest.check_player_privs(name, "godmode") then
		cooldown[name] = nil
		player:set_hp(100)
	end
	minetest.after(0.5, regenerate, player)
end

minetest.register_privilege("godmode", {
	description = "Invulnerability",
	give_to_singleplayer = false,
	give_to_admin = false,
})

minetest.register_on_joinplayer(function(player)
	player:set_properties({hp_max = 100, breath_max = 100})
	player:set_breath(100)
end)

minetest.register_on_player_hpchange(function(player, hp_change, reason)
	if hp_change > 0 then
		return
	end
	local name = player:get_player_name()
	if minetest.check_player_privs(name, "godmode") then
		return
	end
	cooldown[name] = 11
end)

minetest.register_on_joinplayer(function(player)
	regen[player:get_player_name()] = true
	regenerate(player)
end)

minetest.register_on_leaveplayer(function(player)
	regen[player:get_player_name()] = nil
end)
