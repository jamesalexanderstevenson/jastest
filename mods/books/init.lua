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
