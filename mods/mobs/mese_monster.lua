
local S = mobs.intllib


-- Mese Monster by Zeg9

mobs:register_mob("mobs:mese_monster", {
	description = "Mese Monster",
	type = "monster",
	passive = false,
	attack_type = "shoot",
	shoot_interval = 0.5,
	arrow = "mobs:mese_arrow",
	shoot_offset = 2,
	damage = 10,
	hp_min = 10,
	hp_max = 20,
	armor = 100,
	collisionbox = {-0.5, -1.5, -0.5, 0.5, 0.5, 0.5},
	visual = "mesh",
	mesh = "zmobs_mese_monster.x",
	textures = {
		{"zmobs_mese_monster.png"},
	},
	blood_texture = "default_mese_crystal_fragment.png",
	makes_footstep_sound = true,
	sounds = {
		random = "mobs_mesemonster",
		shoot_attack = {name = "mobs_fireball", gain = 0.25},
		war_cry = "mobs_oerkki",
	},
	view_range = 10,
	walk_velocity = 1,
	run_velocity = 2,
	jump = false,
	jump_height = 0,
	fall_damage = 0,
	fall_speed = -1,
	stepheight = 2.1,
	drops = {
		{name = "default:mese_crystal", chance = 9, min = 0, max = 2},
		{name = "default:mese_crystal_fragment", chance = 1, min = 0, max = 2},
	},
	--water_damage = 100,
	--lava_damage = 100,
	--light_damage = 0,
	fly = true,
	fly_in = "air",
	animation = {
		speed_normal = 15,
		speed_run = 15,
		stand_start = 0,
		stand_end = 14,
		walk_start = 15,
		walk_end = 38,
		run_start = 40,
		run_end = 63,
		punch_start = 40,
		punch_end = 63,
	},
})


mobs:spawn({
	name = "mobs:mese_monster",
	nodes = {"default:stone"},
	max_light = 7,
	chance = 5000,
	active_object_count = 1,
	max_height = -20,
})


mobs:register_egg("mobs:mese_monster", S("Mese Monster"), "default_mese_block.png", 1)


-- mese arrow (weapon)
mobs:register_arrow("mobs:mese_arrow", {
	visual = "sprite",
--	visual = "wielditem",
	visual_size = {x = 0.5, y = 0.5},
	textures = {"default_mese_crystal_fragment.png"},
	--textures = {"default:mese_crystal_fragment"},
	velocity = 6,
--	rotate = 180,

	hit_player = function(self, player)
		player:punch(self.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fleshy = 2},
		}, nil)
	end,

	hit_mob = function(self, player)
		player:punch(self.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fleshy = 2},
		}, nil)
	end,

	hit_node = function(self, pos, node)
	end
})

-- 9x mese crystal fragments = 1x mese crystal
minetest.register_craft({
	output = "default:mese_crystal",
	recipe = {
		{"default:mese_crystal_fragment", "default:mese_crystal_fragment", "default:mese_crystal_fragment"},
		{"default:mese_crystal_fragment", "default:mese_crystal_fragment", "default:mese_crystal_fragment"},
		{"default:mese_crystal_fragment", "default:mese_crystal_fragment", "default:mese_crystal_fragment"},
	}
})
