--
-- Author: XiaoMing.Zhang
-- Date: 2014-02-13 12:56:23
--

local SOCKET = class("SOCKET")
local SocketTCP = require("app.network.SocketTCP")
local SOCKET_ACTION = require("app.network.socket_action")
local COMMON_ACTION = require("app.network.common_action")
local ByteArray = require("app.network.ByteArray")

function SOCKET:ctor( host, port )
	self.socket = nil
	self.host = host or ""
	self.port = port or 0
	self.callbacks_table = {}
	self.isConnected = false
	self.preData = nil
end

function SOCKET:connect( host, port)
	if not self.socket then
		printf("Began connect server host:" .. self.host .. " port:" .. self.port)
		self.socket = SocketTCP.new(host or self.host, port or self.port, true)
		self.socket.event:addEventListener(SocketTCP.EVENT_CONNECTED, handler(self, self.onConnected))
		self.socket.event:addEventListener(SocketTCP.EVENT_CLOSE, handler(self,self.onClose))
		self.socket.event:addEventListener(SocketTCP.EVENT_CLOSED, handler(self,self.onClosed))
		self.socket.event:addEventListener(SocketTCP.EVENT_CONNECT_FAILURE, handler(self,self.onConnectFailure))
		self.socket.event:addEventListener(SocketTCP.EVENT_DATA, handler(self,self.onData))
	end
	self.socket:connect()
end

function SOCKET:send(data)
--	-- 拼包
--	local request_data = {
--		length = 12 + #data,
--		messageId = 0x00000265,
--		sequenceId = 0,
--		body = data,
--	}
--	dump(request_data)
	local length = 12 + #data
	local messageId = 0x00000265
	local sequenceId = 0
	local ba = ByteArray.new(ByteArray.ENDIAN_BIG)
	ba:writeUInt(length)
	ba:writeUInt(messageId)
	ba:writeUInt(sequenceId)
	ba:writeStringBytes(data)

	printf("request:%s", ba:toString(10))

	local pack = ba:getPack()
	self.socket:send(pack)
--	-- 发送
--	local pack = ByteArray.new(ByteArray.ENDIAN_BIG):writeStringUInt(request_data):getPack()

--    -- 直接使用 lpack 库生成一个字节流
--    local __pack = string.pack("<bihP2", 0x59, 11, 1101, "", "中文")
--
--    -- 创建一个ByteArray
--    local __ba = ByteArray.new()
--
--    -- ByteArray 允许直接写入 lpack 生成的字节流
--    __ba:writeBuf(__pack)
--
--    -- 不要忘了，lua数组是1基的。而且函数名称比 position 短
--    __ba:setPos(1)
--
--    -- 这个用法和AS3相同了，只是有些函数名称被我改掉了
--    print("ba.len:", __ba:getLen())
--    print("ba.readByte:", __ba:readByte())
--    print("ba.readInt:", __ba:readInt())
--    print("ba.readShort:", __ba:readShort())
--    print("ba.readString:", __ba:readStringUShort())
--    print("ba.available:", __ba:getAvailable())
--    -- 自带的toString方法可以以10进制、16进制、8进制打印
--    print("ba.toString(16):", __ba:toString(16))
--
--    -- 创建一个新的ByteArray
--    local __ba2 = ByteArray.new()
--
--    -- 和AS3的用法相同，还支持链式调用
--    __ba2:writeByte(0x59)
--        :writeInt(11)
--        :writeShort(1101)
--    -- 写入空字符串
--    __ba2:writeStringUShort("")
--    -- 写入中文（UTF8）字符串
--    __ba2:writeStringUShort("中文")
--
--    -- 十进制输出
--    print("ba2.toString(10):", __ba2:toString(10))

	--self.socket:send(pack)
end

--[[
	mod 模块
	act 行为
	data 要发送的数据
	params {
		success_callback	function(data)  成功后回调
		error_callback		function(code,msg)  失败后回调
	}
]]
function SOCKET:call(mod, act, data, params)
	if isConnected == false then
		CCLuaLog("网络连接失败，不能发送! mod:" .. mod .. " act:" .. act)
		-- 需要弹掉线重连对话框
		return
	end

	if type(params) ~= "table" then params = {} end
	if type(params.success_callback) ~= "function" then params.success_callback = function() end end
	if type(params.error_callback) ~= "function" then params.error_callback = function()
			CCLuaLog("网络消息发送失败！mod:" .. mod .. " act:" .. act)
			-- 弹出错误对话框
		end
	end
	if type(data) ~= "table" then data = {} end

	local function_name = mod .. "_" .. act
	if type(SOCKET_ACTION[function_name]) ~= "function" then
		CCLuaLog("缺少回掉处理Action! mod:" .. mod .. " act:" .. act)
		return
	end

	-- 拼包
	local request_data = {
		mod = mod,
		act = act,
		data = data,
	}

	local json_data = json.encode(request_data)

	-- todo: 加密


	-- todo: 显示网络等待框


	-- 处理客户端主动请求服务器的消息回调
	self.callbacks_table[function_name] = function( response_table )
		self.callbacks_table[function_name] = nil
		-- 处理公共数据
		COMMON_ACTION.saveCommonData(response_table["result"])

		if response_table["result"]["code"] ~= 0 then
			local err_desc = check_error_code(response_table["result"]["code"])
			if err_desc then
				MMsg.flashShow(err_desc)
			else
				MMsg.flashShow("error code: " .. response_table["result"]["code"])
			end
			return
		end

		-- 处理消息
		local success = SOCKET_ACTION[function_name](response_table["result"])

		-- todo: 隐藏通信对话框

		-- 回调
		if success == true then
			params.success_callback(response_table["result"])
		end
	end


	-- 发送
	local pack = ByteArray.new(ByteArray.ENDIAN_BIG):writeStringUInt(json_data):getPack()
	self.socket:send(pack)
	CCLuaLog("socket send successed !")
end

-- 拆包
function SOCKET:splitData(data)
	if self.preData ~= nil then
		local temp_data = ByteArray.new()
		temp_data:setEndian(ByteArray.ENDIAN_BIG)
		temp_data:writeBytes(preData, 1, preData:getLen())
		temp_data:writeBytes(data, 1, data.getLen())
		self.preData = nil
		return self:splitData(temp_data)
	end
	local pack_len = data:getLen()
	if pack_len <= 4 then return end
	local realbody_len = pack_len - 4
	local needbody_len = data:readUInt()
	data:setPos(1)

	if realbody_len == 0 or needbody_len == 0 then return end

	if needbody_len > realbody_len then
		self.preData = data
		return
	elseif needbody_len == realbody_len then
		self:parseData(data:readStringUInt())
	else
		local temp_data = ByteArray:new()
		self:parseData(data:readStringUInt())
		temp_data:writeBytes(data, needbody_len + 5, pack_len - needbody_len - 4)
		temp_data:setEndian(ByteArray.ENDIAN_BIG)
		temp_data:setPos(1)
		self:splitData(temp_data)
	end
end

-- 解析并处理数据
function SOCKET:parseData(data)
	local response_table = json.decode(data)
	if response_table == nil or type(response_table) ~= "table" then
		CCLuaLog("socket parse data error! data: " .. data)
		return
	end
	if response_table["code"] ~= 0 then
		CCLuaLog("package parse error , error code:" .. response_table["code"])
		local err_desc = check_error_code(response_table["code"])
		if err_desc then
			MMsg.flashShow(err_desc)
		else
			MMsg.flashShow("error code: " .. response_table["code"])
		end
		return
	end
	local function_name = response_table.mod .. "_" .. response_table.act
	if self.callbacks_table[function_name] ~= nil then
		return self.callbacks_table[function_name](response_table)
	end
	-- 服务器推送数据
	-- 处理公共数据
	COMMON_ACTION.saveCommonData(response_table["result"])
	-- 处理逻辑数据
	SOCKET_ACTION[function_name](response_table["result"])
end

function SOCKET:onData(__event)
	local response = ByteArray.new():writeBuf(__event.data):setPos(1)
	printf("response:",__event.data)
	response:setEndian(ByteArray.ENDIAN_BIG)
	self:splitData(response)
end

function SOCKET:onClose(__event)
	self.isConnected = false
	printf("Socket is closing !!!")
end

function SOCKET:onClosed(__event)
	self.isConnected = false
	printf("Socket is closed !!!")
end

function SOCKET:onConnected(__event)
	self.isConnected = true
	printf("Socket is connected !!!")
end

function SOCKET:onConnectFailure(__event)
	self.isConnected = false
	printf("Socket connect failure !!!")
end

return SOCKET