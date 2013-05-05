local Base = require "base"
local Tools = require 'fabricate.tools'

--require "hump.vector"


local PaletteEffect = Tools:Class(Base)

--PaletteEffect = Base:new()
PaletteEffect.index = 0

-- local path = ...
-- if type(path) ~= "string" then
-- 	path = "."
-- end

function PaletteEffect:init(strData)
	Base.init(self)

	local src = [[
		extern number index;
		extern Image sampler;

		vec4 effect(vec4 color, Image tex, vec2 tc, vec2 pc)
		{
			vec4 sample = Texel(tex, tc);

			if(Texel(sampler, vec2(0, 0)) == sample)
			{
				color = Texel(sampler, vec2(index/16.0f, 0));
			}
			else if(Texel(sampler, vec2(0, 1.0f/8.0f)) == sample)
			{
				color = Texel(sampler, vec2(index/16.0f, 1.0f/8.0f));
			}
			else if(Texel(sampler, vec2(0, 2.0f/8.0f)) == sample)
			{
				color = Texel(sampler, vec2(index/16.0f, 2.0f/8.0f));
			}
			else if(Texel(sampler, vec2(0, 3.0f/8.0f)) == sample)
			{
				color = Texel(sampler, vec2(index/16.0f, 3.0f/8.0f));
			}
			else if(Texel(sampler, vec2(0, 4.0f/8.0f)) == sample)
			{
				color = Texel(sampler, vec2(index/16.0f, 4.0f/8.0f));
			}
			else if(Texel(sampler, vec2(0, 5.0f/8.0f)) == sample)
			{
				color = Texel(sampler, vec2(index/16.0f, 5.0f/8.0f));
			}
			else if(Texel(sampler, vec2(0, 6.0f/8.0f)) == sample)
			{
				color = Texel(sampler, vec2(index/16.0f, 6.0f/8.0f));
			}
			else if(Texel(sampler, vec2(0, 7.0f/8.0f)) == sample)
			{
				color = Texel(sampler, vec2(index/16.0f, 7.0f/8.0f));
			}
			else if(Texel(sampler, vec2(0, 8.0f/8.0f)) == sample)
			{
				color = Texel(sampler, vec2(index/16.0f, 8.0f/8.0f));
			}
			else
			{
				color = sample;
			}

			return color;
		}
	]]

	-- print("what is strData? ")
	-- PaletteEffect.strData = strData
	-- print(strData)
	-- print(type(strData))
	-- self.strData = strData
	-- self.strData = self.strData .. "boo"

	PaletteEffect.image = love.graphics.newImage("assets/sprites/player.sprite_palette.png")
	PaletteEffect.image:setFilter("nearest", "nearest")

	PaletteEffect.effect = love.graphics.newPixelEffect(src)
	PaletteEffect.effect:send('sampler', PaletteEffect.image)
	PaletteEffect.effect:send('index', PaletteEffect.index)

	return self
end

function PaletteEffect:setEffect()
	love.graphics.setPixelEffect(PaletteEffect.effect)
end

function PaletteEffect:clearEffect()
	love.graphics.setPixelEffect()
end

t = 0
function PaletteEffect:update(dt)
	t = t + dt
	PaletteEffect.effect:send('index', PaletteEffect.index)
end

function PaletteEffect:setPaletteIndex(index)
	PaletteEffect.index = index
end

return PaletteEffect
