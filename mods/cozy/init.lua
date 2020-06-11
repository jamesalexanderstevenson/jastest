cozy = {}
cozy.players = {}

local anim = {
	stand = {
		frames = {x = 0,   y = 79},
		eyes = {
			{x = 0, y = 0, z = 0},
			{x = 0, y = 0, z = 0},
		},
		speed = 30,
	},
	lay = {
		frames = {x = 162, y = 166},
		eyes = {
			{x = 0, y = -13, z = 0},
			{x = 0, y = -7, z = 0},
		},
		speed = 30,
	},
	walk = {
		frames = {x = 168, y = 187},
		eyes = {
			{x = 0, y = 0, z = 0},
			{x = 0, y = 0, z = 0},
		},
		speed = 30,
	},
	mine = {
		frames = {x = 189, y = 198},
		eyes = {
			{x = 0, y = 0, z = 0},
			{x = 0, y = 0, z = 0},
		},
		speed = 30,
	},
	walk_mine = {
		frames = {x = 200, y = 219},
		eyes = {
			{x = 0, y = 0, z = 0},
			{x = 0, y = 0, z = 0},
		},
		speed = 30,
	},
	sit = {
		frames = {x = 81,  y = 160},
		eyes = {
			{x = 0, y = -7, z = 0},
			{x = 0, y = -4, z = 0},
		},
		speed = 30,
	},
}

cozy.reset = function(player, pos)
	local name = player:get_player_name()
	local player = minetest.get_player_by_name(name)
	if not player then
		return
	end
	if not pos then
		return
	end
	if vector.equals(vector.round(pos), vector.round(player:get_pos())) then
		minetest.after(0.34, cozy.reset, player, pos)
		return
	end
	player_api.player_attached[name] = false
	cozy.set(name)
end

cozy.set = function(name, posture, pos)
	posture = posture or "stand"
	if not anim[posture] then
		posture = "stand"
	end
	local player = minetest.get_player_by_name(name)
	if not player then
		return
	end
	if pos then
		player:set_pos(pos)
	end
	player:set_animation(anim[posture].frames, anim[posture].speed)
	player:set_eye_offset(anim[posture].eyes[1], anim[posture].eyes[2])
	if posture ~= "stand" then
		minetest.after(1.34, cozy.reset, player, player:get_pos())
		player_api.player_attached[name] = true
	else
		player_api.player_attached[name] = false
	end
	cozy.players[name] = posture
end

minetest.register_chatcommand("cozy", {
	description = "Set posture",
	params = "[sit|lay|stand]",
	privs = "interact",
	func = cozy.set
})

minetest.register_on_joinplayer(function(player)
	cozy.players[player:get_player_name()] = "stand"
end)

minetest.register_on_leaveplayer(function(player)
	cozy.players[player:get_player_name()] = nil
end)
