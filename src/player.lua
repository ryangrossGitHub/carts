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
