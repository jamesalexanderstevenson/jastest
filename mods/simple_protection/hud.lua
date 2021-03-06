--[[
File: hud.lua

areas HUD overlap compatibility
HUD display and refreshing
]]


local S = s_protect.translator

s_protect.player_huds = {}

local hud_time = 0
local prefix = ""
local align_x = 1
local pos_x = 0.02

-- If areas is installed: Move the HUD to th opposite side
if minetest.get_modpath("areas") then
	prefix = "Simple Protection:\n"
	align_x = -1
	pos_x = 0.95
end

local function generate_hud(player, current_owner)
	s_protect.player_huds[player:get_player_name()] = {
		hud_id = player:hud_add({
			hud_elem_type = "text",
			name          = "Simple Protection",
			number        = 0xFFFFFF,
			position      = {x=0, y=1},
			offset = {x = 8, y = -8},
			text          = S("Claimed: @1", current_owner),
			scale         = {x=200, y=60},
			alignment     = {x=1, y=-1},
		}),
		owner = current_owner,
		had_access = has_access
	}
end

minetest.register_globalstep(function(dtime)
	hud_time = hud_time + dtime
	if hud_time < 0.5 then
		return
	end
	hud_time = 0

	local is_shared = s_protect.is_shared
	for _, player in ipairs(minetest.get_connected_players()) do
		local walkie = player:get_wielded_item():get_name() == "walkie:talkie"
		local player_name = player:get_player_name()
		local hud_table = s_protect.player_huds[player_name]
		if walkie then

			local current_owner = ""
			local data = s_protect.get_claim(player:get_pos())
			if data then
				current_owner = data.owner
			end

			local has_access = (current_owner == player_name)
			if not has_access and data then
				-- Check if this area is shared with this player
				has_access = is_shared(data, player_name)
			end
			if not has_access then
				-- Check if all areas are shared with this player
				has_access = is_shared(current_owner, player_name)
			end
			local changed = true

			if hud_table and hud_table.owner == current_owner
					and hud_table.had_access == has_access then
				-- still the same hud
				changed = false
			end

			if changed and hud_table then
				player:hud_remove(hud_table.hud_id)
				s_protect.player_huds[player_name] = nil
			end

			if changed and current_owner ~= "" then
				generate_hud(player, current_owner, has_access)
			end
		elseif hud_table and hud_table.hud_id then
			player:hud_remove(hud_table.hud_id)
			s_protect.player_huds[player_name].hud_id = nil
		end
	end
end)
