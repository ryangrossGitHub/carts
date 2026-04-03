apache = {
	f = 0, -- frame count (helps with sprte animations)
	fmax = 6, -- frame count for total animation (helicopter blades)
	s1 = 0, -- Sprite 1 (animation)
	s2 = 2, -- Sprite 2 (animation)
	x = 56, -- Starting x position (middle of screen)
	y = 110, -- Y position for entire game (bottom of screen)
	w = 2,  -- Sprite width
	h = 2, -- Sprite height
	bullets = {}, -- table primary weapon
	missiles = {}, -- table for secondary weapon
}

function draw_player(player)
	if player.f < player.fmax/2 then
  spr(player.s1, player.x, player.y, player.w, player.h)
 else
  spr(player.s2, player.x, player.y, player.w, player.h)
 end
end

function update_player_animation_frame(player)
	if apache.f < apache.fmax then
  apache.f += 1
 else
  apache.f = 0
 end
end
