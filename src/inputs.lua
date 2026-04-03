-- button/weapon cool downs
btn4_down = 0
btn5_down = 0

function inputs()
 if btn(0) then -- left
  apache.x -= 1
 elseif btn(1) then -- right
  apache.x += 1
 end

 if btn(4) then -- secondary action
	 if btn4_down == 0 then -- only fire missiles on button down
		  sfx(sounds.missiles)
		  local p = gen_p_from_weapon(missiles, apache)
				add(apache.missiles, p)

				btn4_down = 1
	 end
 else
  btn4_down = 0
 end

 if btn(5) then -- primary action
 	if btn5_down < 10 then
		 sfx(sounds.bullets)
		 local p = gen_p_from_weapon(bullets, apache)
			add(apache.bullets, p)
  end

			btn5_down += 1
 else
 	btn5_down = 0
 end
end
