-- /mods/protect is part of jastest
-- copyright 2020 james alexander stevenson
-- gnu gpl 3+

-- -600 for y due to caverealms beginning around -700
local protect_min = minetest.setting_get_pos("protect_min") or {x = -6000, y = -600, z = -6000}
local protect_max = minetest.setting_get_pos("protect_max") or {x = 6000, y = 6000, z = 6000}
local protect_spawn = minetest.settings:get_bool("protect_spawn", false)
local store = AreaStore()
local data = "base"

if protect_spawn then
	store:insert_area(protect_min, protect_max, data, 1)

	minetest.register_privilege("protector", {
		description = "Can modify the core",
		give_to_singleplayer = true,
		give_to_admin = true,
	})

	local old_is_protected = minetest.is_protected
	function minetest.is_protected(pos, name)
		local ars = store:get_areas_for_pos(pos)
		if #ars == 0 then
			--print("Everything is open")
		elseif not minetest.check_player_privs(name, "protector") then
			--print("We are restricted")
			return true
		end
		return old_is_protected(pos, name)
	end

	minetest.register_on_protection_violation(function(pos, name)
		hud.message(name, "Cannot interact here")
	end)
end

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

if minetest.settings:get("pvp_protect_spawn") then
	minetest.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
		if hitter:is_player() then
			return funkyfunc(player:get_pos(), player:get_player_name())
		end
	end)
end
