--[[ Thanks to sofar for helping with that code.
Recommended setting in minetest.conf (requires 0.4.14 or newer) :
	nodetimer_interval = 0.1
]]

local plate = {}
screwdriver = screwdriver or {}

local function door_toggle(pos_actuator, pos_door, player)
	local actuator = minetest.get_node(pos_actuator)
	if actuator.name:sub(-4) == "_off" then
		minetest.set_node(pos_actuator,
			{name=actuator.name:gsub("_off", "_on"), param2=actuator.param2})
	end

	local name = minetest.get_node(pos_door).name
	if name == "mese:meselamp_off" then
		minetest.swap_node(pos_door, {name = "default:meselamp"})
	elseif name == "default:meselamp" then
		minetest.swap_node(pos_door, {name = "mese:meselamp_off"})
	end
	if name == "funblock:block" then
		minetest.registered_nodes["funblock:block"]._runit(player, pos_door)
	end

	local door = doors.get(pos_door)
	minetest.after(2, function()
		if minetest.get_node(pos_actuator).name:sub(-3) == "_on" then
			minetest.set_node(pos_actuator,
					{name = actuator.name, param2 = actuator.param2})
		end
		if door then
			door:close(player)
		end
	end)

	if door then
		door:open(player)
	end
end

function plate.construct(pos)
	local timer = minetest.get_node_timer(pos)
	timer:start(0.1)
end

function plate.timer(pos)
	local objs = minetest.get_objects_inside_radius(pos, 0.8)
	if objs == {} or not doors.get then return true end
	local minp = {x=pos.x-2, y=pos.y-1, z=pos.z-2}
	local maxp = {x=pos.x+2, y=pos.y+1, z=pos.z+2}
	local doors = minetest.find_nodes_in_area(minp, maxp, {"group:door", "funblock:block", "group:mese"})

	for _, player in pairs(objs) do
		if player:is_player() then
			for i = 1, #doors do
				door_toggle(pos, doors[i], player)
			end
			break
		end
	end
	return true
end

function plate.register(material, desc, def)
	minetest.register_node("mechanisms:pressure_"..material.."_off", {
		description = desc.." Pressure Plate",
		tiles = {"mechanisms_pressure_"..material..".png"},
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = {{-0.4375, -0.5, -0.4375, 0.4375, -0.4375, 0.4375}}
		},
		groups = def.groups,
		sounds = def.sounds,
		sunlight_propagates = true,
		paramtype = "light",
		paramtype2 = "facedir",
		on_rotate = screwdriver.rotate_simple,
		on_construct = plate.construct,
		on_timer = plate.timer
	})
	minetest.register_node("mechanisms:pressure_"..material.."_on", {
		tiles = {"mechanisms_pressure_"..material..".png"},
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = {{-0.4375, -0.5, -0.4375, 0.4375, -0.475, 0.4375}}
		},
		groups = def.groups,
		sounds = def.sounds,
		drop = "mechanisms:pressure_"..material.."_off",
		sunlight_propagates = true,
		paramtype = "light",
		paramtype2 = "facedir",
		on_rotate = screwdriver.rotate_simple
	})
end

local function hit_it(pos, node, clicker)
	local c = clicker:get_player_control()
	if (c.aux1 or c.sneak) and c.LMB then
		return itemstack
	end
	--[[
	if not doors.get then
		return itemstack
	end
	--]]
	local minp = {x=pos.x-2, y=pos.y-1, z=pos.z-2}
	local maxp = {x=pos.x+2, y=pos.y+1, z=pos.z+2}
	local doors = minetest.find_nodes_in_area(minp, maxp, {"group:door", "funblock:block", "group:mese"})

	for i = 1, #doors do
		door_toggle(pos, doors[i], clicker)
	end
end


plate.register("wood", "Wooden", {
	sounds = default.node_sound_wood_defaults(),
	groups = {choppy=3, oddly_breakable_by_hand=2, flammable=2}
})

plate.register("stone", "Stone", {
	sounds = default.node_sound_stone_defaults(),
	groups = {cracky=3, oddly_breakable_by_hand=2}
})

minetest.register_node("mechanisms:lever_off", {
	description = "Lever",
	tiles = {"mechanisms_lever_off.png"},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {{-0.375, -0.4375, 0.4375, 0.375, 0.4375, 0.5}}
	},
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults(),
	sunlight_propagates = true,
	paramtype = "light",
	paramtype2 = "facedir",
	on_rotate = screwdriver.rotate_simple,
	on_punch = hit_it,
	on_rightclick = hit_it,
})

minetest.register_node("mechanisms:lever_on", {
	tiles = {"mechanisms_lever_on.png"},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {{-0.375, -0.4375, 0.4375, 0.375, 0.4375, 0.5}}
	},
	groups = {cracky=3, not_in_creative_inventory=1},
	sounds = default.node_sound_stone_defaults(),
	sunlight_propagates = true,
	paramtype = "light",
	paramtype2 = "facedir",
	on_rotate = screwdriver.rotate_simple,
	drop = "mechanisms:lever_off"
})

minetest.register_craft({
	type = "shapeless",
	output = "mechanisms:pressure_wood_off",
	recipe = {"default:wood", "default:wood"}
})

minetest.register_craft({
	type = "shapeless",
	output = "mechanisms:pressure_stone_off",
	recipe = {"default:stone", "default:stone"}
})

minetest.register_craft({
	output = "mechanisms:lever_off",
	recipe = {
		{"default:stick"},
		{"default:stone"}
	}
})
