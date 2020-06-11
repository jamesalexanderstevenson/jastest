
local S = mobs.intllib


-- Oerkki by PilzAdam

mobs:register_mob("mobs:oerkki", {
	description = "Oerkki",
	type = "monster",
	passive = false,
	attack_type = "dogfight",
	pathfinding = true,
	reach = 3,
	damage = 20,
	hp_min = 10,
	hp_max = 20,
	armor = 100,
	collisionbox = {-0.4, -1, -0.4, 0.4, 0.9, 0.4},
	visual = "mesh",
	mesh = "mobs_oerkki.b3d",
	textures = {
		{"mobs_oerkki.png"},
		{"mobs_oerkki2.png"},
	},
	makes_footstep_sound = false,
	sounds = {
		random = "mobs_oerkki",
	},
	walk_velocity = 1,
	run_velocity = 2,
	view_range = 10,
	jump = true,
	drops = {
		{name = "default:obsidian", chance = 3, min = 0, max = 2},
		{name = "default:gold_lump", chance = 2, min = 0, max = 2},
	},
	--water_damage = 100,
	--lava_damage = 100,
	--light_damage = 0,
	fear_height = 4,
	animation = {
		stand_start = 0,
		stand_end = 23,
		walk_start = 24,
		walk_end = 36,
		run_start = 37,
		run_end = 49,
		punch_start = 37,
		punch_end = 49,
		speed_normal = 15,
		speed_run = 15,
	},
	--[[
	replace_rate = 5,
	replace_what = {"default:torch"},
	replace_with = "air",
	replace_offset = -1,
	immune_to = {
		{"default:sword_wood", 0}, -- no damage
		{"default:gold_lump", -10}, -- heals by 10 points
	},
	--]]
})

--[[
mobs:spawn({
	name = "mobs:oerkki",
	nodes = {"default:stone"},
	max_light = 7,
	chance = 7000,
	max_height = -10,
})
--]]

mobs:register_egg("mobs:oerkki", S("Oerkki"), "default_obsidian.png", 1)
