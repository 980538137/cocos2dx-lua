--
-- Author: XiaoMing.Zhang
-- Date: 2014-02-13 15:07:38
--

--[[
	socket tcp 接到服务器消息后，会先在这里处理协议
	函数名为 mod_act
]]

local SOCKET_ACTION = {}

--[[
	登录成功
]]
function SOCKET_ACTION.log_in(data)
	CCLuaLog("action log_in call")
	return true
end


function SOCKET_ACTION:user_create(data)
	if data_error_code == 0 then
		
	else
		CCLuaLog("create user failed")
	end
	return true
end

function SOCKET_ACTION.user_get_info(data)
	return true
end

-- 调整阵形
function SOCKET_ACTION.formation_adjust( data )
	if data.err_code == 0 then
		DATA_FORMATIONS:adjustFormation(data.formation)
	else
		CCLuaLog("formation adjust failue")
	end
end

-- 设置默认阵形
function SOCKET_ACTION.formation_default( data )
	if data.err_code == 0 then
		DATA_FORMATIONS:setDefaultFormation(data.formation_id)
	else
		CCLuaLog("set default formation failue")
	end
end

-- 出售
function SOCKET_ACTION.shop_sell( data )
	if data.err_code == 0 then
		-- 更新 Global 变量
		COMMON_ACTION.saveCommonData(data)
	else
		CCLuaLog("sell out failue")
	end
end

-- 购买
function SOCKET_ACTION.shop_buy( data )
	-- body
	if data.err_code == 0 then
		-- 购买详情未定
		COMMON_ACTION.saveCommonData(data)
	else
		CCLuaLog("get all mails failue")
	end
end

-- 收取所有邮件
function SOCKET_ACTION.mail_get_all( data )
	if data.err_code == 0 then
		DATA_MAILS:setData(data._G_mails)
	else
		CCLuaLog("get all mails failue")
	end
end

-- 邮件领奖
function SOCKET_ACTION.mail_get_award( data )
	if data.err_code == 0 then
		-- 更新Global 变量
		COMMON_ACTION.saveCommonData(data)
		-- 领取奖品后删除邮件
		DATA_MAILS:removeMail(data.mail_sid)

		-- 取出各个奖品，用于显示或者...
		local awards = data.awards
		for k,v in pairs(awards) do
			--todo
		end
	else
		CCLuaLog("get awrad failue")
	end
end

--获取副本进度
function SOCKET_ACTION.fb_get_schedule(data)
	CCLuaLog("action fb_get_schedule call")
	return true
end

--请求副本战斗
function SOCKET_ACTION.fb_fight_begin(data)
	if data.error_code == 0 then
		
	else
		CCLuaLog("")
	end
	return true
end

--副本战斗结算
function SOCKET_ACTION.fb_fight_end(data)
	if data.error_code == 1 then
		
	else
		CCLuaLog("")
	end
	return true
end

--获取副本战友
function SOCKET_ACTION.fb_get_players(data)
	if data.error_code == 0 then
		
	else
		CCLuaLog("")
	end
	return true
end

function SOCKET_ACTION.fb_fight_save(data)
	return true
end

function SOCKET_ACTION.fb_fight_get(data)
	return true
end

--添加好友
function SOCKET_ACTION.friend_add(data)
	if data.error_code == 0 then
		DATA_FRIENDS:addFriend(data.friend)
	else
		CCLuaLog("add friend failed")
	end
	return true
end

--删除好友
function SOCKET_ACTION.friend_del(data)
	if data.error_code == 0 then
		DATA_FRIENDS:deleteFriend(data.friend_uid)
	else
		CCLuaLog("delete friend failed")
	end
	return true
end

--获取所有好友
function SOCKET_ACTION.friend_get_all(data)
	if data.error_code == 0 then
		DATA_FRIENDS:setData(data.friends)
	else
		CCLuaLog("")
	end
	return true
end

--查询好友信息
function SOCKET_ACTION.friend_get_info(data)
	if data.error_code == 0 then
		
	else
		CCLuaLog("")
	end
	return true
end

--更换装备
function SOCKET_ACTION.knight_change_equip(data)
	if data.error_code == 0 then
		--更新装备数据表
		local srcEquip = DATA_EQUIPS:getEquip(data.src_sid)
		srcEquip.knight_sid = 0
		local dstEquip = DATA_EQUIPS:getEquip(data.dst_sid)
		dstEquip.knight_sid = data.knight_sid
		--更新侠客数据表
		local knight = DATA_KNIGHTS:getKnight(data.knight_sid)
		if data.type == 1 then--衣服
			knight.cloth = data.dst_sid
		elseif data.type == 2 then --武器
			knight.weapon = data.dst_sid
		elseif data.type == 3 then --饰品
			knight.trinket = data.dst_sid
		end
	else
		CCLuaLog("change equip failed")
	end
	return true
end

--更换心法
function SOCKET_ACTION.knight_change_mental(data)
	if data.error_code == 0 then
		local srcMental = DATA_MENTALS:getMental(data.src_sid)
		srcMental.knight_sid = 0
		local dstMental = DATA_MENTALS:getMental(data.dst_sid)
		dstMental.knight_sid = data.dst_sid

		local knight = DATA_KNIGHTS:getKnight(data.knight_sid)
		if data.position == 1 then--心法1
			knight.mental1 = data.dst_sid
		elseif data.position == 2 then--心法2
			knight.mental2 = data.dst_sid
		elseif data.position ==3 then--心法3
			knight.mental3 = data.dst_sid
		end
	else
		CCLuaLog("change mental failed")
	end
	return true
end

--装备合成
function SOCKET_ACTION.equip_synthesis(data)
	if data.error_code == 0 then
		DATA_EQUIPS:setEquip(data.sid, data.equip)
	else
		CCLuaLog("equip synthesis failed")
	end
	return true
end

--装备升级
function SOCKET_ACTION.equip_levelup(data)
	if data.error_code == 0 then
		DATA_EQUIPS:setEquip(data.sid,data.equip)	
	else
		CCLuaLog("equip_levelup failed")
	end
	return true
end

--装备进阶
function SOCKET_ACTION.equip_advance(data)
	if data.error_code == 0 then
		DATA_EQUIPS:setEquip(data.sid, data.equip)
	else
		CCLuaLog("equip advance failed")
	end
	return true
end

--心法升级
function SOCKET_ACTION.mental_levelup(data)
	if data.error_code == 0 then
		
	else
		CCLuaLog("")
	end
	return true
end

--心法进阶
function SOCKET_ACTION.mental_advance(data)
	if data.error_code == 0 then
		
	else
		CCLuaLog("")
	end
	return true
end


return SOCKET_ACTION