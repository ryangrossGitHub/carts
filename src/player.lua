player = 0 -- 0 for eagle, 1 for falcon, 2 for warthog

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