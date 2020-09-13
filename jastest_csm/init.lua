-- JASTEST CSM
-- Copyright 2020 James Stevenson
-- GNU GPL 3+

-- jump
local del = minetest.get_us_time()
local touching = false
local in_water = false
local jumping = false
local jumping_ack
local floor = math.floor
local insert = table.insert
local a = minetest.after
local sp = minetest.sound_play

-- sprint
local sprinting = false
local sprinting_ack

-- map
local automap = false
local minimap_ack
local level = 2
local map = minetest.ui.minimap
local radar = false

-- funcs
local function jump(player)
	player = player or minetest.localplayer
	if player then
		local j = player:get_control().jump
		touching = player:is_touching_ground()
		in_water = player:is_in_liquid()

		local m = minetest.mod_channel_join(player:get_name())
		if not ack then
			m:send_all("jump_enable")
		end
		if j and not touching and not jumping and
				not in_water and
				minetest.get_us_time() - del > 334000 then
			jumping = true
			del = minetest.get_us_time()
			if ack == "disabled" then
				sp({name = "jump_jump", gain = 0.2, pitch = 1.05})
			else
				m:send_all("jump")
			end
		elseif touching then
			jumping = false
		elseif minetest.get_us_time() - del > 334000 then
			local p = player:get_pos()
			p.y = p.y - 1
			local n = minetest.get_node_or_nil(p)
			if n and n.name == "air" then
				jumping = true
			else
				jumping = false
				del = minetest.get_us_time()
			end
		end
	end

	a(0, function()
		jump(player)
	end)
end

local function sprint(player)
	player = player or minetest.localplayer
	if player then
		local m = minetest.mod_channel_join(player:get_name())
		if sprinting_ack == "enabled" then
			local keys = player:get_control()
			if keys.aux1 and not sprinting then
				sprinting = true
				m:send_all("aux1")
			elseif sprinting and not keys.aux1 then
				sprinting = false
				m:send_all("aux0")
			end
		elseif not sprinting_ack then
			m:send_all("sprint_enable")
		end
	end
	a(0, function()
		sprint(player)
	end)
end

local function minimap(player)
	player = player or minetest.localplayer
	if player then
		local m = minetest.mod_channel_join(player:get_name())
		if minimap_ack == "enabled" then
		elseif not minimap_ack then
			m:send_all("minimap_enable")
		end
		if player:get_pos().y < -25 and not radar then
			radar = true
			level = level + 3
			--[[
			if map then
				map:show()
				map:set_mode(level)
			end
			--]]
		elseif radar and player:get_pos().y >= -25 then
			radar = false
			level = level - 3
			--[[
			if map then
				map:show()
				map:set_mode(level)
			end
			--]]
		end
		local walkie = player:get_wielded_item():get_name() == "walkie:talkie"
		if minimap_ack and walkie and map and not automap then
			map:show()
			map:set_mode(level)
			automap = true
		elseif not walkie and map and automap then
			map:hide()
			automap = false
		else
			map = minetest.ui.minimap
		end
	end
	a(0, function()
		minimap(player)
	end)
end

minetest.register_on_modchannel_message(function(channel_name, sender, message)
	if sender == "" then
		if message == "minimap_ack" then
			minimap_ack = "enabled"
		elseif message == "sprint_ack" then
			sprinting_ack = "enabled"
		elseif message == "jump_ack" then
			jumping_ack = "enabled"
		end
	end
end)

-- commands
minetest.register_chatcommand("map", {
	params = "<level>",
	description = "Set minimap zoom level",
	func = function(param)
		param = tonumber(param)
		if param then
			if param < 1 or param > 3 then
				return false, "[Client] A level between 1 and 3"
			end
			level = param
			return true, "Level set to " .. param
		end
	end,
})

minetest.register_chatcommand("sprint", {
	description = "Enable or disable client-side sprint polling",
	params = "<enable|disable>",
	func = function(param)
		local player = minetest.localplayer
		local name = player:get_name()
		local m = minetest.mod_channel_join(name)
		if param == "enable" then
			m:send_all("sprint_enable")
			return true, "[CSM] Sprint enabled"
		elseif param == "disable" then
			sprinting_ack = "disabled"
			m:send_all("sprint_disable")
			return true, "[CSM] Sprint disabled"
		end
		return false, "[CSM] enable or disable"
	end,
})

-- startup
sprint()
minimap()
jump()
