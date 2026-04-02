function inputs()
 if btn(0) then
  left(current_player())
 elseif btn(1) then
  right(current_player())
 else
  current_player().x_dir = 0
 end

 if btn(5) then
  fire(current_player())
 end

 if btnp(4) then
  -- # is the length operator in lua
  -- if player < 3 then
  --  player += 1
  -- else
  --  player = 0
  -- end
  -- printh("4", "es1.log")
 end
end
