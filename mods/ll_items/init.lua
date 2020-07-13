-- jastest/mods/ll_items
-- Part of jastest Minetest Game
-- Copyright 2020 James Stevenson
-- GNU GPL 3+

ll_items = {}

local rand = math.random

local function sound(pos)
	minetest.after(0, minetest.sound_play, "items_plop", {pos = pos}, true)
end

local function auto_pickup(player)
	if not minetest.get_player_by_name(player:get_player_name()) then
		return
	end

	local pos = player:get_pos()
	if not pos then
		return
	end

	local alive = player:get_hp() > 0
	local name = player:get_player_name()
	local attached = player_api.player_attached[name]

	if alive and not attached and
			vector.equals(pos, player:get_pos()) then
		--local new_pos = vector.new(player:get_pos()) -- try this if it crashes again
		local pop = vector.new(player:get_pos())
		if pop then
			local o = minetest.get_objects_inside_radius(pop, 0.667)
			for i = 1, #o do
				local obj = o[i]
				local p = obj:is_player()
				if not p then
					local ent = obj:get_luaentity()
					if ent and ent.age and ent.age > 0.67 then
						local inv = player:get_inventory()
						if inv:room_for_item("main", ent.itemstring) then
							sound(obj:get_pos())
							obj:remove()
							local add = inv:add_item("main", ent.itemstring)
							if add then
								minetest.add_item(player:get_pos(), add)
							end
						end
					end
				end
			end
		end
	end

	minetest.after(0, function()
		auto_pickup(player)
	end)
end

ll_items.throw_inventory = function(pos, list, lift)
	for _, item in pairs(list) do
		if lift then
			pos.y = pos.y + 2
		end
		local o = minetest.add_item(pos, item)
		if o then
			o:get_luaentity().collect = true
			o:set_acceleration({x = 0, y = -10, z = 0})
			o:set_velocity({x = rand(-2, 2),
					y = rand(1, 4),
					z = rand(-2, 2)})
		end

	end
end

minetest.registered_entities["__builtin:item"].on_punch = function(self, hitter)
	local inv = hitter:get_inventory()
	if inv and self.itemstring ~= "" then
		local left = inv:add_item("main", self.itemstring)
		if left and not left:is_empty() then
			self:set_item(left)
			return
		end
		sound(self.object:get_pos())
	end
	self.itemstring = ""
	self.object:remove()
end

minetest.register_on_joinplayer(function(player)
	auto_pickup(player)
end)

minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing)
	local n = minetest.registered_nodes[oldnode.name]
	if n.buildable_to then
		local d = minetest.get_node_drops(oldnode.name)
		if d then
			ll_items.throw_inventory(pos, d)
		end
	end
end)
