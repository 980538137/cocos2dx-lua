--
-- Author: XiaoMing.Zhang
-- Date: 2014-01-06 15:23:32
--

--[[

初始化场景

]]


collectgarbage("setpause"  ,  100)
collectgarbage("setstepmul"  ,  5000)

local update_layer = require "update.update_layer"

local M = {}

function M:create()
	local glview = CCDirector:sharedDirector():getOpenGLView()
	glview:setDesignResolutionSize(480, 800, kResolutionShowAll)
	local scene = CCScene:create()
	scene.name = "update"
	scene:addChild(update_layer:new():getLayer())	
	
	return scene
end

return M