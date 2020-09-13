-- move dropped items closer to player
-- check for nearby fire, lava, do environmental damage
-- etc

local function sur(player)
	local name = player:get_player_name()
	if not minetest.get_player_by_name(name) then
		return
	end
	if player:get_hp() > 0 then
		local pos = player:get_pos()
		local p1 = {x = pos.x - 1.25, y = pos.y - 1.25, z = pos.z - 1.25}
		local p2 = {x = pos.x + 1.25, y = pos.y + 1.25, z = pos.z + 1.25}
		local air = minetest.find_nodes_in_area(p1, p2, "air")
		for i = 1, #air do
			local oir = minetest.get_objects_inside_radius(air[i], 1.25)
			for ii = 1, #oir do
				local e = oir[ii]:get_luaentity()
				if e and e.itemstring and e.age > 0.67 then
					if player:get_inventory():room_for_item("main", e.itemstring) then
						oir[ii]:move_to(pos, true)
					end
				end
			end
		end
	end
	minetest.after(0.9, function()
		sur(player)
	end)
end

minetest.register_on_joinplayer(function(player)
	if not player then
		return
	end
	sur(player)
end)

function minetest.handle_node_drops(pos, drops, digger)
	-- Add dropped items to object's inventory
	local inv = digger and digger:get_inventory()
	local give_item
	if inv then
		give_item = function(item)
			return item --inv:add_item("main", item)
		end
	else
		give_item = function(item)
			-- itemstring to ItemStack for left:is_empty()
			return ItemStack(item)
		end
	end

	for _, dropped_item in pairs(drops) do
		local left = give_item(dropped_item)
		if type(left) == "string" or not left:is_empty() then
			local p = {
				x = pos.x + math.random()/2-0.25,
				y = pos.y + math.random()/2-0.25,
				z = pos.z + math.random()/2-0.25,
			}
			local o = minetest.add_item(p, left)
			if digger and digger:is_player() then
				o:add_velocity(vector.direction(o:get_pos(), digger:get_pos()))
			end
		end
	end
end
