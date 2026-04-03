player = {
	f = 0, -- frame count (helps with sprte animations)
	fmax = 6, -- frame count for total animation (helicopter blades)
	s1 = 0, -- Sprite 1 (animation)
	s2 = 2, -- Sprite 2 (animation)
	w = 2,  -- Sprite width
	h = 2, -- Sprite height
	x = (screen.w/2 * (map_row*2 + 1)) - sprite.w, -- Starting x position (middle of screen)
	y = 63 * sprite.h - sprite.h*2, -- Starting position bottom of map
	y_speed = 0.3, -- y speed
	bullets = {}, -- table primary weapon
	missiles = {}, -- table for secondary weapon
}

function draw_player(p)
	if p.f < p.fmax/2 then
  spr(p.s1, p.x, p.y, p.w, p.h)
 else
  spr(p.s2, p.x, p.y, p.w, p.h)
 end
end

function update_player_animation_frame(p)
	if p.f < p.fmax then
  p.f += 1
 else
  p.f = 0
 end
end
