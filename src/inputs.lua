function inputs()
 if btn(0) then -- left
  apache.x -= 1
 elseif btn(1) then -- right
  apache.x += 1
 end

 if btnp(4) then -- secondary action
  sfx(sounds.missiles)
  p = gen_p_from_weapon(missiles, apache)
		add(apache.missiles, p)
 elseif btn(5) then -- primary action
  sfx(sounds.bullets)
  p = gen_p_from_weapon(bullets, apache)
		add(apache.bullets, p)
 end
end
