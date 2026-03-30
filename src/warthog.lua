warthog = {
 s = 34, -- Sprite number
 sl = 34, -- sprite number when banking left
 sr = 34, -- sprite number when banking right
 x = 0, -- x position
 y = 0, -- Y position
 w = 2, -- width in sprites
 h = 2, -- height in sprites
 x_dir = 0, -- x direction, -1 for left, 1 for right, 0 for none
 x_speed = 1, -- speed of movement in x direction

 -- Constructor
 init=function (self)
  self.x = screen.w/2
  self.y = screen.h - px_height(self)
 end,
}