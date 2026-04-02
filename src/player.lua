player = 0 -- 0 for eagle, 1 for falcon, 2 for warthog

function current_player()
 if player == 0 then
  return eagle
 elseif player == 1 then
  return falcon
 elseif player == 2 then
  return warthog
 elseif player == 3 then
  return hornet
 end
end

function draw(obj)
 if obj.x_dir == 0 then
  spr(obj.s,obj.x,obj.y,obj.w,obj.h)
 elseif obj.x_dir == -1 then
  spr(obj.sl,obj.x,obj.y,obj.w,obj.h)
 elseif obj.x_dir == 1 then
  spr(obj.sr,obj.x,obj.y,obj.w,obj.h)
 end

 draw_particles(obj)

 -- weapon cooldown
 if obj.weapon_timout > 0 then
  obj.weapon_timout -= 1
 end
end

function px_height(obj)
 return obj.h * sprite.h
end

function px_width(obj)
 return obj.w * sprite.w
end

function left(obj)
 if obj.x > 0 then
  obj.x_dir = -1
  obj.x = obj.x - obj.x_speed
 end
end

function right(obj)
 if obj.x < screen.w - px_width(obj) then
  obj.x_dir = 1
  obj.x = obj.x + obj.x_speed
 end
end

function fire(obj)
	if obj.weapon == "missiles" then
		if obj.weapon_timout == 0 then
			p = particle(missiles.s, nil, obj.x + sprite.w/2, (screen.h - obj.h * sprite.h), -missiles.speed, nil, screen.h/missiles.speed)
			add(obj.particles, p)

			obj.weapon_timout = missiles.timeout
		end
	elseif obj.weapon == "small_missiles" then
			if obj.weapon_timout == 0 then
				p = gen_p_from_weapon(small_missiles, obj)
				add(obj.particles, p)

				obj.weapon_timout = small_missiles.timeout
			end
	else -- Bullets
  p = gen_p_from_weapon(bullets, obj)
		add(obj.particles, p)
	end
end

function gen_p_from_weapon(w, obj)
 return particle(w.s, w.h, (obj.x + (obj.w * sprite.w)/2 - 1), (screen.h - obj.h * sprite.h),
					-w.speed, w.color, screen.h/w.speed)
end
