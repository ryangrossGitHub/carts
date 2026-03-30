falcon = {
 s = 32, -- Sprite number
 sl = 48, -- sprite number when banking left
 sr = 33, -- sprite number when banking right
 x = 0, -- x position
 y = 0, -- Y position
 w = 1, -- width in sprites
 h = 1, -- height in sprites
 x_dir = 0, -- x direction, -1 for left, 1 for right, 0 for none
 x_speed = 3, -- speed of movement in x direction

 -- Constructor
 init=function (self)
  self.x = screen.w/2
  self.y = screen.h - px_height(self)
 end,
}