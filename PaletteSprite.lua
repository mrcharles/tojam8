local Base = require 'base'
local Tools = require 'fabricate.tools'
local Vector = require "hump.vector"
--require "spritemanager"
local PaletteEffect = require "PaletteEffect"

local PaletteSprite = Tools:Class(Entity)

PaletteSprite.position = Vector(0, 0)
PaletteSprite.baseLayer = {}
PaletteSprite.effect = {}

function PaletteSprite:init(strData, strAnimation)
	print(type(strAnimation))
	Base.init(self)
	self.baseLayer = SpriteManager.createSprite()
	self.baseLayer.strData = strData
	self.baseLayer.animation = strAnimation
	self.baseLayer:setData(self.baseLayer.strData, self.baseLayer.animation, true)
	print("PaletteSprite:init()")
	print(strAnimation)
	--self.baseLayer.sprData.image:setFilter("nearest", "nearest")
	self.baseLayer.flipH = false

	self.effect = PaletteEffect:new()
	self.effect:init(strData)
	self.effect:setPaletteIndex(5)
	return self
end

function PaletteSprite:setPosition(pos)
	self.position = pos
end

function PaletteSprite:setAnimation(animation)
	self.baseLayer:setAnimation(animation, true)
end

function PaletteSprite:update(dt)
	--LayeredSprite.effect:update(dt)

	self.baseLayer.x = self.position.x
	self.baseLayer.y = self.position.y

	self.baseLayer:update(dt)
end

function PaletteSprite:draw()
	self.effect:setEffect()
	self.baseLayer:draw()
	self.effect:clearEffect()
end

return PaletteSprite
