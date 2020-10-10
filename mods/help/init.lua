-- /mods/help is part of jastest
-- copyright 2020 james alexander stevenson
-- gnu gpl 3+

help = {}

local store = minetest.get_mod_storage()
local msg = "Type /spawn if you get stuck. " ..
		"Type /motd for more information. " ..
		"You may use the Minimap and Zoom. " ..
		"See this message with /info." 
local stuff = store:get_string("stuff")
if stuff == "" then
	stuff = msg
end

minetest.register_privilege("editor", {
	description = "Can edit help page",
	give_to_singleplayer = false,
	give_to_admin = false,
})

help.show_help = function(name, mod)
	local fs = "size[8,8.5]" ..
			"textarea[0.34,0.8;7.8,8.5;;" .. stuff .. ";]" ..
			forms.x
	local editor = minetest.check_player_privs(name, "editor")
	if editor then
		fs = fs .. "button[0,8;2,1;edit;Edit]"
	end
	minetest.show_formspec(name, "help:help", fs)
end

local show_editor = function(name)
	local fs = "size[8,8.5]" ..
			"textarea[0.34,0.8;7.8,8.5;edit;;" .. stuff .. "]" ..
			"button[0,8;2,1;save;Save]" ..
			forms.x
	minetest.show_formspec(name, "help:edit", fs)
end

local save = function(massage, player)
	local name = player:get_player_name()
	if minetest.check_player_privs(name, "editor") then
		store:set_string("stuff", massage)
		stuff = massage
		hud.message(player, "Help saved")
	end
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local name = player:get_player_name()
	if formname == "help:help" then
		if fields.edit then
			show_editor(name)
		end
		return
	elseif formname == "help:edit" then
		if fields.save then
			save(fields.edit, player)
		end
		return
	end
end)

minetest.register_chatcommand("info", {
	description = "It was this or man",
	params = "",
	privs = "shout",
	func = function(name, param)
		help.show_help(name)
	end,
})
