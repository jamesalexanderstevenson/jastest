-- /mods/mapgen is part of jastest
-- copyright 2020 james alexander stevenson
-- gnu gpl 3+

if minetest.get_mapgen_setting("mg_name") == "singlenode" then
	minetest.register_on_generated(function(minp, maxp, seed)
		local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
		local a = VoxelArea:new{
			MinEdge = {x = emin.x, y = emin.y, z = emin.z},
			MaxEdge = {x = emax.x, y = emax.y, z = emax.z},
		}
		local data = vm:get_data()
		local c_lava = minetest.get_content_id("default:lava_source")
		local c_floor = minetest.get_content_id("oresplus:bedrock")
		for z = minp.z, maxp.z do
			for y = minp.y, maxp.y do
				for x = minp.x, maxp.x do
					if y < 1 then
						if y >= -9 then
							local vi = a:index(x, y, z)
							data[vi] = c_lava
						else
							local vi = a:index(x, y, z)
							data[vi] = c_floor
						end
					end
				end
			end
		end
		vm:set_data(data)
		vm:calc_lighting()
			--[[{x = minp.x - 16, y = minp.y, z = minp.z - 16},
			{x = maxp.x + 16, y = maxp.y, z = maxp.z + 16}
		)]]
		vm:write_to_map(data)
	end)
end
