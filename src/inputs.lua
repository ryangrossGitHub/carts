-- button/weapon cool downs
btn4_down = 0
btn5_down = 0

function inputs()
 if btn(0) and player.x > 0 then -- left
  player.x -= 1.5
 elseif btn(1)and player.x < screen.w - (player.w * sprite.w) then -- right
  player.x += 1.5
 end

 if btn(2) then
  player.y -= player.y_speed
 end

 if btn(4) then -- secondary action
	 if btn4_down == 0 then -- only fire missiles on button down
		  sfx(sounds.missiles)
		  local p = gen_p_from_weapon(missiles, player)
				add(player.missiles, p)

				btn4_down = 1
	 end
 else
  btn4_down = 0
 end

 if btn(5) then -- primary action
 	if btn5_down < 10 then
		 sfx(sounds.bullets)
		 local p = gen_p_from_weapon(bullets, player)
			add(player.bullets, p)
  end

			btn5_down += 1
 else
 	btn5_down = 0
 end
end
