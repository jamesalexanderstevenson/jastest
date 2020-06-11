
local S = mobs.intllib


-- Penguin by D00Med

mobs:register_mob("mobs:penguin", {
	description = "Penguin",
	stepheight = 0.6,
	type = "animal",
	passive = true,
	reach = 1,
	hp_min = 10,
	hp_max = 20,
	armor = 100,
	collisionbox = {-0.2, -0.0, -0.2,  0.2, 0.5, 0.2},
	visual = "mesh",
	mesh = "mobs_penguin.b3d",
	visual_size = {x = 0.25, y = 0.25},
	textures = {
		{"mobs_penguin.png"},
	},
	sounds = {},
	makes_footstep_sound = true,
	walk_velocity = 1,
	run_velocity = 2,
	runaway = true,
	jump = false,
	stepheight = 1.1,
	drops = {
		{name = "mobs:meat_raw", chance = 1, min = 0, max = 1},
	},
	--water_damage = 0,
	--lava_damage = 50,
	--light_damage = 0,
	fear_height = 2,
	animation = {
		speed_normal = 15,
		stand_start = 1,
		stand_end = 20,
		walk_start = 25,
		walk_end = 45,
		fly_start = 75, -- swim animation
		fly_end = 95,
		-- 50-70 is slide/water idle
	},
	fly = true,
	fly_in = {"default:water_source", "default:water_flowing"},
	floats = 0,
	follow = {
		"ethereal:fish_raw", "mobs_fish:clownfish", "mobs_fish:tropical",
		"mobs_fish:clownfish_set", "mobs_fish:tropical_set"
	},
	view_range = 5,

	on_rightclick = function(self, clicker)

		-- feed or tame
		if mobs:feed_tame(self, clicker, 4, false, true) then return end
		if mobs:protect(self, clicker) then return end
		if mobs:capture_mob(self, clicker, 5, 50, 80, false, nil) then return end
	end,
})
--[[
mobs:spawn({
	name = "mobs:penguin",
	nodes = {"default:snowblock"},
	min_light = 14,
	interval = 60,
	chance = 20000,
	min_height = 0,
	max_height = 200,
	day_toggle = true,
})
--]]
mobs:register_egg("mobs:penguin", S("Penguin"), "mobs_penguin_inv.png")
