-- /mods/jump is part of jastest
-- copyright 2020 james alexander stevenson
-- gnu gpl 3+

jump = {}

jump.jump = function(name, sound)
	sound = sound or "jump_jump"
	local player = minetest.get_player_by_name(name)
	minetest.sound_play(sound, {object = player, gain = 0.2, pitch = 1.05}, true)
	if csm then
		csm.players[name].jumping.jump = false
	end
end
