--
-- Created by IntelliJ IDEA.
-- User: wangcheng
-- Date: 15/8/28
-- Time: 下午1:39
-- To change this template use File | Settings | File Templates.
--

local LoginScene = class("LoginScene",cc.load("mvc").ViewBase)

function LoginScene:onCreate()
    local node = cc.CSLoader:createNode("LoginScene.csb")
    self:addChild(node)

    local function touchEvent(sender,eventType)
        if eventType == ccui.TouchEventType.began then
            printf("Touch Down")
            self:getApp():enterScene("MainScene")
        elseif eventType == ccui.TouchEventType.moved then
            printf("Touch Move")
        elseif eventType == ccui.TouchEventType.ended then
            printf("Touch Up")
        elseif eventType == ccui.TouchEventType.canceled then
            printf("Touch Cancelled")
        end
    end

    local button = node:getChildByName("LoginButton")
    button:addTouchEventListener(touchEvent)
end

return LoginScene
