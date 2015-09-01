
local MainScene = class("MainScene", cc.load("mvc").ViewBase)

--MainScene.RESOURCE_FILENAME = "MainScene.csb"

function MainScene:onCreate()
--    printf("resource node = %s", tostring(self:getResourceNode()))

    local node = cc.CSLoader:createNode("MainScene.csb")
    self:addChild(node)

    local function touchEvent(sender,eventType)
        if eventType == ccui.TouchEventType.began then
            printf("Touch Down")
            self:getApp():enterScene("LoginScene")
        elseif eventType == ccui.TouchEventType.moved then
            printf("Touch Move")
        elseif eventType == ccui.TouchEventType.ended then
            printf("Touch Up")
        elseif eventType == ccui.TouchEventType.canceled then
            printf("Touch Cancelled")
        end
    end

--    local button = ccui.Helper:seekWidgetByName(node, "EnterButton")
    local button = node:getChildByName("EnterButton")
    button:addTouchEventListener(touchEvent)

    SOCKET = require("app.network.socket").new("172.28.14.170",8080)
    SOCKET:connect()
----   Schedule
--    local function tick()
--        printf("OnTick")
--    end
--    cc.Director:getInstance():getScheduler():scheduleScriptFunc(tick , 1, false)
--    cc.Director:getInstance():getScheduler():schedule(tick,)

--    self:scheduleUpdateWithPriorityLua(function(dt)
--        printf("scheduleUpdateWithPriorityLua")
--    end, 0)
--
--    for i = 10,1,-1 do printf(i) end
--
--    local days = {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" }
--    for k,v in pairs(days) do printf("Key:"..k.." Value:"..v) end

----    弱应用table
--    a = {}
--    b = {__mode = "k" }
--    setmetatable(a,b)
--    key = {}
--    a[key] = 1
--    key = {}
--    a[key] = 2
--    collectgarbage()
--    for k, v in pairs(a) do
--        printf("Key:" .."  Value:"..v)
-- end


--    __index
--    father = { house = 1 }
----    father.__index = father
--    son = { car = 1 }
----    setmetatable(son,father)
--    setmetatableindex(son,father)
--    printf(son.house)
--    for n in pairs(_G) do
--        printf(n)
--    end
end

return MainScene