warpstones = {}
warpstones.warps = {}

local selected = {}
local prepane = {}
local store = minetest.get_mod_storage()
local pane = store:get("pane")
if pane then
	prepane = minetest.deserialize(pane)
	local str = ""
	for k, v in pairs(prepane) do
		str = str .. "\t" .. k .. ": "
		for kk, vv in pairs(v) do
			str = str .. kk .. minetest.pos_to_string(vv) .. "; "
		end
		str = str:sub(1, -3) .. "\n"
	end
	str = str:sub(1, -2)
	print(str)
	warpstones.warps = prepane
end

local function warp_formspec(name, init)
	local s = selected[name]
	local dest, name
	if s then
		local m = minetest.get_meta(s)
		dest = m:get_string("destination")
		name = m:get_string("name")
	end
	if not init then
		return "size[7.76,4.9]" ..
				forms.x ..
				"field[1.15,2.2;5.25,1;warp_dest;Warp destination:;" .. dest .. "]" ..
				"button_exit[6,1.88;1,1;ok;OK]" ..
				"field_close_on_enter[warp_dest;true]"
	else
		return "size[7.76,4.9]" ..
				forms.x ..
				"field[1.15,2.2;5.25,1;warp_name;Warp name:;" .. name .. "]" ..
				"button_exit[6,1.88;1,1;ok;OK]" ..
				"field_close_on_enter[warp_name;true]"
	end
end

local colors = {
	mese = "yellow",
	amethyst = "0x542164CC",
	crystal = "blue",
	ruby = "red",
	emerald = "emerald",
}

local timer
local on_punch = function(pos, node, puncher, pointed_thing)
	local meta = minetest.get_meta(pos)
	if meta and meta:get_string("state") == "" then
		local sid = minetest.sound_play("warpstones_woosh", {
			object = puncher,
		})
		meta:set_string("state", "timeout")
		local dest = meta:get_string("destination")
		local name = meta:get_string("name")
		local owner = meta:get_string("owner")
		local warp = warpstones.warps[owner] and warpstones.warps[owner][dest]
		if not warp then
			for k, v in pairs(warpstones.warps) do
				for kk, vv in pairs(v) do
					if kk == dest then
						warp = vv
					end
				end
			end
		end
		if not warp then
			hud.message(puncher, "This warpstone is not connected")
			meta:set_string("state", "")
			minetest.sound_fade(sid, -1, 0)
			return minetest.sound_play("items_plop",
					{pos = pos}, true)
		end
		local p = puncher:get_pos()
		hud.message(puncher, "Hold still")
		timer = function(p, player, time, meta, sid, warp)
			if not player then
				return
			end
			if vector.equals(p, player:get_pos()) then
				if time >= 4.4 then
					minetest.sound_fade(sid, -1, 0)
					meta:set_string("state", "")
					player:set_pos(warp)
					local swf = table.copy(warp)
					swf.y = swf.y + 2
					minetest.after(1, minetest.sound_play, "items_plop",
							{pos = swf}, true)
					hud.message(player, "Warped to " ..
							meta:get_string("destination"))
					return
				end
				minetest.after(0.334, timer, p,
						player, time + 0.334, meta, sid, warp)
			else
				hud.message(puncher,
						"Stand still for 5 seconds after punching to warp")
				minetest.sound_fade(sid, -0.89, 0)
				meta:set_string("state", "")
				return
			end
		end
		return timer(p, puncher, 0, meta, sid, warp)
	elseif meta:get_string("state") == "timeout" then
		hud.message(puncher, "Waiting for the warpstone to cool down")
	else
		hud.message(puncher, "No destination set")
	end
end

local on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
	local name = clicker:get_player_name()
	selected[name] = pos
	local meta = minetest.get_meta(pos)
	local owner = meta:get_string("owner")
	if name ~= owner then
		forms.dialog(name,
				"Only the owner of this warpstone can set its destination.",
				true, nil, nil, true)
		return itemstack
	end
	if meta:get_string("name") == "" then
		minetest.show_formspec(name, "warpstones:warpstones", warp_formspec(name, true))
	else
		minetest.show_formspec(name, "warpstones:warpstones", warp_formspec(name))
	end
	return itemstack
end

local on_construct = function(pos)
	local meta = minetest.get_meta(pos)
	meta:set_string("owner", "")
	meta:set_string("name", "")
	meta:set_string("infotext", "Unnamed Warpstone")
end

local after_place_node = function(pos, placer, itemstack, pointed_thing)
	local meta = minetest.get_meta(pos)
	local name = placer:get_player_name()
	if not name or not meta then
		return
	end
	meta:set_string("owner", name)
end

local after_dig_node = function(pos, oldname, oldmetadata, digger)
	local name = digger:get_player_name()
	if oldmetadata and oldmetadata.fields then
		local f = oldmetadata.fields.owner
		if f and warpstones.warps[f] then
			local gg = oldmetadata.fields.name
			if gg then
				warpstones.warps[f][gg] = nil
			end
		end
	end
end

local delay = 0
minetest.register_globalstep(function(dtime)
	if delay < 60 then
		delay = delay + dtime
		return
	end
	store:set_string("pane", minetest.serialize(warpstones.warps))
	delay = 0
end)

minetest.register_on_shutdown(function()
	store:set_string("pane", minetest.serialize(warpstones.warps))
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local name = player:get_player_name()
	if formname == "warpstones:warpstones" then
		if fields.warp_dest then
			local n = minetest.get_meta(selected[name])
			if warpstones.warps[name] and warpstones.warps[name][fields.warp_dest] then
				if n then
					n:set_string("destination", fields.warp_dest)
					n:set_string("infotext", "Warp to " .. fields.warp_dest ..
							"\nPunch and stand still to warp")
					return
				end
			else
				for _, warps in pairs(warpstones.warps) do
					for k, v in pairs(warps) do
						if k == fields.warp_dest then
							n:set_string("destination", fields.warp_dest)
							n:set_string("infotext", "Warp to " .. fields.warp_dest ..
									"\nPunch and stand still to warp")
							return
						end
					end
				end
			end
			hud.message(player, "No such warp!")
		elseif fields.warp_name then
			if not warpstones.warps[name] then
				warpstones.warps[name] = {}
			end
			local c = 0
			for _, _ in pairs(warpstones.warps[name]) do
				c = c + 1
			end
			-- Max warps
			if c > 99 then
				return forms.dialog(player, "Too many warps", true)
			end
			local sw = fields.warp_name:gsub("%W", "")
			warpstones.warps[name][sw] = selected[name]
			local meta = minetest.get_meta(selected[name])
			if meta then
				meta:set_string("name", sw)
				meta:set_string("infotext", sw)
			end
		end
	end
end)

minetest.register_on_leaveplayer(function(player)
	if not player then
		return
	end
	local name = player:get_player_name()
	selected[name] = nil
end)

minetest.register_chatcommand("warps", {
	description = "List your warps",
	params = "",
	privs = "shout",
	func = function(name, param)
		local w = warpstones.warps[name]
		if w then
			local str = ""
			for k, v in pairs(w) do
				str = str .. k .. " "
			end
			minetest.chat_send_player(name, str)
		end
	end,
})

for label, color in pairs(colors) do
	minetest.register_node("warpstones:" .. label, {
		visual = "mesh",
		mesh = "warps_warpstone.obj",
		description = label:gsub("^%l", string.upper) .. " Warp Stone",
		tiles = {"warpstones_" .. label .. ".png"},
		drawtype = "mesh",
		wield_scale = {x = 1.5, y = 1.5, z = 1.5},
		stack_max = 1,
		sunlight_propagates = true,
		walkable = false,
		paramtype = "light",
		paramtype2 = "facedir",
		use_texture_alpha = true,
		groups = {cracky = 3, oddly_breakable_by_hand = 1},
		light_source = 11,
		sounds = default.node_sound_glass_defaults(),
		selection_box = {
			type = "fixed",
			fixed = {-0.25, -0.5, -0.25,  0.25, 0.5, 0.25}
		},
		on_rightclick = on_rightclick,
		--on_blast = on_blast,
		after_place_node = after_place_node,
		on_punch = on_punch,
		on_construct = on_construct,
		after_dig_node = after_dig_node,
	})
	local mat = "caverealms:glow_" .. label

	minetest.register_craft({
		output = "warpstones:" .. label,
		recipe = {
			{mat, mat, mat},
			{mat, "bucket:bucket_lava", mat},
			{mat, mat, mat}
		}
	})
end
