
local S = mobs.intllib

-- Bee by KrupnoPavel (.b3d model by sirrobzeroone)

mobs:register_mob("mobs:bee", {
	description = "Bee",
	type = "animal",
	passive = true,
	hp_min = 1,
	hp_max = 2,
	armor = 100,
	collisionbox = {-0.2, -0.01, -0.2, 0.2, 0.5, 0.2},
	visual = "mesh",
	mesh = "mobs_bee.b3d",
	textures = {
		{"mobs_bee.png"},
	},
	blood_texture = "mobs_bee_inv.png",
	blood_amount = 1,
	makes_footstep_sound = false,
	sounds = {
		random = "mobs_bee",
	},
	walk_velocity = 1,
	jump = false,
	jump_height = 1,
	drops = {
		{name = "xdecor:honey", chance = 2, min = 1, max = 2},
	},
	--water_damage = 100,
	--lava_damage = 100,
	--light_damage = 0,
	fall_damage = 0,
	fall_speed = -1,
	fly = true,
	fly_in = "air",
	animation = {
		speed_normal = 15,
		stand_start = 0,
		stand_end = 30,
		walk_start = 35,
		walk_end = 65,
	},
	on_rightclick = function(self, clicker)
		mobs:capture_mob(self, clicker, 50, 90, 0, true, "mobs:bee")
	end,
	do_custom = function(self)
		self.object:add_velocity({
				x = math.random(-1.1, 1.1),
				y = math.random(-0.1, 0.01),
				z = math.random(-1.1, 1.1)})
		if not self.object:get_velocity() then
			return
		end
		if self.object:get_velocity().y > 0.1 then
			self.object:add_velocity({x = 0, y = -0.1, z = 0})
		end
	end,
--	after_activate = function(self, staticdata, def, dtime)
--		print ("------", self.name, dtime, self.health)
--	end,
})

--[[
mobs:spawn({
	name = "mobs:bee",
	nodes = {"group:flower"},
	min_light = 14,
	interval = 60,
	chance = 7000,
	min_height = 3,
	max_height = 200,
	day_toggle = true,
})
--]]

mobs:register_egg("mobs:bee", S("Bee"), "mobs_bee_inv.png")
