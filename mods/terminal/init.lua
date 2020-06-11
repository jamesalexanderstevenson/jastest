-- Terminal mod for Minetest `Glitchtest' game
-- Copyright 2018 James Alexander Stevenson
-- GNU GPL 3

terminal = {}
local store = minetest.get_mod_storage()
local players = {}
local function close_fs(name, pos, source_n)
	minetest.close_formspec(name, "terminal" .. source_n ..
			minetest.pos_to_string(pos))
end

terminal.display = function(source, user, pos, input)
	if not source or not user then
		return
	end
	local pos = pos or user:get_pos()
	local input = input or ""
	input = input:sub(1, 400) -- Limit input length.
	local name = user:get_player_name()

	local cmd_table = {
		"+", "broadcast", "bye", "channel", "chat", "echo", "guestbook", "help",
		"hi", "hint", "info", "list", "name", "set", "sign", "warp", "waypoint",
	}

	local term_name, hint, info, wielded, meta
	local source_n
	if source == "item" then
		wielded = user:get_wielded_item()
		meta = wielded:get_meta()
		source_n = 1
	elseif source == "node" then
		meta = minetest.get_meta(pos)
		source_n = 2
	elseif source == "mod" then
		meta = store
		source_n = 3
	else
		return
	end
	minetest.sound_play("walkie_blip", {object = user}, true)

	-- Determine input.
	input = minetest.formspec_escape(input)
	term_name = meta:get_string("term_name") or "default"
	hint = "Some features are better hidden than others."
	info = "Welcome to terminal."

	local feedback = ""
	-- Get table with command/args.
	local command = input
	local args = {}
	if command:match("%w") then
		for i in command:gmatch"%S+" do
			table.insert(args, i)
		end
		command = args[1]
	end
	local output = ""
	if command == "" then
		if forms.wap[name] == "true" then
			feedback = function()
				forms.chat(name)
			end
		else
			command = "Yes Master?"
			output = ""
			feedback = ""
		end
	elseif command == "f" and source == "node" then
		if not minetest.is_protected(pos, name) then
			local nnn = minetest.get_node_or_nil(pos)
			if nnn and nnn.name == "walkie:intercomm" then
				meta:set_string("_on_function", minetest.serialize(args))
			end
		end
	elseif command == "+" then
		local new_args = {}
		for i = 2, #args do
			if type(tonumber(args[i])) == "number" then
				new_args[i] = tonumber(args[i])
			else
				output = "Err"
				break
			end
		end
		command = input
		local math = 0
		for _, v in pairs(new_args) do
			math = math + v
		end
		if output ~= "Err" then
			output = tostring(math)
		end
		feedback = ""
	elseif command == "say" then
		feedback = function()
			local chat_message = input:sub(5, -1)
			forms.message(name, chat_message)
			close_fs(name, pos, source_n)
		end
	elseif command == "broadcast" then
		output = "Broadcasting to all players with a walkie talkie on any channel."
		feedback = ""
	elseif (command == "bye" or
			command == "quit" or
			command == "exit") then
		output = "Shutting down..."
		feedback = ""
		minetest.after(1, function()
			close_fs(name, pos, source_n)
		end)
	elseif command == "channel" then
		local ch = tonumber(args[2])
		if type(ch) == "number" then
		end
		feedback = ""
	elseif command == "chat" then
		feedback = function()
			forms.chat(name)
		end
	elseif command == "echo" then
		if type(args[2]) == "string" then
			for i = 2, #args do
				if output == "" then
					output = args[i]
				else
					output = output .. " " .. args[i]
				end
			end
		else
			output = "Invalid usage, type help echo for more information."
		end
		feedback = ""
	elseif command == "guestbook" then
		command = input
		output = "Guestbook entries:\n" .. meta:get_string("guestbook") or ""
		feedback = "Those are the guestbook entries."
	elseif command == "help" then
		command = input
		if args[2] then
			output = "I don't know about " .. args[2]
			feedback = "Type help for a list of commands."
		else
			output = ""
			for i = 1, #cmd_table do
				output = output .. cmd_table[i] .. " "
			end
			feedback = "Type help <cmd> for more information"
		end
	elseif (command == "hi" or command == "hello") then
		output = "Hello."
		feedback = ""
	elseif command == "hint" then
		output = minetest.formspec_escape(hint)
		feedback = ""
	elseif command == "info" then
		output = minetest.formspec_escape(info)
		feedback = ""
	elseif command == "list" then
		if args[2] and args[2] == "warps" then
			if not args[3] then
				command = "warps list"
				output = "list warps <public|private>"
				feedback = "`public' or `private'"
			elseif args[3] == "private" then
				local bedss = beds.beds[name]
				if not bedss then
					return
				end
				for k, v in pairs(bedss) do
					output = output .. k .. ", "
				end
				output = output:sub(1, -3)
			elseif args[3] == "public" then
				for name, warps in pairs(beds.beds_public) do
					output = output .. name .. ": "
					for w_name, _ in pairs(warps) do
						output = output .. w_name .. ", "
					end
					output = output:sub(1, -3) .. "\n"
				end
			end
		else
			feedback = "List `warps', ..."
		end
	elseif command == "name" then
		command = input
		local args = args[2]
		if args then
			if args == term_name then
				output = "Correct!"
			elseif args ~= "" then
				meta:set_string("term_name", args)
				if source == "item" then
					user:set_wielded_item(wielded)
				end
				output = "Station name is now " .. args
			else
				output = "Invalid usage. Type help name for more information."
			end
		else
			output = "Station name is " .. term_name
		end
		feedback = ""
	elseif command == "set" then
		--[[
		if args[2] and args[2] == "spawn_switch" then
			local pm = user:get_meta()
			local ss = pm:get_int("spawn_switch")
			output = "Choose between clicking spawn in inventory " ..
				"sending you to server spawn location, or your " ..
				"own set respawn position." ..
			""
			if not args[3] then
				if ss == 1 then
					pm:set_int("spawn_switch", 0)
					output = output .. "\n\nSpawn switch is now off."
				else
					pm:set_int("spawn_switch", 1)
					output = output .. "\n\nSpawn switch is now on."
				end
			else
				if args[3] == "on" then
					pm:set_int("spawn_switch", 1)
					output = output .. "\n\nSpawn switch is now on."
				elseif args[3] == "off" then
					pm:set_int("spawn_switch", 0)
					output = output .. "\n\nSpawn switch is now off."
				else
					output = output .. "\n\nEnter `on' or `off'."
				end
			end
		end
		--]]
		feedback = "`home', `spawn_switch'"
	elseif command == "sign" then
		command = "Signed:" 
		local s = ""
		for i = 2, 120 do
			if not args[i] then
				break
			end
			if s == "" then
				s = args[i]
			else
				s = s .. " " .. args[i]
			end
		end
		meta:set_string("guestbook", s)
		if source == "item" then
			user:set_wielded_item(wielded)
		end
		output = s
		feedback = "[more]"
	elseif command == "warp" then
		--local user_beds = beds.beds[name]
		if user_beds and user_beds[args[2]] then
			user:set_pos(user_beds[args[2]])
			return close_fs(name, pos, source_n)
		end
	elseif command == "waypoint" then
		if args[2] and args[2] == "set" and
				args[3] and args[3] == "base" then
			local pteam = teams.get_team(name)
			--local base_loc = bases[pteam]
			if pteam and base_loc then
				feedback = function()
					print("show base")
				end
			end
		elseif args[2] and args[2] == "display" and
				args[3] and args[3] == "off" then
			feedback = function()
				print("toggle display")
			end
		else
			output = "set [base|home|bones|specify <pos>] | display [on | off]"
		end
	else
		output = "Unknown command. Type help for a list."
		feedback = ""
	end
	if type(feedback) == "function" then
		return feedback()
	end

	-- Collect data and display.
	output = output .. "\n\n\n\n" .. minetest.formspec_escape(feedback)
	local fs_command = "label[0,0.1;> " .. command .. "]"
	local fs_output = "textarea[0.334,0.667;8.88,5.14;;;" .. output .. "]"

	local formspec = "size[8.8,5.9]" ..
		"box[-.1,-.0;8.78,5.1;gray]" ..
		fs_command ..
		"field[0.18,5.6;8,1;input;;]" ..
		fs_output ..
		"button[7.78,5.3;1.15,1;ok;OK]" ..
		"field_close_on_enter[input;false]" ..
	""
	players[name].pos = pos
	return minetest.show_formspec(name, "terminal" .. source_n ..
			minetest.pos_to_string(pos), formspec)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname:sub(1, 8) ~= "terminal" or
			not player or fields.quit then
		return
	end
	local name = player:get_player_name()
	--local pos = minetest.string_to_pos(formname:sub(10))
	local pos = players[name].pos
	local source = tonumber(formname:sub(9, 9))
	if fields.ok and fields.input == "" then
		return close_fs(name, pos, source)
	end
	local s = {"item", "node", "mod"}
	source = s[source]
	terminal.display(source, player, pos, fields.input)
end)

minetest.register_on_joinplayer(function(player)
	players[player:get_player_name()] = {pos = player:get_pos()}
end)

minetest.register_on_leaveplayer(function(player)
	players[player:get_player_name()] = nil
end)

minetest.register_chatcommand("terminal", {
	description = "Display terminal interface",
	params = "[<input>]",
	privs = "shout",
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if not player then
			return true, "Invalid usage."
		end
		terminal.display("mod", player, player:get_pos(), param)
	end
})
