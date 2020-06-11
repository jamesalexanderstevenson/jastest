-- jaserver/mods/csm/init.lua
-- Copyright James Stevenson 2020
-- GPL v3+

jump = {}

jump.jump = function(name, sound)
	sound = sound or "jump_jump"
	local player = minetest.get_player_by_name(name)
	minetest.sound_play(sound, {object = player}, true)
	if csm then
		csm.players[name].jumping.jump = false
	end
end
