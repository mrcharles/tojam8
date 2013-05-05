-- Generated by Pumpkin

local data = {}

local path = ...
if type(path) ~= "string" then
	path = "."
end
data.image = love.graphics.newImage(path.."player.sprite.png")
data.image:setFilter("nearest", "nearest")
data.animations = {
	idle_right={
		[0]={u=0, v=34, w=12, h=28, offsetX=6, offsetY=28, duration=0.0333333},
		scale=1
	},
	idle_Left={
		[0]={u=0, v=34, w=12, h=28, offsetX=6, offsetY=28, duration=0.0333333},
		scale=1
	},
	up_left={
		[0]={u=34, v=0, w=12, h=30, offsetX=6, offsetY=30, duration=0.0333333},
		[1]={u=0, v=0, w=32, h=32, offsetX=16, offsetY=32, duration=0.0333333},
		scale=1
	},
	up_Right={
		[0]={u=34, v=0, w=12, h=30, offsetX=6, offsetY=30, duration=0.0333333},
		[1]={u=0, v=0, w=32, h=32, offsetX=16, offsetY=32, duration=0.0333333},
		scale=1
	},
}
data.quad = love.graphics.newQuad(0, 0, 1, 1, data.image:getWidth(), data.image:getHeight())

return data
