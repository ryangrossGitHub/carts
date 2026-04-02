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

function draw_particles(player)
	for p in all(player.particles) do
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
	  del(player.particles, p)
		end
	end
end
