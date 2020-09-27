-- /mods/shooter is part of jastest
-- copyright 2020 james alexander stevenson
-- gnu gpl 3+

local del = {}

local function kb(player, hitter, time_from_last_punch, tool_capabilities, unused_dir, damage)
        local dir = vector.subtract(player:get_pos(), hitter:get_pos())
        local d = vector.length(dir)
        if d ~= 0.0 then
                dir = vector.divide(dir, d)
        end
        local k = minetest.calculate_knockback(player, hitter, time_from_last_punch,
			tool_capabilities, dir, d, damage)
        local kdir = vector.multiply(dir, k * 13)
        return kdir
end

local toolcaps = {
	full_punch_interval = 0.7,
	max_drop_level = 1,
	groupcaps = {
		snappy = {
			times = {
				[1] = 1.90,
				[2] = 0.90,
				[3] = 0.30,
			}, uses = 40, maxlevel = 3,
		},
	},
	damage_groups = {fleshy = 1},
}

local function sh(itemstack, user, pointed_thing, boom)
	local t = pointed_thing
	local loaded = itemstack:get_name() == "shooter:shooter_loaded"
	local wear = itemstack:get_wear()
	local name = user:get_player_name()
	local dif = (minetest.get_us_time() - del[name]) / 1000000
	local swung = false
	if t.type == "object" then
		local o = t.ref
		local e = o:get_luaentity()
		if o:is_player() and o:get_hp() ~= 0 then
			swung = true
			if vector.distance(user:get_pos(), o:get_pos()) > 1 then
				return itemstack
			end
			local pf = kb(o, user, 0.76, toolcaps, nil, 2)
			o:add_player_velocity(pf)
			wear = wear + 1000
		elseif e then
			swung = true
			if vector.distance(user:get_pos(), o:get_pos()) > 3 then
				return itemstack
			end
			local pf = vector.direction(user:get_pos(), o:get_pos())
			pf = vector.multiply(pf, 9)
			o:add_velocity({x = pf.x, y = 3, z = pf.z})
			wear = wear + 1000
		end
		if boom and loaded then
			tnt.boom(o:get_pos(), {
				radius = 2,
				damage_radius = 1,
				explode_center = false,
				ignore_protection = false,
				owner = "",
			})
			wear = wear + 10000
			swung = true
		end
	elseif t.type == "node" then
		local ammo = minetest.get_node_or_nil(t.above)
		if boom and ammo and (ammo.name:find("default:lava_") == 1 or
				ammo.name:find("fire:") == 1) and
				not loaded then
			itemstack:set_name("shooter:shooter_loaded")
			return itemstack
		end
		ammo = minetest.get_node_or_nil(t.under)
		if boom and ammo and (ammo.name:find("default:lava_") == 1 or
				ammo.name:find("fire:") == 1) and
				not loaded then
			itemstack:set_name("shooter:shooter_loaded")
			return itemstack
		end
		if boom and loaded and vector.distance(user:get_pos(), t.above) < 1.67 then
			local pf = user:get_look_dir()
			user:add_player_velocity(vector.multiply(pf, {x = 0, y = -10, z = 0}))
			--if not minetest.is_protected(t.above, "") then
				tnt.boom(user:get_pos(), {
					radius = 1,
					damage_radius = 1,
					explode_center = true,
				})
			--end
			wear = wear + 10000
			swung = true
		elseif minetest.get_node_or_nil(t.above) and dif > 0.18 then
			del[name] = minetest.get_us_time()
			local pf = user:get_look_dir()
			local pit = vector.multiply(pf, {x = -3.34, y = -6.67, z = -3.34})
			if dif < 0.27 then
				pit = vector.multiply(pf, {x = -1.1, y = -1.5, z = -1.1})
				user:add_player_velocity(pit)
				wear = wear + 1000
				swung = true
			else
				user:add_player_velocity(pit)
				wear = wear + 100
				swung = true
			end
		end
	end
	if swung then
		itemstack:set_wear(wear)
		minetest.after(0, minetest.sound_play, "mobs_swing", {object = user}, true)
	end
	return itemstack
end

local function shoo(itemstack, user, pointed_thing)
	if pointed_thing.under then
		local bellow = minetest.get_node_or_nil(pointed_thing.under)
		local pop = minetest.registered_nodes[bellow.name]
		if pop and pop.on_rightclick then
			pop.on_rightclick(pointed_thing.under, bellow, user, itemstack, pointed_thing)
		end
	end

	return sh(itemstack, user, pointed_thing)
end

local function shoot(itemstack, user, pointed_thing)
	if pointed_thing.under then
		local bellow = minetest.get_node_or_nil(pointed_thing.under)
		local pop = minetest.registered_nodes[bellow.name]
		if pop and pop.on_punch then
			pop.on_punch(pointed_thing.under, bellow, user, pointed_thing)
		end
	end
	return sh(itemstack, user, pointed_thing, true)
end

minetest.register_alias("shooter", "shooter:shooter")

minetest.register_tool("shooter:shooter", {
	description = "Shooter",
	liquids_pointable = true,
	inventory_image = "shooter_shooter.png",
	--b1
	on_use = shoot,
	--b2
	on_place = shoo,
        on_secondary_use = shoo,
	--
})

minetest.register_tool("shooter:shooter_loaded", {
	description = "Shooter",
	liquids_pointable = true,
	inventory_image = "shooter_shooter_loaded.png",
	groups = {not_in_creative_inventory = 1},
	--b1
	on_use = shoot,
	--b2
	on_place = shoo,
        on_secondary_use = shoo,
	--
})

minetest.register_on_joinplayer(function(player)
	del[player:get_player_name()] = minetest.get_us_time()
end)

minetest.register_on_leaveplayer(function(player)
	del[player:get_player_name()] = nil
end)

minetest.register_craft({
	output = "default:stick",
	type = "shapeless",
	recipe = {"shooter:shooter"},
})

minetest.register_craft({
	output = "default:stick",
	type = "shapeless",
	recipe = {"shooter:shooter_loaded"},
})

minetest.register_craft({
	output = "shooter:shooter",
	recipe = {
		{"tnt:tnt_stick"},
		{"default:mese_crystal_fragment"},
		{"default:stick"},
	}
})

--setup.init("shooter:shooter", 100, true)
