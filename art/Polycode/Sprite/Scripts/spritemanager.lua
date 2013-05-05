module(..., package.seeall);

class "Sprite"

function Sprite:Sprite()
	self.x = 0
	self.y = 0
	
	self.scaleX = 1
	self.scaleY = 1
	
	self.filter = "nearest"
	
	self.animationSpeed = 1
	self.animCounter = 0
	self.currentFrame = 1
	
	self.flipH = false
	self.flipV = false
	
	self.rotation = 0
	
	if type(strAnimation) == "string" then
		self:setAnimation(strAnimation)
	end
end

function Sprite:setData(sprData, strData)
	self.sprData = sprData
	self.strData = strData
end

-- function Sprite:setData(strData, strAnimation, keepTime)
-- 	if strData == nil then
-- 		self.sprData = nil
-- 		self.strData = nil
-- 		return
-- 	end

-- 	self.sprData = getSpriteData(strData)
-- 	self.strData = strData

-- 	--hack fix for sprite animations
-- 	-- if self.strData and self.strData.animations then
-- 	-- 	for i,anim in ipairs(self.strData.animations) do
-- 	-- 		if anim[1] == nil then
-- 	-- 			anim[1] = anim[0]
-- 	-- 		end
-- 	-- 	end
-- 	-- end
	
-- 	if strAnimation ~= nil then
-- 		self:setAnimation(strAnimation, keepTime)
-- 	end
-- end

function Sprite:setAnimation(strAnimation, keepTime)
	--print("Sprite:setAnimation()")
	keepTime = keepTime or false
	
	self.animation = strAnimation
	--print(self.animation)
	
	local animation = self.sprData.animations[strAnimation]
	
	assert(animation ~= nil, "Sprite doesn't have animation: "..strAnimation)
	
	if not keepTime or self.currentFrame > #animation then
		self.currentFrame = 1
		self.animCounter = animation[self.currentFrame - 1].duration
	end

	self.flipH = animation.flipH
end

function Sprite:hasAnimation(strAnimation)
	--print("strAnimation: ", strAnimation)
	--print("self.sprData: ", self.sprData)
	--print("self.sprData.animations[strAnimation]: ", self.sprData.animations[strAnimation])
	return self.sprData and self.sprData.animations[strAnimation]
end

function Sprite:update(deltaTime)
	--print("sprite:update()")
	self.animCounter = self.animCounter - (deltaTime * self.animationSpeed)

	if self.animCounter < 0 and self.sprData then
		local animation = self.sprData.animations[self.animation]
		
		self.currentFrame = self.currentFrame + 1
		
		if self.currentFrame > #animation + 1 then
			self.currentFrame = 1
		end
		
		self.animCounter = animation[self.currentFrame - 1].duration
	end

	local data = self.sprData
	local animation = data.animations[self.animation]
	local frame = animation[self.currentFrame - 1]
	local primitive = data.primitive
	local animScale = animation.scale

	local offsetX = frame.offsetX
	local offsetY = frame.offsetY

	if self.flipH then
		offsetX = frame.w - offsetX
	end
	
	if self.flipV then
		offsetY = frame.h - offsetY
	end

	--print("frame width: "..frame.w.." height: "..frame.h)

	--print(primitive)
	primitive:setScaleX(frame.w)
	primitive:setScaleY(frame.h)
	--print(primitive:getLocalShaderOptions():getNumLocalParams()) -- 2048 x 1024
	local x = frame.u--2048.0 - frame.u
	local y = self.sprData.textureHeight - frame.v 
	local tempParam = Color((x/self.sprData.textureWidth), (y/self.sprData.textureHeight), 
		((x+frame.w)/self.sprData.textureWidth), ((y-frame.h)/self.sprData.textureHeight))
	primitive:getLocalShaderOptions():getLocalParamByName("custom_uv"):setColor(tempParam)
	primitive:setPosition((0.5 * frame.w) - offsetX, (0.5 * frame.h) - offsetY, 0)

	-- scaling the vertices in the shader doesn't work yet
	--local tempSize = Vector2(frame.w*100, frame.h*100)
	--primitive:getLocalShaderOptions():getLocalParamByName("custom_size"):setVector2(tempSize)
end

function Sprite:draw()
	local data = self.sprData
	if data == nil then return sprite end
	
	local animation = data.animations[sprite.animation]
	local frame = animation[self.currentFrame - 1]
	local q = data.quad
	local animScale = animation.scale
	
	-- q:setViewport(frame.u, frame.v, frame.w, frame.h)
	-- q:flip(self.flipH, self.flipV)
	
	-- love.graphics.setColorMode("replace")

	local offsetX = frame.offsetX
	local offsetY = frame.offsetY

	if self.flipH then
		offsetX = frame.w - offsetX
	end
	
	if self.flipV then
		offsetY = frame.h - offsety
	end

	-- love.graphics.drawq(data.image, q, self.x, self.y, self.rotation, 
	-- 	animScale * self.scaleX, animScale * self.scaleY, 
	-- 	offsetX, offsetY)
end

function Sprite:getPrimitive()
	--print("Sprite:getPrimitive()")
	--print(self.sprData.primitive)
	return self.sprData.primitive
end

class "SpriteManager"

function SpriteManager:SpriteManager()
	self.spriteData = {}
	--print(self.spriteData)
end

function SpriteManager:getSpriteData(strData)
	--print("SpriteManager:getSpriteData "..strData)
	if self.spriteData[strData] == nil then
		local data = Data()
		data:loadFromFile("Resources/sprites/"..strData..".lua")
		local dataString = data:getAsString(String.ENCODING_UTF8)
		local func = loadstring(dataString)
		self.spriteData[strData] = func()
		--print("animations? ")
		--print(self.spriteData[strData].animations.icon_link[0].u)
		--print(self.spriteData[strData].textureName)
		self.spriteData[strData].primitive = ScenePrimitive(ScenePrimitive.TYPE_VPLANE, 1,1)
		self.spriteData[strData].primitive:loadTexture("Resources/sprites/"..self.spriteData[strData].textureName)
		self.spriteData[strData].primitive:setMaterialByName("SpriteMaterial")
		self.spriteData[strData].primitive:getLocalShaderOptions():addParam("Color","custom_uv","0.0 1.0 0.0 1.0")
		self.spriteData[strData].primitive:getLocalShaderOptions():addParam("Vector2","custom_size","1.0 1.0")
		self.spriteData[strData].textureWidth = self.spriteData[strData].primitive:getTexture():getWidth()
		self.spriteData[strData].textureHeight = self.spriteData[strData].primitive:getTexture():getHeight()
		--print(self.spriteData[strData].primitive:getLocalShaderOptions():getNumLocalParams())
	end
	
	return self.spriteData[strData]
end

function SpriteManager:createSprite(strData, strAnimation)
	print(self.spriteData)
	local sprite = Sprite()
	
	if strData ~= nil then
		sprite.sprData = self:getSpriteData(strData)
		sprite.strData = strData

		sprite:setAnimation(strAnimation)
		--print("SpriteManager:createSprite()")
		--print(sprite.strData)

		-- --hack fix for sprite animations
		-- if sprite.strData and sprite.strData.animations then
		-- 	for i,anim in ipairs(sprite.strData.animations) do
		-- 		if anim[1] == nil then
		-- 			anim[1] = anim[0]
		-- 		end
		-- 	end
		-- end
	end
	
	return sprite
end
