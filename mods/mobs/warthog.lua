
local S = mobs.intllib


-- Warthog originally by KrupnoPavel, B3D model by sirrobzeroone

mobs:register_mob("mobs:pumba", {
	description = "Pumba",
	stepheight = 0.6,
	type = "animal",
	passive = false,
	attack_type = "dogfight",
	group_attack = true,
	owner_loyal = true,
	attack_npcs = false,
	reach = 2,
	damage = 5,
	hp_min = 25,
	hp_max = 50,
	armor = 100,
	collisionbox = {-0.4, -0.01, -0.4, 0.4, 0.95, 0.4},
	visual = "mesh",
	mesh = "mobs_pumba.b3d",
	textures = {
		{"mobs_pumba.png"},
	},
	makes_footstep_sound = true,
	sounds = {
		random = "mobs_pig",
		attack = "mobs_pig_angry",
	},
	walk_velocity = 2,
	run_velocity = 3,
	jump = true,
	jump_height = 6,
	pushable = true,
	follow = {"default:apple", "farming:potato"},
	view_range = 10,
	drops = {
		{name = "mobs:pork_raw", chance = 1, min = 1, max = 3},
	},
	--water_damage = 0,
	--lava_damage = 5,
	--light_damage = 0,
	fear_height = 2,
	animation = {
		speed_normal = 15,
		stand_start = 25,
		stand_end = 55,
		walk_start = 70,
		walk_end = 100,
		punch_start = 70,
		punch_end = 100,
	},
	on_rightclick = function(self, clicker)

		if mobs:feed_tame(self, clicker, 8, true, true) then return end
		if mobs:protect(self, clicker) then return end
		if mobs:capture_mob(self, clicker, 0, 5, 50, false, nil) then return end
	end,
})

--[[
local spawn_on = {"default:dirt_with_grass"}
local spawn_by = {"group:grass"}

if minetest.get_mapgen_setting("mg_name") ~= "v6" then
	spawn_on = {"default:dirt_with_dry_grass"}
	spawn_by = {"group:dry_grass"}
end

if minetest.get_modpath("ethereal") then
	spawn_on = {"ethereal:mushroom_dirt"}
	spawn_by = {"flowers:mushroom_brown", "flowers:mushroom_brown"}
end
mobs:spawn({
	name = "mobs:pumba",
	nodes = spawn_on,
	neighbors = spawn_by,
	min_light = 14,
	interval = 60,
	chance = 8000, -- 15000
	min_height = 0,
	max_height = 200,
	day_toggle = true,
})
--]]
mobs:register_egg("mobs:pumba", S("Warthog"), "mobs_pumba_inv.png")
