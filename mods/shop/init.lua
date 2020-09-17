local players = {}
local sel = {}

local function creak_sound(pos, bit)
	bit = bit or "open"
	minetest.sound_play("default_chest_" .. bit, {gain = 0.3,
			pos = pos, max_hear_distance = 10}, true)
end

local function poll_privs(name)
	local player = minetest.get_player_by_name(name)
	if player then
		local m = players[name] or 0
		m = m + 0.1
		local c = player:get_player_control()
		for k, v in pairs(c) do
			if v then
				m = m + 0.1
			end
		end
		players[name] = m
		if m > 1 then
			-- add wear, etc
			local _, inv = armor:get_valid_player(player)
			local armor_p
			for k, v in pairs(inv:get_list("armor")) do
				local it = v:get_name()
				if it == "shop:boots_fast" or
						it == "shop:shield_fly" then
					armor_p = true
					local clay = v:get_wear() + m + 10
					clay = v:set_wear(clay)
					if clay then
						armor:set_inventory_stack(player, k, v)
						armor:set_player_armor(player)
						armor:save_armor_inventory(player)
					else
						armor:set_inventory_stack(player, k, "")
						if it == "shop:shield_fly" then
							it = "Fly Shield"
							has = "has"
						elseif it == "shop:boots_fast" then
							it = "Fast Boots"
							has = "have"
						end
						has = "Your " .. it .. " " ..
								has .. " broken!"
						hud.message(player, has)
						armor:set_player_armor(player)
						armor:update_player_visuals(player)
						armor:save_armor_inventory(player)
					end
				end
			end
			players[name] = nil
			if not armor_p then
				return
			end
		end
		minetest.after(0.1, function()
			poll_privs(name)
		end)
	end
end

local function check_armor_privs(bit, index, stack)
	local f = function(p)
		local name, inv = armor:get_valid_player(p)
		if name and minetest.get_player_by_name(name) then
			local player = minetest.get_player_by_name(name)
			local privs = minetest.get_player_privs(name)
			local boots_fast = inv:contains_item("armor", "shop:boots_fast")
			local shield_fly = inv:contains_item("armor", "shop:shield_fly")
			local y
			if boots_fast and not privs.fast then
				privs.fast = true
				y = true
				hud.message(player, "You now have the fast priv!")
			elseif privs.fast and not boots_fast then
				privs.fast = nil
				y = true
				hud.message(player, "You no longer have the fast priv!")
			end
			if shield_fly and not privs.fly then
				hud.message(player, "You now have the fly priv!")
				privs.fly = true
				y = true
			elseif privs.fly and not shield_fly then
				privs.fly = nil
				y = true
				hud.message(player, "You no longer have the fly priv!")
			end
			if y then
				if (privs.fly or privs.fast) then
					-- activate
					players[name] = nil
				end
				minetest.set_player_privs(name, privs)
				poll_privs(name)
			elseif (privs.fly or privs.fast) then
				poll_privs(name)
			end
		end
	end
	-- once targeted
	if bit and type(bit) ~= "boolean" then
		f(bit)
		return
	end
	-- once all
	local m = minetest.get_connected_players()
	for i = 1, #m do
		f(m[i])
	end
	-- loop all
	if not bit then
		minetest.after(12, function()
			check_armor_privs()
		end)
	end
end

--

local function get_shop_formspec(pos, p)
	local meta = minetest.get_meta(pos)
	local trade = meta:get_string("trade")
	local spos = pos.x.. "," ..pos.y .. "," .. pos.z
	local formspec =
		"size[8,7]" ..
		"label[0,1;Item]" ..
		"label[3,1;Cost]" ..
		"button_exit[6,0;2,1;exit;Exit]" ..
		"button[0,0;2,1;stock;Stock]" ..
		"button[3,0;2,1;register;Register]" ..
		"button_exit[6,2;2,1;done;Save]" ..
		"button[0,2;1,1;prev;<]" ..
		"button[1,2;1,1;next;>]" ..
		"checkbox[3,2;trade;Allow trades;" .. trade .. "]" ..
		"list[nodemeta:" .. spos .. ";sell" .. p .. ";1,1;1,1;]" ..
		"list[nodemeta:" .. spos .. ";buy" .. p .. ";4,1;1,1;]" ..
		"list[current_player;main;0,3.25;8,4;]"
	return formspec
end

local function get_shop_formspec_c(pos, p)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local s = inv:get_stack("sell" .. p, 1)
	local b = inv:get_stack("buy" .. p, 1)
	local spos = pos.x.. "," ..pos.y .. "," .. pos.z
	local formspec =
		"size[8,7]" ..
		"label[0,1;Item]" ..
		"label[3,1;Cost]" ..
		"button[0,0;2,1;ok;Buy]" ..
		"button_exit[6,0;2,1;exit;Exit]" ..
		"button[3,0;2,1;setup;Setup]" ..
		"button[0,2;1,1;prev;<]" ..
		"button[1,2;1,1;next;>]" ..
		"image[1,1;1,1;craftguide_selected.png]" ..
		"style_type[item_image_button;border=false]" ..
		"item_image_button[1,1;1,1;" .. s:get_name() .. ";sell_ok;]" ..
		"image[4,1;1,1;craftguide_selected.png]" ..
		"item_image_button[4,1;1,1;" .. b:get_name() .. ";buy_ok;]" ..
		"list[current_player;main;0,3.25;8,4;]"
	if s:get_count() > 1 then
		formspec = formspec .. "label[1.65,1.55;" .. s:get_count() .. "]"
	end
	if b:get_count() > 1 then
		formspec = formspec .. "label[4.65,1.55;" .. b:get_count() .. "]"
	end
	return formspec
end

local formspec_register =
	"size[8,9]" ..
	"label[0,0;Register]" ..
	"list[current_name;register;0,0.75;8,4;]" ..
	"list[current_player;main;0,5.25;8,4;]" ..
	"listring[]"

local formspec_stock =
	"size[8,9]" ..
	"label[0,0;Stock]" ..
	"list[current_name;stock;0,0.75;8,4;]" ..
	"list[current_player;main;0,5.25;8,4;]" ..
	"listring[]"

minetest.register_privilege("shop_admin", {
	description = "Shop administration and maintainence",
	give_to_singleplayer = false,
	give_to_admin = false,
})

minetest.register_node("shop:shop", {
	description = "Shop",
	paramtype2 = "facedir",
	tiles = {
		"shop_shop_topbottom.png",
		"shop_shop_topbottom.png",
		"shop_shop_side.png",
		"shop_shop_side.png",
		"shop_shop_side.png",
		"shop_shop_front.png",
	},
	groups = {choppy = 3, oddly_breakable_by_hand = 1, trade_value = 25},
	sounds = default.node_sound_wood_defaults(),
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		sel[clicker:get_player_name()] = pos
		minetest.swap_node(pos,
				{name = "shop:shop_open", param1 = node.param1, param2 = node.param2})
		creak_sound(pos)
	end,
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local meta = minetest.get_meta(pos)
		meta:set_string("pos", pos.x .. "," .. pos.y .. "," .. pos.z)
		local owner = placer:get_player_name()

		meta:set_string("owner", owner)
		meta:set_string("infotext", "Shop (Owned by " .. owner .. ")")
		meta:set_string("formspec", get_shop_formspec_c(pos, 1))
		meta:set_string("admin_shop", "false")
		meta:set_string("trade", "false")
		meta:set_int("pages_current", 1)
		meta:set_int("pages_total", 1)

		local inv = meta:get_inventory()
		inv:set_size("buy1", 1)
		inv:set_size("sell1", 1)
		inv:set_size("stock", 8 * 4)
		inv:set_size("register", 8 * 4)
	end,
	on_punch = function(pos, node, puncher, pointed_thing)
		local meta = minetest.get_meta(pos)
		minetest.swap_node(pos, {name = "shop:shop_open", param1 = node.param1, param2 = node.param2})
		creak_sound(pos)
		if meta:get_string("trade") == "" then
			meta:set_string("formspec", get_shop_formspec_c(pos, 1))
		end
		if not minetest.check_player_privs(puncher, "shop_admin") then
			return
		end
		local c = puncher:get_player_control()
		if not (c.aux1 and c.sneak) then
			return
		end
		if meta:get_string("admin_shop") == "false" then
			hud.message(puncher, "Enabling infinite stocks in shop.")
			meta:set_string("admin_shop", "true")
		elseif meta:get_string("admin_shop") == "true" then
			hud.message(puncher, "Disabling infinite stocks in shop.")
			meta:set_string("admin_shop", "false")
		end
	end,
	can_dig = function(pos, player) 
                local meta = minetest.get_meta(pos) 
                local owner = meta:get_string("owner") 
                local inv = meta:get_inventory() 
                return inv:is_empty("register") and
				inv:is_empty("stock") and
				-- FIXME Make all contents in the buy/sell lists drop as items.
				inv:is_empty("buy1") and
				inv:is_empty("sell1") and
				(player:get_player_name() == owner or
				default.can_interact_with_node(player, pos))
	end,

})

minetest.register_node("shop:shop_open", {
	description = "Shop",
	drawtype = "mesh",
	visual = "mesh",
	mesh = "chest_open.obj",
	paramtype = "light",
	paramtype2 = "facedir",
	legacy_facedir_simple = true,
	is_ground_content = false,
	drop = "shop:shop",
	tiles = {
		{name = "shop_shop_topbottom.png", backface_culling = true},
		{name = "shop_shop_topbottom.png", backface_culling = true},
		{name = "shop_shop_side.png", backface_culling = true},
		{name = "shop_shop_side.png", backface_culling = true},
		{name = "shop_shop_front.png", backface_culling = true},
		{name = "shop_shop_inside.png", backface_culling = true},
	},
	groups = {choppy = 3, oddly_breakable_by_hand = 1, trade_value = 25},
	sounds = default.node_sound_wood_defaults(),
	on_punch = function(pos, node, puncher, pointed_thing)
		minetest.swap_node(pos, {name = "shop:shop", param1 = node.param1, param2 = node.param2})
		creak_sound(pos, "close")
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		local meta = minetest.get_meta(pos)
		local node_pos = minetest.string_to_pos(meta:get_string("pos"))
		local owner = meta:get_string("owner")
		local inv = meta:get_inventory()
		local pg_current = meta:get_int("pages_current")
		local pg_total = meta:get_int("pages_total")
		local s = inv:get_list("sell" .. pg_current)
		local b = inv:get_list("buy" .. pg_current)
		local stk = inv:get_list("stock")
		local reg = inv:get_list("register")
		local player = sender:get_player_name()
		local pinv = sender:get_inventory()
		local admin_shop = meta:get_string("admin_shop")
		if fields.next then
			if pg_total > 1 then
				if inv:is_empty("sell" .. pg_current) and inv:is_empty("buy" .. pg_current) then
					if pg_current == pg_total then
						meta:set_int("pages_total", pg_total - 1)
					else
						for i = pg_current, pg_total do
							inv:set_list("buy" .. i, inv:get_list("buy" .. i + 1))
							inv:set_list("sell" .. i, inv:get_list("sell" .. i + 1))
							inv:set_list("buy" .. i + 1, nil)
							inv:set_list("sell" .. i + 1, nil)
						end
						meta:set_int("pages_total", pg_total - 1)
						pg_current = pg_current - 1
					end
				end
				if pg_current < pg_total then
					meta:set_int("pages_current", pg_current + 1)
				else
					meta:set_int("pages_current", 1)
				end
				meta:set_string("formspec", get_shop_formspec_c(pos, meta:get_int("pages_current")))
			end
		elseif fields.prev then
			if pg_total > 1 then
				if inv:is_empty("sell" .. pg_current) and inv:is_empty("buy" .. pg_current) then
					if pg_current == pg_total then
						meta:set_int("pages_total", pg_total - 1)
					else
						for i  = pg_current, pg_total do
							inv:set_list("buy" .. i, inv:get_list("buy" .. i + 1))
							inv:set_list("sell" .. i, inv:get_list("sell" .. i + 1))
							inv:set_list("buy" .. i + 1, nil)
							inv:set_list("sell" .. i + 1, nil)
						end
						meta:set_int("pages_total", pg_total - 1)
						pg_current = pg_current + 1
					end
				end
				if pg_current == 1 and pg_total > 1 then
					meta:set_int("pages_current", pg_total)
				elseif pg_current > 1 then
					meta:set_int("pages_current", pg_current - 1)
				end
				meta:set_string("formspec", get_shop_formspec_c(pos, meta:get_int("pages_current")))
			end
		elseif fields.ok or fields.buy_ok or fields.sell_ok then
			if meta:get_string("trade") == "true" and fields.buy_ok then
				--rev
				-- Shop's closed if not set up, or the till is full.
				if inv:is_empty("buy" .. pg_current) or
					    inv:is_empty("sell" .. pg_current) or
					    (not inv:room_for_item("register", s[1])) then
						hud.message(player, "Shop closed.")
						return
				end

				-- Player has funds.
				if pinv:contains_item("main", s[1]) then
					-- Player has space for the goods.
					if pinv:room_for_item("main", b[1]) then
						-- There's inventory in stock.
						if inv:contains_item("register", b[1]) then
							pinv:remove_item("main", s[1]) -- Take the funds.
							inv:add_item("stock", s[1]) -- Fill the till.
							inv:remove_item("register", b[1]) -- Take one from the stock.
							pinv:add_item("main", b[1]) -- Give it to the player.
						elseif admin_shop == "true" then
							pinv:remove_item("main", s[1])
							inv:add_item("stock", s[1])
							pinv:add_item("main", b[1])
						else
							hud.message(player, "Shop is out of inventory!")
						end
					else
						hud.message(player, "You're all filled up!")
					end
				else
					hud.message(player, "Not enough credits!") -- 32X.
				end

			else
				-- Shop's closed if not set up, or the till is full.
				if inv:is_empty("sell" .. pg_current) or
					    inv:is_empty("buy" .. pg_current) or
					    (not inv:room_for_item("register", b[1])) then
						hud.message(player, "Shop closed.")
						return
				end

				-- Player has funds.
				if pinv:contains_item("main", b[1]) then
					-- Player has space for the goods.
					if pinv:room_for_item("main", s[1]) then
						-- There's inventory in stock.
						if inv:contains_item("stock", s[1]) then
							pinv:remove_item("main", b[1]) -- Take the funds.
							inv:add_item("register", b[1]) -- Fill the till.
							inv:remove_item("stock", s[1]) -- Take one from the stock.
							pinv:add_item("main", s[1]) -- Give it to the player.
						elseif admin_shop == "true" then
							pinv:remove_item("main", b[1])
							inv:add_item("register", b[1])
							pinv:add_item("main", s[1])
						else
							hud.message(player, "Shop is out of inventory!")
						end
					else
						hud.message(player, "You're all filled up!")
					end
				else
					hud.message(player, "Not enough credits!") -- 32X.
				end
			end
		elseif fields.setup then
			if owner == player then
				forms.players[player] = node_pos
				minetest.show_formspec(owner, "shop:shop", get_shop_formspec(pos, 1))
			end
		end
		if fields.quit then
			local n = minetest.get_node(pos)
			minetest.swap_node(pos, {name = "shop:shop", param1 = n.param1, param2 = n.param2})
			creak_sound(pos, "close")
		end
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		local owner = meta:get_string("owner")
		local inv = meta:get_inventory()
		local pg_current = meta:get_string("pages_current")
		local s = inv:get_list("sell" .. pg_current)
		local n = stack:get_name()
		local playername = player:get_player_name()
		if playername ~= owner and
				(not minetest.check_player_privs(playername, "shop_admin")) then
			return 0
		else
			return stack:get_count()
		end
	end,
	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		local owner = meta:get_string("owner")
		local playername = player:get_player_name()
		if playername ~= owner and
				(not minetest.check_player_privs(playername, "shop_admin"))then
			return 0
		else
			return stack:get_count()
		end
	end,
	allow_metadata_inventory_move = function(pos, _, _, _, _, count, player)
		local meta = minetest.get_meta(pos)
		local owner = meta:get_string("owner")
		local playername = player:get_player_name()
		if playername ~= owner and
				(not minetest.check_player_privs(playername, "shop_admin")) then
			return 0
		else
			return count
		end
	end,
	can_dig = function(pos, player) 
                local meta = minetest.get_meta(pos) 
                local owner = meta:get_string("owner") 
                local inv = meta:get_inventory() 
                return inv:is_empty("register") and
				inv:is_empty("stock") and
				-- FIXME Make all contents in the buy/sell lists drop as items.
				inv:is_empty("buy1") and
				inv:is_empty("sell1") and
				(player:get_player_name() == owner or
				default.can_interact_with_node(player, pos))
	end,
})

minetest.register_craft({
	output = "shop:shop",
	recipe = {
		{"group:wood", "group:wood", "group:wood"},
		{"group:wood", "default:goldblock", "group:wood"},
		{"group:wood", "group:wood", "group:wood"}
	}
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "shop:shop" then
		return
	end
	local pos = forms.players[player:get_player_name()]
	if not pos then
		return
	end
	local name = player:get_player_name()
	forms.players[name] = nil
	if fields.quit or fields.exit then
		local n = minetest.get_node(pos)
		minetest.swap_node(pos, {name = "shop:shop", param1 = n.param1, param2 = n.param2})
		creak_sound(pos, "close")
	end
	local meta = minetest.get_meta(pos)
	local owner = meta:get_string("owner")
	local inv = meta:get_inventory()
	local pg_current = meta:get_int("pages_current")
	local pg_total = meta:get_int("pages_total")
	local s = inv:get_list("sell" .. pg_current)
	local b = inv:get_list("buy" .. pg_current)
	local stk = inv:get_list("stock")
	local reg = inv:get_list("register")
	local pinv = player:get_inventory()
	if fields.next then
		if pg_total < 32 and
				pg_current == pg_total and
				name == owner and
				not (inv:is_empty("sell" .. pg_current) or inv:is_empty("buy" .. pg_current)) then
			inv:set_size("buy" .. pg_current + 1, 1)
			inv:set_size("sell" .. pg_current + 1, 1)
			meta:set_int("pages_current", pg_current + 1) 
			meta:set_int("pages_total", pg_current + 1)
			forms.players[name] = pos
			minetest.show_formspec(name, "shop:shop", get_shop_formspec(pos, pg_current + 1))
		elseif pg_total > 1 then
			if inv:is_empty("sell" .. pg_current) and inv:is_empty("buy" .. pg_current) then
				if pg_current == pg_total then
					meta:set_int("pages_total", pg_total - 1)
				else
					for i = pg_current, pg_total do
						inv:set_list("buy" .. i, inv:get_list("buy" .. i + 1))
						inv:set_list("sell" .. i, inv:get_list("sell" .. i + 1))
						inv:set_list("buy" .. i + 1, nil)
						inv:set_list("sell" .. i + 1, nil)
					end
					meta:set_int("pages_total", pg_total - 1)
					pg_current = pg_current - 1
				end
			end
			if pg_current < pg_total then
				meta:set_int("pages_current", pg_current + 1)
			else
				meta:set_int("pages_current", 1)
			end
		end
		forms.players[name] = pos
		minetest.show_formspec(name, "shop:shop", get_shop_formspec(pos, meta:get_int("pages_current")))
	elseif fields.prev then
		if pg_total > 1 then
			if inv:is_empty("sell" .. pg_current) and inv:is_empty("buy" .. pg_current) then
				if pg_current == pg_total then
					meta:set_int("pages_total", pg_total - 1)
				else
					for i  = pg_current, pg_total do
						inv:set_list("buy" .. i, inv:get_list("buy" .. i + 1))
						inv:set_list("sell" .. i, inv:get_list("sell" .. i + 1))
						inv:set_list("buy" .. i + 1, nil)
						inv:set_list("sell" .. i + 1, nil)
					end
					meta:set_int("pages_total", pg_total - 1)
					pg_current = pg_current + 1
				end
			end
			if pg_current == 1 and pg_total > 1 then
				meta:set_int("pages_current", pg_total)
			elseif pg_current > 1 then
				meta:set_int("pages_current", pg_current - 1)
			end
		end
		forms.players[name] = pos
		minetest.show_formspec(name, "shop:shop", get_shop_formspec(pos, meta:get_int("pages_current")))
	elseif fields.done then
		meta:set_string("formspec", get_shop_formspec_c(pos, 1))
	elseif fields.stock then
		forms.players[name] = pos
		minetest.show_formspec(name, "shop:shop", formspec_stock)
	elseif fields.register then
		forms.players[name] = pos
		minetest.show_formspec(name, "shop:shop", formspec_register)
	elseif fields.trade then
		forms.players[name] = pos
		local trade = meta:get_string("trade")
		if trade == "true" then
			meta:set_string("trade", "false")
		elseif trade == "false" then
			meta:set_string("trade", "true")
		end
		minetest.show_formspec(name, "shop:shop", get_shop_formspec(pos, pg_current))
	end
end)

-- xdecor
--[[
craftguide.register_craft({
	result = "shop:shop",
	items = {
		"group:wood, group:wood, group:wood",
		"group:wood, default:goldblock, group:wood",
		"group:wood, group:wood, group:wood",
	}
})
--]]

armor:register_armor("shop:boots_fast", {
	description = "Fast Boots",
	inventory_image = "shop_inv_boots_fast.png",
	groups = {armor_feet = 1, armor_use = 1000,},
	on_use = function(itemstack, user, pointed_thing)
		local t = armor.on_use(itemstack, user, pointed_thing)
		check_armor_privs(user)
		return t
	end,
	on_equip = check_armor_privs,
	on_unequip = check_armor_privs,
	on_destroy = check_armor_privs,
})

armor:register_armor("shop:shield_fly", {
	description = "Flying Shield",
	inventory_image = "shop_inv_shield_fly.png",
	groups = {armor_shield = 1, armor_use = 1000,},
	on_use = function(itemstack, user, pointed_thing)
		local t = armor.on_use(itemstack, user, pointed_thing)
		check_armor_privs(user)
		return t
	end,
	on_equip = check_armor_privs,
	on_unequip = check_armor_privs,
	on_destroy = check_armor_privs,
})

minetest.register_on_joinplayer(function(player)
	minetest.after(0.5, function()
		check_armor_privs(true) -- one-shot all
	end)
end)

minetest.register_on_respawnplayer(function(player)
	minetest.after(0.36, check_armor_privs, player) -- one-shot
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	if players[name] then
		players[name] = nil
	end
end)

check_armor_privs() -- loop all
