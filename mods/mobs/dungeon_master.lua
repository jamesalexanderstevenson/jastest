
local S = mobs.intllib
local b = {radius = 2, explode_center = true}

-- Dungeon Master by PilzAdam

mobs:register_mob("mobs:dungeon_master", {
	description = "Dungeon Master",
	type = "monster",
	passive = false,
	damage = 20,
	attack_type = "dogshoot",
	dogshoot_switch = 1,
	dogshoot_count_max = 12, -- shoot for 10 seconds
	dogshoot_count2_max = 3, -- dogfight for 3 seconds
	reach = 3,
	shoot_interval = 2.2,
	arrow = "mobs:fireball",
	shoot_offset = 1,
	hp_min = 20,
	hp_max = 40,
	armor = 100,
	collisionbox = {-0.7, -1, -0.7, 0.7, 1.6, 0.7},
	visual = "mesh",
	mesh = "mobs_dungeon_master.b3d",
	textures = {
		{"mobs_dungeon_master.png"},
		{"mobs_dungeon_master2.png"},
		{"mobs_dungeon_master3.png"},
	},
	makes_footstep_sound = true,
	sounds = {
		random = "mobs_dungeonmaster",
		shoot_attack = "mobs_fireball",
	},
	walk_velocity = 1,
	run_velocity = 2,
	jump = true,
	jump_height = 1,
	view_range = 15,
	drops = {
		{name = "default:mese_crystal_fragment", chance = 1, min = 0, max = 2},
		{name = "mobs:leather", chance = 2, min = 1, max = 2},
		{name = "default:mese_crystal", chance = 3, min = 0, max = 2},
		{name = "default:diamond", chance = 4, min = 0, max = 1},
		{name = "default:diamondblock", chance = 30, min = 0, max = 1},
	},
	--water_damage = 100,
	--lava_damage = 100,
	--light_damage = 0,
	fear_height = 3,
	animation = {
		stand_start = 0,
		stand_end = 19,
		walk_start = 20,
		walk_end = 35,
		punch_start = 36,
		punch_end = 48,
		shoot_start = 36,
		shoot_end = 48,
		speed_normal = 15,
		speed_run = 15,
	},
})

--[[
mobs:spawn({
	name = "mobs:dungeon_master",
	nodes = {"default:stone"},
	max_light = 5,
	chance = 9000,
	active_object_count = 1,
	max_height = -70,
})
--]]

mobs:register_egg("mobs:dungeon_master", S("Dungeon Master"), "fire_basic_flame.png", 1, true)


-- fireball (weapon)
mobs:register_arrow("mobs:fireball", {
	visual = "sprite",
	visual_size = {x = 1, y = 1},
	textures = {"mobs_fireball.png"},
	collisionbox = {-0.1, -0.1, -0.1, 0.1, 0.1, 0.1},
	velocity = 7,
	tail = 1,
	tail_texture = "mobs_fireball.png",
	tail_size = 10,
	glow = 5,
	expire = 0.1,

	on_activate = function(self, staticdata, dtime_s)
		-- make fireball indestructable
		self.object:set_armor_groups({immortal = 1, fleshy = 100})
	end,

	-- if player has a good weapon with 7+ damage it can deflect fireball
	on_punch = function(self, hitter, tflp, tool_capabilities, dir)

		if hitter and hitter:is_player() and tool_capabilities and dir then

			local damage = tool_capabilities.damage_groups and
				tool_capabilities.damage_groups.fleshy or 1

			local tmp = tflp / (tool_capabilities.full_punch_interval or 1.4)

			if damage > 6 and tmp < 4 then

				self.object:set_velocity({
					x = dir.x * self.velocity,
					y = dir.y * self.velocity,
					z = dir.z * self.velocity,
				})
			end
		end
	end,

	-- direct hit, no fire... just plenty of pain
	hit_player = function(self, player)
		local p = self.object:get_pos()
		if not minetest.is_protected(p, "") then
			tnt.boom(p, b)
		end
	end,

	hit_mob = function(self, player)
		local p = self.object:get_pos()
		if not minetest.is_protected(p, "") then
			tnt.boom(p, b)
		end
	end,

	-- node hit
	hit_node = function(self, pos, node)
		local p = self.object:get_pos()
		if not minetest.is_protected(p, "") then
			tnt.boom(p, b)
		end
	end
})

--minetest.override_item("default:obsidian", {on_blast = function() end})
