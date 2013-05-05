require "Scripts/spritemanager"

screen = Screen()
label = ScreenLabel("Hello, Polycode!", 32)
screen:addChild(label)

Services.ResourceManager:addDirResource("Resources", true)

scene = Scene()
quad = ScenePrimitive(ScenePrimitive.TYPE_VPLANE, 5,5)
quad:setColor(1.0,1.0,1.0,1.0)
quad:setMaterialByName("GroundMaterial")
scene:addEntity(quad)

scene:getDefaultCamera():setOrthoMode(true, 1024, 640)
scene:getDefaultCamera():setPosition(0,0,10)
scene:getDefaultCamera():lookAt(Vector3(0,0,0), Vector3(0,1,0))


light = SceneLight(SceneLight.AREA_LIGHT, scene, 400)
light:setPosition(0,1,25)
--scene:addLight(light)


-- --print(quad:getLocalShaderOptions():getLocalParamByName("vertexColor"))
quad:getLocalShaderOptions():addParam("Color","custom_color","1.0 1.0 1.0 1.0")
--quad:getLocalShaderOptions():addParam("Number","customAlpha","1.0")
-- print(quad:getLocalShaderOptions():getNumLocalParams())
-- print(quad:getLocalShaderOptions():getLocalParamByName("custom_color"))
-- print(quad:getMaterial():getShaderBinding(0):getNumLocalParams())
-- --quad:setMaterial(quad:getMaterial())
-- quad:getMaterial():getShaderBinding(0):addParam("Color","custom_color","1.0 1.0 1.0 1.0")
-- print(quad:getMaterial():getShaderBinding(0):getNumLocalParams())
-- --quad:setMaterial(quad:getMaterial())
-- newMaterial = quad:getMaterial()
-- quad:clearMaterial()
-- quad:setMaterial(newMaterial)
-- print(quad:getLocalShaderOptions():getNumLocalParams())
quad:getLocalShaderOptions():getLocalParamByName("custom_color"):setColor(Color(1.0, 0.0, 1.0, 1.0))
-- --print(quad:getLocalShaderOptions():getLocalParamByName("vertexColor"))
--quad:getLocalShaderOptions():addParam("Number","customAlpha","1.0")


SM = SpriteManager()

local testSprite = SM:createSprite("cell.sprite", "heart")
--testSprite:setData("cell.sprite", "head", true)
--scene:addEntity(testSprite:getPrimitive())
local testEntity = Entity()
scene:addEntity(testEntity)
testEntity:setPosition(0,0,0)
testEntity:addChild(testSprite:getPrimitive())


local custom_color = Color(1.0, 0.0, 1.0, 1.0)
local incR = false
local incG = true

local sumTime = 0

function Update(elapsed)

        if incR then
        	custom_color.r = custom_color.r + elapsed
        else
        	custom_color.r = custom_color.r - elapsed
        end


        if incG then
        	custom_color.g = custom_color.g + elapsed
        else
        	custom_color.g = custom_color.g - elapsed
        end


       	if custom_color.r < 0 then
       		incR = true
       	else
       		if custom_color.r > 1 then
       			incR = false
       		end
       	end

       	if custom_color.g < 0 then
       		incG = true
       	else
       		if custom_color.g > 1 then
       			incG  = false
       		end
       	end

       	quad:getLocalShaderOptions():getLocalParamByName("custom_color"):setColor(custom_color)

        --print("MAIN UPDATE")
        --print(testSprite.strData)
        testSprite:update(elapsed)
        --testEntity:setPosition(sumTime * 100, 0, 0)

        sumTime = sumTime + elapsed

        if sumTime > 5 then
          --testSprite:setAnimation(testSprite.sprData.animations[math.random(#testSprite.sprData.animations)])
          testSprite:setAnimation("gun")
          sumTime = 0
        end
end
