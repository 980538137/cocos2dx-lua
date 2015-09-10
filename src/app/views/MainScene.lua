
local MainScene = class("MainScene", cc.load("mvc").ViewBase)

--MainScene.RESOURCE_FILENAME = "MainScene.csb"
require "protobuf.init"
require "app.proto.PlayerInfo_pb"
require "app.proto.mobileGame_pb"

function MainScene:onCreate()
    printf("resource node = %s", tostring(self:getResourceNode()))

    local node = cc.CSLoader:createNode("MainScene.csb")
    self:addChild(node)

    local function touchEvent(sender,eventType)
        if eventType == ccui.TouchEventType.began then
            --printf("Touch Down")
--            self:getApp():enterScene("LoginScene")
            local req = mobileGame_pb.ReqGameAccountLogin()
            req.account = "sgxsgx"
            req.accountType = 0
            req.password = "123456"
            req.terminal = 2
            req.deviceNumber = ""
            req.gameId = 25011
            req.comeFrom = "thran"
            req.token = ""
            req.language = "en"
            req.source = 1
            local reqData = req:SerializeToString()
            printf("SendData:%s",reqData)
            SOCKET:send(reqData)
        elseif eventType == ccui.TouchEventType.moved then
            --printf("Touch Move")
        elseif eventType == ccui.TouchEventType.ended then
            --printf("Touch Up")
        elseif eventType == ccui.TouchEventType.canceled then
            --printf("Touch Cancelled")
        end
    end

--    local button = ccui.Helper:seekWidgetByName(node, "EnterButton")
    local button = node:getChildByName("EnterButton")
    button:addTouchEventListener(touchEvent)

--  lua-protobuf test

    local msg = PlayerInfo_pb.PlayerInfo()
    msg.id = 100
    msg.name = "helloworld"
    local pb_data = msg:SerializeToString()
    printf("create:%d,%s,%s",msg.id,msg.name,pb_data)

    local msg2 = PlayerInfo_pb.PlayerInfo()
    msg2:ParseFromString(pb_data)
    printf("parser:%d,%s,%s",msg2.id,msg2.name,pb_data)

    local req = mobileGame_pb.ReqGameAccountLogin()
    req.account = "sgxsgx"
    req.accountType = 0
    req.password = "123456"
    req.terminal = 2
    req.deviceNumber = ""
    req.gameId = 25011
    req.comeFrom = "thran"
    req.token = ""
    req.language = "en"
    req.source = 1
    local reqData = req:SerializeToString()
    printf("BodySize:%d",#reqData)
    printf("Account:%s  password:%s  ReqGameAccountLogin:%s",req.account,req.password,reqData)
    --拼包
    local request_head =
    {
        length = 12 + #reqData,
        messageId = 0x00000265,
        sequenceId = 0
    }
    printf("HeadSize:%d",table.getn(request_head))

    local request_data = {
        head = request_head,
        body = reqData
    }

    SOCKET = require("app.network.socket").new("172.28.14.87",22446)
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
