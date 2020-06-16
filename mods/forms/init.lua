forms = {}
forms.players = {}
forms.x = "button_exit[6.89,0;1,1;quit;X]"
forms.q = "button[6.13,0;1,1;help;?]"
forms.title = function(title)
	return "label[0,0;" .. title .. "]"
end

forms.wap = {}
forms.lines = {}

forms.log = function(msg, send_chat_all)
	if send_chat_all then
		minetest.chat_send_all(msg)
	end
	table.insert(forms.lines, 1, msg)
end

local settabs = {
	"Armor",
	"Chat",
	"Clothing",
	"Craftguide",
	"CSM",
	"Environment",
	"Homes",
	"Mobs",
	"Skins",
	"Sounds",
}

function forms.get_hotbar_bg(x,y)
	local out = ""
	for i=0,7,1 do
		out = out .."image["..x+i..","..y..";1,1;gui_hb_bg.png]"
	end
	return out
end

local main_fs = "size[8,8.5]"..
		"button_exit[0,1.5;2,1;safe_home;Home]" ..
		forms.x ..
		forms.q ..
		"button[0,0.5;2,1;setup;Setup]" ..
		"button_exit[0,2.5;2,1;safe_spawn;Spawn]" ..
		"list[current_player;main;0,4.25;8,1;]" ..
		"list[current_player;main;0,5.5;8,3;8]" ..
		"list[current_player;craft;2.5,0.5;3,3;]" ..
		"list[current_player;craftpreview;6.5,1.5;1,1;]" ..
		"list[current_player;backpack;6.5,2.5;1,1;]" ..
		"image[5.5,1.5;1,1;gui_furnace_arrow_bg.png^[transformR270]" ..
		"listring[current_player;main]" ..
		"listring[current_player;craft]" ..
		forms.get_hotbar_bg(0, 4.25)

forms.dialog = function(player, message, dialog, formname, title, no_chat_msg, fullsize)
	if not player then
		return
	end

	local name
	if type(player) == "string" then
		name = player
		player = minetest.get_player_by_name(name)
	else
		name = player:get_player_name()
	end

	if not message then
		message = "This space intentionally left blank."
	end

	if not no_chat_msg then
		minetest.chat_send_player(name, message)
	end

	message = minetest.formspec_escape(message)
	local formspec = ""
	if fullsize then
		formspec = formspec .. "size[8,8.5]"
	else
		formspec = formspec .. "size[8,4]"
	end
	formspec = formspec ..
		forms.x ..
		"textarea[0.35,0.76;8,4;;;" ..
				message .. "]" ..
	""
	if title then
		formspec = formspec .. "label[0,0;" .. title .. "]"
	end

	if formname then
		formspec = formspec ..
			"button_exit[1,3;2,1;cancel;Cancel]" ..
			"button_exit[6,3;1,1;ok;OK]" ..
		""
	else
		formname = "forms:message_dialog"
	end

	if dialog then
		return minetest.after(0, minetest.show_formspec,
				name, formname, formspec)
	else
		return formspec
	end
end

forms.chat = function(name, line, setup)
	local chat_str = table.concat(forms.lines, "\n")
	line = line or ""
	local fs = "size[8,8.5]" ..
			forms.x ..
			forms.q
	if not setup then
		fs = fs .. "button[0,0;2,1;settings;Settings]" ..
				"field[0.06,8.33;6.9,1;chatsend;;" .. line .. "]" ..
				"textarea[0.08,1;8.5,8.3;;;" .. minetest.formspec_escape(chat_str) .. "]" ..
				"field_close_on_enter[chatsend;false]" ..
				"image_button[6.54,8.1;0.83,0.83;chat_update.png;update;]" ..
				"button[7.24,8;1,1;ok;OK]"
	else
		local wa = forms.wap[name]
		fs = fs .. "button[0,0;2,1;back;Back]" ..
				"checkbox[0,1;walkie;Walkie activates;" .. wa .. "]" ..
				"field[0.06,8.33;7.6,1;termsend;;" .. line .. "]" ..
				"button[7.24,8;1,1;ok;OK]"
	end

	minetest.show_formspec(name, "forms:chat", fs)
end

minetest.register_on_joinplayer(function(player)
	player:set_inventory_formspec(main_fs)
	forms.wap[player:get_player_name()] = "true"
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	forms.wap[name] = nil
	if forms.players[name] then
		forms.players[name] = nil
	end
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local name = player:get_player_name()
	if formname == "forms:setup" then
		local tab = ""
		if fields.settabs then
			local id = minetest.explode_table_event(fields.settabs).row
			tab = settabs[id]
		elseif fields.help then
			help.show_help(name, "forms:setup")
		elseif fields.ambient then
			local meta = player:get_meta()
			local amb = meta:get_string("ambient") == "switched_on"
			if amb then
				meta:set_string("ambient", "")
				play.stop(name)
			else
				meta:set_string("ambient", "switched_on")
				play.start(name)
			end
		end

		if tab == "Skins" then
			skins.show(name)
		elseif tab == "Mobs" then
			mobs.show_gui(name)
		elseif tab == "Armor" then
			local fs = "size[8,6.5]" ..
					"list[detached:" .. name .. "_armor;armor;1,0;6,1;]" ..
					"list[current_player;main;0,2.5;8,4]"
			minetest.show_formspec(name, "armor:armor", fs)
		elseif tab == "Chat" then
			forms.chat(name, nil, true)
		elseif tab == "Clothing" then
			local fs = "size[8,6.5]" ..
				"list[detached:" .. name .. "_clothing;clothing;1,0;6,1;]" ..
				"list[current_player;main;0,2.5;8,4]" ..
			""
			minetest.show_formspec(name, "clothing:clothing", fs)
		elseif tab == "Craftguide" then
			minetest.registered_items["craftguide:book"].on_use(nil, minetest.get_player_by_name(name))
		elseif tab == "CSM" then
			local zb = csm.players[name].zooming.state == "enabled"
			local sb = csm.players[name].sprinting.state == "enabled"
			local jb = csm.players[name].jumping.state == "enabled"
			local zfb = csm.players[name].zoom_fov.state == "enabled"
			local fb = csm.players[name].fov.state == "enabled"
			local fs = "size[8,8.5]" ..
					forms.x ..
					forms.q ..
					forms.title("Client-side Modding") ..
					"checkbox[0,1.5;sprint;Sprinting;" .. tostring(sb) .. "]" ..
					"checkbox[0,2.25;jump;Jump (sound);" .. tostring(jb) .. "]" ..
					"checkbox[0,3;zoom;Zooming;" .. tostring(zb) .. "]" ..
					"checkbox[0,3.75;zoom_fov;Zoom FOV;" .. tostring(zfb) .. "]" ..
					"checkbox[0,4.5;fov;FOV;" .. tostring(fb) .. "]" ..
					"label[0,6;Check forum.minetest.net 'jastest' thread for CSM\n" ..
							"scripts. You can also send sprint_enable,\n" ..
							"jump_enable, ..., on your named mod channel."
			minetest.show_formspec(name, "forms:csm", fs)
		elseif tab == "Environment" then
			night.menu(name)
		elseif tab == "Homes" then
			sethome.homes(name)
		end
		return
	elseif formname == "forms:csm" then
		local m = csm.players[name].channel
		if fields.sprint or fields.jump or fields.zoom or fields.zoom_fov or fields.fov then
			forms.dialog(name, "Awaiting an acknowledgement on your named mod channel.", true, nil, nil, true, true)
			m:send_all("sprint_enable")
			csm.ack(name, "sprint_enable")
		elseif fields.jump then
		elseif fields.zoom then
		elseif fields.zoom_fov then
		elseif fields.fov then
		end
	elseif formname == "forms:chat" and not fields.quit then
		if fields.settings then
			forms.chat(name, nil, true)
		elseif fields.walkie then
			if forms.wap[name] == "true" then
				forms.wap[name] = "false"
			else
				forms.wap[name] = "true"
			end
		elseif fields.back then
			forms.chat(name)
		elseif fields.help then
			help.show_help(name, "chat")
		elseif fields.update then
			forms.chat(name, fields.chatsend)
		elseif fields.chatsend and fields.chatsend ~= "" then
			local cs = fields.chatsend
			-- Chat command handling originally from minetest/builtin/game/chat.lua
			if cs:sub(1, 1) == "/" then
			local cmd, param = string.match(cs, "^/([^ ]+) *(.*)")
				if not cmd then
					minetest.chat_send_player(name, "-!- Empty command")
					return forms.dialog(name, "-!- Empty command", true)
				end

				param = param or ""

				local cmd_def = minetest.registered_chatcommands[cmd]
				if not cmd_def then
					minetest.chat_send_player(name, "-!- Invalid command: " .. cmd)
					return forms.dialog(name, "-!- Invalid command: " .. cmd, true)
				end
				local has_privs, missing_privs = minetest.check_player_privs(name, cmd_def.privs)
				if has_privs then
					minetest.set_last_run_mod(cmd_def.mod_origin)
					local _, result = cmd_def.func(name, param)
					if result then
						minetest.chat_send_player(name, result)
						return forms.dialog(name, result, true)
					end
					forms.chat(name, "")
				else
					local cc = "You don't have permission"
							.. " to run this command (missing privileges: "
							.. table.concat(missing_privs, ", ") .. ")"
					minetest.chat_send_player(name, cc)
					return forms.dialog(name, cs, true)
				end
			else
				local it = "<" .. name .. "> " .. cs
				minetest.chat_send_all(it)
				print(it)
				table.insert(forms.lines, 1, it)
				forms.chat(name)
			end
		elseif fields.termsend then
			return terminal.display("mod", player, player:get_pos(), fields.termsend)
		end
	end

	-- Regular inventory below
	if formname ~= "" then
		return
	end
	if fields.help then
		help.show_help(name)
	elseif fields.safe_home then
		local p = sethome.get(name)
		if p then
			player:set_pos(p)
		else
			hud.message(player, "You do not currently have a home set, sending you to spawn!")
			hud.message(player, "Set home with /sethome command", 1)
			player:set_pos({x = 64, y = 65, z = 16})
		end
	elseif fields.safe_spawn then
		player:set_pos({x = 64, y = 65, z = 16})
	elseif fields.setup then
		local meta = player:get_meta()
		local amb = meta:get_string("ambient") == "switched_on" or false
		local st = table.concat(settabs, ",")
		local fs = "size[8,8.5]" ..
			forms.x ..
			forms.q ..
			forms.title("Settings and Features") ..
			"table[0,1;3.5,7.5;settabs;" .. st .. ";10]" ..
			"checkbox[4,1;ambient;Ambient effects;" .. tostring(amb) .. "]" ..
		""
		minetest.show_formspec(name, "forms:setup", fs)
	end
end)

minetest.register_chatcommand("chat", {
	description = "Show chat screen",
	params = "",
	privs = "shout",
	func = forms.chat,
})
