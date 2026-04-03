explosions = {}
explosion_colors = {5,6,7,8}

function explosion(x, y, size)
	for i=0,size do
		-- to get a range, (high - low) + low
		-- negative low is needed for explosion in all directions
		local x_speed = rnd(2 - -2) + -2
		local y_speed = rnd(2 - -2) + -2
		local p = particle(nil, x, y, x_speed, y_speed, rnd(explosion_colors), 50)
		add(explosions, p)
	end
end
