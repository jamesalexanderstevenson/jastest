--
-- fuel
--
minetest.register_entity('helicopter:pointer',{
	initial_properties = {
		physical = false,
		collide_with_objects=false,
		pointable=false,
		visual = "mesh",
		mesh = "pointer.b3d",
		textures = {"default_obsidian.png"},
		},
		
	on_activate = function(self,std)
		self.sdata = minetest.deserialize(std) or {}
		if self.sdata.remove then self.object:remove() end
	end,
		
	get_staticdata = function(self)
		self.sdata.remove = true
		return minetest.serialize(self.sdata)
	end,
})

function load_fuel(self, player_name)
	if self.energy < 9.5 then 
		local player = minetest.get_player_by_name(player_name)
		local inv = player:get_inventory()
		player:set_wielded_item("")
		self.energy = self.energy + 1
		if self.energy > 10 then
		    self.energy = 10
		end

		local energy_indicator_angle = helicopter.get_pointer_angle(self.energy)
		self.pointer:set_attach(self.object,'',{x=0,y=11.26,z=7.5},{x=0,y=0,z=energy_indicator_angle})

		--sound and animation
		-- first stop all
		minetest.sound_stop(self.sound_handle)
		self.sound_handle = nil
		self.object:set_animation_frame_speed(0)
		-- start now
		self.sound_handle = minetest.sound_play({name = "helicopter_motor"},
				{object = self.object, gain = 2.0, max_hear_distance = 32, loop = true,})
		self.object:set_animation_frame_speed(30)
		-- disable gravity
		self.object:set_acceleration(vector.new())
		--
	else
		hud.message(player_name, "Helicopter is all fueled up!")
	end
end

