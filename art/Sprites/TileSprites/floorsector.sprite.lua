-- Generated by Pumpkin

local data = {}

local path = ...
if type(path) ~= "string" then
	path = "."
end
data.image = love.graphics.newImage(path.."floorsector.sprite.png")
data.image:setFilter("nearest", "nearest")
data.animations = {
	floorsector={
		[0]={u=0, v=0, w=32, h=32, offsetX=0, offsetY=0, duration=0.0333333},
		scale=1
	},
}
data.quad = love.graphics.newQuad(0, 0, 1, 1, data.image:getWidth(), data.image:getHeight())

return data
