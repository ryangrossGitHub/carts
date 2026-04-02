eagle = {
 s = 0, -- Sprite number
 sl = 2, -- sprite number when banking left
 sr = 4, -- sprite number when banking right
 x = 0, -- x position
 y = 0, -- Y position
 w = 2, -- width in sprites
 h = 2, -- height in sprites
 x_dir = 0, -- x direction, -1 for left, 1 for right, 0 for none
 x_speed = 2, -- speed of movement in x direction
 weapon = "missiles", -- missiles or bullets
 weapon_timout = 0, --frames since last fire
 particles = {}, -- bullets or missiles

 -- Constructor
 init=function (self)
  self.x = screen.w/2
  self.y = screen.h - px_height(self)
 end,
}
