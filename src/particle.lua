function particle(s, x, y, x_speed, y_speed, color, life)
	local p = {
  s = s,	-- sprite number
  w = 1, -- sprite width
  h = 1, -- sprite height
  x = x,
  y = y,
  x_speed = x_speed,
  y_speed = y_speed,
  color = color, -- pixel color
  life = life, -- frames until deletion
	}

	return p
end

function gen_p_from_weapon(w, obj)
	local obj_spr_width_to_center = (obj.w * sprite.w)/2 -- 8 for a 16x16 sprite
 local weap_spr_width_to_center = 1

	if w.s then -- not sprite-based
	 weap_spr_width_to_center = (w.w * sprite.w)/2 -- 4 for a 8x8 sprite
	end

	local part_x = (obj.x + obj_spr_width_to_center - weap_spr_width_to_center)
 return particle(w.s, part_x, obj.y, 0, -w.speed, w.color, screen.h/w.speed)
end

function draw_particles(particles)
	for p in all(particles) do
		p.y += p.y_speed
		p.x += p.x_speed
		p.life -= 1

		if p.life > 0 then
			if p.s then
		  spr(p.s,p.x,p.y,p.w,p.h)
			else
		  pset(p.x, p.y, p.color)
			end
		else
	  del(particles, p)
		end
	end
end
