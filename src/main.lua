screen = {
 w = 128,
 h = 128,
}

sprite = {
 w = 8,
 h = 8,
}

function _init()
 -- make purple the transparent color
 palt(13, true)
 palt(0, false)

 eagle:init()
 falcon:init()
 warthog:init()
 hornet:init()
end

function _update60()
 inputs()
end

function _draw()
 cls()
 map(0,0,0,0,screen.w,screen.h)
 draw(eagle)
end
