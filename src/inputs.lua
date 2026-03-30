function inputs()
 if btn(0) then
  if player == 0 then
   left(eagle)
  elseif player == 1 then
   left(falcon)
  else
   left(warthog)
  end
 elseif btn(1) then
  if player == 0 then
   right(eagle)
  elseif player == 1 then
   right(falcon)
  else
   right(warthog)
  end
 else
  eagle.x_dir = 0
  falcon.x_dir = 0
 end

 if btnp(4) then
  if player == 0 then
   player = 1
  elseif player == 1 then
   player = 2
  else
   player = 0
  end
 end
end