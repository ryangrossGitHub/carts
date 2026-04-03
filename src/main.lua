screen = { w = 128, h = 128 }
sprite = { w = 8, h = 8 }

function _init()
 -- make purple the transparent color
 palt(13, true)
 palt(0, false)
end

function _update60()
	inputs()
	update_player_animation_frame()
end

function _draw()
	-- Order from bottom to top layer (z axis)
 draw_map()
 draw_particles(apache.bullets)
 draw_particles(apache.missiles)
 draw_player(apache)

 sfx(sounds.helicopter_blades)
end

function draw_map()
	cls()
 map(0,0,0,0,screen.w,screen.h)
end
