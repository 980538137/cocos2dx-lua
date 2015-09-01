--
-- Author: XiaoMing.Zhang
-- Date: 2014-01-06 12:06:34
--

Update_Function = {}

function Update_Function.createHTTPRequest(callback, url, method)
    if not method then method = "GET" end
    if string.upper(tostring(method)) == "GET" then
        method = kCCHTTPRequestMethodGET
    else
        method = kCCHTTPRequestMethodPOST
    end
    return CCHTTPRequest:createWithUrl(callback, url, method)
end

--设置锚点与位置,x,y默认为0，锚点默认为0
function Update_Function.setAnchPos(node,x,y,anX,anY)
    local posX , posY , aX , aY = x or 0 , y or 0 , anX or 0 , anY or 0
    node:setAnchorPoint(ccp(aX,aY))
    node:setPosition(ccp(posX,posY))
end

local cjson = require("cjson")
function Update_Function.json_encode(var)
    local status, result = pcall(cjson.encode, var)
    if status then return result end
    CCLuaLog("json encode error, " .. tostring(result))
end

function Update_Function.json_decode(text)
    local status, result = pcall(cjson.decode, text)
    if status then return result end
    CCLuaLog("json encode error, " .. tostring(result))
end

--[[--

Checks whether a file exists.

@param string path
@return boolean

]]
function Update_Function.file_exists(path)
    local file = io.open(path, "r")
    if file then
        io.close(file)
        return true
    end
    return false
end

--[[--

Reads entire file into a string, or return FALSE on failure.

@param string path
@return string

]]
function Update_Function.readfile(path)
    local file = io.open(path, "r")
    if file then
        local content = file:read("*a")
        io.close(file)
        return content
    end
    return nil
end

--拼装post数据
-- {key=value,key1=value1}
function Update_Function.http_build_query( params )
	if type(params) ~= "table" then return "" end
	local result = "?"
	for key,value in pairs(params) do
		result = result .. key .. "=" .. value .. "&"
	end
	return result
end

--遍历目录
local lfs = require"lfs"
function Update_Function.remove_file_dir( path )
	if path == "" then
		return
	end
	Update_Function.checkDirExist(path)
    for file in lfs.dir(path) do
        if file ~= "." and file ~= ".." then
            local f = path..'/'..file
            local attr = lfs.attributes (f)
            assert (type(attr) == "table")
            if attr.mode == "directory" then
                Update_Function.remove_file_dir(f, fun)
                local ret, err = lfs.rmdir(f)
                print(ret,err)
            else
                os.remove(f)
            end
        end
    end
end

--检测目录是否存在
--如果不存在创建
function Update_Function.checkDirExist( path )
    require "lfs"
	if lfs.chdir(path) then
		return true
	end
	if lfs.mkdir(path) then
		return true
	end
	return false
end

function Update_Function.checkArguments(args, sig)
    if type(args) ~= "table" then args = {} end
    if sig then return args, sig end

    sig = {"("}
    for i, v in ipairs(args) do
        local t = type(v)
        if t == "number" then
            sig[#sig + 1] = "F"
        elseif t == "boolean" then
            sig[#sig + 1] = "Z"
        elseif t == "function" then
            sig[#sig + 1] = "I"
        else
            sig[#sig + 1] = "Ljava/lang/String;"
        end
    end
    sig[#sig + 1] = ")V"

    return args, table.concat(sig)
end

function Update_Function.callStaticMethod(className, methodName, args, sig)
    local args, sig = Update_Function.checkArguments(args, sig)
    CCLuaLog("luaj.callStaticMethod(" .. className .. "," .. methodName .. "," .. sig .. ")")
    return CCLuaJavaBridge.callStaticMethod(className, methodName, args, sig)
end

function Update_Function.split(str, delimiter)
    if (delimiter=='') then return false end
    local pos,arr = 0, {}
    -- for each divider found
    for st,sp in function() return string.find(str, delimiter, pos, true) end do
        table.insert(arr, string.sub(str, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(str, pos))
    return arr
end

function Update_Function.writefile(path, content, mode)
    mode = mode or "w+b"
    local file = io.open(path, mode)
    if file then
        if file:write(content) == nil then return false end
        io.close(file)
        return true
    else
        return false
    end
end