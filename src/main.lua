screen = { w = 128, h = 128 }
sprite = { w = 8, h = 8 }
map_row = 0

function _init()
 -- make purple the transparent color
 palt(13, true)
 palt(0, false)
end

function _update60()
	inputs()
	update_player_animation_frame(player)
	check_for_collisions()
end

function _draw()
	-- Order from bottom to top layer (z axis)
 draw_map()
 draw_particles(player.bullets)
 draw_particles(player.missiles)
 draw_particles(explosions)
 draw_player(player)

 sfx(sounds.helicopter_blades)
end

function draw_map()
	cls()
 map(0,0,0,0,screen.w,screen.h)
 camera(map_row * screen.w, player.y - screen.h + player.h*sprite.h)
end
