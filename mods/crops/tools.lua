--[[

Copyright (C) 2015 - Auke Kok <sofar@foo-projects.org>

"crops" is free software; you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as
published by the Free Software Foundation; either version 2.1
of the license, or (at your option) any later version.

--]]

-- Intllib
local S = crops.intllib

minetest.register_tool("crops:watering_can", {
	description = S("Watering Can"),
	inventory_image = "crops_watering_can.png",
	liquids_pointable = true,
	range = 2.5,
	stack_max = 1,
	wear = 65535,
	tool_capabilities = {},
	on_use = function(itemstack, user, pointed_thing)
		local pos = pointed_thing.under
		local ppos = pos
		if not pos then
			return itemstack
		end
		-- filling it up?
		local wear = itemstack:get_wear()
		local nn = minetest.get_node(pos).name
		if nn == "default:water_source" or nn == "default:river_water_source" then
			if wear ~= 1 then
				minetest.sound_play("crops_watercan_entering", {pos=pos, gain=0.8}, true)
				minetest.after(math.random()/2, function(p)
					if math.random(2) == 1 then
						minetest.sound_play("crops_watercan_splash_quiet", {pos=p, gain=0.1}, true)
					end
					if math.random(3) == 1 then
						minetest.after(math.random()/2, function(pp)
							minetest.sound_play("crops_watercan_splash_small", {pos=pp, gain=0.7}, true)
						end, p)
					end
					if math.random(3) == 1 then
						minetest.after(math.random()/2, function(pp)
							minetest.sound_play("crops_watercan_splash_big", {pos=pp, gain=0.7}, true)
						end, p)
					end
				end, pos)
				local age = itemstack:get_meta():get_int("age")
				if age > 9 then
					hud.message(user, "Your watering can broke!")
					return ""
				end
				itemstack:get_meta():set_int("age", age + 1)
				itemstack:set_wear(1)
				minetest.set_node(pos, {name = nn:sub(1, -7) .. "flowing"})
			end
			return itemstack
		end
		-- using it on a top-half part of a plant?
		local meta = minetest.get_meta(pos)
		if meta:get_int("crops_top_half") == 1 then
			meta = minetest.get_meta({x=pos.x, y=pos.y-1, z=pos.z})
		end
		-- using it on a plant?
		local water = meta:get_int("crops_water")
		if water < 1 then
			return itemstack
		end
		-- empty?
		if wear == 65534 then
			return itemstack
		end
		crops.particles(ppos, 2)
		minetest.sound_play("crops_watercan_watering", {pos=pos, gain=0.8}, true)
		water = math.min(water + crops.settings.watercan, crops.settings.watercan_max)
		meta:set_int("crops_water", water)

		itemstack:set_wear(math.min(65534, wear + (65535 / crops.settings.watercan_uses)))
		return itemstack
	end,
})

minetest.register_tool("crops:hydrometer", {
	description = S("Hydrometer"),
	inventory_image = "crops_hydrometer.png",
	liquids_pointable = false,
	range = 2.5,
	stack_max = 1,
	tool_capabilities = {
	},
	on_use = function(itemstack, user, pointed_thing)
		local pos = pointed_thing.under
		if not pos then
			return itemstack
		end
		-- doublesize plant?
		local meta = minetest.get_meta(pos)
		if meta:get_int("crops_top_half") == 1 then
			meta = minetest.get_meta({x=pos.x, y=pos.y-1, z=pos.z})
		end

		-- using it on a plant?
		local water = meta:get_int("crops_water")
		if water == nil then
			itemstack:set_wear(65534)
			return itemstack
		end
		local age = itemstack:get_meta():get_int("age")
		age = age + 1
		if age > 99 then
			hud.message(user, "Your hydrometer broke!")
			return ""
		end
		itemstack:get_meta():set_int("age", age)
		itemstack:set_wear(65535 - ((65534 / 100) * water))
		return itemstack
	end,
})

minetest.register_craft({
	output = "crops:watering_can",
	recipe = {
		{ "default:steel_ingot", "", "" },
		{ "default:steel_ingot", "", "default:steel_ingot" },
		{ "", "default:steel_ingot", "" },
	},
})

minetest.register_craft({
	output = "crops:hydrometer",
	recipe = {
		{ "default:mese_crystal_fragment", "", "" },
		{ "", "default:steel_ingot", "" },
		{ "", "", "default:steel_ingot" },
	},
})
