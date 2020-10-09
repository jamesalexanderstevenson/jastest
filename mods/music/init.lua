music = {}
music.players = {}
local handles = {}
local boxes = {}

local rand = math.random

function music.play(sss, spt, player, fade)
	if type(sss) == "string" then
		sss = {name = sss}
	end
	spt = spt or {}
	local handle = minetest.sound_play(sss, spt)
	if player then
		local name = player:get_player_name()
		local ph = handles[name] or {}
		ph[#ph + 1] = handle
		handles[name] = ph
	end
	if fade then
		minetest.sound_fade(handle, fade, 0)
	else
		return handle
	end
end

local function show_box(pos, node, clicker, itemstack, pointed_thing)
	local name = clicker:get_player_name()
	setup.sel[name] = pos
	local fs = "size[12,6]" ..
	""
	for i = 1, 12 do
		fs = fs .. "button[" .. i - 1 .. ",0;1,1;pin" .. i .. ";]"
	end
	if pos then
		local spos = pos.x .. "," .. pos.y .. "," .. pos.z
		fs = fs .. "list[nodemeta:" .. spos .. ";disk;5.5,2.6;1,1]" ..
			"button[5.5,3.6;1,1;eject;Eject]" ..
		""
	end
	minetest.show_formspec(name, "music:box", fs)
end

music.seq = function(name, times)
	times = times % 12
	for i = 1, times do
		minetest.after(i * 3, function()
			local handle = music.play("music_bell", {pitch = 0.443, gain = 0.44})
			minetest.sound_fade(handle, -0.06, 0)
		end)
	end
end

music.panic = function(name)
	local h = handles[name]
	if not h then
		return
	end
	for i = 1, #h do
		minetest.sound_stop(h[i])
	end
end

local function stop_disk(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local hash = minetest.hash_node_position(pos)
	boxes[minetest.pos_to_string(pos)] = nil
end

local function eject(pos)
	local meta = minetest.get_meta(pos)
	meta:set_string("t", tostring(minetest.get_us_time()))
	local inv = meta:get_inventory()
	local stack = inv:get_stack("disk", 1)
	ll_items.throw_inventory(pos, {stack})
	inv:set_stack("disk", 1, nil)
	stop_disk(pos)
end

local function show_seq(player)
	local name = player:get_player_name()
	local itemstack = player:get_wielded_item()
	local meta = itemstack:get_meta()
	local seq = meta:get("seq")
	local s = ""
	if seq then
		seq = minetest.deserialize(seq)
		for i = 1, #seq do
			local it = seq[i]
			if type(it) == "string" and
					it:sub(1, 2) == "i " then
				s = s .. it
			else
				s = s .. it.pitch
			end
			if i ~= #seq then
				s = s .. "\n"
			end
		end
	end
	local fs = "size[8,9]" ..
		"real_coordinates[true]" ..
		"textarea[0,0;8,8;seq;;" .. s .. "]" ..
		"button[0,8;8,1;save;Save]" ..
	""
	minetest.show_formspec(name, "music:disk", fs)
end

local function play_note(sss, spt, t, pos)
	local meta = minetest.get_meta(pos)
	local tt = meta:get_string("t")
	if tt ~= t then
		return
	end
	local spos = pos.x .. "," .. pos.y .. "," .. pos.z
	if not boxes[spos] or boxes[spos] ~= t then
		return
	end
	local fade
	if sss.name == "music_square" then
		fade = -0.34
	end
	music.play(sss, spt, nil, fade)
end

local function play_disk(pos)
	local spos = pos.x .. "," .. pos.y .. "," .. pos.z
	if boxes[spos] then
		stop_disk(pos)
	end
	local t = tostring(minetest.get_us_time())
	boxes[spos] = t
	local meta = minetest.get_meta(pos)
	meta:set_string("t", t)
	local inv = meta:get_inventory()
	local disk = inv:get_stack("disk", 1)
	if disk:get_name() ~= "music:disk" then
		return
	end
	local seq = disk:get_meta():get("seq")
	if seq then
		local step = 0
		local stop_delay = 0
		seq = minetest.deserialize(seq)
		if #seq > 40 then
			local s = {}
			for i = 1, 40 do
				s[i] = seq[i]
			end
			seq = s
		end
		for i = 1, #seq do
			if type(seq[i]) ~= "string" then
				stop_delay = stop_delay + 1
				local pitch = seq[i].pitch
				local sss = {name = seq[i].sound}
				local spt = {pitch = seq[i].pitch, pos = pos}
				if pitch == 0 then
					sss.name = ""
					spt = {}
				end
				minetest.after(step, play_note, sss, spt, t, pos)
				step = step + 1
			end
		end
		minetest.after(stop_delay, stop_disk, pos)
	end
end

minetest.register_abm({
	label = "Lava sounds",
	nodenames = "lava:source",
	neighbors = {"obsidian:obsidian"},
	interval = 6.0,
	chance = 3,
	catch_up = false,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local o = minetest.get_objects_inside_radius(pos, 3)
		for i = 1, #o do
			local p = o[i]
			if p:is_player() then
				local name = p:get_player_name()
				local n = music.players[name]
				if n < 3 then
					music.players[name] = n + 1
					pos.y = pos.y - 5
					minetest.sound_play("lava", {
						pos = pos,
						gain = rand(),
						pitch = rand(),
					})
					minetest.after(rand(5, 10), function()
						if music.players[name] then
							music.players[name] = music.players[name] - 1
						end
					end)
					break
				end
			end
		end
	end,
})

minetest.register_on_joinplayer(function(player)
	music.players[player:get_player_name()] = 0
end)

minetest.register_on_leaveplayer(function(player)
	music.players[player:get_player_name()] = nil
	handles[player:get_player_name()] = nil
end)

minetest.register_node("music:box", {
	description = "Piano",
	tiles = {
		"default_steel_block.png^[colorize:black:191^(bases_base.png^[opacity:191)",
		"default_steel_block.png^[colorize:black:191^(bases_base.png^[opacity:191)",
		"default_steel_block.png^[colorize:black:191^(bases_base.png^[opacity:191)",
		"default_steel_block.png^[colorize:black:191^(bases_base.png^[opacity:191)",
		"default_steel_block.png^[colorize:black:191^(bases_base.png^[opacity:191)",
		"default_steel_block.png^[colorize:black:191^(bases_base.png^[opacity:191)^music_disc_slot.png",
	},
	paramtype2 = "facedir",
	stack_max = 1,
	groups = {cracky = 2},
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size("disk", 1)
	end,
	on_dig = function(pos, node, digger)
		eject(pos)
		minetest.node_dig(pos, node, digger)
	end,
	on_rightclick = show_box,
})

minetest.register_craft({
	output = "music:box",
	recipe = {
		{"default:copper_ingot", "default:copper_ingot", "default:copper_ingot"},
		{"default:steel_ingot", "default:mese", "default:steel_ingot"},
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
	},
})

minetest.register_craftitem("music:disk", {
	description = "Music Disk",
	inventory_image = "music_disc.png",
	stack_max = 1,
	on_use = function(itemstack, user, pointed_thing)
		if pointed_thing.type == "node" then
			if minetest.get_node(pointed_thing.under).name == "music:box" then
				local pos = pointed_thing.under
				local meta = minetest.get_meta(pos)
				local inv = meta:get_inventory()
				if inv:get_stack("disk", 1):get_name() == "music:disk" then
					eject(pos)
				end
				inv:set_stack("disk", 1, itemstack)
				play_disk(pos)
				itemstack:take_item()
				return itemstack
			end
		end
		show_seq(user)
		return itemstack
	end,
})

minetest.register_craft({
	output = "music:disk",
	recipe = {
		{"default:mese_crystal", "default:paper", "dye:black"}
	}
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local name = player:get_player_name()
	if formname == "music:box" and not fields.quit then
		if fields.eject then
			local pos = setup.sel[name]
			return eject(pos)
		end
		local spt = {}
		for i = 1, 12 do
			if fields["pin" .. i] then
				spt.pitch = i * 0.13 --TODO more tunings
			end
		end
		spt.pitch = spt.pitch and spt.pitch * 0.6
		local pos = player:get_pos()
		pos.y = pos.y + 0.67
		spt.pos = pos
		spt.gain = 0.34
		local h = music.play("music_bell", spt)
		minetest.after(0, minetest.sound_fade, h, -0.23, 0)
	elseif formname == "music:disk" then
		local s = fields.seq
		if s then
			local seq = {}
			s = s:split("\n")
			if #s > 40 then
				minetest.chat_send_player(name, "Limit of 40 exceeded.")
			end
			local ins = false
			for i = 1, #s do
				local ss = s[i]
				ss = ss:split(" ")
				local pitch = 0
				for ii = 1, #ss do
					local a = ss[ii]
					if ii == 1 then
						if a == "i" then
							ins = true
						else
							pitch = tonumber(a)
							if a then
								pitch = a
							end
						end
					elseif ii == 2 and ins then
						ins = a
						seq[i] = "i " .. ins
						break
					end
				end
				if not ins then
					ins = "music_bell"
				end
				if not seq[i] then
					seq[i] = {pitch = pitch, sound = ins}
				end
			end
			local w = player:get_wielded_item()
			if w:get_name() == "music:disk" then
				w:get_meta():set_string("seq", minetest.serialize(seq))
				player:set_wielded_item(w)
				show_seq(player)
			end
		end
	end
end)

minetest.register_chatcommand("hum", {
	description = "arg(bool) means this arg is a bool",
	params = "loop(bool) gain(float) pitch(float) | stop",
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if param == "stop" then
			music.panic(name)
		end
		a = param:split(" ")
		local spt = {
			to_player = name,
			loop = false,
			gain = 0.06,
			pitch = 0.0334,
		}
		local loop = a[1] and a[1] == "true" or
				a[1] == "false"
		if loop then
			if a[1] == "true" then
				spt.loop = true
			else
				spt.loop = false
			end
		end
		local gain = a[2] and tonumber(a[2])
		if gain then
			spt.gain = tonumber(gain)
		end
		local pitch = a[3] and tonumber(a[3])
		if pitch then
			spt.pitch = tonumber(pitch)
		end
		music.play("music_square", spt, player)
	end,
})

minetest.register_chatcommand("m", {
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if not player then
			return false, "Not in game!"
		end
		local pos = player:get_pos()
		pos.y = pos.y + 0.5
		local spt = {pos = pos}
		param = param:split(" ")
		if not param[1] then
			param[1] = ""
		end
		if param[2] then
			spt.pitch = tonumber(param[2])
		end
		music.play(param[1], spt)
	end,
})

minetest.register_chatcommand("p", {
	func = function(name, param)
		show_box(nil, nil, minetest.get_player_by_name(name))
	end,
})
