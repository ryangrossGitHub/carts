pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
-- golf sunday
-- by @jOHANpEITZ 

done_102=[[
* fixed cart sound not stopping if accelrating with z
]]

-- ★ todo ★

-- ★ polish ★

-- explode cart if hit from afar
--  animation
--  particles
--  sfx(45)

-- put the golf sign on top
-- don't shoot through trees
-- show score card anytime with z

-- -- --

-- sfx for driving in rough
-- indicate where flag is when aiming
-- repeat last aim if ob/cancel

-- time attack
--  time per hole
--  total time, inc between time

-- flatter parabola
-- cart shadows 
-- player shadow

-- birds
-- chance to get crappy cart
-- see player in car
-- custom font
-- turn car when jumping out
-- if closer to car than ball
--  draw arrow on car 
-- x hidden things



done_002=[[
* added proper cart label 
* added ability to hit flags with cart
* added ability to smash signs with cart
* added indication for last tee on score card
* added call outs for various results
* added a brief pause before the game music starts
* added more carts standing left on courses
* tweaked swing animation to allow for more angles
* tweaked putting ui
* tweaked putting to be slightly harder
* fixed empty carts getting pushed into buildings
* fixed 0's showing on score card
* fixed ball indicator showing on title screen post completion
* fixed issue in collision detection and response
* fixed animation issue when moving while leaving swing state
* fixed animation issue when moving vertically
* performance improvements


]]

done_003=[[
* added version number to title (press z)
* added staff greeting
* added sfx to putt ui
* added hole par to hud
* added storing best result
* added swimming
* added sinking carts
* added new sounds
* tweaked putting power slightly
* tweaked water obstacles 
* tweaked flag bounce chance 
* tweaked putting animation 
* tweaked existing sounds
* removed black pixel from aiming reticule
* removed swing sound when putting
* fixed putting ui to allow for longer putts
* fixed bunker and green getting mixed up in some cases
* fixed crash caused by empty vehicles rolling into walls/trees
* fixed occasional jitter when camera was tracking player
]]

done_100=[[
* added waves to water
* added fading when transitioning from title screen
* added ball bouncing on carts
* added sound for hitting carts with carts
* added water particles when driving in water
* added free roaming after hole 9
* tweaked text skipping
* tweaked course tilemap
* tweaked water sound
* tweaked well done sign
* tweaked cart positions on map
* tweaked putting to be slightly easier
* fixed shooting ball outside of the map
* fixed driving cart outside of the map
* fixed walking/swimming outside of the map
* fixed footstep sound played swimming
* fixed cart trails appearing in water
* fixed aiming circle being too narrow
* fixed hole 9 being outside the map
* performance improvements
]]

done_101=[[
 * added ability to accelerate with z
]]

-->8
-- game

version="1.0.2"

my_pal={
 0, 133, 2, 3,
 4, 131, 6, 7,
 136, 10, 139, 11,
 12, 13, 143, 15
}

dpal={
 0, 0, 1, 5,
 2, 1, 13, 6,
 2, 1, 3, 10,
 13, 1, 4, 14
}

intros={
 { "wELCOME! hOPE\nYOU'LL HAVE A\nGREAT DAY.",
   "mORNING.\nwEATHER'S\nNICE TODAY.",
   "wHAT'S UP?\nhERE TO PLAY\ni GUESS...",
   "hELLO HELLO!\ntHE SUN IS\nSHINING!",
   "hI THERE,\nTIME FOR SOME\nGOLF, HUH?",
   "zZZ...\noH, HI.\nsORRY.",
 },
 {
  "dON'T WRECK\nTHE CARTS.\npLEASE.",
  "wEIRD, NO ONE\nELSE HERE\nTO PLAY.",
  "hERE'S YOUR\nEQUIPMENT.",
  "iS IT YOUR\nFIRST TIME\nHERE?",
  "tIME TO BREAK\nTHE RECORD?\n",
  "i JUST MOWED\nTHE GRASS.\n",
 },
 {
  "pAR IS 31 PTS\ngOOD LUCK!"
 }
}


-- tree data
tree_data={}
tree_data[181]=163
tree_data[180]=162
tree_data[179]=163
tree_data[178]=162
tree_data[177]=171
tree_data[176]=170
tree_data[160]=171
tree_data[161]=170

function _init()
 cartdata("jpgolfsunday")
 seed=rnd(32000)
 gid=0
 fade_progress=1

 -- reset best
 best_result=dget(0)
 if best_result==0 then
  reset_best()
 end
 
 -- set up new pal
 for i=1,16 do
  pal(i-1, my_pal[i], 1)
 end
 poke(0x5f2e,1)
  
	-- go into 64x64
	poke(0x5f2c, 3)
	
	-- repeat delay
	poke(0x5f5c,255)
	poke(0x5f5d,255)
	
	show_title()
end

function reset_best()
 dset(0,35) 
 best_result=dget(0)
end

function record_result(result)
 if result<best_result then
  best_result=result
  new_best=true
  dset(0,best_result)
 end
end

function set_score_string()
 caddie_text[3]="pAR IS 31 PTS\nbEST, "..best_result.." PTS\ngOOD LUCK!"
end


function show_title()
 ⧗=0

 -- cam
 camx=0
 camy=0
 track_spd=0.05
 
 restart=false
	
 -- 0=title
 -- 1=playing
 -- 2=ball in hole
 -- 3=end summary
 state=0
 score_card_y=999
 put_ui_x=64
 ui_delay=0
 track_delay=0
 put_⧗=0
 
 ball=nil
 hole=nil
 	 
 setup_world()
end

function setup_world()
 reload()
 
 -- cooldowns
 btnx_cooldown=0 
 counter=0
 
 -- swining
 swing_state=0
 reticule=nil

 -- trails & particles
 trails={}
 particles={}
 waves={}
 wtiles={}

 -- entities	
	entities={}
	statics={}
	dynamics={}
	carts={}
	
	-- greens
 terrain={}
	
	-- scan map
	local bonus_carts=0
	for x=0,127 do
		for y=0,31 do
			local tile=mget(x,y)
			
			-- water?
			if tile==68 then
			 add(wtiles, {x=x,y=y})
			end
			
			-- tree?
			if (tile>=176 and tile <=181) or tile==160 or tile==161 then
	   local t2=mget(x,y-1)
	   if not fget(t2,0) then
	    gid+=1
		   local tree=add(entities,{
		    type="tree",
		    gid=gid,
		    x=x*8+4, y=y*8+8,
		    spr=tree_data[tile],
      tw=1,th=2,
      frame=0,sw=8,sh=16,
      df=draw_entity,
      cr=2,cox=3.5,coy=-1.5
		   })
		   if tile==180 or tile==178 then
 		   add(statics,tree)
		   end
		   if tile==180 or tile==181 then
		    mset(x,y,65)
		   end
		   if tile==178 or tile==179 then
		    mset(x,y,0)
		   end
		  end
			end
			
			-- is it a character
			if tile==16 then
   	pl=make_player(x*8+4,y*8+7)
   	pl.cr=1
    pl.cox=-1
    pl.coy=0
    pl.cprio=10
   	add(dynamics,pl)
   	mset(x,y,240)
			end
			-- is it a course cart
			local cart=nil
			if tile>=2 and tile<=5 then
			 cart=make_cart(x*8+4,y*8+7,(tile-2)*0.25)
   	mset(x,y,0)
			end
			-- is it a start cart
			if rnd()>0.4 and (tile==224 or tile==225) and bonus_carts<2 then
			 cart=make_cart(x*8+(tile==224 and 5 or 3),y*8+5,tile==224 and 0 or 0.5)
			 cart.nox=true
    bonus_carts+=1
			end
			if cart then
   	cart.cr=3
    cart.hit_by_cart=0
    cart.cox=0
    cart.coy=-2
			 cart.cprio=20
    add(dynamics,cart)
    add(carts,cart)
			end
			-- is it a sign?
			if tile>=87 and tile<=95 then
			 -- sign
			 local sign=make_entity(x*8+3,y*8+5,{
			  type="sign",
			  spr=tile,
			  cprio=17,
     cr=2,cox=0,coy=-1,
     on_hit=function(e,src)
      add(to_delete,e)
      mset(e.x/8,e.y/8,86)
      make_sign_smash(e.x,e.y)
      sfx(47)
     end
     
 		 })
			 add(dynamics,sign)
			 mset(x,y,0)
			end
			-- is it a hole?
			if tile>=103 and tile<=111 then
			 -- flag
			 local f=make_entity(x*8+3,y*8+5,{
			  type="flag",
			  spr=1,
			  cprio=15,
     cr=1,cox=0,coy=-1,
     on_hit=function(e,src)
	     e.spr=6
      e.dx=2*src.s*cos(src.a)
      e.dy=-2*src.s*sin(src.a)
      e.ix=0.93
      e.iy=0.93
      del(dynamics, e)
      sfx(46)
     end
			 })
			 add(dynamics, f)
			 
			 -- hole
			 make_entity(f.x,f.y,{
			  type="hole",
		   df=function(e) end,
			  id=tile-102
			 })
			 
			 -- generate green
			 srand(x+y+tile*5)
			 local ox=rnd(8)-4
			 local oy=rnd(8)-4
			 for i=3,5 do
			-- for i=6,8 do
			  add(terrain, {
			   x=ox+x*8+4+2.4*i*(rnd()-0.5),
			   y=oy+y*8+4+2.4*i*(rnd()-0.5),
			   r=2+i+rnd(6),
			   c=11
			  })
			 end
   	srand(seed*x)
			end
		end
	end
	
 panner={
  x=159,y=64,
  uf=function(e)
   e.x=480+300*cos(t()/100)
   e.y=128+ 64*sin(t()/50)
  end
 }
	track(panner,1)	
	
	music(0)
end

function start_game()
 sfx(62)
 state=1
 
 setup_world()
 
 local par={3,2,4,4,3,4,3,4,4,0}
 courses={}
 for i=1,9+1 do
  add(courses,{
   score=0,
   par=par[i],
   started=false
  })
 end

 track(pl,1)
 pl.has_control=true
	
	-- set up first tee
	tee=0 
 next_tee()
 
 msg=nil
 
	music(-1)
	
	-- place instructions
	local e=make_entity(
	 175,208, {
	 df=function(e) end,
  type="hello",
  cprio=1,
  cr=8,cox=0,coy=0,
  on_hit=function(e,src)
   pl.frame=0
   pl.dir=-1
   caddie_count=0
   caddie_y=0
   caddie_page=1
   caddie_tc=0
   caddie_text={
    rnd(intros[1]),
    rnd(intros[2]),
    "i am error."
   }
   set_score_string()
   sfx(63)
   mset(20,26,230)
   add(to_delete, e)
  end	 
	})
	add(entities,e)
	add(dynamics,e)
 
 fadeout()
end


function show_message(txt)
 msg={
  str=txt,
  ⧗=0,
  x=31 - 2 * #txt,
  y=-8
 }
end

function next_tee()
 tee+=1
 
 if tee==10 then --10 then
  state=3
  tee=11
  record_result(total_result)
  return
 end
 
 local teex,teey
 -- search for tee
	for x=0,127 do
		for y=0,31 do
			local tile=mget(x,y)-118
			if tile==tee then
			 teex,teey=x,y
			end
  end
 end 

 state=1
 if tee>1 then
  sfx(63)
 end
  
 if tee<10 then
	 -- place ball
	 ball=make_ball(teex*8+5,teey*8+5)
		poi=ball  
	 -- find and assign hole
	 hole=nil
	 for e in all(entities) do
	  if e.type=="hole" then
	   if e.id==tee then
	    hole=e
	   end
	  end
	 end
 else
  track(pl)
  swing_state=0
  pl.has_control=true
  ball=nil
  pl.frames=4
  pl.spr=16
  poi=nil
  
 	local e=make_entity(
		 163,214, {
			 df=function(e) end,
		  type="bye",
		  cprio=1,
		  cr=3,cox=0,coy=0,
		  nocart=true,
		  on_hit=function(e,src)
			  sfx(49,-2)
			  sfx(51,-2)
					music(-1)
     sfx(62)
		   pl.frame=0
		   pl.dir=-1
		   caddie_count=0
		   caddie_y=0
		   caddie_page=1
		   caddie_tc=0
		   caddie_text={
		    total_result.." POINTS,\nWHAT A GREAT\nRESULT!",
		    "hOPE YOU\nHAD FUN.",
		    "sEE YOU\nNEXT TIME!"
		   }
		   poi=nil
		   sfx(63)
		   add(to_delete, e)
   		restart=true
		  end	 
		})
		add(dynamics,e)
		add(entities,e)
		poi=e
		 
	end
 
end

function track(o,spd,delay)
 ctrack=o
 track_spd=spd or 0.05
 track_delay=delay or 0
end

function _update60()
 if fade_progress>0 then
  fade_progress-=0.1
 end
 
 if (btnp(3,1)) debug=not debug

 to_delete={}

 ⧗+=1
 
 -- animate water
 if rnd()<0.75 then
	 local wtile=rnd(wtiles)
	 add(waves,{
	  x=wtile.x*8+rnd(8),
	  y=wtile.y*8+rnd(8),
	  ⧗=0,
	  df=function(e)
	   if e.⧗>60 then
	    del(waves,e)
	   end
	   local len=-flr(4*sin(e.⧗/120))/2
	   line(e.x-len,e.y,e.x+len,e.y,7)
	   pset(e.x-len,e.y,6)
	   pset(e.x+len,e.y,6)
	   e.⧗+=1
	  end,
	 })
 end
 
 if state==3 then
  if btnpx() then
   next_tee()
--   show_title()
   return 
  end
 end

 if ui_delay>0 then
  ui_delay-=1
 end
 
 if state==0 then
  panner.uf(panner)
  if btnpx() then
   start_game()
  end
  return
 end
 
 if state==2 then
  if btnp(❎) then
   next_tee()
  end
 end
 
 if btnx_cooldown>0 then
  btnx_cooldown-=1
 end

 if caddie_count and btnpx() then
  sfx(63)
  local txt=caddie_text[min(3,caddie_page)]
  if caddie_tc<#txt*4 then
   caddie_tc=#txt*4
  else
	  caddie_page+=1
	  if caddie_page<4 then
	   caddie_tc=0
	  else
	   caddie_count=61
	   mset(20,26,229)
	   if restart then
 	   fadeout()
 	   show_title()
    else
 	   music(5)
    end	   
	  end
	 end
 end
 
 if ui_delay==0 and not caddie_count then
	 if swing_state>=2 then
	  counter+=1
	  if counter==30 then
	   pl.spr=39
	   if not ball.putting then
	    pl.spr=33
	    sfx(60)
	   end
	  end 
	  if counter==60 then
	   pl.spr=pl.rev_swing and 37 or 34
	   if ball.putting then
	    pl.spr=40
	   end
	   sfx(59)
	  end

	  if counter==64 then
	   pl.spr=pl.rev_swing and 38 or 35 
	  end 
	  if counter==68 then
	   pl.spr=36
	  end 
	  if ball.putting and counter>=64 then
    pl.spr=40
   end
	  if counter==100 then
	   pl.spr=16
	  end 
	 end
 
	 if swing_state>0 then
	  if swing_state==1 then
	   if ball.terrain!="green" then
	    ball.putting=false
		   reticule.x+=(reticule.tx-reticule.x)*0.05
		   reticule.y+=(reticule.ty-reticule.y)*0.05
		   -- adjust aim
		   if (btn(⬅️)) reticule.tx-=0.5
		   if (btn(➡️)) reticule.tx+=0.5
		   if (btn(⬆️)) reticule.ty-=0.5
		   if (btn(⬇️)) reticule.ty+=0.5
		   aim_power=distance(reticule,ball)
		   local dx=reticule.tx-ball.x
		   local dy=reticule.ty-ball.y
		   in_bunker=is_bunker(ball.x,ball.y)
		   local max_p=in_bunker and 20 or 80
		   if aim_power>max_p then
		    local a=atan2(dx,dy)
		    reticule.tx=ball.x+(max_p-1)*cos(a)
		    reticule.ty=ball.y+(max_p-1)*sin(a)
		    reticule.max=8
		   end
		   
		   if btnpx() then
				  local dx=reticule.x-ball.x
			   local dy=reticule.y-ball.y
		  	 reticule.r=get_reticule_r()
			   aim_angle=atan2(dx,dy)
		    track(ball)
		    swing_state=2
		    counter=0
		   end
		  else
		   -- ball on green
		   ball.putting=true
		   
		   if btnpx() then
				  local dx=hole.x-ball.x
			   local dy=hole.y-ball.y
			   aim_angle=atan2(dx,dy)
			   aim_power=ball.power+0.025
		    track(ball)
		    swing_state=2
		    counter=0
		    ui_delay=30
		    sfx(63)
		   end
		  end
	   if btnp(🅾️) then
		   pl.spr=16
		   track(pl)
		   swing_state=0
	   end
	  elseif swing_state==2 and counter>60 then
	   -- power meter
	   if ball.putting then
	    swing_power=0.42*aim_power
	   else
	    swing_power=0.3*aim_power
	   end
	   swing_state=3
	  elseif swing_state==3 then
	   -- animate power selection
	   -- done
	   swing_state=4
	  elseif swing_state==4 then
	   -- aim meter
	   swing_angle=aim_angle
	   swing_state=5
	  elseif swing_state==5 then
	   -- animate angle selection
	   -- done
	   swing_state=6
	  elseif swing_state==6 then
	   if not ball.putting then
		   --let the ball fly!
		   -- target 
		   local tx=swing_power*cos(swing_angle)
		   local ty=swing_power*sin(swing_angle)
		   -- adjust
		   local a=rnd()
		   reticule.adj=rnd(reticule.r)/reticule.r
		   reticule.adj=reticule.adj^2
		   local r=reticule.adj*reticule.r
		   tx+=r*cos(a)/2.5
		   ty+=r*sin(a)/2.5
	
	    hit_ball(ball,tx,ty)
	   else
	    put_ball(ball,swing_power,swing_angle)
	   end
	   
	   
	   swing_state=7
	  elseif swing_state==7 then
	   if ball.state==0 then
	    swing_state=0
	    track(pl)
	    pl.frame=0
	    pl.spr=16
	   end
	  end
	 end
 
	 for e in all(entities) do
	 	if (e.uf) e.uf(e)
		end
 end
 
 -- handle collisions
 -- statics
 for sc in all(statics) do
 	for dc in all(dynamics) do
 		local dx=(sc.x+sc.cox)-(dc.x+dc.cox)
 		if abs(dx)<8 then
	 		local dy=(sc.y+sc.coy)-(dc.y+dc.coy)
	 		if abs(dy)<8 then
	  		local d2=dx*dx+dy*dy
	  		if d2<=(sc.cr+dc.cr)^2 then
	 	 	 local a=atan2(dx,dy)
		 	  dc.x-=cos(a)
			   dc.y-=sin(a)
			   dc.pusher=sc
	 	  end
	 	 end
 		end
		end
 end
 
 -- dynamics
 -- sort in prio order
 sort(dynamics,"cprio")
 -- detect collision
 for i=1,#dynamics-1 do
  dc1=dynamics[i]
  for j=i+1,#dynamics do
   dc2=dynamics[j]
 		local dx=(dc1.x+dc1.cox)-(dc2.x+dc2.cox)
 		if abs(dx)<10 then
 			local dy=(dc1.y+dc1.coy)-(dc2.y+dc2.coy)
 			if abs(dy)<10 then
	  		local d2=dx*dx+dy*dy
	  		if d2<=(dc1.cr+dc2.cr)^2 then
	 	 	 local a=atan2(dx,dy)
			   if dc1.is_cart then
			  	 dc1.a+=rnd(0.1)-0.05
			  	 dc1.trail_chance=1
							dc1.ox=dc1.x
							dc1.oy=dc1.y
							if dc1.hit_by_cart==0 then
 							sfx(48)
 							dc1.hit_by_cart=20+flr(rnd(20))
							end
	     end
	     dc1.pusher=dc2
	     dc2.pusher=dc1
	   	 dc1.x+=cos(a)
			   dc1.y+=sin(a)
			   if dc1.on_hit then
			    dc1.on_hit(dc1,dc2)
			   end
	 	  end
	 	 end
			end
	 end 
 end
 
 if not btn(❎) then
  btnx_cooldown=0
 end
 
 for e in all(to_delete) do
 	del(entities,e)
 	del(dynamics,e)
 end

end

function _draw()
	cls(10)

 if track_delay>0 then
  track_delay-=1
 else
	 camlx=camx
	 camly=camy
		camx+=(ctrack.x-31-camx)*track_spd
		camy+=(ctrack.y-31-camy)*track_spd
		if not debug then
 		camx=max(0,min(camx,768))
	 	camy=max(0,min(camy,192))
		end
		
--		if abs(camlx-camx)<0.05 and abs(camly-camy)<0.05 then
		if abs(camlx-camx)<0.1 and abs(camly-camy)<0.1 then
		 track_spd=1
		end
	end
	camera(flr(camx),flr(camy))
	
	-- terrain
	for c in all(terrain) do
	 circfill(c.x,c.y,c.r,c.c)	
	end
	
 local cx=camx-8*(camx\8)
 local cy=camy-8*(camy\8)
	map(camx\8,camy\8,camx-cx,camy-cy,9,9)
	for w in all(waves) do
		w.df(w)
	end
	for p in all(trails) do
		pset(p.x,p.y,p.c)
		p.life-=1
		if p.life<=0 then
		 del(trails,p)
		end
	end
	
	-- particles
	for p in all(particles) do
		update_particle(p)
		pset(p.x,p.y-p.z,p.col)
	end
	
	if swing_state==1 and ball.terrain!="green" then
	-- if swing_state==1 then
 	 reticule.r=get_reticule_r()
	 --end
	 local c=reticule.max>0 and 8 or 11
	 draw_reticule(reticule.x, reticule.y, reticule.r, c)
  if reticule.max>0 then
   reticule.max-=1
  end
 end

	sort(entities,"y")
	
 for e in all(entities) do
 	if (e.df) e.df(e)
	end
	
	-- poi direction
	if poi then
		if ⧗%30<25 and swing_state==0 then
			if poi.x<camx or poi.y<camy or poi.x>camx+63 or poi.y>camy+63 then
		 	local bx=min(max(poi.x,camx+3),camx+60)
		 	local by=min(max(poi.y,camy+3),camy+60)
		 	spr(55,bx-4,by-4)
		 	local bx=min(max(poi.x,camx+5),camx+58)
		 	local by=min(max(poi.y,camy+5),camy+58)
		 	spr(50,bx-4,by-4)
			else
			 if not pl.can_hit_ball then
		   draw_arrow(poi) 
			 end
			end
	 end
	end
	
	-- debug
	if debug then
	 for sc in all(statics) do
	 	circ(sc.x+sc.cox,
	 	     sc.y+sc.coy,
	 	     sc.cr,15)
  end

	 for dc in all(dynamics) do
	 	circ(dc.x+dc.cox,
	 	     dc.y+dc.coy,
	 	     dc.cr,9)
  end
	end
 
	-- hud
	camera()
	if state==0 then
	 draw_title()
	elseif state==3 then
	 pal(7,5)
	 draw_done(14,13)
	 pal(7,7)
	 draw_done(14,12)
	end
	
	if courses and courses[tee] and courses[tee].started then 
 	local dist=flr(distance(ball,hole)/1.5)
 	spr(48,0,49)
 	print(dist.."YDS",1,58,5)
 	print(dist.."YDS",1,57,7)
 	print("PAR"..courses[tee].par,48,58,5)
 	print("PAR"..courses[tee].par,48,57,7)
 end

 if state>=2 then
  if score_card_y>36 then
   score_card_y-=1
  end
  draw_score_card(3,score_card_y)
 end
 if state==1 and score_card_y<64 then
  score_card_y+=1
  draw_score_card(3,score_card_y)
 end
 
 if ball and swing_state>0 and ball.terrain=="green" then
  -- targetx 11
  if put_ui_x==11 then
   put_⧗+=1
  end
  ball.power=draw_putt_ui(put_ui_x,47)
  if swing_state==1 then
   put_ui_x=max(11,put_ui_x-2)
  end
  if swing_state==2 then
   if counter>30 then
    put_ui_x=min(64,put_ui_x+2)
   end
  end
 end
 
--	spr(49,57,49)
--	local mm=⧗\3600
--	local ss=(⧗-mm*3600)\60
--	local ss=(⧗-mm*3600)\60
--	local str=mm.."M"..(ss<10 and "0" or "")..ss.."S"
--	print(str,64-4*#str,58,5)
--	print(str,64-4*#str,57,7)
	
	-- hit ui
-- if swing_state>1 then
--	 draw_swinger(40,17)
--	end

 if msg then
  rectfill(0,msg.y,63,msg.y+6,7)
  line(0,msg.y+7,63,msg.y+7,5)
  print(msg.str,msg.x,msg.y+1,1)
  msg.⧗+=1
  if msg.⧗<60 and msg.y<-1 then
   msg.y+=1
  end
  if msg.⧗>120 then
   msg.y-=1
   if msg.y<-8 then
    msg=nil
   end
  end
 end
 
 if caddie_count then
  caddie_tc+=1
  draw_bubble(sub(caddie_text[min(3,caddie_page)],1,caddie_tc\4),4,36+32-min(32,caddie_y*3))
 
  if caddie_count<16 then
   caddie_y+=1
   caddie_count+=1 
  end
  if caddie_count>60 then
   caddie_count+=1 
   caddie_y-=1
   if caddie_count>86 then
    caddie_count=false
   end
  end
 end
	
	-- debug
	if debug then
 	?flr(100*stat(1)),1,1,0
 	?#carts,1,7,0
 --	?#dynamics.." | "..#statics.." | "..#entities,1,13,0
 end

 update_fade()
 
end


-->8
-- entities

function make_entity(x,y,p)
 gid+=1
 local e={
  gid=gid,
  ⧗=0,
  x=x,
  y=y,
  dx=0,dy=0, -- delta movement
  ix=0,iy=0,
  
  w=8,h=8,

  spr=1,
  frame = 0,
  frames = 0,
  fs = 4,
  tw=1,th=1,
  sw=8,sh=8,
  
  df=draw_entity,
  uf=update_entity
 }
 
 add_params(p,e)
 
 return add(entities,e)
end

function update_entity_x(e)
 e.x += e.dx
 e.dx *= e.ix
 if abs(e.dx)<0.001 then
  e.dx=0
 end
end

function update_entity_y(e)
 e.y += e.dy
 
 e.dy *= e.iy
 if abs(e.dy)<0.001 then
  e.dy=0
 end
end

function update_entity(e)
 e.⧗ += 1

 -- store old values
 e.odx=e.dx
 e.ody=e.dy
 e.ox=e.x
 e.oy=e.y
 
 -- collide with world
 update_entity_x(e)
 
 update_entity_y(e)
  
 update_entity_a(e)
end

function update_entity_a(e)
 if e.frames>0 then
  if (e.⧗ % e.fs == 0) e.frame += 1
  if (e.frame>=e.frames) e.frame=0
 end 
end

function draw_entity(e)
 spr(e.spr+e.frame*e.tw,
  e.x - e.sw/2, 
  e.y - e.sh + 1, 
  e.tw, e.th,
  e.dir==-1)  

 if (debug) then
  pset(e.x,e.y,8)
  print(e.frames,e.x-8,e.y,7)
  if e.pusher then
	  print(e.pusher.type.."-"..e.pusher.gid,e.x,e.y-8,7)
	  line(e.pusher.x,e.pusher.y,e.x,e.y,9)
	  --e.pusher=nil
  end
 end
end

----------------
-- ball


function make_ball(x,y)
	return make_entity(x,y,{
	 type="ball",
	 ix=0.9,iy=0.9,
	 z=0, dz=0,
	 state=0,
	 uf=update_ball,
	 df=draw_ball
	})
	
end

function update_ball(b)

 if b.state==1 then
  
  if not b.putting then
   b.z+=b.dz
   b.dz-=0.01
  end
  

  local stop_ball=false
  
  if b.z<=0 then
   local snd=nil
   b.z=0
   b.dz=-b.dz/2
   b.terrain="grass"
   
   if is_tree(b.x,b.y) or not on_map(b) then
    sfx(54)
    snd=true
    b.terrain="tree"
    kill_ball(b)
    stop_ball=true
			 show_message("OUT OF BOUNDS")
   end
   
   if is_bunker(b.x,b.y) then
    sfx(57)
    snd=true
    b.terrain="sand"
			 -- particles
			 make_dust(b.x,b.y,b.dx,b.dy,b.dz)
    -- stop in the bunker
    b.dz=0
    stop_ball=true
			end
			
   if is_rough(b.x,b.y) then
    b.terrain="rough"
    -- bad bounce
    b.dz/=2
			end

 
	  if is_water(b.x,b.y) then
    sfx(56)
    snd=true
    b.terrain="water"
    -- stop and die
    kill_ball(b)
			
			 -- particles
			 make_splash(b.x,b.y)
    stop_ball=true   
			 show_message("OUT OF BOUNDS")
			end
			
			-- ball in hole?
	  local d=distance(b,hole)
	  if d<1.5 and not b.bounce then
	   local spd=sqrt(b.dx*b.dx+b.dy*b.dy)
	   if b.putting and spd>0.25 then
	    local a=atan2(b.dx,b.dy)
	    a+=rnd(0.4)-0.2
	    b.dx=spd*cos(a)
	    b.dy=spd*sin(a)
	    b.bounce=true
	    sfx(55)
	   else
		   pl.spr=16
		   del(entities,b)
		   state=2
		   score_card_y=96
     sfx(52)
     snd=true
     if courses[tee].score==1 then
 	  	 show_message("HOLE IN ONE")
	    else
	     local diff=courses[tee].score-courses[tee].par 
	     if (diff==-3) show_message("ALBATROSS")
	     if (diff==-2) show_message("EAGLE")
	     if (diff==-1) show_message("BIRDIE")
	     if (diff==0) show_message("PAR")
	     if (diff==1) show_message("BOGEY")
	     if (diff==2) show_message("DOUBLE BOGEY")
	     if (diff==3) show_message("TRIPPLE BOGEY")
	    end
		   return
		  end
	  end
	  
	  if not snd and not b.putting then
 	  sfx(58)
	  end

   -- stopped bouncing?
   if abs(b.dz)<0.1 and not ball.putting then
    stop_ball=true
   end
   if abs(b.dx)<0.05 and
      abs(b.dy)<0.05 and
      ball.putting then
    stop_ball=true
   end
    
   if stop_ball then
    b.state=2
    b.count=0
    b.dx=0
    b.dy=0
    b.bounce=false
    
    -- is on green?
    if not is_bunker(b.x,b.y) then
	    for g in all(terrain) do
	     local dist=distance(g,b)
	     if dist<=g.r then
	      b.terrain="green"
	      if not b.on_green then
	       b.on_green=true
	       show_message("ON THE GREEN")
	      end
	     end
     end
    end
    
   elseif not ball.putting then
    b.dx/=2
    b.dy/=2
	  end
  end
 elseif b.state==2 then
  b.count+=1
  if b.count>=30 then
   b.state=0
  end
 end
 
 update_entity(b)	

 if b.state==1 and not b.hit_cart then
	 -- check against carts
	 if b.z>0.1 and b.z<6 then
	  for c in all(carts) do
	  	-- overlap?
	 		local dx=(c.x+c.cox)-b.x
	 		if abs(dx)<8 then
	 		local dy=(c.y+c.coy)-b.y
		 		if abs(dy)<8 then
 	  		local d2=dx*dx+dy*dy
	   		if d2<=c.cr^2 then
			 		 b.x-=b.dx
			 		 b.y-=b.dy
			 		 local a=atan2(b.dx,b.dy)
			 		 local f=sqrt(b.dx*b.dx+b.dy*b.dy)
			 		 b.dx=-f*cos(a)/2
			 		 b.dy=-f*sin(a)/2
			 		 sfx(53)
			 		 b.hit_cart=true
		 			 c.a+=rnd(0.1)-0.05
			 		end
		 		end
	   end
	  end
	 end
	end
end

function kill_ball(b)
 swing_state=0
 pl.frames=4
 track(pl,nil,30)
 del(entities, b)
 ball=make_ball(b.orgx, b.orgy)
 poi=ball
end

function put_ball(b,pow,a)
 b.orgx=b.x
 b.orgy=b.y
 b.dx=2.5*pow*cos(a)
 b.dy=2.5*pow*sin(a)
 b.ix=0.95
 b.iy=0.95
 b.dz=0
 b.state=1
 b.hit_cart=false
 courses[tee].score+=1
end

function hit_ball(b,dx,dy)
 b.dist=sqrt(dx*dx+dy*dy)
 b.odist=b.dist
 b.dx=dx/b.dist/2.5
 b.dy=dy/b.dist/2.5
 b.ix=1
 b.iy=1
 b.dz=b.dist/24
 b.state=1
 b.hit_cart = false
 
 b.orgx=b.x
 b.orgy=b.y
 
 courses[tee].score+=1
 
 if in_bunker then
  make_dust(b.x,b.y,b.dx/2,b.dy/2,1)
 end
end   
   
function draw_ball(e)

 if swing_state==0 and not pl.can_hit_ball then
  if ⧗%120<15 then
   circ(e.x,e.y,1,15)
  end
 end

 pset(e.x,e.y,dpal[pget(e.x,e.y)+1])
 pset(e.x,e.y-e.z,7)
 
-- print(e.dy,e.x,e.y-10,7)
-- print(e.iy,e.x,e.y-16,7)
end


----------------
-- characters

function make_player(x,y)
 return make_entity(x,y,{
	 type="character",
	 spr=16,
	 frames=0,
	 fs=6,
	 df=draw_character,
	 uf=update_character,
	 has_control=false
	})
end

function draw_character(e)
 draw_entity(e)
 
 local c=e.can_enter_cart
 local b=e.can_hit_ball
 if swing_state==0 then
	 if e.has_control and c and not c.nox and btnx_cooldown==0 then
   draw❎(c.x-4,c.y-13,7,13)
	 elseif e.has_control and b and btnx_cooldown==0 then
   draw❎(b.x-4,b.y-13,7,13)
	 end
	end
end

function update_character(e)
 if e.has_control and swing_state==0 then
	 if (btn(⬅️)) e.dx-=0.25
	 if (btn(➡️)) e.dx+=0.25
	 if (btn(⬆️)) e.dy-=0.25
	 if (btn(⬇️)) e.dy+=0.25
 end
 
 if not e.swimming then
  if (e.dx!=0 or e.dy!=0) and ⧗%16==0 then
   sfx(rnd()>0.5 and 61 or 42)
  end
 end
  
 if ssgn(e.dx)!=0 or ssgn(e.dy)!=0 then
  if e.dx!=0 then
   e.dir=ssgn(e.dx)
  end
  e.frames=4
 else
  e.frames=0
  e.frame=0
 end
 
 e.swimming=false
 if swing_state==0 then
	 if is_water(e.x,e.y) then
	  e.dx*=0.7
	  e.dy*=0.7
	  e.swimming=(mget(e.x/8,e.y/8)==68)
	 end
	  
	 if e.swimming then
	  if e.frames>2 then
 	  e.frames=2
	  end
	  if not e.was_swimming then
 	  e.spr=20
 	  e.fs=18
	   make_splash(e.x,e.y)
    sfx(56)
	  end
	  e.dx*=0.7
	  e.dy*=0.7
	  if rnd()>0.9 and (abs(e.dx)>0.01 or abs(e.dy)>0.01) then
	   local a=atan2(e.dx,e.dy)+0.15*(rnd()-0.5)
				make_swim_trail(e.x,e.y,a)
			end
	  
	  e.dx/=2
	  e.dy/=2
	 elseif e.was_swimming then
	  e.fs=6
	  e.spr=16
	  e.frames=4
	 end
 end
 e.was_swimming=e.swimming

 update_entity(e)
  
 if is_blocked(e.x,e.y) or not on_map(e) then
  e.x=e.ox
  e.y=e.oy
  e.dx,e.dy=0,0
 end

 -- check for carts
 e.can_enter_cart=nil
 e.can_hit_ball=nil
 
 if e.has_control then
  e.y+=1

  -- check carts
  for _,e2 in ipairs(carts) do
   local dx=abs(e.x-e2.x)
   local dy=abs(e.y-e2.y)
   if dx<10 and dy<10 then
	 	 local dist=distance(e,e2)
	 	 if dist<6 then
	 	  e.can_enter_cart=e2
		  end
	  end
	 end

  -- check ball
  if ball then
   if distance(e,ball)<4 then
    e.can_hit_ball=ball
	 	 e.can_enter_cart=nil
	  end
  end

	 e.y-=1
 end
 
 if btnpx() then
	 if e.can_enter_cart then
	  -- enter cart
	  e.has_control=false
	  e.can_enter_cart.nox=false
	  e.can_enter_cart.has_control=true
	  e.can_enter_cart.character=e
	  track(e.can_enter_cart,1)
	  del(entities,e)
	  del(dynamics,e)
 	 e.can_enter_cart.cprio=30
	  
	 elseif e.can_hit_ball and swing_state==0 then
	  -- hit ball
	  put_⧗=0
			courses[tee].started=true
   local dx=hole.x-e.can_hit_ball.x
   local dy=hole.y-e.can_hit_ball.y
   local a=atan2(dx,dy)+rnd(0.1)-0.05
   e.spr=32
   e.y=e.can_hit_ball.y
   e.rev_swing=hole.y>e.y
   if hole.x>e.x then
    e.x=e.can_hit_ball.x-2
    e.dir=1
   else
    e.x=e.can_hit_ball.x+3
    e.dir=-1
   end
   swing_state=1
   local dist=(rnd(0.2)+0.5)*min(80,distance(hole,e.can_hit_ball))
   reticule={
    max=0,
    r=0,adj=0,
    x=e.can_hit_ball.x,
    y=e.can_hit_ball.y,
    tx=e.can_hit_ball.x+dist*cos(a),
    ty=e.can_hit_ball.y+dist*sin(a)
   }
		 swing_a=-0.35
		 track(reticule)
	 end
	end
	
	-- push player into the tilemap
 if (e.x>=830) e.x-=0.25
 if (e.x<=2)   e.x+=0.25
 if (e.y>=254) e.y-=0.25
 if (e.y<=2)   e.y+=0.25
	
	
end


------------------
-- carts

function make_cart(x,y,a)
	return make_entity(x,y,{
	 type="cart",
	 a=a,ta=a,
	 is_cart=true,
	 s=0,
	 uf=update_cart,
	 df=draw_cart,
	 col=rnd({1,2,4,8,0}),
	 gcol=7,
	 trail_chance=0,
	 throttle_count=0
	})
end
	
function draw_cart(e)
 if e.x>camx-9 and e.x<camx+72 and 
    e.y>camy-9 and e.y<camy+72 then
	  
	 e.gcol=pget(e.x,e.y)
	 
	 pal(8,my_pal[e.col+1])
		-- draw stack
		for i=11+flr(e.sinking),15 do
		 local sx = 8 * (i%16)
		 local sy = 8 * flr(i/16)
		 rspr(sx,sy, e.x-4, e.y-i*1+6+flr(e.sinking),e.a, 1)
		end

	 pal(8,my_pal[9])
	 
	 if (debug) then
	  pset(e.x,e.y,7)
	  if e.sinking then
 	  print(e.sinking,e.x,e.y-8,7)
 --	  line(e.pusher.x,e.pusher.y,e.x,e.y,9)
 	  --e.pusher="bob"
	  end
	 end
	end
end

function update_cart(e)
 if e.hit_by_cart>0 then
  e.hit_by_cart-=1
 end

 local oa=e.a
 local throttle=false
 if e.has_control then
  if not e.sinking  then
	 	if btn(⬆️) or btn(🅾️) then
	 	 e.s+=0.03
	 	 e.throttle_count+=1
	 	end
	 	if btn(⬇️) then
	 	 e.s-=0.015
	 	 e.throttle_count+=1
	 	end
	 	if (btn(⬅️)) e.a-=0.008
	 	if (btn(➡️)) e.a+=0.008
  end
 	
 	if btnpx() then
 	 if e.character then
 	  -- leave cart
 	  leave_cart(e)
 	 end
 	end
 end
 
 e.x+=e.s*cos(e.a)
 e.y-=e.s*sin(e.a)
 
	e.s*=0.95
	if oa!=e.a then
	 e.s*=0.98
	end
	if e.s>0.1 and is_bunker(e.x,e.y-1) then
	 e.s*=0.9
	 e.a+=rnd(0.04)-0.02
	end
	local tile=mget(e.x/8,(e.y-1)/8)
	if tile==68 and not e.sinking then
	 e.sinking=0
	 e.s=0
-- 	if is_water(e.x,e.y-1) then
--	  e.s*=0.3
--	 end
	end
	local nx=e.x+3*cos(e.a)*ssgn(e.s)
	local ny=e.y-3*sin(e.a)*ssgn(e.s)
	if is_blocked(nx,ny) or not on_map(e) then
	 e.s=-e.s
	 if not e.character then
	  e.x=e.ox
	  e.y=e.oy
	 end
	end

 e.trail_chance*=0.9
 if e.s>0.1 and (oa!=e.a or e.character==nil) then
  e.trail_chance+=0.075
 end
	
 if e.gcol!=12 then
		if rnd()<e.trail_chance then
		 add(trails,{
		  x=e.x-2.5*cos(e.a+0.1),
		  y=e.y+2.5*sin(e.a+0.1)-1,
		  c=dpal[e.gcol+1],
		  life=399+rnd(99),
		 })
	 end
		if rnd()<e.trail_chance then
		 add(trails,{
		  x=e.x-2.5*cos(e.a-0.1),
		  y=e.y+2.5*sin(e.a-0.1)-1,
		  c=dpal[e.gcol+1],
		  life=399+rnd(99),
		 })
		end
	else --if rnd()<e.trail_chance then
  make_swim_trail(e.x,e.y,e.a-0.3+rnd(0.4))	
	end
 -- sound
 if e.throttle_count==1 then
  sfx(49,-2)
  sfx(51)
 elseif (not btn(⬆️) and not btn(⬇️) and not btn(🅾️)) and e.s<0.5 and e.throttle_count>1 then
  sfx(51,-2)
  sfx(49)
  e.throttle_count=0
 end
 
 if (not btn(⬆️) and not btn(⬇️) and not btn(🅾️)) then
  if e.throttle_count>0 then
   e.throttle_count-=1
  end
 end

 if e.sinking then
  e.sinking+=0.1
  if rnd()>0.9 then
   make_splash(e.x,e.y)
  end
  if (e.sinking==0.1) sfx(56)
  if e.sinking>5 then
   leave_cart(e)
   sfx(51,-2)
   sfx(49,-2)
   del(entities,e)
   del(dynamics,e)
   del(carts,e)
  end
 end
 e.ox=e.x
 e.oy=e.y

end

function leave_cart(e)
 if e.character then
  e.character.x=e.x
  e.character.y=e.y
  add(entities,e.character)
  add(dynamics, e.character)
  track(e.character,1)
  e.character.has_control=true
 end
 e.cprio=20
 e.has_control=false
 e.character=nil
end
-->8
-- particles

function make_splash(x,y)
	for i=1,8 do
		add(particles, {
		 x=x, y=y,
		 z=0, g=1,
		 dx=rnd(0.2)-0.1,
		 dy=rnd(0.1)-0.05,
		 dz=rnd(0.3)+0.6,
		 life=100,
		 col=7
		})
	end
end

function make_swim_trail(x,y,a)
	add(particles, {
				 x=x-cos(a), y=y-sin(a),
				 z=0,
				 g=0,
				 dx=-0.1*cos(a),
				 dy=-0.1*sin(a),
				 dz=0,
				 life=15+rnd(30),
				 col=7
				})
end


function make_sign_smash(x,y)
	for i=1,8 do
		add(particles, {
		 x=x, y=y,
		 z=0, g=1,
		 dx=rnd(0.4)-0.2,
		 dy=rnd(0.4)-0.2,
		 dz=rnd(0.5)+0.5,
		 life=100,
		 col=rnd() > 0.5 and 7 or 6
		})
	end
end

function make_dust(x,y,dx,dy,dz)
	for i=1,8 do
		add(particles, {
		 x=x, y=y,
		 z=0, g=1,
		 dx=rnd(0.2)-0.1+dx,
		 dy=rnd(0.1)-0.05+dy,
		 dz=rnd(0.3)+dz/2,
		 life=200,
		 col=rnd()>0.7 and 14 or 6
		})
	end
end

function update_particle(p)
 p.z+=p.dz
 p.dz-=0.05*p.g
 p.y+=p.dy
 p.x+=p.dx
 p.life-=1
 if p.z<0 or p.life<=0 then
  del(particles,p)
 end
end
-->8
-- helpers


function update_fade()
 for i=0,15 do
  local col,k=i,6*fade_progress
  for j=1,k do
   col=dpal[col+1]
  end
  pal(i,my_pal[col+1],1)
 end
end

function fadeout()
 while fade_progress<1 do
  fade_progress=min(fade_progress+0.1,1)
  update_fade()
  flip()
 end
 
 for i=0,4 do
  flip()
 end

end

function get_reticule_r()
 local dist=distance(reticule,ball)
 if dist>40 then
  dist+=2*(dist-40)
 end
 
 if ball.terrain=="sand" then
  dist+=40
 end
 
 return dist/8+4
end

function is_bunker(x,y)
 -- get tile
 local tile=mget(x/8,y/8)
 
 -- skip non-bunker tiles
 if (not fget(tile,6)) return false

 -- get pos in sprite mem
 local sx=8*(tile%16)
 local sy=8*(tile\16)
 
 -- check pixel
 local tx=flr(x)%8
 local ty=flr(y)%8
 local c=sget(sx+tx,sy+ty)

 return c!=0
end

function is_tree(x,y)
 -- get tile
 local tile=mget(x/8,y/8)
 
 -- skip non-tree tiles
 if (not fget(tile,0)) return false

 return true
end

function on_map(b)
 if b.x<=2 or b.y<=2 or b.x>=830 or b.y>=254 then
  return false
 end
 return true
end

function is_rough(x,y)
 -- get tile
 local tile=mget(x/8,y/8)
 
 -- skip non-bunker tiles
 if (not fget(tile,2)) return false

 -- get pos in sprite mem
 local sx=8*(tile%16)
 local sy=8*(tile\16)
 
 -- check pixel
 local tx=flr(x)%8
 local ty=flr(y)%8
 local c=sget(sx+tx,sy+ty)

 return c!=0
end

function is_blocked(x,y)
 -- get tile
 local tile=mget(x/8,y/8)
 
 -- skip non-blocked tiles
 if (not fget(tile,0)) return false

 -- get pos in sprite mem
 local sx=8*(tile%16)
 local sy=8*(tile\16)
 
 -- check pixel
 local tx=flr(x)%8
 local ty=flr(y)%8
 local c=sget(sx+tx,sy+ty)

 return c!=0
end


function is_water(x,y)
 -- get tile
 local tile=mget(x/8,y/8)
 
 -- skip non-water tiles
 if (not fget(tile,4)) return false

 -- get pos in sprite mem
 local sx=8*(tile%16)
 local sy=8*(tile\16)
 
 -- check pixel
 local tx=flr(x)%8
 local ty=flr(y)%8
 local c=sget(sx+tx,sy+ty)

 if c==12 or c==7 then
  return true
 end
 
 return false
end


function dcirc(x,y,r,c,step1,step2)
 step1=step1 or 0.05
 step2=step2 or 0.05
 local base=⧗/250
 local x1=r*cos(base)
 local y1=r*sin(base)
 local j=0
 local a=0
 while a<1 do
 	local x2=r*cos(a+base)
 	local y2=r*sin(a+base)
 	if j%2==0 then
  	line(x+x1,y+y1,x+x2,y+y2,c)
  	a+=step1
  else
   a+=step2
  end
 	x1=x2
 	y1=y2
  j+=1
 end
 
-- for a=0,1,step do
-- 	local x2=r*cos(a+base)
-- 	local y2=r*sin(a+base)
-- 	if j%2==0 then
--  	line(x+x1,y+y1,x+x2,y+y2,c)
--  end
-- 	x1=x2
-- 	y1=y2
-- 	j+=1
-- end
end

function btnpx()
 if btnx_cooldown==0 then
  if btnp(❎) then
   btnx_cooldown=16
   return true
  end
 end
 return false
end

function distance(a,b)
 local dx=abs(a.x-b.x)/10
 local dy=abs(a.y-b.y)/10
 return sqrt(dx*dx+dy*dy)*10	
end

function sort(a,p)
 for i=1,#a do
  local j = i
  while j > 1 and a[j-1][p] > a[j][p] do
   a[j],a[j-1] = a[j-1],a[j]
   j = j - 1
  end
 end
end

function add_params(src,dst)
 for k,v in pairs(src) do
  dst[k]=v
 end
end

function ssgn(x)
	if (x<0) return -1
	if (x>0) return 1
	return 0
end

-- sprite rotation by @fsouchu

-- rotate a sprite
-- col 0 is transparent
-- sx,sy - sprite sheet coords
-- x,y - screen coords
-- a - angle
-- w - width in tiles
function rspr(sx,sy,x,y,a,w)
 local ca,sa=cos(a),sin(a)
 local srcx,srcy
 local ddx0,ddy0=ca,sa
 local mask=shl(0xfff8,(w-1))
 w*=4
 ca*=w-0.5
 sa*=w-0.5
 local dx0,dy0=sa-ca+w,-ca-sa+w
 w=2*w-1
 for ix=0,w do
  srcx,srcy=dx0,dy0
  for iy=0,w do
   if band(bor(srcx,srcy),mask)==0 then
    local c=sget(sx+srcx,sy+srcy)
				-- set transparent color here
    if (c!=0) pset(x+ix,y+iy,c)
   end
   srcx-=ddy0
   srcy+=ddx0
  end
  dx0+=ddx0
  dy0+=ddy0
 end
end


-->8
-- ui


function draw_arrow(e)
 spr(51+(⧗\8)%4,e.x-3,e.y-12+2*sin(t()))
end

function draw_bubble(txt,x,y)
 local yy=y+184-camy
 rectfill(x-1,yy,x+57,yy+18,1)
 rectfill(x,yy-1,x+56,yy+19,1)
 rectfill(x,yy,x+56,yy+18,7)
 spr(46,x+158-camx,yy-4)
 print(txt,x+1,yy+1,1)
 draw❎(x+49,yy+16,6,1)
end


function set_ticker(str)
 ticker={
  str=str,
  x=64,
  y=-8,
  life=4 * #str + 64
 }
end

function update_ticker()
 
end

function draw_score_card(x,y)
 rectfill(x,y,x+57,y+24,13)
 rectfill(x,y,x+57,y+23,7)
 spr(74,x+1,y+1,2,1)
 spr(76,x+1,y+20,2,1)
 spr(78,x+46,y+20,2,1)
 local sum=0
 for i=1,9 do
  rectfill(x-4+i*5,y+5,x+i*5,y+11,i%2==1 and 15 or 7)
  print(i,x-3+i*5,y+6,14)
  rectfill(x-4+i*5,y+12,x+i*5,y+18,i%2==1 and 6 or 7)
--  if courses[i].score>0 or i==tee then
  if courses[i].score>0 then
   if i<tee or ⧗%30>15 then
    local col=1
    if (courses[i].score<courses[i].par) col=5
    if (courses[i].score>courses[i].par) col=2
    print(courses[i].score,x-3+i*5,y+13,col)   
   end
  end
  sum+=courses[i].score
 end
 local len=#(""..sum)*4
 print(sum,x+58-len,y+13,1)
 total_result=sum
 
 draw❎(x+50,y,6,13)
end

function draw❎(x,y,c1,c2)
 print("❎",x,y,c2)
 print("x",x+2,y,c2)
 print("❎",x,y-(⧗%60>20 and 1 or 0),c1)
end



function draw_reticule(x,y,r,c)
 dcirc(x,y+1,r,1)
 dcirc(x,y,  r,c)
-- pset(x,y+1,1)
-- pset(x,y+1,1)
 pset(x,y,7)
end

function draw_putt_ui(x,y)
	local d=distance(hole,ball)/2
	local r=d/10 --7

 -- bar
	spr(58,x,y,5,1)
	spr(63,x+1+r*30,y+1)

	-- marker
	local dy=-4
	if (r*30>16) dy=-5
	if (r*30>27) dy=-6
	spr(47,x+1+r*30,y+dy)
	
	-- x
	if swing_state==1 then
 	draw❎(x+38,y+2,7,5)
	end
	
	-- ball
	local r=1-abs(cos(put_⧗/250))
	if swing_state==2 then
	 r=ball.power
	end
	local id=56
	if swing_state==2 and ⧗%16>7 then
	 id=57
	end
	spr(id,x+33*r-1,y+1)
	
	return r
end

function draw_done(x,y)
 local ltrs={9,10,24,24,64,29,23,28,10}
 local i=0
 for l in all(ltrs) do
  spr(ltrs[i+1],x+i*9,y)
  if ltrs[i+1]==64 then
   x-=45 -- 9*5
   y+=10
  end
  i+=1
 end
end

function draw_logo(x,y)
 for i=0,3 do
  spr(22+i,x+i*9,y)
 end
 for i=0,5 do
  spr(26+i,x-9+i*9,y+10)
 end
end

function draw_title()
 pal(7,5)
 draw_logo(14,13)
 pal(7,7)
 draw_logo(14,12)
 
 draw❎(28,40,7,5)
 
 local ticker="CREATED BY @jOHANpEITZ     MUSIC & SFX BY @gRUBER_mUSIC  "
 local tx=64-(⧗%((#ticker*4+64)*4))/4
 print(ticker,tx,58,5)
 print(ticker,tx,57,7)
 
 if btn(🅾️) then
  print("V"..version,1,2,5)
  print("V"..version,1,1,7)
 end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000077000077077777770000000000000000000000000000000000000000
00000000000000000000000000000000000000000000771000000000000000000000000077000077777000000000000000000000000000000000000000000000
00700700000078000077770001766700007777000076670000000000000000000000000077000077777000000110011008877777086000600060060000777700
000770000000788000600600007007000060060000700700000000000000000000000000770770777777777700111100088ddd77080000000000000000777700
000770000000700000600670007007000760060000700700000000000000000000000000770770777777777700111100088ddd77080000000000000000777700
00700700000070000077777000766700077777000076671000000076000000000000000077077077777000000110011008877777086000600060060000777700
00000000000060000010001001770000010001000000000000006788000000000000000077777777777777770000000000000000000000000000000000000000
000000000000d0000000000000000000000000000000000000670008000000000000000007700770077777770000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000007777770077777700770000007777777077777707770077777777770777777700777777077700770
00000000000000000000000000000000000000000000000077700777777007777770000077700000777007777770077777700777777007777770077777700777
00000000000000000000000000000000000000000000000077700000777007777770000077700000777000007770077777700777777007777770077777700777
00000000000000000000000000000000000000000000000077707777777007777770000077777777077777707770077777700777777007777777777777777777
000e0000000e0000000e0000000e0000000000000000000077707777777007777770000077777777007777777770077777700777777007777777777707777777
008800000f88e0000088000000880000000000000000000077700777777007777770000077700000770007777770077777700777777007777770077700000777
00fd000000dd000000fdd0000ddf0000000e00000000000077777777777777777777777777700000777777777777777777700777777777777770077777777777
000d000000d000000d0000000000d00000080000000e000007777770077777700777777777700000077777700777777077700777777777707770077707777770
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000017100000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000177710000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001777771000000000
000e0000010e0000000e0000000e0100000e0100000e0000000e0100000e0000000e000000000000000000000000000000000000000000000000000000000000
0008000000f80000000800000008f7000008f000000800000008f700000800000008000000000000000000000000000000000000000000000000000007770000
000df000000d0000070df000000d7700000d0000070df000000d7700000f0000000df00000000000000000000000000000000000000000000000000067776000
000d0170000d00700077717000777000000d0000007d7170007d7000000d1070000d010000000000000000000000000000000000000000000000000000700000
00000000000000000000000000000000000000000000000000000000000000000000000000880000000000000000000000000000000000007777700000000000
07800000006d600000000000077777000076d0000007000000d6700000000000006600000866800000000000000000000007777777777777bbbb700000000000
078800000678760000088800078887000078d0000007000000d87000000000000677d0008677d80077777777777777777775533333aaaaab9999700000000000
0755000006788d0000867d20078887000078d0000007000000d87000000080000676d0008676d80072222121112122255553a3aaababbb9b9999700000000000
070000000677760000877620007870000078d0000007000000d870000008820000dd000008dd8000788888222225555533333aaaaabbbbb99999700000700000
0700000005666500008d6d200007000000060000000700000006000000002000000000000088000078888282225255535333a3aaababbb9b9999700067776000
05000000005550000002220000000000000000000000000000000000000000000000000000000000777777777777777777777777777777777777700007770000
00000000000000000000000000000000000000000000000000000000000000000000000000000000555555555555555555555555555555555555500005550000
0000000033333333ffffff0000ffffffcccccccc33333333333333330000000077700700777000006060666060006660ddd0ddd00dd00000ddd0ddd0ddd00000
0000000033333333ffff00000000ffffcccccccc33333333353333330000000077707770775000006660606060006600ddd00d000d0000000d00d0d00d000000
0000000033333333fff0000000000fffcccccccc33333333355333330000000075507570757000006060666066606660d0000d00dd0000000d00ddd00d000000
0000000033333333ff000000000000ffcccccccc3333353333533553000000005000505050500000000000000000000000000000000000000000000000000000
0000000033333333f00000000000000fcccccccc5533553333535533000000000000000000000000000000000000000000000000000000000000000000000000
0000000033333333f00000000000000fcccccccc3553533333333333000000000000000000000000000000000000000000000000000000000000000000000000
00000000333333330000000000000000cccccccc3333333333333333000000000000000000000000000000000000000000000000000000000000000000000000
00000000333333330000000000000000cccccccc3333333333333333000000000000000000000000000000000000000000000000000000000000000000000000
44444444444244420000000000000000444244424442444200000000007777700077777000777770007777700077777000777770007777700077777000777770
44444444444244420000000000000000444244424442444200660000007717700071177000711170007171700071117000771770007111700071117000771770
4444444444424442f00000000000000e444244424442444267dd6000007117700077717000777170007171700071777000717770007771700071717000717170
2222222244424442f00000000000000e44424442444244426d7d7600007717700077177000771770007111700071177000711770007771700077177000771170
4444444444424442ff000000000000ee444244424442444206776620007717700071777000777170007771700077717000717170007717700071717000777170
4444444444424442fff0000000000eee444244424442444200660000007717700071117000711770007771700071177000771770007717700071117000771770
4444444444424442ffff00000000eeef444244424442222200040000006666600066666000666660006666600066666000666660006666600066666000666660
2222222244424442ffffff0000eeeeff222122212221ccc100000000004000400040004000400040004000400040004000400040004000400040004000400040
eeeffffffffffeee000000eeee000000ffffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eefffeffffefffee0000eeeeeeee0000fffffeff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
effffffffffffffe000eeeeffffee000ffffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffffffffffffff00eeeffffffffe00ffffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
feffffffffffffef0eeefffffefffff0feffffff0000000000000000001110000011100000111000001110000011100000111000001110000011100000111000
ffffffffffffffff0eeffffffffffef0ffffffff0000000000000000001110000011100000111000001110000011100000111000001110000011100000111000
ffffeffffffeffffeeefefffffffffffffffefff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffffffffffffffeeffffffffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffffffffffffffeeffffffffffffffeeffffffeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffeffffffeffffeeffffffffffffffeefffeffeeeeeeee00000000000000000000444000000000000000000000000000004440000000000000444000000000
ffffffffffffffff0efffffffefffff0eeffffffffffffff00000000000000000000444000000000000000000000000000004440000000000000444000000000
feffffffffffffef0eefeffffffffff0eeffffffffffffff00000000000000000000444000000000000000000000000000004440000000000000444000000000
ffffffffffffffff00efffffffffef00eefffffffeffffff00000000044444400000444004444440044444400444444000004440044444400000444004444440
effffffffffffffe000efffffffff000eeffffffffffffff00000000044444400000444004444440044444400444444000004440044444400000444004444440
eefffeffffefffee0000ffffffff0000eeffefffffffefff00000000044444400000444004444440044444400444444000004440044444400000444004444440
eeeffffffffffeee000000ffff000000eeffffffffffffff00000000022222200000222002222220022222200222222000002220022222200000222002222220
333333000333333300003033330000003333333333333333000effffffe00000ffffccccccccfffffe000effcccc7fff00000000000000000000000000000000
33333000003033330000333333330300333333333333333300efffffffffe000fff7cccccccc7fffffffffffcccc7ffe00000000000000000000000000000000
33303000000033330303333333333300333334334433434400ffffffffffffe0f77ccccccccc77ffffffffffccc77ff000000000000000000000000000000000
3330000000003033033333333333330044333334444444440efff77777fffff0f7cccccccccccc7f777ffff7ccc7fff000000000000000000000000000000000
3030000000000003033333333333333033343333344444440fff7777777ffffeccccccccccccccccccccc777ccc7fff000000000000000000000000000000000
300000000000000303333333333333303333333333343333efff77cccc77ffffccccccccccccccccccccccccccccfffe00000000000000000000000000000000
300000000000000033333333333333333333333333333333fff77cccccc7ffffccccccccccccccccccccccccccccffff03000030000000000000000000000000
000000000000000033333333333333333333333333333333fff7ccccccc77fffcccccccccccccccccccccccccccc7fff03303030000000000000000000000000
000000000000000033333333333333333333333333333333fff7cccccccc7fffccccccccccccccccfff7cccccccccccc00000000000000000000000000000000
000000000000000033333333333333333333333333333333fff77cccccc77fffccccccccccccccccffffcccccccccccc00000000000000000000000000000000
300000000000000303333333333333303333933333393333efff7ccccc777fffccccccccccccccccefffcccccccccccc00000000000000000000000000000000
3030000000000003030333333333333033333333333333330fff77cc7777ffffcccccccccccccccc0fff7cccc777cccc00000000000000000000000000000000
3330000000003033000333333333330033333666666333330ffff777777ffffef7cccccccccccc7f0fff7ccc7ffff77700000000000000000000000000000000
3330300000003333000333333333330093366666666663390efffffffffffff0ff7ccccccccc77ff0ff7ccccffffffff00000000000000000000000000000000
3333300000003333000033333333030033666dd66dd66633000efffffffffe00fff7cccccccc7fffeff7ccccffffffff00000000000000000000000000000000
3333330000333333000000333300000033666dddddd6663300000efffffe0000ffffccccccccfffffff7ccccffe000ef00000000000000000000000000000000
3353553335333333000000555500000033666dd66dd666333333efffffffe33333333333ccc7fff3000000555500000033443333004400000000000000000000
3535333333533333000055333355000033d6666666663d3333efffffffffff33fe333effccc7ffe3000055333355000033444333004440000000000000000000
33533333333553330005333333355000933dd666666d333933ffffffffffffe3ffffffffcc77ff33000533333335500033344333000440000000000000000000
3533353333355555005333333335550033333d3dddd333333efffff7777ffff3ffffffffcc7fff33005333333335550033344433000444000000000000000000
5533535333535555005353533333550033333333333333333ffff777c777fffe777ffff7cc7fff33005335333333550033444333004440000000000000000000
533333333535555505333533333555503333933333393333efff77cccc777fffccccc777cccfffe3053353533335555033344333000440000000000000000000
133333333353555405333333333355503333333333333333fff77cccccc77fffcccccccccccffff3053333333333555033444333004440000000000000000000
333333333535555305333333333555503333333333333333fff77cccccc77fffccccccccccc7fff3053333333335555033444333004440000000000000000000
353333335355553305333333335355503533333353535553fff77ccccccc7fff3fff7ccccccccccc553333335355555533343333000400000000000000000000
335533333555333305333333353555503533333333355553fff77ccccccc7fff3ffffccccccccccc335533333555533333333333000000000000000000000000
333553335553333305333535335555503553333533555553fff777ccccc77ffe3efffcccc777cccc333553335553333333433333004000000000000000000000
333555555533333300553353555555003355335355555533ffff777cc777fff333fff7cc7ffff777333555555533333333333333000000000000000000000000
333355555533533300055555555550003335555555555333efffff7777ffffe333fff7ccffffffff333355555533533333334333000040000000000000000000
3335555553353533000005555550000033333555555333333effffffffffff3333ff77ccffffffff333555555335353333333333000000000000000000000000
335355541333333300000004100000003333333413333333333efffffffffe333eff7cccffe333ef335355541333333333343333000400000000000000000000
33355553333333330000000000000000333333333333333333333effffe333333fff7ccc33333333333555533333333333343333000400000000000000000000
33333333dddd6666dddddddddddd6666333333332882882821221221333333333333333333333333000000000000000000000000000000000000000000000000
33333333dddd6666dddddddddddd6666333333332822822821121121333333333333333333333333000888888888800000000000000000000000000000000000
33333333dddd6666dddddddddddd6666333333332281222821111211333333333333333333332333000800000000080000000000000000000000000000000000
36333333dddd6666dddddddddddd666633333333288281282112122133333333333333333332f233008000000000088000000000000000000000000000000000
66336333dddd66666666666666666666533333332828812821122121333333333333333333332333080000000000008000000000000000000000000000000000
66636633dddd66666666666666666666553363362828822821122121777777777777777733333333080000000000008000000000000000000000000000000000
66666636dddd6666666666666666666655d366662128282821212111771177117177711733333333080000000000008000000000000000000000000000000000
66666666dddd66666666666666666666dddd66662882882821221221717771717177177733333333080000000000088000000000000000000000000000000000
66666666dddddddd3333333212222222222222223333333213333333717171717177117733333333088800000088800000000000000000000000000000000000
66666666dddddddd3333322821111111111111113333322821133333771171177117177733333233000888000880000000000000000000000000000000000000
66666666dddddddd3332282821211221222122213332282821211333777777777777777733332f23000000800800000000000000000000000000000000000000
66666666dddddddd3222882821221121222122213222882821221113666666666666666633233233000000800880000000000000000000000000000000000000
66666666666666662882882821221211111111112882882821221221111111111111111132f23333000000800080000000000000000000000000000000000000
66666666666666662822822821121121212221222822822821121121212221222122212233233333000008800088000000000000000000000000000000000000
66666666666666662282282821211211212221222282282821211211212221222122212233333333000088000008888800000000000000000000000000000000
77777777777666662882882821221221111111112882882821221221111111111111111133333333088880000000000000000000000000000000000000000000
6ddd6666666666672882882821221221222222222222222222222222288288282122122133833333000000000000000000000000000000000000000000000000
6ddd6666666666672822822821121121444444444444444444444444282282282112112138823333000000000000000000000000000000000000000000000000
6ddd6666666666672282282821211211e4411144e4411444e4411444228228282121121188222333000000000000000000000000000000000000000000000000
6ddd6666666666672882882821221221441111144411114444111144288288211122122182422333000000000000000000000000000000000000000000000000
6ddd666666666667288288282122122144111114441e11444411e144288281122112122124142333000000000000000000000000000000000000000000000000
6ddd666666666667282282282112112144111114441c1144441c1144282112444421112134143333000000000000000000000000000000000000000000000000
6ddd666666666667228228282121121144ddddd44444444444444444211244444444211133333883000000000000000000000000000000000000000000000000
6666777777777777288288282122122122ddddd22222222222222222124444444444442133333333000000000000000000000000000000000000000000000000
66666666666666666666666666666666dddddddddd66766677766677444444444444444444444444000000000000000000000000000000000000000000000000
66666666666666666666666666666666ddddddddd666666777666777444444444444444444444444000000000000000000000000000000000000000000000000
66666666666666666666666666666666dddddddd666d667776667776444444444441144444411444000000000000000000000000000000000000000000000000
66666666666666666666666666666666dddddddddddd666666666666444444444411114444411444000000000000000000000000000000000000000000000000
66666666666666666666666666666666dddd6666dddd666666666666444444444411114444422444000000000000000000000000000000000000000000000000
66666666666666666666666666666666dddd6666dddd666666666666444444444411114444444444000000000000000000000000000000000000000000000000
66666666666666666666666666666666dddd6666dddd666666666666444444444455554444444444000000000000000000000000000000000000000000000000
66666666776766666667767766666777666d7667dddd666666666666222222222233332222222222000000000000000000000000000000000000000000000000
__label__
ffffffffffcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ffffffffffcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ffffff77cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ffffff77cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ff777777cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ff777777cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
7777cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
7777cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
77cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
77cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
77cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
77cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccc777777777777cccccc777777777777cccccc7777cccccccccccccc77777777777777cccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccc777777777777cccccc777777777777cccccc7777cccccccccccccc77777777777777cccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccc777777jjjj777777cc777777jjjj777777cc777777cccccccccccc777777jjjjjjjjjjcccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccc777777jjjj777777cc777777jjjj777777cc777777cccccccccccc777777jjjjjjjjjjcccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccc777777ccccjjjjjjcc777777cccc777777cc777777cccccccccccc777777cccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccc777777ccccjjjjjjcc777777cccc777777cc777777cccccccccccc777777cccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccc777777cc77777777cc777777cccc777777cc777777cccccccccccc7777777777777777cccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccc777777cc77777777cc777777cccc777777cc777777cccccccccccc7777777777777777cccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccc777777cc77777777cc777777cccc777777cc777777cccccccccccc7777777777777777cccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccc777777cc77777777cc777777cccc777777cc777777cccccccccccc7777777777777777cccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccc777777ccjj777777cc777777cccc777777cc777777cccccccccccc777777jjjjjjjjjjcccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccc777777ccjj777777cc777777cccc777777cc777777cccccccccccc777777jjjjjjjjjjcccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccc7777777777777777cc7777777777777777cc7777777777777777cc777777cccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccc7777777777777777cc7777777777777777cc7777777777777777cc777777cccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccjj777777777777jjccjj777777777777jjccjj77777777777777cc777777cccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccjj777777777777jjccjj777777777777jjccjj77777777777777cc777777cccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccjjjjjjjjjjjjccccccjjjjjjjjjjjjccccccjjjjjjjjjjjjjjccjjjjjjcccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccjjjjjjjjjjjjccccccjjjjjjjjjjjjccccccjjjjjjjjjjjjjjccjjjjjjcccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccc777777777777cccc777777cccc777777cc77777777777777cccc77777777777777cccccc777777777777cccc777777cccc7777cccccccccccccc
cccccccccccc777777777777cccc777777cccc777777cc77777777777777cccc77777777777777cccccc777777777777cccc777777cccc7777cccccccccccccc
cccccccccc777777jjjj777777cc777777cccc777777cc777777jjjj777777cc777777jjjj777777cc777777jjjj777777cc777777cccc777777cccccccccccc
cccccccccc777777jjjj777777cc777777cccc777777cc777777jjjj777777cc777777jjjj777777cc777777jjjj777777cc777777cccc777777cccccccccccc
cccccccccc777777ccccjjjjjjcc777777cccc777777cc777777cccc777777cc777777cccc777777cc777777cccc777777cc777777cccc777777cccccccccccc
cccccccccc777777ccccjjjjjjcc777777cccc777777cc777777cccc777777cc777777cccc777777cc777777cccc777777cc777777cccc777777cccccccccccc
ccccccccccjj777777777777cccc777777cccc777777cc777777cccc777777cc777777cccc777777cc7777777777777777cc7777777777777777cccccccccccc
ccccccccccjj777777777777cccc777777cccc777777cc777777cccc777777cc777777cccc777777cc7777777777777777cc7777777777777777cccccccccccc
ccccccccccccjj777777777777cc777777cccc777777cc777777cccc777777cc777777cccc777777cc7777777777777777ccjj77777777777777cccccccccccc
ccccccccccccjj777777777777cc777777cccc777777cc777777cccc777777cc777777cccc777777cc7777777777777777ccjj77777777777777cccccccccccc
cccccccccc7777jjjjjj777777cc777777cccc777777cc777777cccc777777cc777777cccc777777cc777777jjjj777777ccccjjjjjjjj777777cccccccccccc
cccccccccc7777jjjjjj777777cc777777cccc777777cc777777cccc777777cc777777cccc777777cc777777jjjj777777ccccjjjjjjjj777777cccccccccccc
cccccccccc7777777777777777cc7777777777777777cc777777cccc777777cc7777777777777777cc777777cccc777777cc7777777777777777cccccccccccc
cccccccccc7777777777777777cc7777777777777777cc777777cccc777777cc7777777777777777cc777777cccc777777cc7777777777777777cccccccccccc
ccccccccccjj777777777777jjccjj777777777777jjcc777777cccc777777cc77777777777777jjcc777777cccc777777ccjj777777777777jjcccccccccccc
ccccccccccjj777777777777jjccjj777777777777jjcc777777cccc777777cc77777777777777jjcc777777cccc777777ccjj777777777777jjcccccccccccc
ccccccccccccjjjjjjjjjjjjccccccjjjjjjjjjjjjccccjjjjjjccccjjjjjjccjjjjjjjjjjjjjjccccjjjjjjccccjjjjjjccccjjjjjjjjjjjjcccccccccccccc
ccccccccccccjjjjjjjjjjjjccccccjjjjjjjjjjjjccccjjjjjjccccjjjjjjccjjjjjjjjjjjjjjccccjjjjjjccccjjjjjjccccjjjjjjjjjjjjcccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc777777cccccccccc777777cccccccccc777777cccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc777777cccccccccc777777cccccccccc777777cccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccc77ffffffff77777777ffffffff77777777ffffffff777777cccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccc77ffffffff77777777ffffffff77777777ffffffff777777cccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccffffffffffffffffffffffffffffffffffffffffffffffffffffcccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccffffffffffffffffffffffffffffffffffffffffffffffffffffcccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccffffffffffffffffffffffffffffffffffffffffffffffffffffffffcccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccffffffffffffffffffffffffffffffffffffffffffffffffffffffffcccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccffffffffffvvrrrrrrvvffffffvvrrrrrrvvffffffvvrrrrrrvvffffffffcccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccffffffffffvvrrrrrrvvffffffvvrrrrrrvvffffffvvrrrrrrvvffffffffcccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccc77ffffffrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrffffff77cccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccc77ffffffrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrffffff77cccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccc7777ffffffrr7777777777rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrffffff7777cccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccc7777ffffffrr7777777777rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrffffff7777cccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccc777777ffffff7777jj77jj7777rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrvvffffff77cccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccc777777ffffff7777jj77jj7777rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrvvffffff77cccccccccccccc
cccccccccccccccccccccccccc777777cccccccc77777777ffffffff777777jj777777rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrffffff7777cccccc777777
cccccccccccccccccccccccccc777777cccccccc77777777ffffffff777777jj777777rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrffffff7777cccccc777777
cccccccccccccccccccccccc77ffffffff777777777777ffffffffvv7777jj77jj7777rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrffffffff77777777ffffff
cccccccccccccccccccccccc77ffffffff777777777777ffffffffvv7777jj77jj7777rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrffffffff77777777ffffff
ccccccccccccccccccccccffffffffffffffffffffffffffffffffrrjj7777777777jjrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrvvffffffffffffffffffff
ccccccccccccccccccccccffffffffffffffffffffffffffffffffrrjj7777777777jjrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrvvffffffffffffffffffff
ccccccccccccccccccccffffffffffffffffffffffffffffffvvrrrrrrjjjjjjjjjjrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrvvffffffffffffffff
ccccccccccccccccccccffffffffffffffffffffffffffffffvvrrrrrrjjjjjjjjjjrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrvvffffffffffffffff
ccccccccccccccccccffffffffffvvrrrrrrvvffffffffvvrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrvvffffffffvvrr
ccccccccccccccccccffffffffffvvrrrrrrvvffffffffvvrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrvvffffffffvvrr
cccccccccccccccc77ffffffrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr
cccccccccccccccc77ffffffrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr
cccccccccccccc7777ffffffrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrjjjjjjjjrrrrrrrrrrrrrrrrrrrr
cccccccccccccc7777ffffffrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrjjjjjjjjrrrrrrrrrrrrrrrrrrrr
cccccccccccc777777ffffffrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrjjjj33333333jjjjrrrrrrrrrrrrrrrr
cccccccccccc777777ffffffrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrjjjj33333333jjjjrrrrrrrrrrrrrrrr
cccccccc77777777ffffffffrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrjj33333333333333jjjjrrrrrrrrrrrrrr
cccccccc77777777ffffffffrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrjj33333333333333jjjjrrrrrrrrrrrrrr
cccccccc777777ffffffffvvrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrjj3333333333333333jjjjjjrrrrrrrrrrrr
cccccccc777777ffffffffvvrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrjj3333333333333333jjjjjjrrrrrrrrrrrr
ccccccffffffffffffffffrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrjj33jj33jj3333333333jjjjrrrrrrrrrrrr
ccccccffffffffffffffffrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrjj33jj33jj3333333333jjjjrrrrrrrrrrrr
ccccffffffffffffffvvrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrjj333333jj3333333333jjjjjjjjrrrrrrrrrr
ccccffffffffffffffvvrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrjj333333jj3333333333jjjjjjjjrrrrrrrrrr
ccffffffffffffvvrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrjj33333333333333333333jjjjjjrrrrrrrrrr
ccffffffffffffvvrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrjj33333333333333333333jjjjjjrrrrrrrrrr
77ffffffrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrjj333333333333333333jjjjjjjjrrrrrrrrrr
77ffffffrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrjj333333333333333333jjjjjjjjrrrrrrrrrr
77ffffvvrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrjj3333333333333333jj33jjjjjjrrrrrrrrrr
77ffffvvrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrjj3333333333333333jj33jjjjjjrrrrrrrrrr
77ffffrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrjj33333333333333jj33jjjjjjjjrrrrrrrrrr
77ffffrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrjj33333333333333jj33jjjjjjjjrrrrrrrrrr
ffffffrrrrrrrrrr77rrrr777777rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr777777rrrrrrrrrrrrrrrrrrrrrrjj333333jj33jj3333jjjjjjjjjjrrrrrrrrrr
ffffffrrrrrrrrrr77rrrr777777rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr777777rrrrrrrrrrrrrrrrrrrrrrjj333333jj33jj3333jjjjjjjjjjrrrrrrrrrr
ff77ffrrrrrrrr77jj77rrjj77jjrrrr7777rr77rr77rrrr7777rr7777rrrr77jj77rr777777rr777777rr777777jj777777jj33jjjjjjjjjjjjrrrrrrrrrrrr
ff77ffrrrrrrrr77jj77rrjj77jjrrrr7777rr77rr77rrrr7777rr7777rrrr77jj77rr777777rr777777rr777777jj777777jj33jjjjjjjjjjjjrrrrrrrrrrrr
7777ffvvrrrrrr77rr77rrrr77rrrr77jj77rr77rr77rr77jj77rr77jj77rr777777rr7777jjrrjj77jjrrjj77jjrrjjjj77jjjjjjjjjjjjjjrrrrrrrrrrrrrr
7777ffvvrrrrrr77rr77rrrr77rrrr77jj77rr77rr77rr77jj77rr77jj77rr777777rr7777jjrrjj77jjrrjj77jjrrjjjj77jjjjjjjjjjjjjjrrrrrrrrrrrrrr
jj77ffffrrrrrr77rrjjrrrr77rrrr77rr77rr777777rr777777rr77rr77rr77jjjjrr77jjrrrrrr77rrrrrr77rrrr77rrjjjjjjjjjjjjrrrrrrrrrrrrrrrrrr
jj77ffffrrrrrr77rrjjrrrr77rrrr77rr77rr777777rr777777rr77rr77rr77jjjjrr77jjrrrrrr77rrrrrr77rrrr77rrjjjjjjjjjjjjrrrrrrrrrrrrrrrrrr
77jjffffrrrrrrjj7777rr7777rrrr7777jjrr77jj77rr77jj77rr77rr77rr77rrrrrrjj7777rr777777rrrr77rrrr777777rr44llrrrrrrrrrrrrrrrrrrrrrr
77jjffffrrrrrrjj7777rr7777rrrr7777jjrr77jj77rr77jj77rr77rr77rr77rrrrrrjj7777rr777777rrrr77rrrr777777rr44llrrrrrrrrrrrrrrrrrrrrrr
jjffffffrrrrrrrrjjjjrrjjjjrrrrjjjjrrrrjjrrjjrrjjrrjjrrjjrrjjrrjjrrrrrrrrjjjjrrjjjjjjrrrrjjrrrrjjjjjjrrrrrrrrrrrrrrrrrrrrrrrrrrrr
jjffffffrrrrrrrrjjjjrrjjjjrrrrjjjjrrrrjjrrjjrrjjrrjjrrjjrrjjrrjjrrrrrrrrjjjjrrjjjjjjrrrrjjrrrrjjjjjjrrrrrrrrrrrrrrrrrrrrrrrrrrrr
77ffffffrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr
77ffffffrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr

__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044040100404000000000000000000000040400000000000000000000000004040404040000000000000000000000040404040404000000000000000000000
0404040404041010101010100000000004040404040410101010101000000000010102020404101010100202040400000101010101011010101001010404000004000000040101000004000000000000000001010101010101040000000000000000010101010101010100000000000000000000000000010101000000000000
__map__
a0a1a0a1a0a1a0a1a0a1a0a1a0a1a0414141d9c94141414141414141414141414141414141414145464141414141414141414141454141a1a0a1a0a1a0a1a0a1a0a1a0414141414141414141414141414141414141414141414141b8444444444444444444444444000000000000000000000000000000000000000000000000
b0b1b0b5b4b5b4b1b0a0a1a0a1b1b0b58000000000814141414680000000000000000000009246414193000000000000814145464145b4b1b0b1b0b1b0b1b0b1b0b1b0b546414645414193006275638141414546b4b54141414141b8444444444444444444444444000000000000000000000000000000000000000000000000
a0a1b541414141b4b1b0b1b0b1b0b5800000000000000081418000000200000000000000000000000000868a87b2b30000000000008141a1a0a1a0a1d5d6a0a1a0a1a04141454141800000007464640041414145414546b4b54141b8444444444444444444444444000000000000000000000000000000000000000000000000
b4b5419495414141b4b1b0a0a1b54102000000007f00000041000000000000000000b2b300000000008688448b000000000000000000b4b1b0b1b0b5e7e8b4b1b0b1b0b5414141800000000072646400b4b541414141414641848554555444444444444444444444000000000000000000000000000000000000000000000000
a8a741a4a541414141b4a0b0b14141000000000000005f0041006263006e00000000000000000000009a4499970000000000005e000041b0a0a1a041f7f841b4b5b4b541414193000000006a007273914180000081414141b4b541b8444444444444444444444444000000000000000000000000000000000000000000000000
44a9414141a6a8a8a741b4b1a1b5930000000000000000004100746400000000000000000000000000969b9700000000000000000000b4b5b4b1b0b184858585858585844180000000000000000082419300000000924141454141b8444444444444444444444444000000000000000000000000000000000000000000000000
4489a8a8a888444489a8a7b4b580000000000000000000004190726463000000000000000000000000000000000000000000007e0000414141a1a0a1a0a1a0a1a0a1b54141000000000000008c82418000000000000081414141a688444444444444444444444444000000000000000000000000000000000000000000000000
4444444444444444444489a8a8870000000000000000008241419072738c8c8c8c0000000000000000000000000000a1b30000008c914141b4b1b0b1b0b1b0b1b0b541414100000000000082414180000000007b0000009241a68844444444444444444444444444000000000000000000000000000000000000000000000000
444444444444444444444444448b00000000000000009141414541414141414141908c8c8c8c8c8c8c8c8c8c8c8cb2b38c8c8c914141414141b4a0a1a0a1b5b4b5414641800000000000004141410000005b000000000086a8884444444444504444444444444444000000000000000000000000000000000000000000000000
44444444444444444444444444898700000000000091414541418081808141414541414141414141414141414141414141414141800081414141b4b5b4b5414141414541000000006275634145410000000000000000868844444444444444504444444444444444000000000000000000000000000000000000000000000000
4444444444444444444444444444898a8a8a8a8782414641418000000000008141464141414141414141414141414141418004000000009241414141414141414146419300000000746464414641900000000000868a88444444444444999b509b98444444444444000000000000000000000000000000000000000000000000
44444444444450444444444444444444444444a941464546410000670000020041418058000000008141414141b4b5c94100000000000000814146454141b4b541c941000000006260646441414541900400868a884444444444999b9b9700ad0096b9b9b9b9b9b9000000000000000000000000000000000000000000000000
4444444499b950b9b99844444444444444444489a74146418000000000000000414100780000000000a1a0a1b5c9d941410000006d006263009241414641414141d9410000000074646473414141a6a88a8a88444444444444999700000000bd000081414141a1b1000000000000000000000000000000000000000000000000
444499b9b741acd941b69b984444444444444444a941418040000040000000004141000000000000b2b1b0b141d94141410000000000746400000081414141414541b4b3000000726473914141a6884444444444444444449997000200000000b2b3004145b4b1a1000000000000000000000000000000000000000000000000
b9b9b746d5d6bc46419300969844444444444444a94180000000000000000000414100000000000000b2b3b2b392414141900000000072730000000081414141464180000000000000824141e9b8444444444444444444448b00000000000000000000814146b4b1000000000000000000000000000000000000000000000000
41d2d3d4e7e8414541000000969b984444444444a993000000000000000000914141000000000000000000000000814141418300000000000000b2b3008141454141000000000000004146848554545554444444444444448b0000000000000000000000414141a1000000000000000000000000000000000000000000000000
41e7e8f8f9f94641930000000000b6984444449997000000000000bd82b4b5414141900091b4a041830000000000008141414190000000000000000000004141414100000000000091414141d9b8444444444444444444448b00000000000000000000004141b4b1000000000000000000000000000000000000000000000000
41f9f8414641418000000000000081b6b9b9b9970000000000868a50a7414141414141414141b0b1410000006800626341414141830000000000000000008141414100007a00000041b4b541c9b698444444444444444444898700000000000000000000814141a1000000000000000000000000000000000000000000000000
41848585844641006275630000000046b4b58000000000008688445089a8a8a8a8a8a74141b4b1b0b500000000536064414146414190000000000000000000814141900000005a00414141414141b6b9b99844444444444499b7000000000000000000000041b4b1000000000000000000000000000000000000000000000000
b0b1b0b141418000746473000000824141b4b30000000082b8444450444444444444a9414146b4b5459000006260647341464145414183000000000000000000414141908c8c8c914145414141b4b54141b6b9b998444499b741b4b541838c8c00006b00004141a1000000000000000000000000000000000000000000000000
a0a1a0a1a0a1b3007273000000004141464100000000b2b5b844445044444444444489a7414145464141908c72647391414145464141419000000000005d0000414541414141414141464141414141414141b4b5b84444a94193000092414141830000000046b4b1000000000000000000000000000000000000000000000000
b0b1b0b1b0b1000000000000000092454141005777000051515151504444444444444489a741414146464141414141414141414141454141830000007d00009141414645414141414541b4b54141414141414145b844448b000000000000814541908c8c914141a1000000000000000000000000000000000000000000000000
a0a1a0a1a0a1b30000006f0000000041b4b5000000009145b84444444444444444444444a94141454145414141800000008141414141414141908c00000091414141414141414141414141414146b4b541418051515151515100000000000092414141414141a1b1000000000000000000000000000000000000000000000000
b0b1b0b1b0b59000000000006263004645d9908c8c914546b6984444444499b9b998444489a74141414141414100000000009241b4b5a0a1a0a141414141414146414180000000924193627575757563929300515154555454000000000000000000000081b4b1a1000000000000000000000000000000000000000000000000
a0a1a0a1b541418300000062606400414645c7c84141414645b698444444a9b4b5b844444489a8a741414141410059007900008141a0a1b1b0b1b0b18000008141419300000000000062606464646464000000009a44448b00000000000000000000000000c9b4b1000000000000000000000000000000000000000000000000
b0b1b0b14141454190000072647391d2d3d4d7d8d4c4c0d5d646b844444489a741b6984444444489a7414641410000000000000092b0b1b0a0a1a0a14000000241800000000000000074646464646473000000009a44448987000000627563000000005c00d941a1000000000000000000000000000000000000000000000000
a0a1a0a1a041464145414141414146c5e3e4e4e4e5f5f6e2c645b844444444a9b4b5b8444444444489a7414541000000000000000092b4b5b4b5b4b5000069004100006c000000000072646464647300000000009a4444448b00006260646400007c000000c9b4b1000000000000000000000000000000000000000000000000
b0b1b0b1b0b1414141414141464541e2c6f4d1c2c2c3d0c5e3a6884444444489a8a888444444444444a9414641000000000000006263004040404040400000004100000000000200000072647300000000000082b6b9b9988bb2b3726464646300000000914141a1000000000000000000000000000000000000000000000000
a0a1a0a1a0a1a0a1a0a1a041414141c5e3e0f1f0f0f2e1e2c6b844444444444444444444444444444489a7414190000000000000726463000000000000000091410000000000000000000000000000000000004141a1b5b8a9414141907264738c8c8c914141a1b1000000000000000000000000000000000000000000000000
b0b1b0b1b0b1b0b1b0b1b0b1b0b1b0e2e3e0f0f0f0f3e1e2e38844444444444444444444444444444444a9414141900000000000007273000000000000000041b0b30000000000000000000000000000008c9141a1b141b889a7b4b1414141414145464141b0b1a1000000000000000000000000000000000000000000000000
a0a1a0a1a0a1a0a1a0a1a0a1a0a1a0c5c6c1f010f0f0f0c5e34444444444444444444444444444444499b7b0b1b0b141414141414141414141414141414141b0b183b2b300008c8c8c8c8c8c8c8c8c8c824141b0b1a1b5b698a941b0b1b0b14145414141b0b1a1a0000000000000000000000000000000000000000000000000
b0b1b0b1b0b1b0b1b0b1b0b1b0b1b0e2e3c1f0f0f0f0f0e2e344444444444444444444444444444444a9b4b1b0b1b0b1b0b1b0b1b0b1b0b1b0b1b0b1b0b1b0b1b0b14141b0b1414141454641414141414141a1a0a1a04141b8a9b4b1b0b1b0b141b4a0a1a0a1a0a1000000000000000000000000000000000000000000000000
__sfx__
011000010c75000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
0906000118020000000000000000306053b0001f6050000018303000000000000000306050000024605246052b6050000030605000001630322000220003200030605000002460503000010001c0001c00033000
1106000111020000000000000000306053b0001f6050000018303000000000000000306050000024605246052b6050000030605000001630322000220003200030605000002460503000010001c0001c00033000
01080000186150c7000b0000d0000000000000000000000018605350003f0003f0000c703340003f0003600035000360003600000000186050000000000000000000000000000000000000000000000000000000
010a00001872400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004
01080000246550c7000b0000d0000000000000000000000018605350003f0003f0000c703340003f0003600035000360003600000000186050000000000000000000000000000000000000000000000000000000
010100050014000100011400010000100011000010000100011000010000100011000010000100011000010000100011000010000100011000010000100011000010000100011000010000100011000010000100
010c00003c31500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
013218001d7151471524a25117151d71524a150f7151671525a250f7151e71525a25117151471524a25117151d71524a15257151671522a250f715167151b9250fb05247050070020705127052e7050f00500000
013218000d8400d811207151482520915207150b8400b81122a251282522a25227150d8400d811207151482520a252071508840088111e9250f8251e9250883508b0020d0500b0000b0000b0000b0000b0000000
013218001d7151471524a25117151d71524a15137151671526a25137151f71526a250f7151671526a25137151f71526a1528a25187152492515715219151ca250000000000000000000000000000000000000000
013218000a8400a811207151482520a25207150f8400f81122a251682522925227150c8400c811227151682522a2522715118401181121715188251d7151183508b0020d0500b0000b0000b0000b0000b0000000
01321800128401281122715197150d84519715128401281125a15197150d82519715148401481125a25148252292514715088400881125a2525815207151483508b0020d0500b0000b0000b0000b0000b0000000
0132000029a2519715259251671522915169152ca251971529a251671522925167152ca251971529a251671525a1520a152ca251971529a25147151e925147150000000000000000000000000000000000000000
05240000158451992518b15158451084519a2518b15108451584520a2518b1510845199251584520a2510855138551792518b15138550e85517a2518b150e855138551ea2518b150e855138551ea25108551ea25
0124000020c2625b0020c2625500255152cc26255001e51520c2625c0020c26255152500020c26255152a5151ec2623c001ec26235042151526c262a500235151ec26215152351521c262f5151ec262f5152a515
0124000020c2625b0020c26255002050025c26205002550020c0625c2620c0025c262050025c2620b15255001ec2623c001ec2623c001ec0023c261ec0023c001ec2623c001ec0023c261ec0023c261eb1523c26
052400000b8451b9251ab150b845128451ba251ab151284510845209251ab150b84520a251784522a251284515845199251ab15158451084519a251ab15128451084521a251ab151084521a25209251282514835
0124000022c2627b0022c2627500275152ec26275002051520c2627c0020c26275152700020c26275152c51520c2625c0020c26255042351528c262c5002551520c26235152551523c263151520c26315152c515
0124000022c2627b0022c2627500275152ec26275152c51522c2627c0022c26275152700022c26275152551520c2625c0020c26255152351528c262c5152551520c26235152551523c263151520c26315152c515
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5d0200000c84500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002000003376006752e3770067403476263731f26700662083671d26100667006521025305450213570064403346084431f247006332833300633033332d42300623006230c3230062320313006131321403417
000200000067722277004061f37300671002051566617463003070f25300457082060165100343106071724300444093051e43106233003060063716231006030f3250042307205004231e615083030021300613
15030000206531333325403216331b20319333156030f4030d6230a32307223056030442302303006030022300303006230040300613003030021300603003030041300613003030021300603003030041300613
1701000024f701ff411cf211af111764339633216230861321603106131f60312613206102b6002c6101e60016600166001560015600156001560015600156001560015600156001560015600156001560016600
010c00001863300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a3020000316632f633003532b6330034327623003330032321623003131c6231a61300303003031460300303116030d603003030a603003030760300303003030260300303016030060300303003031460300303
050b000018e6018e6014e6112e510fe510de410be4109e3107e3105e2503e2501e1500e1500e0000e0000e0000e0000e0000e0000e0000e0000e0000e0000e0000e0000e0000e0000e0000e0000e0000e0000e00
0104010218e6018e6018e0018e0018e0118e0018e0118e0018e0118e0018e0118e0000e0000e0000e0000e0000e0000e0000e0000e0000e0000e0000e0000e0000e0000e0000e0000e0000e0000e0000e0000e00
01040a0c18e1418e1018e2118e2018e3118e3018e4118e4018e5118e5018e6118e6000e0000e0000e0000e0000e0000e0000e0000e0000e0000e0000e0000e0000e0000e0000e0000e0000e0000e0000e0000e00
0b03000000645240052400528005280052b0052b0052f0052ba342ba212ba112ba15309343092130911309152b0052f0052f00532005320053600536005390053900500000000000000000000000000000000000
330a00002464500600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
7309000030b740052500b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b00
810300003c34500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09030000056100b62007630036300c62001610096100160001600036100762002610006000060000c0000c0000c0000c0000c0000c0000c0000c0000c0000c000c9000fc0000c000c9000fc0000c0000c0000000
c30700003cb7430b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b00
9302000024d740cd6624d0018d0000d0400d0400d0400d0400d0400d0400d0400d0400d0400d0400d0400d0400d0400d0400d0400d0400d0400d0400d0400d0400d0400d0400d0400d0400d0400d0400d0400d04
3d0200000e15400025001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
030d000030d4400b0500000000000c10300b0500b0500b0500b0500b0500b0500b0500b0500b0500b0500b0500b0500b0500b0500b0500b0500b0500b0500b0500b0500b0500b0500b0500b0500b0500b0500b05
5d0200000784500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
c504000024945289452b9452f94532945369453994524925289252b9252f92532925369253992524915289152b9152f91532915369153991500a0500a0500a0500a0500a0500a0500a0500a0500a0500a0500005
9502000030a6535a4500a0500a0500a0500a0500a0500a0500a0500a0500a0500a0500a0500a0500a0500a0500a0500a0500a0500a0500a0500a0500a0500a0500a0500a0500a0500a0500a0500a0500a0500005
__music__
01 09084344
00 09084344
00 0b0a4344
00 0b0a4344
02 0c0d4344
01 0e104344
00 0e104344
00 0e0f4344
00 0e0f4344
00 11126144
02 11134344

