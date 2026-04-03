function particle(s, ph, x, y, y_speed, color, life)
	p = {
  s = s,	-- sprite number
  w = 1, -- sprite width
  h = 1, -- sprite height
  ph = ph, -- pixel height for procedural gen
  color = color, -- pixel color
  x = x,
  y = y,
  y_speed = y_speed,
  life = life, -- frames until deletion
	}

	return p
end

function gen_p_from_weapon(w, obj)
	obj_spr_width_to_center = (obj.w * sprite.w)/2 -- 8 for a 16x16 sprite

	if w.s == nil then -- not sprite-based
	 weap_spr_width_to_center = 1
 else
	 weap_spr_width_to_center = (w.w * sprite.w)/2 -- 4 for a 8x8 sprite
	end

	part_x = (obj.x + obj_spr_width_to_center - weap_spr_width_to_center)
 return particle(w.s, w.h, part_x, (screen.h - obj.h * sprite.h),
					-w.speed, w.color, screen.h/w.speed)
end

function draw_particles(particles)
	for p in all(particles) do
		p.y += p.y_speed
		p.life -= 1

		if p.life > 0 then
			if p.s then
		  spr(p.s,p.x,p.y,p.w,p.h)
			else
			 if p.ph == 1 then -- bullets
			  pset(p.x, p.y, p.color)
				else
			  line(p.x, p.y, p.x, p.y + p.ph, p.color)
				end
			end
		else
	  del(particles, p)
		end
	end
end
