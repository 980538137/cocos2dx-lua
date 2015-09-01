--
-- Author: XiaoMing.Zhang
-- Date: 2014-02-14 10:55:16
--


--[[
	处理公共数据
]]

local COMMON_ACTION = {}

function COMMON_ACTION.saveCommonData( data )
	if type(data) ~= "table" then return false end
	if isset(data,"g_userinfo") then DATA_USER:setData(data["g_userinfo"]) end
	if isset(data, "g_fb") then DATA_FB_SCHEDULE:setData(data["g_fb"]) end
	if isset(data, "g_equips") then DATA_EQUIPS:setData(data["g_equips"]) end
	if isset(data, "g_knights") then DATA_KNIGHTS:setData(data["g_knights"]) end
	if isset(data, "g_mental") then DATA_MENTALS:setData(data["g_mental"]) end
	if isset(data, "g_formation") then DATA_FORMATIONS:setData(data["g_formation"]) end
	if isset(data, "g_context") then DATA_CONTEXT:setData(data["g_context"]) end
	if isset(data, "g_friends") then DATA_Friends:setData(data["g_friends"]) end
	return true
end

return COMMON_ACTION