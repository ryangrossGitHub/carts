function inputs()
 if btn(0) then
  if player == 0 then
   left(eagle)
  else
   left(falcon)
  end
 elseif btn(1) then
  if player == 0 then
   right(eagle)
  else
   right(falcon)
  end
 else
  eagle.x_dir = 0
  falcon.x_dir = 0
 end

 if btnp(4) then
  if player == 0 then
   player = 1
  else
   player = 0
  end
 end
end