function check_for_collisions()
 for p in all(apache.bullets) do
  local x = p.x/sprite.w
  local y = p.y/sprite.h

  if fget(mget(x, y)) == 1 then
   sfx(sounds.explosion)
   del(apache.bullets, p)
   mset(x, y, 10)
   explosion(p.x, p.y, 50)
   break
  end
 end

 for p in all(apache.missiles) do
  -- detect collision with the top most pixels of each missile in the sprite
  local m1x = p.x/sprite.w
  local m2x = (p.x + 6)/sprite.w
  local my = p.y/sprite.h

  if fget(mget(m1x, my)) == 1 then
	 	sfx(sounds.explosion)
			del(apache.missiles, p)
	  mset(m1x, my, 10)
			explosion(p.x, p.y, 50)
	  break
  elseif fget(mget(m2x, my)) == 1 then
   sfx(sounds.explosion)
   del(apache.missiles, p)
   mset(m2x, my, 10)
   explosion(p.x + 6, p.y, 50)
   break
  end
 end
end
