-- /mods/protect is part of jastest
-- copyright 2020 james alexander stevenson
-- gnu gpl 3+

-- should check setting later
if not minetest.settings:get("protect_spawn") or
		minetest.settings:get_bool("protect_spawn") == false then
	return
end

local store = AreaStore()
-- -600 for y due to caverealms beginning around -700
local e1 = {x = -6000, y = -600, z = -6000}
local e2 = {x = 6000, y = 6000, z = 6000}
local data = "base"
-- Should check protect_spawn setting here, instead, and only insert
-- if true, then TODO above numbers configurable.
store:insert_area(e1, e2, data, 1)

minetest.register_privilege("protector", {
	description = "Can modify the core",
	give_to_singleplayer = true,
	give_to_admin = true,
})

-- When not protect_spawn, currently, this function doesn't
-- check for godmode and separate functionality is lost.
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

minetest.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
	if hitter:is_player() then
		return funkyfunc(player:get_pos(), player:get_player_name())
	end
end)
