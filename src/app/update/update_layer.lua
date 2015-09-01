--
-- Author: XiaoMing.Zhang
-- Date: 2014-01-06 16:50:29
--

--[[
	在线更新
]]

require("update.update_config")
require("update.update_function")

local UpdateLayer = {
	layer,
}

function UpdateLayer:new(params)
	local this = {}
	setmetatable(this,self)
	self.__index  = self

	params = params or {}

	this.layer = CCLayer:create()

	local bg = nil
	if Update_Function.file_exists(IMG_PATH .. "image/scenes/login/update_bg.jpg") then
	 	bg = CCSprite:create(IMG_PATH .. "image/scenes/login/update_bg.jpg")
	else
	 	bg = CCSprite:create("image/scenes/login/update_bg.jpg")
	end
	Update_Function.setAnchPos( bg , 0 , 0 )
	this.layer:addChild( bg )

	local updatebar_bg = nil
	if Update_Function.file_exists(IMG_PATH .. "image/common/bar/update/bg.png") then
		updatebar_bg = CCSprite:create(IMG_PATH .. "image/common/bar/update/bg.png")
	else
		updatebar_bg = CCSprite:create("image/common/bar/update/bg.png")
	end
	Update_Function.setAnchPos( updatebar_bg , (bg:getContentSize().width - updatebar_bg:getContentSize().width) /2 , 73)
	this.layer:addChild(updatebar_bg)

	self.updatebar_fore = nil
	if Update_Function.file_exists(IMG_PATH .. "image/common/bar/update/fore.png") then
		self.updatebar_fore = CCSprite:create(IMG_PATH .. "image/common/bar/update/fore.png")
	else
		self.updatebar_fore = CCSprite:create("image/common/bar/update/fore.png")
	end
	Update_Function.setAnchPos( self.updatebar_fore , (bg:getContentSize().width - self.updatebar_fore:getContentSize().width) / 2, 83)
	self.updatebar_fore:setScaleX(0.0)
	this.layer:addChild(self.updatebar_fore)

	self.update_label = CCLabelTTF:create("同步资源", "Marker Felt", 18)
	Update_Function.setAnchPos(self.update_label, 204, 120)
	this.layer:addChild(self.update_label)

	self.percent_label = CCLabelTTF:create("0%", "fonts/Hei.ttf", 15)
	Update_Function.setAnchPos(self.percent_label, 222, 82)
	this.layer:addChild(self.percent_label)

	this.layer:setKeypadEnabled(true)
	this.layer:addKeypadEventListener(function(event)
        if event == "back" then
            CCDirector:sharedDirector():endToLua()
    		os.exit()
        end
    end)


	self:init()

	self.reload_main = false
	self.reload_update = false
	self.reload_game = false

	local handle
	handle = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function()
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(handle)
		handle = nil
		this:checkUpdate()
	end , 0.01 , false)
	

	return this
end

function UpdateLayer:enterGame()
	self.updatebar_fore:setScaleX(1.0)
	self.percent_label:setString("100%")
	local handle
	CCLuaLoadChunksFromZIP(IMG_PATH .. "res/game.mod")
	handle = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function()
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(handle)
		handle = nil
		require("game")
	end , 0.01 , false)
end

function UpdateLayer:getLayer()
	return self.layer
end

-- 检测更新
function UpdateLayer:checkUpdate()
	Update_Function.checkDirExist(IMG_PATH)
	-- 检测sdcard有没有文件
	local sdcard_main = Update_Function.file_exists(IMG_PATH .. "res/main.mod")
	local sdcard_update = Update_Function.file_exists(IMG_PATH .. "res/update.mod")
	local sdcard_game = Update_Function.file_exists(IMG_PATH .. "res/game.mod")
	local sdcard_filelist = Update_Function.file_exists(IMG_PATH .. "filelist")
	local init_res = false
	if sdcard_filelist then
		local sd_filelist = dofile(IMG_PATH .. "filelist")
		local app_filelist = dofile("filelist")
		CCLuaLog("App script version: " .. app_filelist.version)
		CCLuaLog("SD script version: " .. sd_filelist.version)
		local sd_version = Update_Function.split(sd_filelist.version, ".")
		local app_version = Update_Function.split(app_filelist.version, ".")
		if app_version[1] > sd_version[1] then
			init_res = true
		elseif app_version[2] > sd_version[2] then
			init_res = true
		elseif app_version[3] > sd_version[3] then
			init_res = true
		end
	end
	if sdcard_main == false or 
		sdcard_update == false or
		sdcard_game == false or 
		sdcard_filelist == false or
		init_res == true then
		--删除旧文件
		CCLuaLog("Began remove old files...")
		Update_Function.remove_file_dir(IMG_PATH)
		CCLuaLog("Finished remove old files !!!")
		--拷贝新版本 C++版本
		-- local count = UpdateResource:getAllFilesCount(".")
		-- CCLuaLog("All files count: " .. count)
		-- local result = UpdateResource:copyFiles(".",
		-- 	IMG_PATH ,
		-- 	function(count)
		-- 		CCLuaLog(count)
		-- 	end)
		-- CCLuaLog("copy..." .. result)
		-- 拷贝文件
		local javaClassName = "com.morbe.nzjh.Nzjh"
    	local javaMethodName = "copyfiles"
        local javaParams = {
            "",
            IMG_PATH,
            function(persent)
            	CCLuaLog(persent)
            	self.percent_label:setString(persent .. "%")
            	self.updatebar_fore:setScaleX(persent/100)
            	if tonumber(persent) >= 100 then
            		--检测更新
					self:checkVersion()		
				end
            end
        }
    	local javaMethodSig = "(Ljava/lang/String;Ljava/lang/String;I)V"
    	Update_Function.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
    else
    	self:checkVersion()
	end
end

function UpdateLayer:download(list)
	CCLuaLog("Began download script && resource , count = " .. #list )
	local cur_down_size = 0
	for i,v in ipairs(list) do
		local request = Update_Function.createHTTPRequest(
		function(event)
			local ok = (event.name == "completed")
			local request = event.request

		    if not ok then
		        -- 请求失败，显示错误代码和错误消息
		        print(request:getErrorCode(), request:getErrorMessage())
		        return
		    end

		    local code = request:getResponseStatusCode()
		    if code ~= 200 then
		        -- 请求结束，但没有返回 200 响应代码
		        CCLuaLog("错误代码" .. code)
		        return
		    end
		 
		    -- 请求成功，显示服务端返回的内容
		    local response = request:getResponseData()

		    local temp = Update_Function.split(v.name , "/")
            local dir = ""
            for i = 1 , #temp - 1 do
                if temp[i] ~= "" then
                    dir = dir .. temp[i] .. "/"

                    local temp_fp = io.open(IMG_PATH .. dir , "r")
                    if temp_fp then
                        io.close(temp_fp)
                    else
                        if CCApplication:sharedApplication():getTargetPlatform()
                        	 == kTargetAndroid then
                        	os.execute("mkdir \"" .. IMG_PATH .. dir .. "\"")
                        else
                        	-- ios create dir
                        end
                    end
                end
            end
        
            local fp = io.open(IMG_PATH .. v.name, "w")
            if fp then
                fp:write(response)
                fp:close()
            end
            cur_down_size = cur_down_size + v.size
            -- call back
            local persent , _ = math.modf((cur_down_size / self.downfiles_size) * 100)
            self:updateLoadingBar(persent)
		end,
		self.base_update_url .. v.name,
		"GET")
		request:setTimeout(1000)
		request:start()
	end	
end

-- 更新进度条
function UpdateLayer:updateLoadingBar(persent)
	CCLuaLog("Download proccess " .. persent)
	self.updatebar_fore:setScaleX(persent/100)
	self.percent_label:setString(persent .. "%")
	if persent == 100 then
		CCLuaLog("Finished download script ...")
		-- 覆盖旧的updatelist
		local file = io.open(IMG_PATH .. "filelist.ud", "rb")
	    if file then
    		local content = file:read("*all")
			io.close(file)
			Update_Function.writefile(IMG_PATH .. "filelist", content)
			os.remove(IMG_PATH .. "filelist.ud")
			if self.reload_main or self.reload_update then
				-- 重新加载
				CCLuaLog("Began reload main package ...")
				package.loaded["update.update_config"] = nil
				package.loaded["update.update_function"] = nil
				package.loaded["update.update_scene"] = nil
				package.loaded["update.update_layer"] = nil
				package.loaded["main"] = nil
				CCLuaLoadChunksFromZIP(IMG_PATH .. "res/main.mod")
				handle = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function()
					CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(handle)
					handle = nil
					require("main")
				end , 0.01 , false)
				CCLuaLog("Reload main package finished !")
				return
			end
			if self.reload_game then
				CCLuaLog("Began reload game package ...")
				
				self:enterGame()
				CCLuaLog("Reload game package finished !")
			end
		else
			CCLuaLog("Remove old filelist.ud error !!!")
		end
	end
end

function UpdateLayer:checkVersion()
	-- 从服务器检测版本号
	local request = Update_Function.createHTTPRequest(
	function(event)
		local ok = (event.name == "completed")
		local request = event.request

	    if not ok then
	        -- 请求失败，显示错误代码和错误消息
	        print(request:getErrorCode(), request:getErrorMessage())
	        return
	    end

	    local code = request:getResponseStatusCode()
	    if code ~= 200 then
	        -- 请求结束，但没有返回 200 响应代码
	        CCLuaLog("错误代码" .. code)
	        return
	    end
	 
	    -- 请求成功，显示服务端返回的内容
	    local response = request:getResponseString()
	    CCLuaLog(response)
	    -- 拆分
	    local json_result = Update_Function.json_decode(response)
	    if json_result.errorCode ~= 0 then
	    	CCLuaLog("Get Update info error ! code = " .. json_result.errorCode)
	    	return
	    end
	    CCLuaLog(json_result.data.url)
	    local params = Update_Function.split(json_result.data.url, ";")
	    local needUpdate = params[1]	--是否需要更新
	    if needUpdate == "1" then
	    	local isAppUpdate = params[2]	--是否是整包更新
	    	if isAppUpdate == "1" then
	    		local apk_url = params[3]
	    		local app_version = params[4]
	    		local script_version = params[5]
	    		self:updateApp(apk_url)
			else
				local filelist_url = params[3]
				local app_version = params[4]
	    		local script_version = params[5]
	    		CCLuaLog(filelist_url)
	    		self.base_update_url = string.sub(filelist_url, 1, -(string.len("filelist")+1))
	    		CCLuaLog(self.base_update_url)
				-- 增量更新
				local request = Update_Function.createHTTPRequest(
				function(event)
		    		local request = event.request
		    		if event.name == "completed" then
		    			if request:getResponseStatusCode() ~= 200 then
		    				CCLuaLog("错误代码" .. code)
				        	return
				        else
				        	local response = request:getResponseData()
	    					Update_Function.writefile(IMG_PATH .. "filelist.ud", response)
	    					-- 加载自己的filelist
	    					self.filelist = nil
							if Update_Function.file_exists(IMG_PATH .. "filelist") then --检测文件列表是否存在
								self.filelist = dofile(IMG_PATH .. "filelist") --如果存在就进行加载
							end
							if self.filelist == nil then --如果不存在，默认一个
								self.filelist = {
									version = "1.0.0",
									down = {},
									remove = {},
								}
							end
							-- 加载最新列表
							self.filelist_new = dofile(IMG_PATH .. "filelist.ud")
							-- 删除remove列表的文件
							self:update_remove_files(self.filelist_new.remove)
							-- 对比列表找出要更新的列表
							self.downfiles_size = 0
							self.downlist = {}
							for i,vnew in ipairs(self.filelist_new.down) do
								local find = false --如果本地没有
								for j,vold in ipairs(self.filelist.down) do
									if vold.name == vnew.name then
										find = true
										if  vold.code ~= vnew.code then
											if vnew.name == "res/main.mod" then
												self.reload_main = true
												CCLuaLog("Need reload main package")
											end
											if vnew.name == "res/update.mod" then
												self.reload_update = true
												CCLuaLog("Need reload update package")
											end
											if vnew.name == "res/game.mod" then
												self.reload_game = true
												CCLuaLog("Need reload game package")
											end
											table.insert(self.downlist, vnew)
											self.downfiles_size = self.downfiles_size + vnew.size
										end
										break
									end
								end
								if find == false then
									table.insert(self.downlist, vnew)
									self.downfiles_size = self.downfiles_size + vnew.size
								end
							end
							if #self.downlist > 0 then
								-- 开始更新
								self:download(self.downlist)
							else
								local file = io.open(IMG_PATH .. "filelist.ud", "rb")
							    if file then
						    		local content = file:read("*all")
									io.close(file)
									Update_Function.writefile(IMG_PATH .. "filelist", content)
									os.remove(IMG_PATH .. "filelist.ud")
								else
									CCLuaLog("Remove old filelist.ud error !!!")
								end
								self:enterGame()
							end
		    			end
		    		else
		    			CCLuaLog("Error:" .. request:getErrorCode() .. "," .. request:getErrorMessage())
				        return
		    		end
		    	end, 
		    	filelist_url, 
		    	"GET")
			    if request then
			        request:setTimeout(30)
			        request:start()
			    end
	    	end
	    else
	    	-- 直接进入游戏
			self:enterGame()
	    end
	end,
	CONFIG_UPDATE_URL .. Update_Function.http_build_query(
		{app_version=APP_VERSION,
		 script_version=SCRIPT_VERSION,
		 channel=CHANNEL_ID}))
	request:start()
end

-- 删除没用的文件
function UpdateLayer:update_remove_files(rm_list)
	CCLuaLog("Began remove old version files ...")
	for i,v in ipairs(rm_list) do
		if Update_Function.file_exists(IMG_PATH .. v.name) then
			os.remove(IMG_PATH .. v.name)
		end
	end
	CCLuaLog("Finished remove old version files !!!")
end

--拷贝文件
--会堵塞主线程，已废弃
function UpdateLayer:copyFiles()
	CCLuaLog("开始拷贝文件...")
	local lfs = require"lfs"
    function read_file(src_path, dst_path)
    	for file in lfs.dir(src_path) do
	        if file ~= "." and file ~= ".." then
	            local sp = src_path .. '/' .. file
	            local dp = dst_path .. '/' .. file
	            local attr = lfs.attributes(sp)
	            assert (type(attr) == "table")
	            if attr.mode == "directory" then
	                if Update_Function.checkDirExist(dp) then
	                	read_file(sp, dp)
	                else
	                	CCLuaLog(dp .. " dir not exist , cant copy!")
	                end
	            else
	            	local file = io.open(sp, "rb")
	            	if file then
	            		local content = file:read("*all")
        				io.close(file)
        				Update_Function.writefile(dp, content)
        			else
        				CCLuaLog(sp .. "file open faild!")
	            	end
	            end
	        end
    	end
    end
    read_files("", "")
    
	CCLuaLog("拷贝文件完成...")
end

--android下面需要全量更新
function UpdateLayer:updateApp(apk_url)
	local javaClassName = "com.morbe.nzjh.Nzjh"
	local javaMethodName = "DownloadApk"
    local javaParams = {
        apk_url,
        IMG_PATH .. "download",
        function(persent)
        	CCLuaLog("Download apk: " .. persent)
        	self.updatebar_fore:setScaleX(persent / 100)
        	if persent == "100" then
        		--检测更新
				CCLuaLog("Download apk finish !!!")
			end
        end,
        function(err_msg)
        	CCLuaLog("Download apk error: " .. err_msg)
        end
    }
	local javaMethodSig = "(Ljava/lang/String;Ljava/lang/String;II)V"
	Update_Function.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
end


function UpdateLayer:init()

end

return UpdateLayer
