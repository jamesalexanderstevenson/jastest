-- /mods/books is part of jastest
-- copyright 2020 james alexander stevenson
-- gnu gpl 3+

local S = default.get_translator

minetest.register_chatcommand("book", {
	params = "[text]",
	privs = "interact",
	description = "Book it",
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if not player then
			return false, "No player!"
		end
		local inv = player:get_inventory()
		if not inv:contains_item("main", "default:book") then
			return false, "[Server] No writeable book!"
		else
			inv:remove_item("main", "default:book")
		end
		local new_stack = ItemStack("default:book_written")
		if param ~= "" then
			local it = minetest.formspec_escape(param)
			local data = {}

			data.title = param:sub(1, 80)
			data.owner = name
			local short_title = data.title
			if #short_title > 38 then
				short_title = short_title:sub(1, 35) .. "..."
			end
			data.description = S("\"@1\" by @2", short_title, data.owner)
			data.text = param:sub(1, 10000)
			data.text = data.text:gsub("\r\n", "\n"):gsub("\r", "\n")
			data.page = 1
			data.page_max = math.ceil((#data.text:gsub("[^\n]", "") + 1) / 14)

			new_stack:get_meta():from_table({ fields = data })
			print(dump(data))
		end
		local inv = player:get_inventory()
		local putt = inv:add_item("main", new_stack)
		if putt then
			minetest.add_item(player:get_pos(), putt)
		end
		return true, "Book"
	end,
})

local welcome_book = [[default:book_written 1 0 "\u0001text\u0002Hearts regenerate if you're not starving, but if you're hungry you take damage.\n\nWalkie shows waypoint of last place of death.\n\nYou can sprint with AUX and hit it twice to toggle.\n\nDip the shooter in some lava to load it.\u0003owner\u0002jastvn\u0003description\u0002\u001b(T@default)\"\u001bFWelcome to jastest!\u001bE\" by \u001bFjastvn\u001bE\u001bE\u0003page_max\u00021\u0003title\u0002Welcome to jastest!\u0003page\u00021\u0003"]]

setup.init(welcome_book, 1)

--[[
local lpp = 14 -- Lines per book's page
local max_text_size = 10000
local max_title_size = 80
local short_title_size = 35

local function on_place(itemstack, placer, pointed_thing)
	if minetest.is_protected(pointed_thing.above, placer:get_player_name()) then
		-- TODO: record_protection_violation()
		return itemstack
	end

	local stack = ItemStack({name = "books:book_closed"})
	stack:get_meta():from_table(itemstack:get_meta():to_table())
	local _, placed = minetest.item_place(stack, placer, pointed_thing)
	if placed then
		itemstack:take_item()
	end
	return itemstack
end

local function after_place_node(pos, placer, itemstack, pointed_thing)
	local data = itemstack:get_meta():to_table()
	data = data.fields or nil
	if data and data.owner then
		local meta = minetest.get_meta(pos)
		meta:set_string("title", data.title)
		meta:set_string("text", data.text)
		meta:set_string("owner", data.owner)
		meta:set_string("text_len", data.text_len)
		meta:set_string("page", data.page)
		meta:set_string("page_max", data.page_max)
		meta:set_string("infotext", data.title .. "\n\n" ..
				"by " .. data.owner)
		meta:set_string("description", data.description)
	end
end

local function formspec_display(player_name, pos)
	-- Courtesy of minetest_game/mods/default/craftitems.lua
	local title, text, owner = "", "", player_name
	local page, page_max, lines, string = 1, 1, {}, ""

	local meta = minetest.get_meta(pos)
	local tbl = meta:to_table()
	if tbl.fields.owner then
		title = meta:get_string("title")
		text = meta:get_string("text")
		owner = meta:get_string("owner")

		for str in (text .. "\n"):gmatch("([^\n]*)[\n]") do
			lines[#lines+1] = str
		end

		if tbl.fields.page then
			page = tbl.fields.page
			page_max = tbl.fields.page_max

			for i = ((lpp * page) - lpp) + 1, lpp * page do
				if not lines[i] then break end
				string = string .. lines[i] .. "\n"
			end
		end
	end

	local formspec
	if owner == player_name then
		formspec = "size[8,8]" ..
			"field[0.5,1;7.5,0;title;Title:;" ..
				minetest.formspec_escape(title) .. "]" ..
			"textarea[0.5,1.5;7.5,7;text;Contents:;" ..
				minetest.formspec_escape(text) .. "]" ..
			"button_exit[2.5,7.5;3,1;save;Save]"
	else
		formspec = "size[8,8]" ..
			"label[0.5,0.5;by " .. owner .. "]" ..
			"tablecolumns[color;text]" ..
			"tableoptions[background=#00000000;highlight=#00000000;border=false]" ..
			"table[0.4,0;7,0.5;title;#FFFF00," .. minetest.formspec_escape(title) .. "]" ..
			"textarea[0.5,1.5;7.5,7;;" ..
				minetest.formspec_escape(string ~= "" and string or text) .. ";]" ..
			"button[2.4,7.6;0.8,0.8;book_prev;<]" ..
			"label[3.2,7.7;Page " .. page .. " of " .. page_max .. "]" ..
			"button[4.9,7.6;0.8,0.8;book_next;>]"
	end

	minetest.show_formspec(player_name,
			"books:book_" .. minetest.pos_to_string(pos), formspec)
end

local function on_rightclick(pos, node, clicker, itemstack, pointed_thing)
	if node.name == "books:book_closed" then
		node.name = "books:book_open"
		minetest.swap_node(pos, node)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext",
				meta:get_string("text"))
	elseif node.name == "books:book_open" then
		local player_name = clicker:get_player_name()
		formspec_display(player_name, pos)
	end
end

local function on_punch(pos, node, puncher, pointed_thing)
	if node.name == "books:book_open" then
		node.name = "books:book_closed"
		minetest.swap_node(pos, node)
		local meta = minetest.get_meta(pos)
		if meta:get_string("owner") ~= "" then
			meta:set_string("infotext",
					meta:get_string("title") .. "\n\n" ..
					"by " .. meta:get_string("owner"))
		end
	end
end

local function on_dig(pos, node, digger)
	if minetest.is_protected(pos, digger:get_player_name()) then
		-- TODO: record_protection_violation()
		return false
	end

	local meta = minetest.get_meta(pos)
	local data = {
		title = meta:get_string("title"),
		text = meta:get_string("text"),
		owner = meta:get_string("owner"),
		text_len = meta:get_int("text_len"),
		page = meta:get_int("page"),
		page_max = meta:get_int("page_max"),
		description = meta:get_string("description")
	}
	local stack
	if data.owner ~= "" then
		stack = ItemStack({name = "books:book_written"})
		stack:get_meta():from_table({fields = data})
	else
		stack = ItemStack({name = "books:book"})
	end

	local adder = digger:get_inventory():add_item("main", stack)
	if adder then
		minetest.item_drop(adder, digger, digger:get_pos())
	end
	minetest.remove_node(pos)
end

local function book_on_use(itemstack, user)
	local player_name = user:get_player_name()
	local meta = itemstack:get_meta()
	local title, text, owner = "", "", player_name
	local page, page_max, lines, string = 1, 1, {}, ""

	-- Backwards compatibility
	--local old_data = minetest.deserialize(itemstack:get_metadata())
	--if old_data then
		--meta:from_table({ fields = old_data })
	--end

	local data = meta:to_table().fields

	if data.owner then
		title = data.title
		text = data.text
		owner = data.owner

		for str in (text .. "\n"):gmatch("([^\n]*)[\n]") do
			lines[#lines+1] = str
		end

		if data.page then
			page = data.page
			page_max = data.page_max

			for i = ((lpp * page) - lpp) + 1, lpp * page do
				if not lines[i] then break end
				string = string .. lines[i] .. "\n"
			end
		end
	end

	local formspec
	if owner == player_name then
		formspec = "size[8,8]" ..
			"field[0.5,1;7.5,0;title;Title:;" ..
				minetest.formspec_escape(title) .. "]" ..
			"textarea[0.5,1.5;7.5,7;text;Contents:;" ..
				minetest.formspec_escape(text) .. "]" ..
			"button_exit[2.5,7.5;3,1;save;Save]"
	else
		formspec = "size[8,8]" ..
			"label[0.5,0.5;by " .. owner .. "]" ..
			"tablecolumns[color;text]" ..
			"tableoptions[background=#00000000;highlight=#00000000;border=false]" ..
			"table[0.4,0;7,0.5;title;#FFFF00," .. minetest.formspec_escape(title) .. "]" ..
			"textarea[0.5,1.5;7.5,7;;" ..
				minetest.formspec_escape(string ~= "" and string or text) .. ";]" ..
			"button[2.4,7.6;0.8,0.8;book_prev;<]" ..
			"label[3.2,7.7;Page " .. page .. " of " .. page_max .. "]" ..
			"button[4.9,7.6;0.8,0.8;book_next;>]"
	end

	minetest.show_formspec(player_name, "books:book", formspec)
	return itemstack
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "books:book" then
		local inv = player:get_inventory()
		local stack = player:get_wielded_item()

		if fields.save and fields.title and fields.text
				and fields.title ~= "" and fields.text ~= "" then
			local new_stack, data
			if stack:get_name() ~= "books:book_written" then
				local count = stack:get_count()
				if count == 1 then
					stack:set_name("books:book_written")
				else
					stack:set_count(count - 1)
					new_stack = ItemStack("books:book_written")
				end
			else
				data = stack:get_meta():to_table().fields
			end

			if data and data.owner and data.owner ~= player:get_player_name() then
				return
			end

			if not data then data = {} end
			data.title = fields.title:sub(1, max_title_size)
			data.owner = player:get_player_name()
			local short_title = data.title
			-- Don't bother triming the title if the trailing dots would make it longer
			if #short_title > short_title_size + 3 then
				short_title = short_title:sub(1, short_title_size) .. "..."
			end
			data.description = "\""..short_title.."\" by "..data.owner
			data.text = fields.text:sub(1, max_text_size)
			data.text = data.text:gsub("\r\n", "\n"):gsub("\r", "\n")
			data.page = 1
			data.page_max = math.ceil((#data.text:gsub("[^\n]", "") + 1) / lpp)

			if new_stack then
				new_stack:get_meta():from_table({ fields = data })
				if inv:room_for_item("main", new_stack) then
					inv:add_item("main", new_stack)
				else
					minetest.add_item(player:get_pos(), new_stack)
				end
			else
				stack:get_meta():from_table({ fields = data })
			end

		elseif fields.book_next or fields.book_prev then
			local data = stack:get_meta():to_table().fields
			if not data or not data.page then
				return
			end

			data.page = tonumber(data.page)
			data.page_max = tonumber(data.page_max)

			if fields.book_next then
				data.page = data.page + 1
				if data.page > data.page_max then
					data.page = 1
				end
			else
				data.page = data.page - 1
				if data.page == 0 then
					data.page = data.page_max
				end
			end

			stack:get_meta():from_table({fields = data})
			stack = book_on_use(stack, player)
		end

		-- Update stack
		player:set_wielded_item(stack)
	elseif formname:sub(1, 11) == "books:book_" then
		if fields.save and fields.title ~= "" and fields.text ~= "" then
			local pos = minetest.string_to_pos(formname:sub(12))
			local node = minetest.get_node(pos)
			local meta = minetest.get_meta(pos)

			local short_title = fields.title
			-- Don't bother triming the title if the trailing dots would make it longer
			if #short_title > short_title_size + 3 then
				short_title = short_title:sub(1, short_title_size) .. "..."
			end
			local name = player:get_player_name()
			meta:set_string("title", fields.title:sub(1, max_title_size))
			meta:set_string("text", fields.text)
			meta:set_string("owner", name)
			meta:set_string("infotext", fields.text)
			meta:set_int("text_len", fields.text:len())
			meta:set_int("page", 1)
			meta:set_int("page_max", math.ceil((fields.text:gsub("[^\n]", ""):len() + 1) / lpp))
			meta:set_string("description", "\"" .. short_title .. "\" by " .. name)
		elseif fields.book_next or fields.book_prev then
			local pos = minetest.string_to_pos(formname:sub(12))
			local node = minetest.get_node(pos)
			local meta = minetest.get_meta(pos)

			if fields.book_next then
				meta:set_int("page", meta:get_int("page") + 1)
				if meta:get_int("page") > meta:get_int("page_max") then
					meta:set_int("page", 1)
				end
			elseif fields.book_prev then
				meta:set_int("page", meta:get_int("page") - 1)
				if meta:get_int("page") == 0 then
					meta:set_int("page", meta:get_int("page_max"))
				end
			end

			formspec_display(player:get_player_name(), pos)
		end
	end
end)

minetest.register_node("books:book_open", {
	description = "Book Open (you hacker you!)",
	inventory_image = "default_book.png",
	tiles = {
		"books_book_open_top.png", -- Top
		"books_book_open_bottom.png", -- Bottom
		"books_book_open_side.png", -- Right
		"books_book_open_side.png", -- Left
		"books_book_open_front.png", -- Back
		"books_book_open_front.png" -- Front
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.375, -0.47, -0.282, 0.375, -0.4125, 0.282}, -- Top
			{-0.4375, -0.5, -0.3125, 0.4375, -0.47, 0.3125},
		}
	},
	--groups = {attached_node = 1},
	on_punch = on_punch,
	on_rightclick = on_rightclick,
	--preserve_metadata = preserve_metadata,
})

minetest.register_node("books:book_closed", {
	description = "Book Closed (you hacker you!)",
	inventory_image = "default_book.png",
	tiles = {
		"books_book_closed_topbottom.png", -- Top
		"books_book_closed_topbottom.png", -- Bottom
		"books_book_closed_right.png", -- Right
		"books_book_closed_left.png", -- Left
		"books_book_closed_front.png^[transformFX", -- Back
		"books_book_closed_front.png" -- Front
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.25, -0.5, -0.3125, 0.25, -0.35, 0.3125},
		}
	},
	groups = {dig_immediate = 2},--, attached_node = 1},
	on_dig = on_dig,
	on_rightclick = on_rightclick,
	after_place_node = after_place_node,
	--preserve_metadata = preserve_metadata,
})

minetest.register_craftitem("books:book", {
	description = "Book",
	inventory_image = "default_book.png",
	groups = {book = 1, flammable = 3},
	on_use = book_on_use,
	on_place = on_place,
})

minetest.register_craftitem("books:book_written", {
	description = "Book With Text",
	inventory_image = "default_book_written.png",
	groups = {book = 1, not_in_creative_inventory = 1, flammable = 3},
	stack_max = 1,
	on_use = book_on_use,
	on_place = on_place,
})

minetest.register_craft({
	type = "shapeless",
	output = "books:book_written",
	recipe = {"books:book", "books:book_written"}
})

minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
	if itemstack:get_name() ~= "books:book_written" then
		return
	end

	local original
	local index
	for i = 1, player:get_inventory():get_size("craft") do
		if old_craft_grid[i]:get_name() == "books:book_written" then
			original = old_craft_grid[i]
			index = i
		end
	end
	if not original then
		return
	end
	local copymeta = original:get_meta():to_table()
	-- copy of the book held by player's mouse cursor
	itemstack:get_meta():from_table(copymeta)
	-- put the book with metadata back in the craft grid
	craft_inv:set_stack("craft", index, original)
end)

local bookshelf_formspec =
	"size[8,7;]" ..
	"list[context;books;0,0.3;8,2;]" ..
	"list[current_player;main;0,2.85;8,1;]" ..
	"list[current_player;main;0,4.08;8,3;8]" ..
	"listring[context;books]" ..
	"listring[current_player;main]" ..
	forms.get_hotbar_bg(0,2.85)

local function update_bookshelf(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local invlist = inv:get_list("books")

	local formspec = bookshelf_formspec
	-- Inventory slots overlay
	local bx, by = 0, 0.3
	local n_written, n_empty = 0, 0
	for i = 1, 16 do
		if i == 9 then
			bx = 0
			by = by + 1
		end
		local stack = invlist[i]
		if stack:is_empty() then
			formspec = formspec ..
				"image[" .. bx .. "," .. by .. ";1,1;default_bookshelf_slot.png]"
		else
			local metatable = stack:get_meta():to_table() or {}
			if metatable.fields and metatable.fields.text then
				n_written = n_written + stack:get_count()
			else
				n_empty = n_empty + stack:get_count()
			end
		end
		bx = bx + 1
	end
	meta:set_string("formspec", formspec)
	if n_written + n_empty == 0 then
		meta:set_string("infotext", "Empty Bookshelf")
	else
		meta:set_string("infotext", "Bookshelf (" .. n_written ..
			" written, " .. n_empty .. " empty books)")
	end
end

minetest.register_node("books:bookshelf", {
	description = "Bookshelf",
	tiles = {"default_wood.png", "default_wood.png", "default_wood.png",
		"default_wood.png", "default_bookshelf.png", "default_bookshelf.png"},
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {choppy = 3, oddly_breakable_by_hand = 2, flammable = 3},
	sounds = music.sounds.nodes.wood,

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size("books", 8 * 2)
		update_bookshelf(pos)
	end,
	can_dig = function(pos,player)
		local inv = minetest.get_meta(pos):get_inventory()
		return inv:is_empty("books")
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack)
		if minetest.get_item_group(stack:get_name(), "book") ~= 0 then
			return stack:get_count()
		end
		return 0
	end,
	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		minetest.log("action", player:get_player_name() ..
			" moves stuff in bookshelf at " .. minetest.pos_to_string(pos))
		update_bookshelf(pos)
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name() ..
			" puts stuff to bookshelf at " .. minetest.pos_to_string(pos))
		update_bookshelf(pos)
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name() ..
			" takes stuff from bookshelf at " .. minetest.pos_to_string(pos))
		update_bookshelf(pos)
	end,
	on_blast = function(pos)
		local drops = {}
		inventory.get_inventory_drops(pos, "books", drops)
		drops[#drops+1] = "books:bookshelf"
		minetest.remove_node(pos)
		return drops
	end,
})

minetest.register_node("books:multishelf", {
	description = "Multishelf",
	on_rotate = screwdriver.rotate_simple,
	tiles = {
		"default_wood.png", "default_wood.png", "default_wood.png",
		"default_wood.png", "default_wood.png^books_multishelf.png"
	},
	paramtype2 = "facedir",
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size("main", 8 * 2)
		inv:set_list("main", {})
		meta:set_string("formspec",
				"size[8,6.5]list[context;main;0,0;8,2]" ..
				"list[current_player;main;0,2.5;8,4]listring[]")
	end,
	groups = {choppy = 3, oddly_breakable_by_hand = 2, flammable = 3},
	sounds = music.sounds.nodes.wood,
})

minetest.register_craft({
	output = "books:multishelf",
	recipe = {
		{"group:wood", "group:wood", "group:wood"},
		{"group:vessel", "group:book", "group:vessel"},
		{"group:wood", "group:wood", "group:wood"}
	}
})

minetest.register_craft({
	type = "fuel",
	recipe = "books:bookshelf",
	burntime = 30,
})

minetest.register_craft({
	type = "fuel",
	recipe = "books:book",
	burntime = 3,
})

minetest.register_craft({
	type = "fuel",
	recipe = "books:book_written",
	burntime = 3,
})

minetest.register_craft({
	output = "books:book",
	recipe = {
		{"papyrus:paper"},
		{"papyrus:paper"},
		{"papyrus:paper"},
	}
})

minetest.register_craft({
	output = "books:bookshelf",
	recipe = {
		{"group:wood", "group:wood", "group:wood"},
		{"books:book", "books:book", "books:book"},
		{"group:wood", "group:wood", "group:wood"},
	}
})
--]]
