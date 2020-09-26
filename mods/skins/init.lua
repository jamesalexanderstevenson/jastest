-- /mods/skins is part ofjastest
-- copyright 2020 james alexander stevenson
-- gnu gpl 3+

skins = {}
skins.players = {}
skins.skins = {}
local modpath = minetest.get_modpath(minetest.get_current_modname())
local dir_list = minetest.get_dir_list(modpath .. "/textures")
for _, fn in pairs(dir_list) do
	if not fn:find("_preview") then
		table.insert(skins.skins, fn:sub(7, -5))
	end
end
table.sort(skins.skins)

skins.show = function(name, framed)
	local player = minetest.get_player_by_name(name)
	local sel = skins.players[name] or
			player:get_meta():get_string("skin") or
			skins.skins[math.random(#skins.skins)]
	if sel:find("wardrobe") then
		sel = skins.skins[1]
	elseif sel:find("skins_") == 1 then
		sel = sel:sub(7, -5)
	end
	local pid
	for i = 1, #skins.skins do
		if skins.skins[i] == sel then
			pid = i
		end
	end
	if not pid then
		pid = 1
	end
	local sstr = table.concat(skins.skins, ",")
	local preview = "skins:" .. sel
	local fs
	if framed then
		player:set_eye_offset({x = 0, y = 0, z = 0},
				{x = 0, y = -10, z = 0})
		local inv = player:get_inventory()
		if not inv:get_list("skin") then
			inv:set_size("skin", 1)
		end
		fs = "size[8,10.5]" ..
			"no_prepend[]" ..
			"bgcolor[#FFFFFF00]" ..
			"box[-0.15,-0.15;8,1.2;#000000FF]" .. -- Top border
			"box[6.85,-0.15;1.1,11.2;#000000FF]" .. -- Right border
			"box[-0.15,6.85;8.1,4.2;#000000FF]" .. -- Bottom border
			"box[-0.15,-0.15;1.1,10;#000000FF]" .. -- Left border
			"box[-0.1,-0.1;1,10;#343434FF]" .. -- Left
			"box[-0.1,-0.1;8,1.1;#343434FF]" .. -- Top
			"box[6.9,-0.1;1,10;#343434FF]" .. -- Right
			"box[-0.1,6.9;8,4.1;#343434FF]" .. -- Bottom
			"listcolors[#00000069;#5A5A5A;#141318;#30434C;#FFF]" ..
			forms.q ..
			forms.x ..
			forms.title("Wardrobe") ..
			"button[4.8,0;1.55,1;flip;Flip]" ..
			"list[current_player;skin;3.5,0;1,1]" ..
			"list[detached:" .. name .. "_clothing;clothing;0,1;1,6]" ..
			"list[detached:" .. name .. "_armor;armor;7,1;1,6]" ..
			"list[current_player;main;0,7;8,4]" ..
		""
	else
		fs = "size[4.2,8.5]" ..
			"position[0.67, 0.5]" ..
			"anchor[0.0, 0.5]" ..
			"button[2.67,-0.3;1.5,1;pilf;Flip]" ..
			"label[0,0;Skins]" ..
			"table[0,0.67;4,4.34;skintab;" .. sstr .. ";" .. pid .. "]" ..
			"item_image[1.2,5.5;2,2;" .. preview .. "]" ..
			"button[2.2,7.67;2,1;apply;Apply]" ..
			"button_exit[0,7.67;2,1;quit;Cancel]" ..
		""
	end
	minetest.show_formspec(name, "skins:skintab", fs)
end

local function apply(player, skin)
	local meta = player:get_meta()
	local sk
	if not skin then
		local gender = meta:get("gender")
		if not gender then
			gender = "male"
			meta:set_string("gender", "male")
		end
		if gender == "female" then
			sk = "wardrobe_female.png"
		else
			sk = "wardrobe_male.png"
		end
		local inv = player:get_inventory()
		if not inv:is_empty("skin") then
			ll_items.throw_inventory(player:get_pos(),
					{inv:get_stack("skin", 1)}, true)
			inv:set_stack("skin", 1, "")
		end
	else
		sk = "skins_" .. skin .. ".png"
	end
	skins.players[player:get_player_name()] = skin
	meta:set_string("skin", sk)
	multiskin.set_player_skin(player, sk)
	armor.textures[name].skin = sk
	armor:set_player_armor(player)
end

for i = 1, #skins.skins do
	local ss = skins.skins[i]
	local prev = "skins_" .. ss .. "_preview.png"
	local sk = "skins_" .. ss .. ".png"
	minetest.register_craftitem("skins:" .. ss, {
		description = ss:gsub("_", " "),
		inventory_image = prev,
		stack_max = 1,
		on_use = function(itemstack, user, pointed_thing)
			local inv = user:get_inventory()
			ll_items.throw_inventory(user:get_pos(),
					{inv:get_stack("skin", 1)}, true)
			inv:set_stack("skin", 1, itemstack:get_name())
			apply(user, itemstack:get_name():sub(7))
			itemstack:take_item()
			return itemstack
		end,
	})
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "skins:skintab" then
		local name = player:get_player_name()
		if fields.quit then
			player:set_eye_offset({x = 0, y = 0, z = 0},
					{x = 0, y = 0, z = 0})
			return
		elseif fields.flip then
			skins.show(name)
		elseif fields.pilf then
			skins.show(name, true)
		end
		if fields.skintab then
			local f = minetest.explode_table_event(fields.skintab)
			local r = f.row
			local s = skins.skins[r]
			skins.players[name] = s
			skins.show(name)
		elseif fields.apply then
			local inv = player:get_inventory()
			local meta = player:get_meta()
			local s = skins.players[name]
			if not s then
				s = skins.skins[1]
			end
			if s:find("skins_") == 1 then
				-- Player hits apply button when selected skin is stil applied.
				s = s:sub(7, -5)
			end
			local give = false
			if s == meta:get_string("skin"):sub(7, -5) then
				hud.message(player, "Already applied")
				return forms.dialog(name, "This skin is already applied.")
			elseif inv:contains_item("main", "skins:" .. s) then
				give = true
				inv:remove_item("main", "skins:" .. s)
				local it = inv:get_stack("skin", 1)
				if not it:is_empty() then
					ll_items.throw_inventory(player:get_pos(), {it}, true)
				end
				inv:set_stack("skin", 1, "skins:" .. s)
			elseif inv:contains_item("main", "mtd:gold_coin 8") then
				give = true
				inv:remove_item("main", "mtd:gold_coin 8")
				local it = inv:get_stack("skin", 1)
				if not it:is_empty() then
					ll_items.throw_inventory(player:get_pos(), {it}, true)
				end
				inv:set_stack("skin", 1, "skins:" .. s)
			end
			if give then
				apply(player, s)
				hud.message(player, "Skin applied")
			else
				hud.message(player, "Not enough credits!")
				forms.dialog(name, "The cost is eight gold coints", true)
			end
		end
	end
end)

minetest.register_on_player_inventory_action(function(player, action, inventory, inventory_info)
	if inventory_info.to_list == "skin" then
		local it = inventory:get_stack("skin", 1):get_name()
		if it:find("skins:") == 1 then
			apply(player, it:sub(7))
		else
			apply(player)
		end
	elseif inventory_info.from_list == "skin" or
			inventory_info.listname == "skin" then
		apply(player)
	end
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	skins.players[name] = nil
end)

minetest.register_on_joinplayer(function(player)
	local meta = player:get_meta()
	local skin = meta:get_string("skin")
	local name = player:get_player_name()
	minetest.after(2.34, function()
		if skin ~= "" then
			local check = false
			if minetest.check_player_privs(name, "skins") then
				check = true
			else
				for i = 1, #skins.skins do
					if skin == "skins_" .. skins.skins[i] ..
							".png" then
						check = true
						break
					elseif skin:find("female") or
							skin:find("male") then
						check = true
						break
					end
				end
			end
			if not check then
				skin = "skins_" ..
						skins.skins[math.random(#skins.skins)] ..
						".png"
			end
			skins.players[name] = skin
			multiskin.set_player_skin(player, skin)
			armor.textures[name].skin = skin
			armor:set_player_armor(player)
		else
			local rp = skins.skins[math.random(#skins.skins)]
			local sk = "skins_" .. rp .. ".png"
			meta:set_string("skin", sk)
			skins.players[name] = sk
			multiskin.set_player_skin(player, sk)
			armor.textures[name].skin = sk
			armor:set_player_armor(player)
			if math.random() >= 0.5 then
				meta:set_string("gender", "male")
			else
				meta:set_string("gender", "female")
			end
			local inv = player:get_inventory()
			if not inv then
				return
			end
			inv:set_size("skin", 1)
			inv:set_stack("skin", 1, "skins:" .. rp)
		end
	end)
end)

minetest.register_privilege("skins", {
	description = "Can set skin by filename",
	give_to_admin = false,
	give_to_singleplayer = false,
})

minetest.register_chatcommand("gender", {
	description = "Specify a gender",
	params = "any",
	privs = "shout",
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if not player then
			return false, "[Server] Must be in-game"
		end
		if param:len() > 12 then
			return false, "[Server] Specified gender too long"
		end
		param = param:gsub("%W", "")
		if param == "female" then
			player:get_meta():set_string("gender", "female")
			apply(player)
			return true, "[Server] Gender specified to male"
		else
			player:get_meta():set_string("gender", param)
			apply(player)
			return true, "[Server] Gender specified to " .. param
		end
	end,
})
			
minetest.register_chatcommand("skins", {
	description = "Show skins menu",
	params = "",
	privs = "interact",
	func = function(name, param)
		if param == "wardrobe" then
			skins.show(name, true)
			return true, "[Server] Showing Wardrobe"
		end
		skins.show(name)
		return true, "[Server] Showing Skins"
	end,
})

minetest.register_chatcommand("skin", {
	description = "Set skin by name or index. Use /skin <n> " ..
			"where <n> is the number of the skin you want. " ..
			"Or you can use any texture by filename.",
	params = "[<n> | <filename.png>]",
	--TODO check and buy
	privs = "skins",
	func = function(name, msg)
		local player = minetest.get_player_by_name(name)
		if msg == "" then
			minetest.chat_send_player(name, "[Server] Skins:")
			for i = 1, #skins.skins do
				minetest.chat_send_player(name, i .. ": " .. skins.skins[i])
			end
			return true, "Select a number from the list"
		end
		local textures = {msg}
		local sk = msg
		if type(tonumber(msg)) == "number" and skins.skins[tonumber(msg)] then
			sk = skins.skins[tonumber(msg)]
			textures = {sk}
		elseif not minetest.check_player_privs(name, "skins") then
			return false, "[Server] Bad number"
		end
		apply(player, sk)
		return true, "[Server] Set to specified skin"
	end,
})
